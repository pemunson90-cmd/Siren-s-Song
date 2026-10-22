extends SceneTree
# Isolated navigation fixture: unchanged operation terrain and bare Quietus, no threats/drones.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func _initialize():
 var cases=[{ "op":0,"point":Vector2(1300,510) },{ "op":1,"point":Vector2(900,1730) },{ "op":3,"point":Vector2(1110,770) },{ "op":4,"point":Vector2(800,390) },{ "op":4,"point":Vector2(1300,510) },{ "op":5,"point":Vector2(320,80) }]
 for scenario in cases:
  for frame in [1./60.,1./16.,.25]:
   var s=Sim.new();s.start(scenario.op,"endurance");s.sirens=[]
   for id in [1,2]:s.units[id].alive=false
   var accepted=s.command("route",{"point":scenario.point})
   if not accepted:printerr("REJECT ",scenario);continue
   var planned=s.units[0].route.duplicate(true)
   s.paused=false
   for n in ceili(240./frame):
    s.advance(frame)
    if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
   checks+=1
   var creaks=s.events.filter(func(e):return e.type=="creak")
   if s.hull<100.:
    failures+=1;printerr("HULL LOSS op=",scenario.op," dt=",frame," target=",scenario.point," hull=",s.hull," pos=",s.units[0].pos," strikes=",creaks," plan=",planned)
   print("NAV FOLLOW op=",scenario.op," dt=",frame," hull=",s.hull," elapsed=",s.elapsed," pos=",s.units[0].pos," remaining=",s.units[0].route.size()," outcome=",s.outcome)
 print("NAV FOLLOW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
