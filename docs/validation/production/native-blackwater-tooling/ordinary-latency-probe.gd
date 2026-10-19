extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
func _initialize():
 for delay in [0.0,0.5,1.0,1.5,2.0,3.0]:
  var s=Simulation.new();s.start(2,"endurance");s.command("select",{"unit":1});s.command("route",{"point":Vector2(760,390)});s.paused=false
  for n in 1200:
   s.advance(1.0/60)
   if s.camera_context().ready:break
  var ready=s.elapsed
  for n in int(round(delay*60)):s.advance(1.0/60)
  s.paused=true;var emp=s.command("emp");var sample=s.command("camera");s.paused=false
  for n in 300:s.advance(1.0/60)
  print("LATENCY delay=",delay," ready=",ready," emp=",emp," sample=",sample," earned=",s.mission.objectives[0].captured," alive=",s.units[1].alive," hull=",s.hull)
 quit()
