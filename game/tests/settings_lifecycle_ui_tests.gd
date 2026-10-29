extends SceneTree
# Pending frontend settings must flush when their host is closed or suspended.
const FrontSettings=preload("res://src/presentation/frontend/frontend_settings.gd")
const SettingsStore=preload("res://src/persistence/settings_store.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func tap(point):
	for down in [true,false]:
		var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
		var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
	await settle()
func button(node,id):
	if node==null:return null
	for b in node.find_children("*","Button",true,false):
		if b.get_meta("ui_action","")==id and b.is_visible_in_tree():return b
	return null
func press(node,id):
	var b=button(node,id)
	check(b!=null,"visible action "+id)
	if b==null:return false
	var parent=b.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(b);await settle()
	await tap(b.get_global_rect().get_center());return true
func clean(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func saved_values(path):
	var store=SettingsStore.new();store.path=path;return store.load_settings()
func case_run(case_name,target_scale,route,suspend=false):
	var stem="user://settings-lifecycle-%s"%case_name
	var settings_path=stem+"-settings.json";var archive=stem+".save"
	clean(settings_path);clean(archive)
	var defaults=SettingsStore.DEFAULTS.duplicate(true)
	var disk=SettingsStore.new();disk.path=settings_path
	check(disk.save_settings(defaults),case_name+" starts with a written defaults file")
	FrontSettings.apply(defaults.duplicate(true),null)
	var game=load("res://scenes/main.tscn").instantiate()
	game.store.path=archive;game.settings_path=settings_path;game.capture_scenario="runtime-test"
	root.add_child(game);await settle();game.set_process(false)
	game._show_campaign();game.capture_scenario=""
	var front=null
	if route=="title":
		game._boot_frontend();await settle();front=game.get_node_or_null("Frontend")
		check(front!=null,case_name+" has a title frontend")
		if front!=null:
			if await press(front,"frontend_settings"):
				front=game.get_node_or_null("Frontend")
	else:
		game._settings_menu();await settle();front=game.get_node_or_null("Frontend")
	check(front!=null,case_name+" uses the shared settings frontend")
	if front==null:
		game.queue_free();await settle();clean(settings_path);clean(archive);return
	front.save_timer.wait_time=60.0
	var sim=game.sim;var sim_before=sim.snapshot()
	var action="text_scale_%d"%roundi(target_scale*100)
	var surface=front if route=="title" else game
	await press(surface,"settings_page_display") # SETDEPTH: text size is on the DISPLAY page.
	if await press(surface,action):
		check(is_equal_approx(FrontSettings.text_scale(),target_scale),case_name+" applies the selected scale immediately")
		check(is_equal_approx(float(saved_values(settings_path).text_scale),float(defaults.text_scale)),case_name+" keeps debounce pending before lifecycle boundary")
	else:
		check(false,case_name+" reaches the requested text scale through touch")
	if suspend:
		root.propagate_notification(Node.NOTIFICATION_APPLICATION_PAUSED);await settle()
		check(is_equal_approx(float(saved_values(settings_path).text_scale),target_scale),case_name+" flushes pending setting on application suspend")
		check(sim.snapshot()==sim_before,case_name+" suspend leaves the campaign simulation unchanged")
	else:
		game.queue_free();await settle()
		check(is_equal_approx(float(saved_values(settings_path).text_scale),target_scale),case_name+" flushes pending setting when host exits")
		check(sim.snapshot()==sim_before,case_name+" host exit leaves the campaign simulation unchanged")
	if is_instance_valid(game):game.queue_free();await settle()
	clean(settings_path);clean(archive)
func run():
	root.size=Vector2i(1280,720);await settle()
	await case_run("operations-host-exit",1.15,"operations")
	await case_run("title-host-exit",1.15,"title")
	await case_run("operations-app-suspend",1.3,"operations",true)
	FrontSettings.apply(SettingsStore.DEFAULTS.duplicate(true),null)
	print("SETTINGS LIFECYCLE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
