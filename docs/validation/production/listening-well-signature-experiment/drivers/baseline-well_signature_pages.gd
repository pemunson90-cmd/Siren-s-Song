extends SceneTree
var game
var folder=""
func _initialize():call_deferred("run")
func still(name):
	for n in 16:await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(name+".png"))
	FileAccess.open(folder.path_join(name+"-metrics.json"),FileAccess.WRITE).store_string(JSON.stringify(game._ui_metrics(),"\t"))
func run():
	folder=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="well-pages";game.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(game)
	await process_frame;await process_frame;game.upgrade="disruption";game._start_mission(4);game.set_process(false)
	var plan=load("res://tests/well_signature_plan.gd").new();plan.s=game.sim;plan.travel(1,Vector2(800,390));plan.sample(1);game._observation_diagnostics();game._briefing(4)
	await still("baseline-briefing-cover-top");game.scroll.scroll_vertical=100000;await still("baseline-briefing-cover-bottom")
	root.size=Vector2i(2184,1968);game.fixture_safe_area=Rect2(0,0,2184,1968);await process_frame;game._layout();game.scroll.scroll_vertical=0;await still("baseline-briefing-inner-top");game.scroll.scroll_vertical=100000;await still("baseline-briefing-inner-bottom")
	game._briefing(4);await still("briefing-inner-top");game.scroll.scroll_vertical=100000;await still("briefing-inner-bottom")
	root.size=Vector2i(2520,1080);game.fixture_safe_area=Rect2(136,0,2384,1080);await process_frame;game._layout();game.scroll.scroll_vertical=0;await still("briefing-cover-top");game.scroll.scroll_vertical=100000;await still("briefing-cover-bottom")
	print("EARNED FIRST RECORD time=",game.sim.elapsed," records=",game.sim.mission.objectives.map(func(o):return o.captured)," actions=",plan.actions)
	game.queue_free();await process_frame;await create_timer(.3).timeout;quit()
