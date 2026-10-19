extends SceneTree
func _initialize():
	var s=load("res://src/simulation/simulation.gd").new();s.start(4,"disruption")
	var p=load("res://tests/well_signature_plan.gd").new();p.s=s;p.travel(1,Vector2(800,390));p.sample(1)
	var path=OS.get_cmdline_user_args()[0];FileAccess.open(path,FileAccess.WRITE).store_var(s.snapshot())
	print("EXPORTED exact6ab snapshot t=",s.elapsed," records=",s.mission.objectives.map(func(o):return o.captured)," snapshot=",path);quit()
