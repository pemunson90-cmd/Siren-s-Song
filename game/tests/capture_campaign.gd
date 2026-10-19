extends SceneTree
# Evidence driver: consumes ordinary production commands; no production save writes.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var mission=0; var view="overview"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--mission="): mission=clampi(int(arg.get_slice("=",1)),0,5)
		if arg.begins_with("--view="): view=arg.get_slice("=",1)
	var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="campaign-evidence"; root.add_child(game)
	game.upgrade="disruption"; game._start_mission(mission)
	if view=="brief": game._briefing(mission); return
	if view=="ending":
		game._start_mission(5); var s=game.sim; s.units[1].alive=false; s.units[2].alive=false
		for target in s.mission.objectives:
			var vantage=target.pos+Vector2(0,210)
			if s.blocked(vantage,25): vantage=target.pos+Vector2(-210,0)
			if not preload("res://tests/campaign_scenarios.gd").move(s,vantage): break
			s.command("camera")
			for n in int((target.get("duration",4.0)+0.5)*10): s.advance(0.1)
		preload("res://tests/campaign_scenarios.gd").move(s,s.mission.extraction)
		print("EVIDENCE ENDING outcome=",s.outcome," time=",snappedf(s.elapsed,0.1)," hull=",snappedf(s.hull,0.1))
	else:
		game.sim.command("recon"); game.sim.paused=true
