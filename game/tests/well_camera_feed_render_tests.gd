extends SceneTree
var game
var folder=""
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;print("FAIL ",label)
	else:print("PASS ",label)
func picture(name:String):
	game.ocean.queue_redraw();game.ocean.optical_feed.queue_redraw()
	for n in 3:await process_frame
	await RenderingServer.frame_post_draw
	var frame=root.get_texture().get_image()
	var rect=Rect2i(game.ocean.optical_feed.get_global_rect())
	var crop=frame.get_region(rect)
	if not folder.is_empty():
		frame.save_png(folder.path_join(name+"-full.png"));crop.save_png(folder.path_join(name+"-feed.png"))
	return crop.get_data()
func run():
	if DisplayServer.get_name()=="headless":printerr("This regression requires a real Canvas renderer, not headless.");quit(1);return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
	if not folder.is_empty():DirAccess.make_dir_recursive_absolute(folder)
	root.size=Vector2i(1280,720);await process_frame;await process_frame
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="well-render-key-fixture";root.add_child(game);await process_frame
	game._start_mission(4);game.set_process(false)
	# Explicit local camera fixture, not an ordinary travel/win or received-match claim.
	game.sim.units[1].pos=Vector2(800,390);game.sim.units[1].vel=Vector2.ZERO
	game.sim.command("select",{"unit":1});var accepted=game.sim.command("camera");game._refresh()
	check(accepted and game.sim.capture_unit==1 and game.sim.capture_target==0,"real first-record CAMERA accepts the fresh Well text-only objective")
	var before=game.sim.snapshot();var objective=game.sim.mission.objectives[0]
	var fresh=await picture("fresh-well")
	check(game.ocean.optical_feed.visible,"actual main scene displays active first-record camera feed")
	objective.erase("optical");var fallback=await picture("legacy-fallback")
	check(fresh==fallback,"text-only Well key renders the existing complete fallback without an image lookup failure")
	objective["optical"]="unknown_future_record";var unknown=await picture("unknown-key")
	check(unknown==fallback,"unknown illustration key also uses the existing fallback")
	objective.optical="furnace";var known=await picture("known-furnace")
	check(known!=fallback,"known furnace illustration still renders its distinct evidence image")
	objective.optical="well_pattern"
	check(game.sim.snapshot()==before,"rendering and temporary fixture metadata leave camera/simulation state unchanged")
	game.queue_free();await process_frame;await create_timer(.5).timeout
	print("WELL CAMERA RENDER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
