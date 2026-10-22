extends SceneTree
# Tutorial auto-pause: in operations 1 to 3 only, the first Siren warning pauses the game once,
# shows a GOT IT prompt, and is remembered in the saved hint flags. UI flow only.
var failures:=0
var checks:=0
var game
func check(value: bool,label: String) -> void:
	checks+=1
	if not value: failures+=1; printerr("FAIL: ",label)
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for n in 4: await process_frame
# A real Siren lock: a patroller in clear water within sight of silent Quietus, run for half a second.
func lock_on() -> void:
	var s=game.sim
	s.mission.rocks=[]; s.mission.structures=[]; s._build_navigation(); s._configure_terrain(); s._configure_depth_charts()
	var e=s.sirens[0]; e.pos=s.units[0].pos+Vector2(120,0); e.home=e.pos; e.goal=e.pos; e.route=[]; e.stun=0.0; e.band=s.units[0].band
	e.patrol_points=[]
	s.sirens=[e]
	for id in [1,2]: s.units[id].alive=false
	s.paused=false; s.advance(0.5)
	game._refresh()
func start(op: int) -> void:
	game.hints_seen=[]; game._start_mission(op); await settle()
	game.sim.paused=false
func run() -> void:
	root.size=Vector2i(1280,720); await process_frame; await process_frame
	game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="runtime-test"; root.add_child(game)
	await settle()
	var Text=preload("res://src/campaign/onboarding_text.gd")
	check(Text.applies("warning",1) and Text.applies("warning",3) and not Text.applies("warning",0) and not Text.applies("warning",4),"the warning prompt is limited to operations 1 to 3")
	check(Text.valid_seen(["warning"]) and Text.valid_seen(["move","sweep","warning"]),"the saved flag list accepts the warning flag")
	# Operation 1: the first lock warning pauses once.
	await start(1)
	var hints=game.mission_hud.hints
	hints.current=""; hints.panel.hide(); game.hints_seen=["move","pause","drone","noise"]
	check(not game.sim.paused,"play is running before any warning")
	lock_on(); await settle()
	check(game.sim.sirens[0].lock>0.0,"a real Siren lock is building")
	check(hints.current=="warning" and hints.panel.visible and game.sim.paused,"the first lock warning pauses the game and shows the prompt")
	check("warning" in game.hints_seen,"the shown prompt is recorded in the saved hint flags")
	check(game.pause_button.text.begins_with("PAUSED"),"the pause control reads paused")
	check(hints.dismiss_button.text=="GOT IT" and hints.dismiss_button.visible,"the prompt offers GOT IT")
	var snapshot=game._archive_data() if game.has_method("_archive_data") else {}
	# Unpausing stays one tap, and the prompt does not pause again.
	game._pause(); await settle()
	check(not game.sim.paused,"one tap on the pause control resumes play")
	for n in 6: game.sim.advance(0.1); game._refresh(); await settle()
	check(not game.sim.paused,"the warning never pauses a second time")
	hints.dismiss(); await settle()
	check(not hints.panel.visible and hints.current=="","GOT IT hides the prompt")
	# Never again in the campaign: a later operation with a fresh lock keeps running.
	var kept=game.hints_seen.duplicate()
	game._start_mission(2); await settle(); game.sim.paused=false
	lock_on(); await settle()
	check(not game.sim.paused and hints.current!="warning" and game.hints_seen.count("warning")==1 and kept.has("warning"),"a later warning in the same campaign does not pause")
	# Outside operations 1 to 3 the prompt never fires.
	for op in [0,4]:
		await start(op)
		game.hints_seen=["move","pause","drone","noise","sweep"]
		lock_on(); await settle()
		check(not game.sim.paused and hints.current!="warning" and not ("warning" in game.hints_seen),"operation %d never auto-pauses on a warning"%op)
	# A heard-investigation cue counts as a warning too, in operation 3.
	await start(3)
	game.hints_seen=["move","pause","drone","noise"]
	var s=game.sim; s.sirens=s.sirens.slice(0,1); s.sirens[0].pos=Vector2(2000,2000)
	s.sonar.history.append({"station":0,"enemy":0,"origin":s.units[0].pos,"direction":Vector2.UP,"time":s.elapsed,"band":-1,"confidence":.6,"tone":300.0,"classification":"SWEEPER INVESTIGATING","direct":true,"kind":"bearing"})
	game._refresh(); await settle()
	check(hints.current=="warning" and game.sim.paused and "warning" in game.hints_seen,"a heard sweeper investigation also triggers the one-time pause")
	print("SIREN WARNING PAUSE CHECKS ",checks," FAILURES ",failures)
	game.queue_free(); await process_frame
	quit(1 if failures>0 else 0)
