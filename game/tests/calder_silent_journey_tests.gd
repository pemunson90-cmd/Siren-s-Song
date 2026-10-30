extends SceneTree
# Counterexample to pressure obtained by choosing cruise: same useful core routes,
# no finite tools or drone orders, Quietus SILENT throughout. Received reports can
# expire during one pursuit; transitions count reports, not distinct encounters.
const Sim=preload("res://src/simulation/simulation.gd")
const Course=preload("res://tests/calder_trench_journey_tests.gd")
class SilentRun extends Sim:
 var stayed_silent=true
 var ordinary_only=true
 var hunt_peak=0.
 var locks=0
 var locking={}
 func command(order:String,args:Dictionary={})->bool:
  if order not in ["route","depth","frame","camera"] and not (order=="glass_action" and args.get("action","")=="recover"):
   ordinary_only=false
   return false
  return super.command(order,args)
 func advance(dt:float)->void:
  stayed_silent=stayed_silent and units[0].silent
  super.advance(dt)
  stayed_silent=stayed_silent and units[0].silent
  hunt_peak=maxf(hunt_peak,float(mission.get("reconnaissance",{}).get("hunt",0.)))
  var now={}
  for id in contacts:
   var c=contacts[id]
   if elapsed-float(c.time)<=.4 and float(c.lock)>0.:
    now[id]=true
    if not locking.has(id):locks+=1
  locking=now
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
# Keep the pressure screen on the authored radio recovery approach. The generic
# core fixture also covers a DEEP outside detour; this policy breaks a visible
# charge with ordinary Quietus movement, then physically returns with the cargo.
func radio_return(s)->bool:
 for step in Course.steps(33,s).slice(0,8):
  var ok=false
  match step[0]:
   "go":ok=Course.go(s,step[1])
   "dive":ok=Course.dive(s,step[1])
   "shoot":ok=Course.expose(s,Course.obj(s,step[1]))
   "cargo":ok=Course.recover_cargo(s)
  if not ok:return false
 if not Course.dive(s,1) or not Course.go(s,Vector2(1910,1700)):return false
 if not s.command("route",{"point":Vector2(2380,1700)}):return false
 var noticed=false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty():break
  if s.contacts.values().any(func(c):return s.elapsed-c.time<.25 and c.get("report_remaining",0.)>0):
   noticed=true;break
 s.paused=true
 if not noticed or not Course.go(s,Vector2(1760,1700)) or not Course.dive(s,2):return false
 for point in [Vector2(1760,1950),Vector2(2800,1950),Vector2(2800,1900)]:
  if not Course.go(s,point):return false
 if not Course.dive(s,1) or not Course.go(s,s.mission.extraction):return false
 Course.tick(s,1.)
 return s.outcome=="won" and s.mission.recovered
func run():
 var pressure=0
 for id in [30,31,32,33,34,35,36]:
  var s=SilentRun.new();s.start(id)
  var reserve=s.oxygen
  for key in s.tools:s.tools[key]=0
  check(s.mission.launch_equipment.values().all(func(item):return str(item).is_empty() or str(item)=="standard"),"bare loadout "+str(id))
  var finished=radio_return(s) if id==33 else Course.run_core(s,id)
  check(finished and s.outcome=="won" and s.mission.recovered,"silent bare physical recovery "+str(id))
  check(s.stayed_silent and s.ordinary_only and s.selected==0,"SILENT with ordinary Quietus work only "+str(id))
  check(Sim.valid_snapshot(s.snapshot()),"silent final snapshot valid "+str(id))
  if s.hunt_peak>=20. or s.locks>0:pressure+=1
  print("CALDER SILENT ",id," seconds=",s.elapsed," hull=",s.hull," Hunt=",s.hunt_peak," received_lock_transitions=",s.locks," oxygen_percent=",100.*s.oxygen/reserve)
 check(pressure>=5,"at least five of seven useful SILENT routes meet Sirens")
 print("CALDER SILENT CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
