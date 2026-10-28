extends SceneTree
# Source-known bare routes. Ordinary movement, depth, camera and extraction;
# no position assignments, enemy removal, free film or pre-captured records.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func go(s,point)->bool:
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return s.units[0].alive and s.units[0].pos.distance_to(point)<25
func dive(s,band)->bool:
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2);return s.units[0].band==band and s.units[0].transition.is_empty()
func photo(s)->bool:
 var o=s.mission.objectives[0]
 if not s.command("frame",{"mode":"wide","focus":o.optical}):return false
 # Settled route arrival still needs the ordinary frame to turn onto the mark.
 tick(s,3.)
 if not s.command("camera"):return false
 tick(s,6.)
 return o.captured
func _initialize():call_deferred("run")
func run():
 for id in [30,31]:
  var s=Sim.new();s.start(id)
  check(s.mission.get("launch_equipment",{}).values().all(func(item):return str(item).is_empty() or str(item)=="standard"),"bare initial loadout "+str(id))
  var reached=false
  if id==30:reached=dive(s,2) and go(s,Vector2(800,500)) and dive(s,1) and go(s,Vector2(1180,420))
  else:reached=dive(s,0) and go(s,Vector2(400,1300)) and dive(s,1) and go(s,Vector2(880,1000))
  check(reached,"physical depth route to final photo "+str(id))
  if not reached:print("ROUTE STOP ",id," ",s.message," ",s.units[0].pos);continue
  check(photo(s),"ordinary held bare exposure "+str(id))
  var returned=go(s,s.mission.extraction)
  tick(s,1.)
  check(returned and s.outcome=="won" and s.mission.recovered,"bare recovery with real threats "+str(id))
  check(not s.mission.objectives[1].captured and Sim.valid_snapshot(s.snapshot()),"bonus optional and final save valid "+str(id))
  print("FINAL ROUTE ",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen)
 print("FINAL PAIR JOURNEY CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
