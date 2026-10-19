extends SceneTree
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;print("FAIL ",label)
	else:print("PASS ",label)
func run():
	root.size=Vector2i(1280,720);await process_frame;await process_frame
	var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="well-ui-rules";root.add_child(game);await process_frame;game._start_mission(4)
	# Rule fixture for retained-record boundaries; no optical image is granted.
	game.sim.mission.objectives[0].captured=true;game._retain_evidence()
	check(game.recovered_evidence.has("well_pattern"),"first earned record appears in actual campaign evidence")
	game._order("hold");game._refresh();check("UNVERIFIED" in game.log_label.text,"known unverified comparison persists after another log message")
	var store=Store.new();store.path="user://well-ui-tests.archive"
	check(store.valid(game._archive()),"existing archive accepts the two explicitly whitelisted Well record types")
	check(game.has_method("_evidence_is_text"),"gallery distinguishes acoustic text evidence from optical image access")
	if game.has_method("_evidence_is_text"):
		check(game._evidence_is_text(game.recovered_evidence.well_pattern) and not game._evidence_is_text({"optical":"furnace"}),"Well pattern uses text while earlier optical evidence keeps its image")
		game._evidence_gallery(0);await process_frame
		var labels=game.panel_box.get_children().filter(func(c):return c is Label).map(func(c):return c.text)
		check(labels.any(func(v):return "ACOUSTIC" in v) and not game.panel_box.get_children().any(func(c):return c is TextureRect),"unassigned record is visibly labeled acoustic and supplies no unearned image")
	game._enter_water();game.sim.units[0].pos=Vector2(1190,450);game.sim.units[0].vel=Vector2(65,0);game.sim.units[0].silent=false;game.sim.units[2].pos=Vector2(780,850)
	for enemy in game.sim.sirens:enemy.stun=100
	game.sim.paused=false;game.sim.advance(1.0/60);game._observation_diagnostics()
	game._order("select",{"unit":1});game._refresh();check("MATCH RECORDED" in game.log_label.text,"observed match stays player-visible after later commands replace the event log")
	check(game.recovered_evidence.has("well_signature"),"actual observed comparison is retained without requiring another optical capture")
	check(store.save(game._archive()) and store.load_game()==game._archive(),"comparison and reference round-trip through real archive bytes")
	for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
	game.sim.outcome="won";game._debrief();await process_frame
	check(game.panel_box.get_children().any(func(c):return c is Button and c.text=="REVIEW RECOVERED RECORDS"),"earned Well debrief names retained acoustic records truthfully")
	game._start_mission(4);check(game.sim.mission.well_reference.is_empty() and game.sim.mission.well_observation.is_empty(),"retained archive does not auto-confirm a retry's new active mission")
	game.queue_free();await process_frame;await create_timer(.5).timeout
	print("WELL UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
