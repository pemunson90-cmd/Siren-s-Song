extends SceneTree
var game
var step_count=0
var output_path=""
func _initialize():call_deferred("run")
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-path="):output_path=arg.trim_prefix("--capture-path=")
	game=load("res://proto/main.tscn").instantiate();root.add_child(game);game.set_process(false)
	game.sim.command("select",{"unit":1});game.sim.command("route",{"point":Vector2(760,390)});game.sim.paused=false
	for n in 1500:
		game.sim.advance(1.0/60)
		for c in game.sim.contacts.values():
			if game.sim.elapsed-c.time<0.3 and c.lock>1 and c.target==1 and game.sim.tools.emp>0:game.sim.command("emp");break
		if not game.sim.units[1].alive or (game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2):break
	print("ROOT_FIRST_LOOK start_time=",game.sim.elapsed," camera=",game.sim.command("camera")," own_pos=",game.sim.units[1].pos," tools=",game.sim.tools," context=",game.sim.camera_context())
	game._refresh();process_frame.connect(tick)
func tick():
	game.sim.advance(1.0/15);game._refresh();step_count+=1
	if step_count==4:save_frame()
func save_frame():
	await RenderingServer.frame_post_draw
	print("ROOT_FIRST_LOOK screenshot=",root.get_texture().get_image().save_png(output_path))
