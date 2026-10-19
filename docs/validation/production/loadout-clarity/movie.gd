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
func push(action,down):
	var p=identified(action).get_global_rect().get_center()
	var motion=InputEventMouseMotion.new();motion.position=p;motion.global_position=p;root.push_input(motion,true)
	var e=InputEventMouseButton.new();e.position=p;e.pressed=down;e.button_index=MOUSE_BUTTON_LEFT;root.push_input(e,true)
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="loadout-motion";game.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(game)
	await settle();game.set_process(false);game.upgrade="endurance";game._start_mission(0);game.sim.paused=true;game._show_campaign();await settle();game.scroll.scroll_vertical=100000;await settle()
	var active=game.sim.snapshot();var samples=[]
	for n in 240:
		if n in [29,59]:push("loadout",true)
		if n in [30,60]:push("loadout",false)
		if n in [34,64,104]:game.scroll.scroll_vertical=100000
		if n==90:game.scroll.ensure_control_visible(identified("mission0"))
		if n==98:push("mission0",true)
		if n==99:push("mission0",false)
		if n==179:push("begin",true)
		if n==180:push("begin",false)
		await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(folder.path_join("%04d.png"%n))
		if n%15==0:samples.append({"frame":n,"screen":game.screen,"selection":game.upgrade,"scroll":game.scroll.scroll_vertical,"active_stock_unchanged":game.sim.snapshot()==active,"oxygen":game.sim.oxygen,"tools":game.sim.tools.duplicate()})
	var f=FileAccess.open(folder.path_join("chronology.json"),FileAccess.WRITE);f.store_string(JSON.stringify({"frames":240,"fps":15,"input_frames":{"cycle1":[29,30],"cycle2":[59,60],"mission0":[98,99],"begin":[179,180]},"programmatic_scroll_frames":[34,64,90,104],"samples":samples},"  "));f.close();print("LOADOUT_MOVIE ",samples)
	game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
