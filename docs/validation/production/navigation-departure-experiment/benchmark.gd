extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var s=Sim.new();s.start(2);s.sirens=[];s.paused=false
 for scenario in ["aligned-open","sharp-open","sharp-near"]:
  var origin=Vector2(800,800) if scenario!="sharp-near" else Vector2(1353.052,618.3444)
  var angle=PI if scenario=="aligned-open" else 0.234
  var samples=[]
  for sample in 5:
   var start=Time.get_ticks_usec()
   for n in 2000:
    for u in s.units:u.pos=origin;u.vel=Vector2.ZERO;u.angle=angle;u.route=[{"pos":origin+Vector2(-200,0),"stop":true}]
    s._tick(1.0/60)
   samples.append((Time.get_ticks_usec()-start)/2000.0)
  print("BENCHMARK scenario=",scenario," microseconds_per_tick_samples=",samples)
 quit()
