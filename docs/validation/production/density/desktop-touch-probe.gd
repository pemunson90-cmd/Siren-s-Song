extends SceneTree
var checks=0
var failures=0
var game
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1; printerr("FAIL: ",message)
func _initialize() -> void: call_deferred("run")
func identified(action: String):
	for control in game.menu.find_children("*","Button",true,false):
		if control.get_meta("action",control.get_meta("ui_action",""))==action: return control
	return null
func click(button) -> void:
	var motion=InputEventMouseMotion.new(); motion.position=button.get_global_rect().get_center(); motion.global_position=motion.position
	root.push_input(motion,true); await process_frame
	for down in [true,false]:
		var event=InputEventMouseButton.new(); event.position=button.get_global_rect().get_center(); event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down
		root.push_input(event,true); await process_frame
	await process_frame
func scroll_to(control: Control) -> bool:
	for step in 50:
		if game.scroll.get_global_rect().encloses(control.get_global_rect()): return true
		var event=InputEventMouseButton.new()
		event.position=game.scroll.get_global_rect().get_center()
		event.button_index=MOUSE_BUTTON_WHEEL_DOWN; event.pressed=true; event.factor=3.0
		root.push_input(event,true)
		event=event.duplicate(); event.pressed=false; root.push_input(event,true)
		await process_frame; await process_frame
	return false
func touch_scroll_to(control: Control) -> bool:
	for stroke in 10:
		if game.scroll.get_global_rect().encloses(control.get_global_rect()): return true
		var area=game.scroll.get_global_rect()
		var start=area.get_center()+Vector2(0,area.size.y*0.3)
		var touch=InputEventScreenTouch.new(); touch.index=0; touch.position=start; touch.pressed=true
		root.push_input(touch,true); await process_frame
		var point=start
		for step in 12:
			var next=start-Vector2(0,area.size.y*0.05*(step+1))
			var drag=InputEventScreenDrag.new(); drag.index=0; drag.position=next; drag.relative=next-point; drag.velocity=drag.relative*60
			root.push_input(drag,true); point=next; await process_frame
		touch=InputEventScreenTouch.new(); touch.index=0; touch.position=point; touch.pressed=false
		root.push_input(touch,true); await process_frame; await process_frame
	return false
func run() -> void:
	root.size=Vector2i(2520,1080); await process_frame; await process_frame
	game=load("res://scenes/main.tscn").instantiate(); game.set_script(preload("res://tests/density_main.gd")); game.capture_scenario="density-menu-test"; root.add_child(game)
	await process_frame; await process_frame
	game._show_campaign(); await process_frame; await process_frame
	check(identified("settings")!=null and identified("loadout")!=null,"operations navigation has stable logical settings/loadout IDs independent of label punctuation")
	var settings=identified("settings")
	var settings_present=settings!=null
	check(settings_present and await scroll_to(settings),"engine wheel input reaches below-fold operations settings fully")
	if settings!=null: await click(settings)
	else: game._settings_menu(); await process_frame; await process_frame
	check(settings_present and game.screen=="settings","real pointer input opens settings through its stable target")
	var settings_ids=[]
	for control in game.menu.find_children("*","Control",true,false):
		if control is BaseButton or control is Slider: settings_ids.append(control.get_meta("action",control.get_meta("ui_action","")))
	var expected=["volume_music","volume_effects","mute","back"]
	var visible_ids=game._ui_metrics().controls.map(func(c):return c.action)
	check(expected.all(func(a):return a in settings_ids) and visible_ids.all(func(a):return a in expected),"settings retain stable slider/mute/BACK IDs even when scroll clips optional rows")
	var back=identified("back")
	check(back!=null and back.get_parent()==game.menu_footer and game.get_viewport_rect().encloses(back.get_global_rect()),"settings BACK stays fully exposed outside scrolling content")
	var back_present=back!=null
	if back_present: await click(back)
	check(back_present and game.screen=="menu","real pointer BACK restores operations without a text-derived target")
	settings=identified("settings")
	check(settings!=null and await touch_scroll_to(settings),"engine touch drags reach below-fold Settings without selecting a mission")
	check(game.screen=="menu","scrolling operations via touch does not activate crossed buttons")
	game._briefing(5); await process_frame; await process_frame
	var footer_actions=game.menu_footer.get_children().map(func(b):return b.get_meta("action",b.get_meta("ui_action","")))
	check("begin" in footer_actions and "back" in footer_actions,"sticky ENTER and BACK keep stable IDs when their visible labels wrap")
	game.queue_free(); await process_frame; await create_timer(0.5).timeout
	print("DENSITY MENU CHECKS ",checks," FAILURES ",failures); quit(1 if failures else 0)
