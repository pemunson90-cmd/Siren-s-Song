extends SceneTree
var game
func _initialize(): call_deferred("run")
func run():
	var view="initial"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--finale-view="): view=arg.get_slice("=",1)
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="finale-review"; root.add_child(game)
	await process_frame; await process_frame
	var stage="complete" if view=="ending" else ("warning" if view=="archive" else view)
	game.sim=preload("res://tests/finale_command_plan.gd").play(true,stage); game.mission_index=5; game.ocean.sim=game.sim; game._refresh(); game._layout()
	if view in ["crown","wakes","receiver"]:
		game.ocean.zoom_at(1.6,game.ocean.screen_position(game.sim.units[game.sim.selected].pos))
	if view=="ending": game._debrief()
	if view=="archive":
		game._retain_evidence(); game._evidence_gallery(game.recovered_evidence.keys().find("warning"))
	print("FINALE_CAPTURE view=",view," outcome=",game.sim.outcome," t=",snappedf(game.sim.elapsed,0.1)," hull=",game.sim.hull," records=",game.sim.mission.objectives.map(func(o):return o.captured)," drones=",game.sim.units[1].alive,",",game.sim.units[2].alive)
