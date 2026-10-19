extends SceneTree
# Local replay of the proposed native ordinary-input protocol, not OS-input proof.
var game
func _initialize() -> void: call_deferred("run")
func frames():
	for n in 3: await process_frame
func click(point:Vector2):
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.button_index=MOUSE_BUTTON_LEFT; event.position=point; event.global_position=point; event.pressed=down; root.push_input(event,true); await process_frame
	await frames()
func step() -> void:
	game.sim.advance(0.1); game._observation_diagnostics()
func run() -> void:
	root.size=Vector2i(1280,720); await frames()
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="native-role-protocol"; root.add_child(game)
	game.set_process(false); game._start_mission(4); await frames()
	game._order("route",{"point":Vector2(640,850)}); game.sim.paused=false
	for n in 400:
		step()
		if game.diagnostic_role_route_ready: break
	var arrived=game.diagnostic_role_route_ready
	game.sim.paused=true; game.mission_hud.open("tools"); await frames()
	await click(game.order_buttons.decoy.get_global_rect().get_center())
	if not arrived or not game.decoy_armed or game.sim.tools.decoy!=3:
		printerr("Role protocol failed to arm without spending"); quit(1); return
	# Same own-only150m diagnostic as the native adapter, rounded to actual pixels.
	await game._report_targets()
	var point=(game.ocean.global_position+game.ocean.screen_position(game.sim.units[0].pos+Vector2(150,0))).round()
	await click(point)
	if game.decoy_armed or game.sim.tools.decoy!=2 or game.sim.noises.size()!=1:
		printerr("Role protocol target did not launch exactly once"); quit(1); return
	game._order("route",{"point":Vector2(140,800)}); game.sim.paused=false
	var modes=[]; var max_excursion=0.0; var no_visual=true
	for n in 500:
		step(); var hunter=game.sim.sirens[1]
		max_excursion=maxf(max_excursion,hunter.pos.distance_to(hunter.home)); no_visual=no_visual and hunter.target==-1 and hunter.lock==0
		if not hunter.mode in modes: modes.append(hunter.mode)
		if "RETURN" in modes and hunter.mode=="DORMANT": break
	var ok=arrived and ["INVESTIGATE","SEARCH","RETURN","DORMANT"].all(func(m):return m in modes) and max_excursion>190 and no_visual and game.sim.hull==100 and game.sim.outcome.is_empty()
	print("ROLE_PROTOCOL decoy_count=",game.sim.tools.decoy," ok=",ok," modes=",modes," max_excursion=",max_excursion," hull=",game.sim.hull," elapsed=",game.sim.elapsed," tools=",game.sim.tools," quietus=",game.sim.units[0].pos)
	game.queue_free(); await create_timer(0.5).timeout; quit(0 if ok else 1)
