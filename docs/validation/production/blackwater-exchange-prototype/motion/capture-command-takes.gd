extends SceneTree
var game
var folder=""
var mode="cycle"
var take="quiet_reply"
var last_emp=-100.0
var command_log=[]
func _initialize():call_deferred("run")
func order(name,args={}):
	var accepted=game.sim.command(name,args)
	command_log.append({"time":game.sim.elapsed,"order":name,"args":str(args),"accepted":accepted})
	return accepted
func protect():
	if game.sim.elapsed-last_emp<1:return
	for c in game.sim.contacts.values():
		if game.sim.elapsed-c.time<0.3 and c.lock>1 and c.target==game.sim.selected and game.sim.tools.emp>0:
			order("emp");last_emp=game.sim.elapsed;return
func step(dt=0.1,defend=true):
	game.sim.advance(dt)
	if defend:protect()
func travel(point):
	order("route",{"point":point});game.sim.paused=false
	for n in 1500:
		step()
		if not game.sim.units[game.sim.selected].alive or not game.sim.outcome.is_empty():return false
		if game.sim.units[game.sim.selected].route.is_empty() and game.sim.units[game.sim.selected].vel.length()<2:return game.sim.units[game.sim.selected].pos.distance_to(point)<25
	return false
func sample(id,active=false):
	if active:order("ping")
	if not order("camera"):return false
	for n in 125:
		step()
		if game.sim.mission.objectives[id].captured:return true
		if not game.sim.units[game.sim.selected].alive:return false
	return false
func state():
	return {"time":game.sim.elapsed,"own_pos":str(game.sim.units[game.sim.selected].pos),"hull":game.sim.hull,"tools":game.sim.tools.duplicate(),"records":game.sim.mission.objectives.map(func(o):return o.captured),"context":game.sim.camera_context(),"contacts":game.sim.contacts.duplicate(true),"message":game.sim.message,"outcome":game.sim.outcome}
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
		if arg.begins_with("--exchange-mode="):mode=arg.trim_prefix("--exchange-mode=")
		if arg.begins_with("--take="):take=arg.trim_prefix("--take=")
	DirAccess.make_dir_recursive_absolute(folder)
	game=load("res://proto/main.tscn").instantiate();root.add_child(game)
	await process_frame;await process_frame;game.set_process(false);game._start_mission(2)
	var active=take=="active_reply"
	# Explicit SOLO FALLBACK fixture, not earned drone deaths or a played campaign.
	game.sim.units[1].alive=false;game.sim.units[2].alive=false
	order("select",{"unit":0})
	var prepared=travel(Vector2(760,340)) and sample(0,false)
	var planned_wait=-1.0
	if prepared and take in ["planned_reply","planned_approach"]:
		prepared=travel(Vector2(1090,230))
		var info=game.sim.exchange_context(1);var eta=game.sim.units[0].pos.distance_to(Vector2(1360,340))/42.0+1.0
		var phase=fposmod(game.sim.elapsed+eta-5,10)
		var wait=10-phase if phase>2 else 0.0
		command_log.append({"earned_prediction":info,"time":game.sim.elapsed,"charted_stage":str(game.sim.units[0].pos),"own_eta":eta,"wait":wait})
		if take=="planned_approach":planned_wait=ceil(wait*10)/10
		else:
			for n in int(ceil(wait*10)):step()
	if prepared and take!="planned_approach":prepared=travel(Vector2(1360,270 if active else 340))
	if not active and take!="planned_approach":order("camera")
	game.sim.paused=false;game._refresh()
	var initial=state();var samples=[]
	print("CLIP_START mode=",mode," take=",take," prepared=",prepared," initial=",initial," commands=",command_log," noinput=",not active and take!="planned_approach")
	var clip_start=game.sim.elapsed;var route_sent=false;var sample_sent=false;var command_start=command_log.size()
	for n in 240:
		if active:
			if n==15:order("ping")
			if n==16:order("camera")
		if take=="planned_approach":
			if not route_sent and game.sim.elapsed-clip_start>=planned_wait:
				order("route",{"point":Vector2(1360,340)});route_sent=true
			if route_sent and not sample_sent and game.sim.units[0].route.is_empty() and game.sim.units[0].vel.length()<2:
				order("camera");sample_sent=true
		# No protective actions or hidden-state-driven inputs during the clip.
		game.sim.advance(1.0/15);game._refresh();game.ocean.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		var frame=root.get_texture().get_image()
		if n in [0,29,59,104,149,239]:frame.save_png(folder.path_join("full-%03d.png"%n))
		frame.save_png(folder.path_join("%04d.png"%n))
		if n%15==0:
			var view=state();view["frame"]=n;samples.append(view);print("OBSERVED ",view)
	var out={"mode":mode,"take":take,"setup_ok":prepared,"solo_fixture":true,"commands":command_log,"initial":initial,"samples":samples,"final":state(),"fps":15,"frames":240,"inputs_during_clip":command_log.size()-command_start}
	var file=FileAccess.open(folder.path_join("chronology.json"),FileAccess.WRITE);file.store_string(JSON.stringify(out,"  "));file.close()
	print("CLIP_END ",state())
	game.queue_free();await process_frame;quit()
