extends SceneTree
# Local replay of the proposed native ordinary-input protocol, not OS-input proof.
var game
func _initialize() -> void: call_deferred("run")
func step() -> void:
	game.sim.advance(0.1); game._observation_diagnostics()
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="native-role-protocol"; root.add_child(game)
	game._start_mission(4); await process_frame; await process_frame
	game._order("route",{"point":Vector2(640,850)}); game.sim.paused=false
	for n in 400:
		step()
		if game.diagnostic_role_route_ready: break
	var arrived=game.diagnostic_role_route_ready
	game._order("decoy"); game._order("route",{"point":Vector2(140,800)})
	var modes=[]; var max_excursion=0.0; var no_visual=true
	for n in 500:
		step(); var hunter=game.sim.sirens[1]
		max_excursion=maxf(max_excursion,hunter.pos.distance_to(hunter.home)); no_visual=no_visual and hunter.target==-1 and hunter.lock==0
		if not hunter.mode in modes: modes.append(hunter.mode)
		if "RETURN" in modes and hunter.mode=="DORMANT": break
	var ok=arrived and ["INVESTIGATE","SEARCH","RETURN","DORMANT"].all(func(m):return m in modes) and max_excursion>190 and no_visual and game.sim.hull==100 and game.sim.outcome.is_empty()
	print("ROLE_PROTOCOL ok=",ok," modes=",modes," max_excursion=",max_excursion," hull=",game.sim.hull," elapsed=",game.sim.elapsed," tools=",game.sim.tools," quietus=",game.sim.units[0].pos)
	game.queue_free(); await create_timer(0.5).timeout; quit(0 if ok else 1)
