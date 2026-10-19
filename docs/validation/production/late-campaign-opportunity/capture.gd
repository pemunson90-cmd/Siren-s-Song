extends SceneTree
var game
var folder=""
var idle=false
var last_emp=-99.0
func _initialize():call_deferred("run")
func protect():
	var s=game.sim
	if s.elapsed-last_emp<=1:return
	for c in s.contacts.values():
		if s.elapsed-c.time<.3 and c.lock>1 and c.target>=0 and s.tools.emp>0:
			var chosen=s.selected;game._order("select",{"unit":c.target});game._order("emp");game._order("select",{"unit":chosen});last_emp=s.elapsed;return
func advance(seconds:float,defend:bool=true):
	for n in int(round(seconds*60)):
		if not game.sim.outcome.is_empty():return
		game.sim.advance(1.0/60)
		if defend:protect()
func arrive(unit:int,point:Vector2):
	game._order("select",{"unit":unit});game._order("route",{"point":point});game.sim.paused=false
	for n in 2400:
		advance(1.0/15)
		if not game.sim.units[unit].alive or not game.sim.outcome.is_empty():return false
		if game.sim.units[unit].route.is_empty() and game.sim.units[unit].vel.length()<2:return true
	return false
func still(name):
	game._refresh();game.ocean.queue_redraw()
	for n in 3:await process_frame
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
		if arg=="--idle":idle=true
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="late-campaign-scout";game.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(game)
	await process_frame;await process_frame;game.upgrade="disruption";game._start_mission(4);game.set_process(false)
	game._order("select",{"unit":1});game._order("route",{"point":Vector2(800,390)});game.sim.paused=false
	if idle:
		for n in 2400:
			advance(1.0/15)
			if game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2:break
		game._order("camera")
	print("CLIP_START idle=",idle," t=",game.sim.elapsed," tools=",game.sim.tools," sub=",game.sim.units[0].pos)
	var camera_sent=idle
	for frame in 300:
		if not idle:
			if not camera_sent and game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2:
				game._order("camera");camera_sent=true
		advance(1.0/15,not idle);game._observation_diagnostics();game._refresh();game.ocean.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		var picture=root.get_texture().get_image()
		if frame in [0,180,195,210,240,299]:picture.save_png(folder.path_join("full-%03d.png"%frame))
		picture.resize(1260,540,Image.INTERPOLATE_LANCZOS);picture.save_png(folder.path_join("%04d.png"%frame))
		if frame%15==0:print("FRAME ",frame," t=",game.sim.elapsed," selected=",game.sim.selected," records=",game.sim.mission.objectives.map(func(o):return o.captured)," drones=",game.sim.units[1].alive,",",game.sim.units[2].alive," contacts=",game.sim.contacts," tools=",game.sim.tools," message=",game.sim.message)
	print("CLIP_END t=",game.sim.elapsed," records=",game.sim.mission.objectives.map(func(o):return o.captured)," hull=",game.sim.hull," sub=",game.sim.units[0].pos," events=",game.sim.events)
	if not idle:
		if arrive(1,Vector2(1150,450)):
			game._order("camera");advance(2);await still("second-optical");advance(2.5)
		if arrive(1 if game.sim.units[1].alive else 2,Vector2(780,850)):
			game._order("camera");advance(4.5)
		game._observation_diagnostics();print("FINAL outcome=",game.sim.outcome," time=",game.sim.elapsed," sub=",game.sim.units[0].pos," records=",game.sim.mission.objectives.map(func(o):return o.captured)," recovered=",game.recovered_evidence.keys()," drones=",game.sim.units[1].alive,",",game.sim.units[2].alive," tools=",game.sim.tools)
		if game.sim.outcome=="won":game._debrief();await still("earned-debrief")
	game.queue_free();await process_frame;await create_timer(.5).timeout;quit()
