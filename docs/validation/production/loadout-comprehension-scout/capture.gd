extends SceneTree
var game
var folder=""
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
	await RenderingServer.frame_post_draw
func click(button):
	var p=button.get_global_rect().get_center()
	var down=InputEventMouseButton.new();down.position=p;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;root.push_input(down,true)
	await process_frame
	var up=InputEventMouseButton.new();up.position=p;up.button_index=MOUSE_BUTTON_LEFT;up.pressed=false;root.push_input(up,true)
	await settle()
func save(name):
	await settle();root.get_texture().get_image().save_png(folder.path_join(name+".png"))
	print("SCOUT_SCREEN ",name," choice=",game.upgrade," active_time=",game.sim.elapsed," oxygen=",game.sim.oxygen," tools=",game.sim.tools," labels=",game.panel_box.get_children().map(func(c):return c.text if c is Label or c is Button else ""))
func loadout_button():
	for child in game.panel_box.get_children():
		if child is Button and child.get_meta("action","")=="loadout":return child
	return null
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):folder=arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="loadout-scout"
	game.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(game)
	await settle();game._start_mission(0);game.sim.paused=true;game._show_campaign();await settle()
	for name in ["endurance","disruption","survey"]:
		game.scroll.scroll_vertical=100000;await save("operations-"+name)
		if name!="survey":await click(loadout_button())
	print("ACTIVE_UNCHANGED_AFTER_CYCLE choice=",game.upgrade," oxygen=",game.sim.oxygen," tools=",game.sim.tools)
	game._briefing(0);await settle();game.scroll.scroll_vertical=100000;await save("briefing-survey-selected")
	for child in game.menu_footer.get_children():
		if child is Button and child.get_meta("action","")=="begin":await click(child);break
	print("NEW_DIVE_AFTER_BEGIN choice=",game.upgrade," oxygen=",game.sim.oxygen," tools=",game.sim.tools)
	for choice in ["endurance","disruption","survey"]:
		var sim=load("res://src/simulation/simulation.gd").new();sim.start(0,choice)
		print("DETERMINISTIC_START choice=",choice," oxygen=",sim.oxygen," tools=",sim.tools)
	game.queue_free();await process_frame;await create_timer(.5).timeout;quit()
