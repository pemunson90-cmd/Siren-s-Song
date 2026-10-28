extends SceneTree
# Source-known core routes using ordinary Quietus orders with the authored threats.
# Shared with the finale UI fixture; no fixture state shortcuts or free equipment.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
static func tick(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):
  s.advance(Sim.STEP)
  if not s.outcome.is_empty():break
 s.paused=true
static func go(s,point)->bool:
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return s.units[0].alive and s.units[0].pos.distance_to(point)<25
static func dive(s,band)->bool:
 if s.units[0].band==band and s.units[0].transition.is_empty():return true
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2)
 return s.units[0].band==band and s.units[0].transition.is_empty()
static func expose(s,o)->bool:
 if not s.command("frame",{"mode":"wide","focus":o.get("optical",o.site_id)}):return false
 tick(s,3.)
 if not s.command("camera"):return false
 tick(s,float(o.get("duration",4.))+2.)
 return o.captured
static func run_core(s,id:int)->bool:
 if id not in [32,33,34] or s.mission.id!=id or s.selected!=0:return false
 var work=s.mission.objectives[2]
 var photo=s.mission.objectives[0]
 if not go(s,Vector2(350,1250)) or not go(s,work.pos) or not expose(s,work):return false
 if not dive(s,2):return false
 if id in [33,34] and not go(s,Vector2(1400,1250)):return false
 if not go(s,photo.pos+Vector2(-120,0)) or not expose(s,photo):return false
 if id in [32,33]:
  var artifact=s.mission.glass_reach.artifact
  if not go(s,artifact.pos+Vector2(-30,0)) or not s.command("glass_action",{"action":"recover"}):return false
  tick(s,4.2)
  if artifact.state!="cargo" or artifact.carrier!=0:return false
 if id in [33,34] and not go(s,Vector2(1400,1250)):return false
 if not go(s,work.pos) or not go(s,Vector2(350,1250)) or not go(s,Vector2(350,2450)) or not dive(s,1):return false
 tick(s,1.)
 return s.outcome=="won" and s.mission.recovered
func _initialize():call_deferred("run")
func run():
 for id in [32,33,34]:
  var s=Sim.new();s.start(id)
  check(s.mission.get("launch_equipment",{}).values().all(func(item):return str(item).is_empty() or str(item)=="standard"),"bare initial loadout "+str(id))
  var finished=run_core(s,id)
  check(finished,"ordinary physical core recovery "+str(id))
  check(s.mission.objectives.filter(func(o):return not o.get("optional",false)).all(func(o):return o.captured),"all required work and photos complete "+str(id))
  if id in [32,33]:check(s.mission.glass_reach.artifact.state=="recovered" and s.mission.glass_reach.retrieved,"physical material recovered "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"final current snapshot valid "+str(id))
  print("CALDER ROUTE ",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," pos=",s.units[0].pos," message=",s.message)
 print("CALDER TRENCH JOURNEY CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
