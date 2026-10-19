extends SceneTree
# Actual passive player-view footage after ordinary production commands.
# No sensor override, wide-survey stimulus, forced poses or hidden-contact rendering.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var stage="idle_patrol"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--stage="): stage=arg.get_slice("=",1)
	var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="siren-role-evidence"; root.add_child(game)
	var mission=0 if stage=="idle_patrol" else 3 if stage=="sentinel_return" else 4
	game._start_mission(mission)
	if stage in ["idle_hunter","hunter_response","hunter_return"]:
		preload("res://tests/campaign_scenarios.gd").move(game.sim,Vector2(600,600))
	elif stage=="idle_patrol":
		preload("res://tests/campaign_scenarios.gd").move(game.sim,Vector2(800,510))
		for n in 16*60: game.sim.advance(1.0/60.0)
	if stage in ["hunter_response","hunter_return"]:
		game.sim.command("decoy",{"point":Vector2(800,850)}); game.sim.paused=false
		if stage=="hunter_return":
			for n in 26*60: game.sim.advance(1.0/60.0)
	game.sim.paused=false
	print("ROLE CLIP stage=",stage," mission=",mission," start_elapsed=",game.sim.elapsed," no further commands during recording; passive observation only; roles=",game.sim.sirens.map(func(s):return {"type":s.get("type","patroller"),"mode":s.mode,"position":str(s.pos)}))
