extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
func _initialize():
 for strategy in ["drone-decoy","quietus","quietus-decoy","drone-emp-arrival"]:
  var s=Simulation.new();s.start(2,"endurance");var unit=0 if strategy.begins_with("quietus") else 1;s.command("select",{"unit":unit})
  if "decoy" in strategy:s.command("decoy")
  var route=s.command("route",{"point":Vector2(760,330 if unit==0 else 390)});s.paused=false
  for n in 3600:
   s.advance(1.0/60)
   if not s.units[unit].alive or (s.units[unit].route.is_empty() and s.units[unit].vel.length()<2):break
  if strategy=="drone-emp-arrival":s.command("emp")
  print("PROBE strategy=",strategy," route=",route," time=",s.elapsed," alive=",s.units[unit].alive," hull=",s.hull," pos=",s.units[unit].pos," sample=",s.command("camera"))
  for n in 125:s.advance(1.0/60)
  print("PROBE earned=",s.mission.objectives[0].captured," alive=",s.units[unit].alive," hull=",s.hull," outcome=",s.outcome)
 quit()
