extends SceneTree
# Read-only foreground hook probe. No archive load/save and no forced game poses.
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(2184,1968)
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/resume_metrics_main.gd"));game.capture_scenario="menu"
	game._notification(NOTIFICATION_APPLICATION_RESUMED);game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	root.add_child(game)
	game._start_mission(0)
	for i in 20:await process_frame
	game.resume_snapshots.clear();var before=game.sim.snapshot()
	game._notification(NOTIFICATION_APPLICATION_RESUMED);game._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	for i in 12:await process_frame
	var expected="layout_only" if DisplayServer.get_name()=="headless" else "post_draw"
	var valid=game.resume_snapshots.size()>0 and game.sim.snapshot()==before
	for report in game.resume_snapshots:valid=valid and report.capture_state.phase==expected and report.capture_state.paused and report.capture_state.mission==0
	print("RESUME_TEST reports=",game.resume_snapshots.size()," phase=",expected," display=",DisplayServer.get_name()," drawn=",Engine.get_frames_drawn()," unchanged=",game.sim.snapshot()==before," result=",valid)
	game.queue_free();await process_frame;await create_timer(0.5).timeout;quit(0 if valid else 1)
