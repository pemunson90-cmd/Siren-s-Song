extends SceneTree
# Retained v7-style sight-over-lure counterexample, ordinary commands only.
# Fresh Well dive; no sensor/pose overrides, no commands during recording.
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="observed-contact-lock";root.add_child(game);game._start_mission(4)
	var arrived=preload("res://tests/campaign_scenarios.gd").move(game.sim,Vector2(800,800))
	var deployed=game.sim.command("decoy",{"point":Vector2(1100,650)});game.sim.paused=false
	var observed_lock=false
	for n in 4*60:
		game.sim.advance(1.0/60)
		if game.sim.contacts.values().any(func(c):return game.sim.elapsed-c.time<0.3 and c.lock>0.5):
			observed_lock=true;break
	var second=game.sim.command("decoy",{"point":Vector2(1100,650)})
	print("OBSERVED_EXISTING_LOCK observed=",observed_lock," second_decoy=",second)
	print("OBSERVED_LOCK_CLIP arrived=",arrived," deployed=",deployed," start_elapsed=",game.sim.elapsed," hull=",game.sim.hull," tools=",game.sim.tools," no further commands during recording")
