extends SceneTree
var folder=""
func _initialize():call_deferred("run")
func run():
	folder=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(folder)
	for profile in [{"name":"desktop","size":Vector2i(1280,720),"density":false},{"name":"cover","size":Vector2i(2520,1080),"density":true},{"name":"inner","size":Vector2i(2184,1968),"density":true}]:
		root.size=profile.size;for n in 3:await process_frame
		var game=load("res://scenes/main.tscn").instantiate()
		if profile.density:
			game.set_script(load("res://tests/density_main.gd"));game.fixture_safe_area=Rect2(136,0,2384,1080) if profile.name=="cover" else Rect2(0,0,2184,1968)
		game.capture_scenario="well-context-fixture";root.add_child(game);await process_frame;game._start_mission(4);game.set_process(false)
		game.sim.units[1].pos=Vector2(800,390);game.sim.units[1].vel=Vector2.ZERO;game.sim.command("select",{"unit":1});var accepted=game.sim.command("camera")
		game.sim.paused=false;game.sim.advance(1.2);game.sim.paused=true;game._observation_diagnostics();game._refresh();game._layout()
		for n in 12:await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(folder.path_join(profile.name+".png"))
		var snapshot=game.sim.snapshot();var digest=HashingContext.new();digest.start(HashingContext.HASH_SHA256);digest.update(var_to_bytes(snapshot))
		var record={"profile":profile.name,"fixture":"paused local acquisition; Drone A posed800,390; real SELECT/CAMERA and1.2s physical simulation; no enemy changes or received evidence","camera_accepted":accepted,"simulation_sha256":digest.finish().hex_encode(),"time":game.sim.elapsed,"target":game.sim.capture_target,"unit":game.sim.capture_unit,"progress":game.sim.capture_time,"reference":game.sim.mission.well_reference,"observation":game.sim.mission.well_observation,"metrics":game._ui_metrics()}
		FileAccess.open(folder.path_join(profile.name+".json"),FileAccess.WRITE).store_string(JSON.stringify(record,"\t"));print("CAPTURE ",record)
		if profile.density:
			for id in [1,2]:
				game._start_mission(4);game.sim.units[1].pos=[Vector2(1150,450),Vector2(780,850)][id-1];game.sim.units[1].vel=Vector2.ZERO
				game.sim.command("select",{"unit":1});var starts=game.sim.command("camera");game.sim.paused=false;game.sim.advance(1.2);game.sim.paused=true;game._refresh()
				for n in 6:await process_frame
				await RenderingServer.frame_post_draw
				var name=profile.name+"-site%d"%(id+1)
				root.get_texture().get_image().save_png(folder.path_join(name+".png"))
				FileAccess.open(folder.path_join(name+".json"),FileAccess.WRITE).store_string(JSON.stringify({"camera_accepted":starts,"target":game.sim.capture_target,"time":game.sim.elapsed,"progress":game.sim.capture_time,"metrics":game._ui_metrics()},"\t"))
		game.queue_free();for n in 3:await process_frame
	await create_timer(.5).timeout;quit()
