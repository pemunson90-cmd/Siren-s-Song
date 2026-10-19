extends SceneTree
# Ordinary actual engine GUI input replay, fixed 15fps. No simulation fixture edits.
var game
func _initialize() -> void: call_deferred("run")
func pointer(point: Vector2,down: bool) -> void:
	var motion=InputEventMouseMotion.new(); motion.position=point; motion.global_position=point; root.push_input(motion,true)
	var event=InputEventMouseButton.new(); event.position=point; event.button_index=MOUSE_BUTTON_LEFT; event.pressed=down; root.push_input(event,true)
func run() -> void:
	var folder="res://../work/acoustic-feedback/capture"
	var count=300
	var inset=0.0
	var idle=false
	var desktop=false
	for arg in OS.get_cmdline_user_args():
		if arg=="--idle":idle=true
		if arg=="--desktop":desktop=true
		if arg.begins_with("--clip-frames="):count=int(arg.trim_prefix("--clip-frames="))
		if arg.begins_with("--safe-inset-x="):inset=float(arg.trim_prefix("--safe-inset-x="))
		if arg.begins_with("--clip-dir="):folder=arg.trim_prefix("--clip-dir=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate()
	if not desktop:game.set_script(preload("res://tests/density_main.gd"))
	game.capture_scenario="acoustic-replay"
	if inset>0:game.fixture_safe_area=Rect2(inset,0,root.size.x-inset,root.size.y)
	root.add_child(game)
	await process_frame; await process_frame; game._start_mission(0)
	await process_frame; await process_frame
	var actions={0:"pause",5:"silent",15:"route_sub",30:"more",45:"decoy",60:"droneA",75:"route_drone",90:"decoy",105:"sub",110:"more",120:"silent",135:"hold",150:"pause",165:"pause",180:"route_sub"}
	if idle:
		game._order("decoy"); game._pause(); actions={}
	var point=Vector2.ZERO
	for n in count:
		if actions.has(n):
			var action=actions[n]
			if action.begins_with("route_"):
				point=game.ocean.global_position+game.ocean.screen_position(Vector2(600,800) if action=="route_sub" else Vector2(600,700))
			else:
				var buttons={"more":game.advanced_button,"droneA":game.unit_buttons[1],"sub":game.unit_buttons[0],"pause":game.pause_button}
				point=(buttons[action] if buttons.has(action) else game.order_buttons[action]).get_global_rect().get_center()
			print("ACOUSTIC_INPUT frame=",n," action=",action," sim_time=",game.sim.elapsed)
			pointer(point,true)
		elif actions.has(n-1): pointer(point,false)
		await process_frame; await RenderingServer.frame_post_draw
		var image=root.get_texture().get_image()
		if n in [100,145,185,240,299] or n==count-1:image.save_png(folder.path_join("full-%03d.png"%n))
		image.resize(image.get_width()/2,image.get_height()/2,Image.INTERPOLATE_LANCZOS); image.save_png(folder.path_join("%04d.png"%n))
	print("ACOUSTIC_END fps=15 frames=",count," elapsed=",game.sim.elapsed," hull=",game.sim.hull," outcome=",game.sim.outcome," noises=",game.sim.noises)
	game.queue_free(); await process_frame; await create_timer(0.5).timeout; quit()
