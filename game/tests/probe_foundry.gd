extends SceneTree
func _initialize() -> void:
	for coordinated in [false,true]:
		for protect in [false,true]:
			var s=preload("res://tests/foundry_command_plan.gd").play(coordinated,"complete",protect)
			print("FOUNDRY coordinated=",coordinated," protect=",protect," outcome=",s.outcome," t=",snappedf(s.elapsed,0.1)," hull=",snappedf(s.hull,0.1)," tools=",s.tools," drones=",s.units[1].alive,",",s.units[2].alive," records=",s.mission.objectives.filter(func(o):return o.captured).size()," message=",s.message)
	quit()
