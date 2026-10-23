extends SceneTree
# Compare the retained pre-PHOTO1 illustration path with legacy-shaped records,
# then verify the current photographic view separately at a fixed display clock.
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
	var feed=game.ocean.optical_feed
	feed.set_process(false);feed.time=0.0;feed._vm_age=1.0
	game.ocean.queue_redraw();feed.queue_redraw()
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
	for site in game.sim.mission.objectives:site.erase("subject")
	check(preload("res://src/simulation/simulation.gd").valid_snapshot(game.sim.snapshot()),"compatibility renderer fixture is a valid legacy-shaped snapshot")
	# Explicit local camera fixture, not an ordinary travel/win or received-match claim.
	game.sim.units[1].pos=Vector2(800,390);game.sim.units[1].vel=Vector2.ZERO
	game.sim.command("select",{"unit":1});var accepted=game.sim.command("camera");game._refresh()
	check(accepted and game.sim.capture_unit==1 and game.sim.capture_target==0,"real CAMERA accepts the legacy-shaped Well text-only objective")
	var before=game.sim.snapshot();var objective=game.sim.mission.objectives[0]
	var fresh=await picture("fresh-well")
	check(game.ocean.optical_feed.visible,"actual main scene displays active first-record camera feed")
	var revision=game.sim.mission.well_revision;game.sim.mission.erase("well_revision")
	objective.erase("optical");var fallback=await picture("legacy-fallback")
	game.sim.mission.well_revision=revision
	check(fresh!=fallback,"fresh Well first-record feed gives site-specific context instead of the generic foundry fallback")
	objective["optical"]="unknown_future_record";var unknown=await picture("unknown-key")
	check(unknown==fallback,"unknown illustration key also uses the existing fallback")
	objective.optical="furnace";var known=await picture("known-furnace")
	check(known!=fallback,"known furnace illustration still renders its distinct evidence image")
	objective.optical="well_pattern"
	game.sim.mission.erase("well_revision")
	var legacy=await picture("legacy-well-key")
	check(legacy==fallback,"legacy Well key without revision preserves existing camera fallback")
	game.sim.mission.well_revision=revision
	var enemies=game.sim.sirens.duplicate(true)
	for enemy in game.sim.sirens:enemy.pos=Vector2(1500,900);enemy.mode="ENGAGE"
	var hidden=await picture("hidden-enemies")
	check(hidden==fresh,"site context does not disclose hidden Siren state")
	game.sim.sirens=enemies
	check(game.sim.snapshot()==before,"rendering and temporary fixture metadata leave camera/simulation state unchanged")
	for id in [1,2]:
		game._start_mission(4)
		game.sim.units[1].pos=[Vector2(1150,450),Vector2(780,850)][id-1];game.sim.units[1].vel=Vector2.ZERO
		game.sim.command("select",{"unit":1});var starts=game.sim.command("camera");game._refresh()
		var site=await picture("well-site-%d"%id)
		game.sim.mission.erase("well_revision")
		game.sim.mission.objectives[id].erase("subject");game.sim.mission.objectives[id].erase("optical")
		var old=await picture("legacy-site-%d"%id)
		check(starts and game.sim.capture_target==id and site!=old,"fresh Well site%d uses its own acquisition context while legacy keeps fallback"%id)
	# Current PHOTO1 records retain their subject and render the live scene.
	game._start_mission(4);game.sim.units[1].pos=Vector2(800,390);game.sim.units[1].vel=Vector2.ZERO
	game.sim.command("select",{"unit":1});var live=game.sim.command("camera");game._refresh()
	check(live and not game.ocean.optical_feed.subject_view().is_empty(),"current Well record uses the actual photographic view")
	var live_before=game.sim.snapshot();var live_picture=await picture("current-photo")
	var live_enemies=game.sim.sirens.duplicate(true)
	for enemy in game.sim.sirens:enemy.pos=Vector2(1500,900);enemy.mode="ENGAGE"
	check(await picture("current-photo-hidden-enemies")==live_picture,"fixed-time current photograph does not disclose hidden Siren state")
	game.sim.sirens=live_enemies
	check(game.sim.snapshot()==live_before,"current photo rendering preserves the complete simulation")
	game.queue_free();await process_frame;await create_timer(.5).timeout
	print("WELL CAMERA RENDER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
