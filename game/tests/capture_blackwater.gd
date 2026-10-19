extends SceneTree
# Ordinary-command setup; density is an explicitly labelled desktop fixture.
var game
var folder=""
var take="receiving"
var profile="desktop"
var last_emp=-100.0
var commands=[]
func _initialize():call_deferred("run")
func order(name,args={}):
	var ok=game.sim.command(name,args);commands.append({"time":game.sim.elapsed,"order":name,"args":str(args),"accepted":ok});return ok
func step(dt=0.1,defend=true):
	game.sim.advance(dt)
	if not defend or game.sim.elapsed-last_emp<1:return
	for c in game.sim.contacts.values():
		if game.sim.elapsed-c.time<0.3 and c.lock>1 and c.target==game.sim.selected and game.sim.tools.emp>0:
			order("emp");last_emp=game.sim.elapsed;return
func travel(point):
	if not order("route",{"point":point}):return false
	game.sim.paused=false
	for n in 1500:
		step()
		if not game.sim.units[game.sim.selected].alive:return false
		if game.sim.units[game.sim.selected].route.is_empty() and game.sim.units[game.sim.selected].vel.length()<2:return game.sim.units[game.sim.selected].pos.distance_to(point)<25
	return false
func finish(id):
	for n in 60:
		step()
		if game.sim.mission.objectives[id].captured:return true
	return false
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
		if arg.begins_with("--take="):take=arg.trim_prefix("--take=")
		if arg.begins_with("--profile="):profile=arg.trim_prefix("--profile=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate()
	if profile!="desktop":game.set_script(load("res://tests/density_main.gd"))
	game.capture_scenario="blackwater-evidence";root.add_child(game);game.set_process(false)
	await process_frame;await process_frame;game._start_mission(2)
	if profile=="cover":game.fixture_safe_area=Rect2(136,0,2384,1080)
	game._layout();order("select",{"unit":1});var prepared=travel(Vector2(760,390)) and order("camera")
	if take=="receiving":
		for n in 6:step()
	else:
		prepared=prepared and finish(0)
		if take=="gallery-reply":prepared=prepared and travel(Vector2(1360,290)) and order("camera") and finish(1)
	game.sim.paused=true;game._refresh();game._layout()
	if take.begins_with("gallery"):
		game._retain_evidence();game._evidence_gallery(0 if take=="gallery-request" else 1)
	for n in 12:await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join("full.png"))
	var data={"take":take,"profile":profile,"prepared":prepared,"commands":commands,"window":str(root.size),"viewport":str(root.get_visible_rect().size),"metrics":game._ui_metrics(),"time":game.sim.elapsed,"hull":game.sim.hull,"tools":game.sim.tools,"capture_time":game.sim.capture_time,"records":game.sim.mission.objectives.map(func(o):return o.captured),"archive":game.recovered_evidence.keys(),"receiver_font":game.ocean.optical_feed.receiver_font_size}
	var f=FileAccess.open(folder.path_join("capture.json"),FileAccess.WRITE);f.store_string(JSON.stringify(data,"  "));f.close();print("BLACKWATER_CAPTURE ",data)
	game.queue_free();await process_frame;await create_timer(0.5).timeout;quit(0 if prepared else 1)
