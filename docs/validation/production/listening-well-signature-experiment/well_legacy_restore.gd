extends SceneTree
func _initialize():
	var data=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.READ).get_var()
	var s=load("res://src/simulation/simulation.gd").new();var ok=s.restore(data)
	var unchanged=ok and s.snapshot()==data.merged({"paused":true},true) and not s.mission.has("well_revision") and s.mission.objectives[0].captured and "lone pilot" in s.mission.record
	print("ACTUAL BASELINE LEGACY unchanged=",unchanged," restored=",ok," t=",s.elapsed," record=",s.mission.record)
	quit(0 if unchanged else 1)
