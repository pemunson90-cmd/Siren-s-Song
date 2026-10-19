extends SceneTree
var game
var plan
var folder=""
var mode="moving"
var sampled=false
var second_start=-1.0
var third_started=false
func _initialize():call_deferred("run")
func state():
	return {"time":game.sim.elapsed,"hull":game.sim.hull,"tools":game.sim.tools,"outcome":game.sim.outcome,"units":game.sim.units,"records":game.sim.mission.objectives.map(func(o):return o.captured),"reference":game.sim.mission.get("well_reference",{}),"observation":game.sim.mission.get("well_observation",{}),"archive":game.recovered_evidence,"message":game.sim.message,"story":game.sim.mission.record}
func sync():
	game._observation_diagnostics();game._refresh();game.ocean.queue_redraw()
func still(name):
	for n in 3:await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(name+".png"))
	FileAccess.open(folder.path_join(name+"-metrics.json"),FileAccess.WRITE).store_string(JSON.stringify(game._ui_metrics(),"\t"))
func live():
	game.screen="mission";game.menu.hide();game.hud.show();game.sim.paused=false;sync()
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
		if arg.begins_with("--mode="):mode=arg.trim_prefix("--mode=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="well-signature-experiment";game.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(game)
	await process_frame;await process_frame;game.upgrade="disruption";game._start_mission(4);game.set_process(false)
	plan=load("res://tests/well_signature_plan.gd").new();plan.s=game.sim
	if mode in ["remote","solo"]:
		if mode=="remote":plan.remote()
		else:plan.moving(true)
		sync();print("EARNED ",state())
		if not game.sim.outcome.is_empty():game._debrief();await still("earned-debrief")
		if not game.recovered_evidence.is_empty():game._evidence_gallery(game.recovered_evidence.size()-1);await still("earned-record")
	else:
		plan.travel(1,Vector2(800,390));plan.sample(1);sync()
		if game.recovered_evidence.has("well_pattern"):
			game._evidence_gallery(0);await still("first-record-cover");live()
		plan.order("select",{"unit":1});plan.order("route",{"point":Vector2(420,180)})
		plan.order("select",{"unit":2});plan.order("route",{"point":Vector2(780,850)})
		plan.order("select",{"unit":0});plan.order("silent");plan.order("select",{"unit":0});plan.order("route",{"point":Vector2(1150,450)})
		plan.advance((32.9 if mode=="idle" else 27.0)-game.sim.elapsed)
		if mode=="idle":plan.defend=false
		sync();print("CLIP_START ",state());var command_count=plan.actions.size()
		for frame in 240:
			if mode!="idle":
				if not sampled and game.sim.units[0].route.is_empty() and game.sim.units[0].vel.length()<2:
					plan.order("silent");plan.order("select",{"unit":0});plan.order("camera");sampled=true;second_start=game.sim.elapsed
				if sampled and not third_started and game.sim.elapsed-second_start>=4.5 and game.sim.units[2].alive:
					plan.order("select",{"unit":2});plan.order("camera");third_started=true
			plan.advance(1.0/15);sync()
			await process_frame;await RenderingServer.frame_post_draw
			var picture=root.get_texture().get_image()
			if frame in [0,59,89,119,179,239]:picture.save_png(folder.path_join("full-%03d.png"%frame))
			picture.resize(1260,540,Image.INTERPOLATE_LANCZOS);picture.save_png(folder.path_join("%04d.png"%frame))
			if frame%15==0:print("FRAME ",frame," ",state())
		print("CLIP_END ",state()," commands_during=",plan.actions.size()-command_count)
		if game.recovered_evidence.has("well_signature"):
			game._evidence_gallery(game.recovered_evidence.keys().find("well_signature"));await still("match-record-cover")
			root.size=Vector2i(2184,1968);game.fixture_safe_area=Rect2();await process_frame;game._layout();await still("match-record-inner")
		game._briefing(4);await still("briefing-inner");game.scroll.scroll_vertical=100000;await still("briefing-inner-bottom")
		root.size=Vector2i(2520,1080);game.fixture_safe_area=Rect2(136,0,2384,1080);await process_frame;game._layout();game.scroll.scroll_vertical=0;await still("briefing-cover");game.scroll.scroll_vertical=100000;await still("briefing-cover-bottom")
	FileAccess.open(folder.path_join("provenance.json"),FileAccess.WRITE).store_string(JSON.stringify({"mode":mode,"state":state(),"commands":plan.actions,"viewport":root.size,"density":420,"fixture":"direct chapter index4/disruption; no pose/enemy/tool/outcome override except solo begins with both drones lost"},"\t"))
	print("ACTIONS ",plan.actions)
	game.queue_free();await process_frame;await create_timer(.3).timeout;quit()
