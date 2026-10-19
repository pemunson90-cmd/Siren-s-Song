extends SceneTree
var failures:=0
var checks:=0
var game
func check(value: bool,label: String) -> void:
	checks+=1
	if not value: failures+=1; printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run")
func click(p: Vector2) -> void:
	var down=InputEventMouseButton.new(); down.position=p; down.button_index=MOUSE_BUTTON_LEFT; down.pressed=true
	var motion=InputEventMouseMotion.new(); motion.position=p; motion.global_position=p; root.push_input(motion,true)
	root.push_input(down,true); await process_frame
	var up=InputEventMouseButton.new(); up.position=p; up.button_index=MOUSE_BUTTON_LEFT; up.pressed=false
	root.push_input(up,true); await process_frame
func run() -> void:
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="runtime-test"; root.add_child(game)
	await process_frame; await process_frame
	game._start_mission(0); await process_frame
	print("UI root=",root.size," game=",game.size," drone=",game.unit_buttons[1].get_global_rect())
	await click(game.unit_buttons[1].get_global_rect().get_center())
	check(game.sim.selected==1,"actual pointer input selects independent drone")
	var destination=Vector2(320,800)
	var screen_point=game.ocean.global_position+game.ocean.world_offset+destination*game.ocean.world_scale
	await click(screen_point)
	check(not game.sim.units[1].route.is_empty(),"actual map tap issues route to selected drone")
	await click(game.unit_buttons[0].get_global_rect().get_center())
	check(game.sim.selected==0 and not game.sim.queue_mode,"actual sub selection clears queue mode")
	await click(game.pause_button.get_global_rect().get_center())
	check(not game.sim.paused,"actual pause button starts simulation")
	game._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	var before=game.sim.snapshot(); await process_frame
	check(game.sim.paused and before==game.sim.snapshot(),"application suspend freezes active mission")
	for dimensions in [Vector2i(1280,720),Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,540)]:
		root.size=dimensions; await process_frame; await process_frame
		game._layout()
		var all=game.unit_buttons.duplicate(); all.append(game.pause_button); all.append_array(game.order_buttons.values())
		for button in all:
			var rect=button.get_global_rect()
			check(Rect2(Vector2.ZERO,game.size).encloses(rect),"%s button %s remains inside viewport"%[dimensions,button.text])
			check(button.size.y>=44,"%s button %s has logical touch height"%[dimensions,button.text])
		check(not Rect2(game.ocean.position,game.ocean.size).intersects(game.pause_button.get_global_rect()),"%s map and pause controls do not overlap"%dimensions)
	game.queue_free(); await process_frame
	print("RUNTIME CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
