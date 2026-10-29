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
func touch(button) -> void:
	var point=root.get_final_transform()*button.get_global_rect().get_center()
	for down in [true,false]:
		var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down
		Input.parse_input_event(event);Input.flush_buffered_events();await process_frame
	for n in 6:await process_frame
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
	# SETDEPTH: controls are spread over three pages; gather ids from each, ending on the CONTROLS page.
	for page in ["audio","display","controls"]:
		var tab=identified("settings_page_"+page)
		if tab!=null:
			await scroll_to(tab);await click(tab);await process_frame;await process_frame
		for control in game.menu.find_children("*","Control",true,false):
			if control is BaseButton or control is Slider: settings_ids.append(control.get_meta("action",control.get_meta("ui_action","")))
	var required=["volume_master","volume_music","volume_effects","mute","back","text_scale_115","setting_high_contrast","setting_reduced_motion","setting_haptics"]
	if OS.is_debug_build():required.append("developer")
	var expected=required+["text_scale_100","text_scale_130","text_scale_150","setting_safe_palette","setting_audio_captions","settings_reset","reset_tips","new_campaign",
		"settings_page_audio","settings_page_display","settings_page_controls","volume_alerts","volume_messages","setting_night_mode",
		"frame_cap_30","frame_cap_60","haptic_strength_1","haptic_strength_2","haptic_strength_3","drag_preset_0","drag_preset_1",
		"drag_preset_2","hold_preset_0","hold_preset_1","hold_preset_2"]
	var visible_ids=game._ui_metrics().controls.map(func(c):return c.action)
	check(required.all(func(a):return a in settings_ids) and visible_ids.all(func(a):return a in expected),"shared settings retain stable slider/mute/BACK IDs and the full accessibility controls when optional rows scroll")
	var developer=identified("developer")
	check((developer!=null)==OS.is_debug_build(),"Settings Developer stable ID follows the debug-build entry gate")
	if developer!=null:
		check(await scroll_to(developer),"wheel input reaches the Developer row after regular settings controls")
		check(developer.size.x>=game.ui_touch_height and developer.size.y>=game.ui_touch_height,"Developer row keeps the shared touch target in both dimensions")
		await touch(developer)
		check(game.debug_console.panel.visible,"injected screen touch opens Developer from Settings")
		game.debug_console.panel.hide()
	var back=identified("back")
	check(back!=null and back.get_parent()==game.menu_footer and game.get_viewport_rect().encloses(back.get_global_rect()),"settings BACK stays fully exposed outside scrolling content")
	var back_present=back!=null
	if back_present: await click(back)
	check(back_present and game.screen=="menu","real pointer BACK restores operations without a text-derived target")
	game._briefing(5); await process_frame; await process_frame
	var footer_actions=game.menu_footer.get_children().map(func(b):return b.get_meta("action",b.get_meta("ui_action","")))
	check("begin" in footer_actions and "back" in footer_actions,"sticky ENTER and BACK keep stable IDs when their visible labels wrap")
	game.queue_free(); await process_frame; await create_timer(0.5).timeout
	print("DENSITY MENU CHECKS ",checks," FAILURES ",failures); quit(1 if failures else 0)
