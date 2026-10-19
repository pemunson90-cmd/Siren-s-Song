extends SceneTree
var game
var folder=""
var profile="cover"
var report=[]
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
	await RenderingServer.frame_post_draw
func identified(action):
	for c in game.panel_box.get_children()+game.menu_footer.get_children():
		if c is Button and c.get_meta("action","")==action:return c
	return null
func click(control):
	if game.scroll.is_ancestor_of(control):game.scroll.ensure_control_visible(control)
	await settle();var p=control.get_global_rect().get_center()
	var motion=InputEventMouseMotion.new();motion.position=p;motion.global_position=p;root.push_input(motion,true)
	for down in [true,false]:
		var e=InputEventMouseButton.new();e.position=p;e.pressed=down;e.button_index=MOUSE_BUTTON_LEFT;root.push_input(e,true);await process_frame
	await settle()
func save(name):
	await settle();root.get_texture().get_image().save_png(folder.path_join(name+".png"))
	var visibility=[];var text=[];var viewport=game.scroll.get_global_rect()
	for c in game.panel_box.get_children():
		if c is Label or c is Button:
			text.append(c.text)
			if "NEXT DIVE" in c.text or "COMPARE:" in c.text or c.get_meta("action","") in ["loadout","settings"]:visibility.append({"text":c.text,"rect":str(c.get_global_rect()),"fully_visible":viewport.encloses(c.get_global_rect())})
	var state={"name":name,"selection":game.upgrade,"active_oxygen":game.sim.oxygen,"active_tools":game.sim.tools.duplicate(),"screen":game.screen,"scroll":game.scroll.scroll_vertical,"scroll_max":game.scroll.get_v_scroll_bar().max_value,"page":game.scroll.get_v_scroll_bar().page,"labels":text,"visibility":visibility,"metrics":game._ui_metrics()}
	report.append(state);print("LOADOUT_VIEW ",state)
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
		if arg.begins_with("--profile="):profile=arg.trim_prefix("--profile=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="loadout-clarity"
	if profile=="cover":game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false);game.upgrade="endurance";game._start_mission(0);game.sim.paused=true;game._show_campaign();await settle()
	var before=game.sim.snapshot()
	for choice in ["endurance","disruption","survey"]:
		game.scroll.scroll_vertical=100000;await save("operations-"+choice)
		if choice!="survey":
			await click(identified("loadout"));print("CYCLE_AFTER scroll=",game.scroll.scroll_vertical," active_unchanged=",before==game.sim.snapshot())
	await click(identified("settings"));await save("settings-reached")
	await click(identified("back"));game._briefing(0);await settle();game.scroll.scroll_vertical=100000;await save("briefing-survey")
	await click(identified("begin"));print("START_SELECTED actual=",game.upgrade," oxygen=",game.sim.oxygen," tools=",game.sim.tools)
	var f=FileAccess.open(folder.path_join("views.json"),FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
	game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
