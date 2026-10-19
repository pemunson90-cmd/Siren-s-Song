extends SceneTree
var game
func _initialize(): call_deferred("run")
func run():
	var folder=""; var scenario="approach"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="): folder=arg.trim_prefix("--folder=")
		if arg.begins_with("--scenario="): scenario=arg.trim_prefix("--scenario=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="campaign-scout"; root.add_child(game)
	await process_frame; await process_frame
	game.upgrade="survey"; game._start_mission(2); game.set_process(false)
	game._order("select",{"unit":1}); game._order("route",{"point":Vector2(760,410)})
	game.sim.paused=false
	var last_emp=-99.0
	if scenario=="idle":
		for n in 110:
			game.sim.advance(0.1)
			if _fresh_lock() and game.sim.elapsed-last_emp>1 and game.sim.tools.emp>0:
				game._order("emp"); last_emp=game.sim.elapsed
		game._order("camera")
	print("CLIP_START scenario=",scenario," t=",game.sim.elapsed," pos=",game.sim.units[1].pos," tools=",game.sim.tools," no_input=",scenario=="idle")
	for n in 240:
		if scenario=="approach":
			if n==90:game._order("ping")
			if _fresh_lock() and game.sim.elapsed-last_emp>1 and game.sim.tools.emp>0:
				game._order("emp"); last_emp=game.sim.elapsed
			if n==170:game._order("camera")
		game.sim.advance(1.0/15.0); game._refresh(); game.ocean.queue_redraw()
		await process_frame; await RenderingServer.frame_post_draw
		var frame=root.get_texture().get_image()
		if n in [0,90,169,199,239]: frame.save_png(folder.path_join("full-%03d.png"%n))
		frame.resize(640,360,Image.INTERPOLATE_LANCZOS); frame.save_png(folder.path_join("%04d.png"%n))
		if n%15==0:print("SAMPLE frame=",n," t=",game.sim.elapsed," context=",game.sim.camera_context()," known=",game.sim.known.size()," contacts=",game.sim.contacts," record=",game.sim.mission.objectives.map(func(o):return o.captured)," drone_alive=",game.sim.units[1].alive," message=",game.sim.message)
	print("CLIP_END t=",game.sim.elapsed," hull=",game.sim.hull," tools=",game.sim.tools," events=",game.sim.events)
	game.queue_free(); await process_frame; await create_timer(0.5).timeout; quit()
func _fresh_lock():
	for c in game.sim.contacts.values():
		if game.sim.elapsed-c.time<0.3 and c.lock>1 and c.target==1: return true
	return false
