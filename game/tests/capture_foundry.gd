extends SceneTree
# Replays production commands, retains their real state; never writes player saves.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var stage="initial"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--stage="): stage=arg.get_slice("=",1)
	var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="foundry-evidence"; root.add_child(game)
	game._start_mission(3)
	var plan_stage="cradle" if stage=="response_live" else ("complete" if stage.begins_with("archive") or stage=="debrief" else stage)
	game.sim=preload("res://tests/foundry_command_plan.gd").play(true,plan_stage,true); game.ocean.sim=game.sim; game.sim.paused=true
	print("FOUNDRY EVIDENCE stage=",stage," time=",snappedf(game.sim.elapsed,0.1)," hull=",snappedf(game.sim.hull,0.1)," outcome=",game.sim.outcome," records=",game.sim.mission.objectives.filter(func(o): return o.captured).size()," tools=",game.sim.tools)
	game._retain_evidence(); game._refresh()
	if stage=="response_live": game.sim.events.clear(); game.sim.paused=false
	if stage.begins_with("archive"): game._evidence_gallery(1 if stage=="archive_cradle" else 0)
	elif stage=="debrief": game._debrief()
