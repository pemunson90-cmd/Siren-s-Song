extends SceneTree
# Actual engine GUI replay. No simulation state edits; not Android OS input.
var game
func _initialize() -> void: call_deferred("run")
func pointer(point: Vector2,down: bool) -> void:
	var motion=InputEventMouseMotion.new(); motion.position=point; motion.global_position=point; root.push_input(motion,true)
	var event=InputEventMouseButton.new(); event.position=point; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; root.push_input(event,true)
func run() -> void:
	var folder="/tmp/sirens-density-interaction"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--clip-dir="): folder=arg.trim_prefix("--clip-dir=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate(); game.set_script(preload("res://tests/density_main.gd")); game.capture_scenario="density-planning-replay"; root.add_child(game)
	var screenshot_path=game.capture_path; game.capture_path=""
	await process_frame; await process_frame
	game._start_mission(0); await process_frame; await process_frame; await process_frame
	var clicks={15:"droneA",30:"route_a",45:"queue",60:"route_b",75:"more_orders",90:"camera",105:"route_c",120:"home",135:"more_orders",150:"droneB",165:"route_c",180:"pause",195:"pause",210:"zoom_in",225:"fit"}
	var held_point=Vector2.ZERO
	for n in 240:
		if clicks.has(n):
			var action=clicks[n]
			var buttons={"droneA":game.unit_buttons[1],"droneB":game.unit_buttons[2],"pause":game.pause_button,"more_orders":game.advanced_button,"zoom_in":game.zoom_buttons[1],"fit":game.zoom_buttons[2]}
			if action.begins_with("route_"):
				var world={"route_a":Vector2(600,800),"route_b":Vector2(900,800),"route_c":Vector2(900,700)}[action]
				held_point=game.ocean.global_position+game.ocean.world_offset+world*game.ocean.world_scale
			else: held_point=(buttons[action] if buttons.has(action) else game.order_buttons[action]).get_global_rect().get_center()
			print("DENSITY_INPUT frame=",n," action=",action," point=",held_point," sim_time=",game.sim.elapsed)
			pointer(held_point,true)
		elif clicks.has(n-1): pointer(held_point,false)
		await process_frame; await RenderingServer.frame_post_draw
		var image=root.get_texture().get_image()
		if n==0 and not screenshot_path.is_empty(): image.save_png(screenshot_path)
		image.resize(image.get_width()/2,image.get_height()/2,Image.INTERPOLATE_LANCZOS)
		image.save_png(folder.path_join("%04d.png"%n))
	print("DENSITY_CLIP frames=240 fps=15 screen=",game.screen," paused=",game.sim.paused," elapsed=",game.sim.elapsed)
	game.queue_free(); await process_frame; await create_timer(0.5).timeout; quit()
