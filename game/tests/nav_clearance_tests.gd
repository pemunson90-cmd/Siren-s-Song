extends SceneTree
# Source-known Cold Foundry corner. The safe AStar entry must not be cut from the course.
const Sim=preload("res://src/simulation/simulation.gd")
const Measure=preload("res://tests/nav_clearance_measure.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(3,"endurance")
 var origin=Vector2(889.6,800);var target=s.mission.extraction
 check(Measure.leg_clearance(s,origin,origin)>=24.,"the staged near-corner start has the full requested planning margin")
 check(s.path(origin,target)==[{"pos":Vector2(940,820),"stop":false},{"pos":target,"stop":true}],"the shared non-player path remains exactly as recorded before NAV1")
 var planned=s.player_path(origin,target)
 check(not planned.is_empty(),"the legal route remains reachable instead of rejecting every corner")
 var clearance=Measure.route_clearance(s,origin,planned)
 check(clearance>=12.,"every accepted player leg clears the actual 12 m hull, measured independently")
 print("NAV CORNER clearance=",clearance," origin=",origin," route=",planned)
 # Isolate fixed-step autopilot from threats and other hulls; terrain and bare physics unchanged.
 s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
 s.units[0].pos=origin;s.units[0].angle=0.
 check(s.command("route",{"point":target}),"the ordinary route command accepts the regression destination")
 s.paused=false
 for n in 7200:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 check(s.units[0].pos.distance_to(target)<20 and s.units[0].vel.length()<2,"fixed-step bare Quietus reaches the accepted destination without a safety-stop dead end")
 check(s.hull==100.,"the route does not consume collision hull")
 print("NAV CLEARANCE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
