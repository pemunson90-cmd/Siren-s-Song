extends SceneTree
# Same ordinary-command controller can run against accepted0afe and challenger.
# Explicit solo fallback fixture only for the second-site audible take.
var game
var folder=""
var take="approach"
var commands=[]
var last_emp=-100.0
func _initialize():call_deferred("run")
func order(name,args={}):
	var ok=game.sim.command(name,args);commands.append({"time":game.sim.elapsed,"order":name,"args":str(args),"accepted":ok});return ok
func protect():
	if game.sim.elapsed-last_emp<1:return
	for c in game.sim.contacts.values():
		if game.sim.elapsed-c.time<0.3 and c.lock>1 and c.target==game.sim.selected and game.sim.tools.emp>0:
			order("emp");last_emp=game.sim.elapsed;return
func step(dt=0.1,defend=true):
	game.sim.advance(dt)
	if defend:protect()
func travel(point):
	if not order("route",{"point":point}):return false
	game.sim.paused=false
	for n in 1500:
		step()
		if not game.sim.units[game.sim.selected].alive:return false
		if game.sim.units[game.sim.selected].route.is_empty() and game.sim.units[game.sim.selected].vel.length()<2:return game.sim.units[game.sim.selected].pos.distance_to(point)<25
	return false
func state():
	return {"time":game.sim.elapsed,"selected":game.sim.selected,"own_positions":game.sim.units.map(func(u):return str(u.pos)),"alive":game.sim.units.map(func(u):return u.alive),"hull":game.sim.hull,"tools":game.sim.tools.duplicate(),"records":game.sim.mission.objectives.map(func(o):return o.captured),"context":game.sim.camera_context(),"contacts":game.sim.contacts.duplicate(true),"message":game.sim.message,"outcome":game.sim.outcome,"capture_time":game.sim.capture_time}
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
		if arg.begins_with("--take="):take=arg.trim_prefix("--take=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="blackwater-motion";root.add_child(game)
	await process_frame;await process_frame;game.set_process(false);game._start_mission(2)
	var prepared=true
	if take=="active_reply":
		game.sim.units[1].alive=false;game.sim.units[2].alive=false
		order("select",{"unit":0});prepared=travel(Vector2(760,340)) and order("camera")
		# Identical4.1s command hold on accepted/challenger if reused, despite2s new sample.
		for n in 41:step()
		prepared=prepared and game.sim.mission.objectives[0].captured and travel(Vector2(1360,270))
	else:
		order("select",{"unit":1});order("route",{"point":Vector2(760,390)});game.sim.paused=false
		if take=="idle":
			for n in 1500:
				step()
				if game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2:break
			prepared=order("camera")
			for n in 60:
				step()
				if game.sim.mission.objectives[0].captured or not game.sim.units[1].alive:break
			prepared=prepared and game.sim.mission.objectives[0].captured
	game.sim.paused=false;game._refresh();var initial=state();var samples=[];var start_commands=commands.size();var sampled=false
	for n in 240:
		if take=="approach":
			protect()
			if not sampled and game.sim.units[1].alive and game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2:
				order("camera");sampled=true
		if take=="active_reply":
			if n==15:order("ping")
			if n==16:order("camera")
		# Idle take has zero commands; no protective input after its setup.
		game.sim.advance(1.0/15);game._observation_diagnostics();game._refresh();game.ocean.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		var frame=root.get_texture().get_image();frame.save_png(folder.path_join("%04d.png"%n))
		if n in [0,29,59,104,149,239]:frame.save_png(folder.path_join("full-%03d.png"%n))
		if n%15==0:
			var view=state();view["frame"]=n;samples.append(view);print("PLAYER_VIEW ",view)
	var report={"take":take,"setup_ok":prepared,"solo_fixture":take=="active_reply","initial":initial,"commands":commands,"inputs_during_clip":commands.size()-start_commands,"samples":samples,"final":state(),"frames":240,"fps":15}
	var f=FileAccess.open(folder.path_join("chronology.json"),FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print("CLIP_FINAL ",report)
	game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
