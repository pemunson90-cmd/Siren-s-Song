extends RefCounted
# Shared scripted-route helpers for the challenge completion journeys.
# Every helper uses ordinary commands on the live ChallengeRun; nothing here relocates a craft or a Siren.
# AI-DESIGNED test support, not game content.
const Run=preload("res://src/campaign/challenges/challenge_run.gd")
const Records=preload("res://src/campaign/challenges/challenge_records.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Patient=preload("res://tests/patient_play.gd")
static func fresh(id:String):
 var s=Run.new()
 if not s.setup(id):printerr("CHALLENGE setup failed ",id)
 s.mission["dev"]=true # 127: scripted challenge courses fly the dev/test pathfinder route (Pat 2026-10-30).
 return s
static func tick(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(1./60)
 s.paused=true
# Route one craft to a point and run until it settles; false if it dies, stalls or the run ends lost.
static func go(s,id:int,point:Vector2,tol:float=22.,survey:bool=false)->bool:
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[id].pos.distance_to(point)<65
 s.command("select",{"unit":id})
 if not s.command("route",{"point":point}):printerr("ROUTE rejected ",point," ",s.message);return false
 s.paused=false
 for n in 30000:
  s.advance(1./60)
  # An earned chart can stop at a newly observed face. Reissue the same intended
  # waypoint through that observation, without changing the arrival tolerance.
  if survey and s.units[id].has("chart_stop") and n%30==0:s.command("route",{"point":point})
  if not s.outcome.is_empty() or not s.units[id].alive:break
  if s.units[id].route.is_empty() and s.units[id].vel.length()<2:break
  if s.units[id].pos.distance_to(point)<18 and s.units[id].vel.length()<2:break
 s.paused=true
 if not s.units[id].alive:printerr("CRAFT lost ",id," at ",s.units[id].pos," ",s.message);return false
 return (s.outcome=="won" or s.units[id].pos.distance_to(point)<tol) and s.outcome!="lost"
static func course(s,id:int,points:Array)->bool:
 for p in points:
  if not go(s,id,p):printerr("COURSE STOP ",p," at ",s.units[id].pos," ",s.message);return false
 return true
static func dive(s,id:int,band:int)->bool:
 s.command("select",{"unit":id})
 if not s.command("depth",{"band":band}):printerr("DEPTH rejected ",band," ",s.message);return false
 tick(s,4.2);return s.units[id].band==band and s.units[id].transition.is_empty()
static func lull(s,id:int,band:int,target:int,then:Vector2=Vector2.INF,at:Vector2=Vector2.INF)->void:
 for n in 40:
  if Patient.rehearsal_survives(s,id,band,target,then,at):return
  tick(s,2.)
# Rehearse one leg (route, optional camera work, then the planned follow-on points) on a copy; true when no Siren would lock
# or beam, no craft would be lost and no hull would be lost.
static func _bad(copy,id:int,hull:float)->bool:
 return copy.sirens.any(func(e):return e.mode in ["LOCKING","BEAM"]) or not copy.units[id].alive or copy.hull<hull-.001 or copy.outcome=="lost"
static func _fly(copy,id:int,point:Vector2,hull:float,cap:int=3600)->bool:
 copy.command("select",{"unit":id})
 if not copy.command("route",{"point":point}):return true
 copy.paused=false
 for n in cap:
  copy.advance(1./60)
  if _bad(copy,id,hull):return false
  if copy.outcome=="won":return true
  if copy.units[id].pos.distance_to(point)<18 and copy.units[id].vel.length()<2:break
  if copy.units[id].route.is_empty() and copy.units[id].vel.length()<2:break
 return true
static func leg_survives(s,id:int,point:Vector2,target:int=-1,then:Array=[])->bool:
 var copy=Sim.new()
 if not copy.restore(s.snapshot()):return true
 if not _fly(copy,id,point,s.hull,9000):return false
 if target>=0 and copy.command("camera"):
  for n in roundi((copy.mission.objectives[target].get("duration",4.)+.3)*60):
   copy.advance(1./60)
   if _bad(copy,id,s.hull):return false
 for p in then:
  if not _fly(copy,id,p,s.hull,3600):return false
 return true
# Wait in place (real time on the clock) until the rehearsed leg would be safe, then fly it for real.
static func patient_go(s,id:int,point:Vector2,target:int=-1,then:Array=[],waits:int=80,step:float=1.)->bool:
 var safe=false
 for n in waits:
  if leg_survives(s,id,point,target,then):safe=true;break
  tick(s,step)
 if not safe:printerr("PATIENCE exhausted before ",point)
 return go(s,id,point)
static func record(s,id:int,target:int)->bool:
 s.command("select",{"unit":id})
 if not s.command("camera"):printerr("RECORD rejected ",target," ",s.message);return false
 tick(s,s.mission.objectives[target].get("duration",4.)+.3)
 return s.mission.objectives[target].captured
static func choir(s,action:String,seconds:float=8.2)->bool:
 if not s.command("choir_action",{"action":action}):printerr("WORK REJECT ",action," ",s.message);return false
 tick(s,seconds);return true
static func report(id:String,route:String,s)->String:
 var row=s.definition;var r=s.result()
 var line="CHALLENGE %s route=%s outcome=%s time=%.1f hull=%.1f tools=%s tools_total=%d lost_craft=%d loud=%.1f rule_failure=%s par_time=%.0f par_hull=%.0f par_tools=%d pars_met=%d"%[id,route,s.outcome,s.elapsed,s.hull,s.used,s.tools_used(),s.lost_craft(),s.loud_time,s.rule_failure,row.par.time,row.par.hull,row.par.tools,Records.pars(row,r)]
 print(line);return line
