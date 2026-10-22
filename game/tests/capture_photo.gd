extends SceneTree
# Renders the real viewfinder and archive viewer for visual review; never writes saves.
func _initialize() -> void: call_deferred("run")
func put(s,uid,pos,angle):
	s.units[uid].pos=pos;s.units[uid].angle=angle;s.units[uid].vel=Vector2.ZERO
func run_sim(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
	s.paused=true
func run() -> void:
	var stage="viewfinder"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--stage="): stage=arg.get_slice("=",1)
	var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="foundry-evidence"; root.add_child(game)
	var spire=Vector2(1300,300);var facing=2.74
	match stage:
		"viewfinder","exposure","tight":
			game._start_mission(0)
			var s=game.sim;s.sirens=[]
			put(s,0,spire+Vector2.from_angle(facing)*120,facing+0.5)
			game.ocean.sim=s;game.ocean.focus_craft()
			if stage=="tight":s.command("frame",{"mode":"tight","focus":"drill"})
			if stage!="viewfinder":
				s.command("camera");run_sim(s,2.0)
			game._refresh()
		"archive","compare":
			game._start_mission(0)
			var s=game.sim;s.sirens=[]
			put(s,0,spire+Vector2.from_angle(facing)*100,facing+PI)
			s.command("camera");run_sim(s,6.0)
			s.command("frame",{"mode":"tight","focus":"drill"})
			put(s,0,spire+Vector2.from_angle(facing+PI)*100,facing)
			s.command("camera");run_sim(s,6.0)
			put(s,0,spire+Vector2.from_angle(facing+0.5)*200,facing+PI)
			s.command("frame",{"mode":"wide"})
			s.command("camera");run_sim(s,6.0)
			game._retain_evidence()
			game._evidence_gallery(0,-1,stage=="compare")
		"silt":
			game._start_mission(17)
			var s=game.sim;s.sirens=[]
			var target=Vector2(1750,1230)
			put(s,0,target+Vector2(-150,0),0.0);run_sim(s,0.4)
			put(s,0,target+Vector2(-110,0),0.0)
			game.ocean.sim=s;game.ocean.focus_craft()
			s.command("camera");run_sim(s,3.0)
			game._refresh()
		"siren":
			game._start_mission(0)
			var s=game.sim;var guard=s.sirens[0];guard.pos=Vector2(780,560);guard.stun=100.0;guard.angle=0.0
			s.units[1].alive=false;s.units[2].alive=false
			put(s,0,Vector2(900,560),PI);run_sim(s,0.4)
			game.ocean.sim=s;game.ocean.focus_craft()
			s.command("camera");run_sim(s,4.0)
			game._refresh()
	print("PHOTO CAPTURE stage=",stage)
