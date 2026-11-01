extends SceneTree
# 127 (Pat 2026-10-30): scripted journeys here fly the dev/test pathfinder route; hand_pilot_journeys covers release play.
# Isolated navigation fixture: unchanged operation terrain and bare Quietus, no threats/drones.
const Sim=preload("res://src/simulation/simulation.gd")
const Measure=preload("res://tests/nav_clearance_measure.gd")
var checks=0
var failures=0
func _initialize():
 var cases=[{ "op":0,"point":Vector2(1300,510) },{ "op":1,"point":Vector2(900,1730) },{ "op":3,"point":Vector2(1110,770) },{ "op":4,"point":Vector2(800,390) },{ "op":4,"point":Vector2(1300,510) },{ "op":5,"point":Vector2(320,80) },{ "op":3,"point":Vector2(1420,880),"origin":Vector2(889.6,800) }]
 for scenario in cases:
  for frame in [1./60.,1./16.,.25]:
   var s=Sim.new();s.start(scenario.op,"endurance");s.mission["dev"]=true;s.sirens=[]
   for id in [1,2]:s.units[id].alive=false
   s.units[0].pos=scenario.get("origin",s.units[0].pos)
   var origin=s.units[0].pos
   var accepted=s.command("route",{"point":scenario.point})
   checks+=1
   if not accepted:failures+=1;printerr("FAIL REJECT ",scenario);continue
   var planned=s.units[0].route.duplicate(true)
   checks+=1
   if Measure.route_clearance(s,origin,planned)<12.:failures+=1;printerr("FAIL planned hull clearance ",scenario)
   s.paused=false
   for n in ceili(240./frame):
    s.advance(frame)
    if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
   checks+=1
   var creaks=s.events.filter(func(e):return e.type=="creak")
   if s.hull<100.:
    failures+=1;printerr("HULL LOSS op=",scenario.op," dt=",frame," target=",scenario.point," hull=",s.hull," pos=",s.units[0].pos," strikes=",creaks," plan=",planned)
   checks+=1
   if s.units[0].pos.distance_to(scenario.point)>=20. or s.units[0].vel.length()>=2.:failures+=1;printerr("FAIL accepted route did not settle at destination ",scenario)
   print("NAV FOLLOW op=",scenario.op," dt=",frame," hull=",s.hull," elapsed=",s.elapsed," pos=",s.units[0].pos," remaining=",s.units[0].route.size()," outcome=",s.outcome)
 print("NAV FOLLOW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
