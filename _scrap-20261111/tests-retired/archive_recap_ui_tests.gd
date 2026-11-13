extends SceneTree
const Fixtures=preload("res://tests/archive_recap_fixtures.gd")
const Recap=preload("res://src/campaign/archive_recap.gd")
var checks=0
var failures=0
var game
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;print("FAIL ",label)
	else:print("PASS ",label)
func settle():
	for n in 3:await process_frame
func labels():return game.panel_box.get_children().filter(func(c):return c is Label).map(func(c):return c.text)
func run():
	root.size=Vector2i(1280,720);await settle()
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="archive-recap-ui-fixture";root.add_child(game);await settle()
	Fixtures.apply(game,true);var before=var_to_bytes(game.recovered_evidence);game._debrief();await settle()
	check(labels().any(func(t):return t.begins_with("YOUR FIELD RECORD") and "ACROSS DIVES" in t),"final success labels the field record as retained across dives")
	check(Recap.summary(game.recovered_evidence) in labels(),"actual final debrief displays the earned-key summary")
	check(var_to_bytes(game.recovered_evidence)==before,"debrief recap does not alter retained archive entries")
	check(labels().any(func(t):return t.begins_with("THE SONG CONTINUES") and "Two bearings. People at both" in t and "Introductory arc complete. Every dive remains replayable." in t),"current finale presents the two-bearing continuation and replay ending")
	Fixtures.apply(game,false);game._debrief();await settle()
	check(Recap.summary(game.recovered_evidence) in labels() and not "Well" in Recap.summary(game.recovered_evidence),"minimal final archive gets no fabricated prior chapter or Well match")
	game._start_mission(5);game.recovered_evidence={};game.sim.mission.erase("finale_revision")
	for objective in game.sim.mission.objectives:objective.erase("optical")
	game.sim.outcome="won";game._debrief();await settle()
	check("No chapter records are retained." in labels(),"legacy finale without evidence displays an honest empty archive")
	game._start_mission(4);game.sim.outcome="won";game._debrief();await settle()
	check(not labels().any(func(t):return t.begins_with("YOUR FIELD RECORD")),"ordinary chapter debrief stays unchanged")
	game._start_mission(5);game.sim.outcome="lost";game._debrief();await settle()
	check(not labels().any(func(t):return t.begins_with("YOUR FIELD RECORD")),"final loss does not fabricate a successful-dive recap")
	game.queue_free();await process_frame;await create_timer(.5).timeout
	print("ARCHIVE RECAP UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
