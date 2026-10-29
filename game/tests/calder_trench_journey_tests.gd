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
static func go_unit(s,point)->bool:
 var unit=s.selected
 if not s.command("route",{"point":point}):return false
 for n in 18000:
  tick(s,Sim.STEP)
  if not s.outcome.is_empty() or (s.units[unit].route.is_empty() and s.units[unit].vel.length()<2):break
 return s.units[unit].alive and s.units[unit].pos.distance_to(point)<25
static func dive(s,band)->bool:
 if s.units[0].band==band and s.units[0].transition.is_empty():return true
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2)
 return s.units[0].band==band and s.units[0].transition.is_empty()
static func expose(s,o,linger:float=2.)->bool:
 if not s.command("frame",{"mode":"wide","focus":o.get("optical",o.site_id)}):return false
 tick(s,3.)
 if not s.command("camera"):return false
 tick(s,float(o.get("duration",4.))+linger)
 return o.captured
static func obj(s,key):
 for o in s.mission.objectives:
  if o.site_id==key:return o
 return {}
static func recover_cargo(s)->bool:
 var artifact=s.mission.glass_reach.artifact
 if not go(s,artifact.pos+Vector2(-30,0)) or not s.command("glass_action",{"action":"recover"}):return false
 tick(s,4.2)
 return artifact.state=="cargo" and artifact.carrier==0
# ARC6 (076) authored bare-Quietus routes, one per core operation: ordinary route, depth, camera and
# recovery orders only. Steps: [go,point] [dive,band] [shoot,site_id] [cargo].
static func steps(id:int,s)->Array:
 var m=s.mission;var k=("final_photo_%d"%id) if id in [30,31] else ("glass_record_%d"%id)
 var fleet=s.get("fleet_policy")==true
 var core=obj(s,k).get("pos",Vector2.ZERO)+Vector2(-120,-120 if id==30 else 0)
 match id:
  30:return [["dive",2],["go",Vector2(800,500)],["dive",1],["go",core],["shoot",k],["go",m.extraction]]
  31:return [["dive",0],["go",Vector2(400,1300)],["dive",1],["go",core],["shoot",k],["go",m.extraction]]
  32:return [["go",Vector2(1100,2700)],["go",obj(s,"calder_32_shut_in").pos],["shoot","calder_32_shut_in"],["go",Vector2(1100,1100)],["dive",2],["go",core],["shoot",k],["cargo"],["go",Vector2(1100,2900)],["go",m.extraction],["dive",1]]
  33:return [["go",obj(s,"calder_33_gallery").pos],["shoot","calder_33_gallery"],["go",Vector2(1900,1150)],["dive",2],["go",core],["shoot",k],["cargo"],["go",Vector2(1900,1150)],["dive",1],["go",m.extraction]]
  34:return [["go",obj(s,"calder_34_stage_1").pos],["shoot","calder_34_stage_1"],["go",obj(s,"calder_34_stage_2").pos],["shoot","calder_34_stage_2"],["go",obj(s,"calder_34_disconnect").pos],["shoot","calder_34_disconnect"],["dive",2],["go",core],["shoot",k],["dive",1],["go",Vector2(1050,2150)],["go",m.extraction]]
  35:
   if fleet:return [["dive",2],["go",Vector2(1100,300)],["go",Vector2(1800,300)],["go",core],["shoot",k],["cargo"],["go",Vector2(2300,1000)],["dive",1],["go",Vector2(2300,1450)],["shoot","calder_35_lift"],["go",Vector2(2900,1450)],["go",m.extraction]]
   return [["dive",2],["go",Vector2(1100,300)],["go",Vector2(1800,300)],["go",core],["shoot",k],["cargo"],["go",Vector2(1800,300)],["go",Vector2(1800,200)],["go",Vector2(2900,200)],["dive",1],["go",m.extraction]]
  36:
   if fleet:return [["go",Vector2(1700,2100)],["go",Vector2(1700,1300)],["dive",2],["go",core],["shoot",k],["go",Vector2(1700,1300)],["dive",1],["go",Vector2(1000,1300)],["go",m.extraction]]
   return [["go",Vector2(1700,2100)],["go",Vector2(1700,1300)],["dive",2],["go",core],["shoot",k],["go",Vector2(1700,1300)],["dive",1],["go",Vector2(1700,2200)],["go",Vector2(300,2200)],["go",m.extraction]]
 return []
static var last_step=""
static func run_core(s,id:int)->bool:
 if id not in [30,31,32,33,34,35,36] or s.mission.id!=id or s.selected!=0:return false
 if s.get("fleet_policy")==true:
  if id==36:
   s.command("select",{"unit":2})
   if not go_unit(s,obj(s,"calder_36_breaker").pos+Vector2(100,0)) or not expose(s,obj(s,"calder_36_breaker")):return false
   s.stage_breaker()
   s.command("select",{"unit":0})
 for step in steps(id,s):
  last_step=str(id)+" "+str(step)
  var ok=false
  match step[0]:
   "go":ok=go(s,step[1])
   "dive":ok=dive(s,step[1])
   "shoot":ok=expose(s,obj(s,step[1]))
   "cargo":ok=recover_cargo(s)
  if not ok:return false
 if not s.mission.get("launch_equipment",{}).get("drone_a","").is_empty():
  if s.get("fleet_policy")==true:
   for n in 12000:
    if obj(s,("final_photo_%d"%id if id in [30,31] else "glass_record_%d"%id)+"_bonus").captured:break
    tick(s,Sim.STEP)
   if not obj(s,("final_photo_%d"%id if id in [30,31] else "glass_record_%d"%id)+"_bonus").captured:return false
  # Fitted drones must physically rendezvous in MIDDLE before departure.
  for unit in [1,2]:
   if not s.units[unit].alive:return false
   s.command("select",{"unit":unit})
   if s.units[unit].band!=1:
    s.command("depth",{"band":1});tick(s,4.2)
   s.command("route",{"point":s.parking(unit) if s.get("fleet_policy")==true else s.mission.extraction+(s.mission.extraction-s.units[unit].pos).normalized().orthogonal()*50.})
  s.command("select",{"unit":0})
  for n in 18000:
   if s.units.slice(1).all(func(u):return u.pos.distance_to(s.mission.extraction)<60 and u.vel.length()<12):break
   tick(s,Sim.STEP)
  tick(s,1.)
 tick(s,1.)
 return s.outcome=="won" and s.mission.recovered
func _initialize():call_deferred("run")
func run():
 for id in [30,31,32,33,34,35,36]:
  var s=Sim.new();s.start(id)
  check(s.mission.get("launch_equipment",{}).values().all(func(item):return str(item).is_empty() or str(item)=="standard"),"bare initial loadout "+str(id))
  var finished=run_core(s,id)
  check(finished,"ordinary physical core recovery "+str(id))
  if not finished:print("ROUTE STOP ",last_step," ",s.message," ",s.units[0].pos," hull=",s.hull)
  check(s.mission.objectives.filter(func(o):return not o.get("optional",false)).all(func(o):return o.captured),"all required work and photos complete "+str(id))
  if id in [32,33,35]:check(s.mission.glass_reach.artifact.state=="recovered" and s.mission.glass_reach.retrieved,"physical material recovered "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"final current snapshot valid "+str(id))
  print("CALDER ROUTE ",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," pos=",s.units[0].pos," message=",s.message)
 print("CALDER TRENCH JOURNEY CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
