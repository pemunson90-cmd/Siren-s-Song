extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Routes=preload("res://tests/campaign_scenarios.gd")
func _initialize():
 for reverse in [false,true]:
  var s=Sim.new();s.start(2,"disruption")
  # Explicit post-loss recovery fixture; no enemy/sensor/resource weakening.
  s.units[1].alive=false;s.units[2].alive=false
  var okay=true
  for id in ([1,0] if reverse else [0,1]):
   var target=s.mission.objectives[id];var point=target.pos+Vector2(0,140)
   okay=okay and Routes.move(s,point)
   okay=okay and s.command("camera")
   for n in 25:s.advance(0.1)
   okay=okay and target.captured
   print("HUNT_SOLO reverse=",reverse," target=",id," captured=",target.captured," elapsed=",s.elapsed," hull=",s.hull," tools=",s.tools," outcome=",s.outcome)
  if okay:okay=Routes.move(s,s.mission.extraction)
  print("HUNT_SOLO_FINAL reverse=",reverse," okay=",okay," outcome=",s.outcome," elapsed=",s.elapsed," hull=",s.hull," tools=",s.tools," oxygen=",s.oxygen)
 quit()
