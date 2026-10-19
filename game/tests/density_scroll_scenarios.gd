extends SceneTree
# Engine GUI emulation, not Android OS input. Enabling touch emulation exposes
# the same ScrollContainer touchscreen-gated mouse-drag path as Android.
var game
var checks=0
var failures=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",message)
func _initialize() -> void:call_deferred("run")
func mouse(point: Vector2,down: bool) -> void:
	var event=InputEventMouseButton.new();event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;event.device=InputEvent.DEVICE_ID_EMULATION
	root.push_input(event,true)
func drag(start: Vector2,finish: Vector2) -> void:
	var move=InputEventMouseMotion.new();move.position=start;move.global_position=start;move.device=InputEvent.DEVICE_ID_EMULATION;root.push_input(move,true)
	mouse(start,true);await process_frame
	var previous=start
	for step in 30:
		var point=start.lerp(finish,(step+1)/30.0)
		move=InputEventMouseMotion.new();move.position=point;move.global_position=point;move.relative=point-previous;move.button_mask=MOUSE_BUTTON_MASK_LEFT;move.device=InputEvent.DEVICE_ID_EMULATION
		root.push_input(move,true);previous=point;await process_frame
	mouse(finish,false);await create_timer(0.5).timeout
func action(id: String):
	for b in game.menu.find_children("*","Button",true,false):
		if b.get_meta("action","")==id:return b
	return null
func operations() -> void:
	game.active_started=false;game._show_campaign();await process_frame;await process_frame;await process_frame
func gap_origin() -> Vector2:
	var body=game.scroll.get_global_rect()
	for y in range(int(body.end.y-20),int(body.get_center().y),-4):
		var point=Vector2(body.get_center().x,y);var clear=true
		for c in game.panel_box.get_children():
			if (c is BaseButton or c is Slider) and c.get_global_rect().grow(5).has_point(point):clear=false
		if clear:return point
	return Vector2(-1,-1)
func run() -> void:
	var previous_emulation=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(true)
	root.size=Vector2i(2520,1080);await process_frame;await process_frame
	game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/density_main.gd"));game.capture_scenario="density-scroll-test";root.add_child(game)
	await process_frame;await process_frame;await operations()
	check(DisplayServer.is_touchscreen_available(),"fixture explicitly exposes engine touchscreen scroll path")
	var reports=[0];game.scroll_report_timer.timeout.connect(func():reports[0]+=1)
	var disabled
	for child in game.panel_box.get_children():
		if child is Button and child.disabled and game.scroll.get_global_rect().encloses(child.get_global_rect()):disabled=child;break
	check(disabled!=null,"disabled row is genuinely exposed before drag")
	if disabled!=null:
		var start=disabled.get_global_rect().get_center();var before=game.sim.snapshot()
		await drag(start,start-Vector2(0,minf(300,start.y-game.scroll.global_position.y-20)))
		print("SCROLL_DISABLED offset=",game.scroll.scroll_vertical," reports=",reports[0])
		check(game.scroll.scroll_vertical>50,"drag originating on disabled row scrolls actual body")
		check(reports[0]>0,"scroll emits debounced fresh metrics callback")
		check(game.screen=="menu" and game.sim.snapshot()==before,"disabled-row drag does not select mission or issue order")
	await operations()
	var enabled=action("mission0");var start=enabled.get_global_rect().get_center();var before=game.sim.snapshot()
	await drag(start,start-Vector2(0,minf(180,start.y-game.scroll.global_position.y-20)))
	print("SCROLL_ENABLED offset=",game.scroll.scroll_vertical," screen=",game.screen)
	check(game.scroll.scroll_vertical>30,"drag originating on enabled mission row scrolls actual body")
	check(game.screen=="menu" and game.sim.snapshot()==before,"scroll gesture cancels enabled button activation")
	await operations();start=action("mission0").get_global_rect().get_center();mouse(start,true);await process_frame;mouse(start,false);await process_frame;await process_frame
	check(game.screen=="briefing","ordinary release tap still opens mission after propagation change")
	game._settings_menu();await process_frame;await process_frame;await process_frame
	var values=game.settings.duplicate(true);start=gap_origin();check(start.x>=0,"settings exposes measured non-control scroll origin")
	if start.x>=0:await drag(start,start-Vector2(0,minf(300,start.y-game.scroll.global_position.y-20)))
	print("SCROLL_SETTINGS offset=",game.scroll.scroll_vertical," values=",game.settings)
	check(game.scroll.scroll_vertical>0,"settings body scrolls from measured gap")
	check(game.screen=="settings" and game.settings==values,"settings scroll leaves music/effects/mute unchanged")
	for control in game.panel_box.get_children():
		if control is Slider and control.get_meta("ui_action","")=="volume_effects":check(game.scroll.get_global_rect().encloses(control.get_global_rect()),"below-fold effects slider becomes fully reachable without activation")
	var mute=action("mute")
	check(mute!=null and game.scroll.get_global_rect().encloses(mute.get_global_rect()),"below-fold mute becomes fully reachable")
	if mute!=null and game.scroll.get_global_rect().encloses(mute.get_global_rect()):
		start=mute.get_global_rect().get_center();await drag(start,start-Vector2(0,150))
		check(game.settings==values,"mute-origin drag never toggles audio")
	var back=action("back");start=back.get_global_rect().get_center();mouse(start,true);await process_frame;mouse(start,false);await process_frame;await process_frame
	check(game.screen=="menu" and game.settings==values,"sticky BACK tap returns without changing audio")
	game.queue_free();await process_frame;await create_timer(0.5).timeout;Input.set_emulate_touch_from_mouse(previous_emulation)
	print("DENSITY SCROLL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
