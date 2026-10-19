extends SceneTree
func _initialize():
 for loadout in ["endurance","survey","disruption"]:
  var s=preload("res://src/simulation/simulation.gd").new();s.start(4,loadout);s.units[1].alive=false;s.units[2].alive=false
  preload("res://tests/listening_well_command_plan.gd").play(true,true,s)
  print("WELL loadout=",loadout," outcome=",s.outcome," t=",s.elapsed," hull=",s.hull," tools=",s.tools)
 quit()
