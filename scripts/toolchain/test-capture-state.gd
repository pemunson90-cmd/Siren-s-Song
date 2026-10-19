extends SceneTree
# Paused, isolated presentation fixtures; not an ordinary native playtest.
var game
var frames:=0
var image_dir:=""
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in 8: await process_frame
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--images="): image_dir=arg.trim_prefix("--images=")
	root.size=Vector2i(2184,1968)
	game=load("res://scenes/main.tscn").instantiate()
	game.capture_scenario="capture-state-test"
	root.add_child(game)
	await settle()
	game._start_mission(0)
	await settle()
	game.sim.units[1].pos=Vector2(1300,510)
	game.sim.command("select",{"unit":1})
	game._refresh()
	await settle()
	print("SYNC_TEST camera_before")
	game._order("camera")
	print("SYNC_TEST ack capture=",game.sim.capture_unit," optical=",game.ocean.optical_feed.visible," drawn=",Engine.get_frames_drawn())
	await settle()
	print("SYNC_TEST camera_settled optical=",game.ocean.optical_feed.visible," drawn=",Engine.get_frames_drawn())
	await save_image("camera")
	game._order("select",{"unit":0})
	game._show_campaign()
	await settle()
	print("SYNC_TEST restore_before")
	game._enter_water()
	await settle()
	print("SYNC_TEST restore_settled hud=",game.hud.is_visible_in_tree()," menu=",game.menu.is_visible_in_tree())
	await save_image("entered-mission")
	game.queue_free()
	await process_frame
	await create_timer(0.5).timeout
	print("SYNC_TEST done display=",DisplayServer.get_name()," drawn=",Engine.get_frames_drawn())
	quit()
func save_image(label: String) -> void:
	if image_dir.is_empty() or DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	var image=root.get_texture().get_image()
	print("SYNC_TEST image=",label," result=",image.save_png(image_dir.path_join(label+".png")))
