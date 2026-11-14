extends SceneTree
# WP-54: the six trial rules of 2026-11-13 (trial_rules.gd). Each rule is checked with the rule on and with it
# switched off through the test seam (TrialRules.override); the off checks prove the old behaviour comes back.
const TrialRules=preload("res://src/trial_rules.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const RiderSim=preload("res://src/presentation/career/rider_dive.gd")
const Aids=preload("res://src/presentation/accessibility/tactical_aids.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const Words=preload("res://src/presentation/hud_words.gd")
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
const ExpeditionSession=preload("res://src/presentation/runs/expedition_session.gd")
const CareerSession=preload("res://src/presentation/career/career_session.gd")
const RiderChoice=preload("res://src/presentation/rider_choice.gd")
class Host extends RefCounted:
	var sim=Sim.new()
	var screen="mission"
	var debug_console=null
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
func run():
	var saved=Settings.current.duplicate()
	table_case()
	lock_length_case()
	lock_fire_case()
	lock_pause_case()
	blocked_case()
	rider_case()
	await game_cases()
	TrialRules.reset()
	Settings.current=saved
	print("TRIAL RULES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func table_case():
	TrialRules.reset()
	check(TrialRules.wheel_holds_time() and TrialRules.pause_at_route_end() and TrialRules.pause_on_every_lock() and TrialRules.pause_when_blocked(),"the four on/off trial rules are on by default")
	check(is_equal_approx(TrialRules.first_dive_lock_seconds(),6.0) and is_equal_approx(TrialRules.STANDARD_LOCK_SECONDS,4.0),"the first dive lock is 6 s, the standard 4 s")
	check(not TrialRules.expedition_rider_default_on(),"the Expedition rider starts off by default")
	TrialRules.override("PAUSE_WHEN_BLOCKED",false)
	check(not TrialRules.pause_when_blocked(),"an override changes the answer")
	TrialRules.reset()
	check(TrialRules.pause_when_blocked(),"reset puts the table back")
# Rule 2: the length. Operation 01 of the Campaign only; Expedition, Career and Challenge simulations are subclasses.
func lock_length_case():
	TrialRules.reset()
	var first=Sim.new();first.start(0)
	var second=Sim.new();second.start(1)
	check(is_equal_approx(first.lock_seconds(),6.0),"operation 01 of the Campaign locks for 6 s")
	check(is_equal_approx(second.lock_seconds(),4.0),"operation 02 keeps 4 s")
	var career=RiderSim.new();career.start(0)
	check(is_equal_approx(career.lock_seconds(),4.0),"operation 01 as a Career or Expedition run keeps 4 s")
	TrialRules.override("FIRST_DIVE_LOCK_SECONDS",4.0)
	check(is_equal_approx(first.lock_seconds(),4.0),"switched back, operation 01 locks for 4 s")
	TrialRules.reset()
# A real Siren lock on the first dive: the beam fires at 6 s with the rule on, at 4 s with it off.
func fire_fixture():
	var s=Sim.new();s.start(0);PlayerDive.launch_drones(s)
	s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
	var e=s.sirens[0];e.pos=s.units[0].pos+Vector2(120,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.stun=0.0;e.band=s.units[0].band;e.patrol_points=[]
	s.sirens=[e]
	for id in [1,2]:s.units[id].alive=false
	s.paused=false
	return s
func lock_fire_case():
	TrialRules.reset()
	var s=fire_fixture();run_for(s,5.0)
	check(s.outcome.is_empty() and s.sirens[0].lock>4.0 and s.sirens[0].mode=="LOCKING","first dive: after 5 s the lock is still building")
	run_for(s,1.5)
	check(s.outcome=="lost","first dive: the lock fires by 6 s")
	# A dive saved in the middle of a lock keeps working.
	var mid=fire_fixture();run_for(mid,3.0)
	var snapshot=mid.snapshot()
	var restored=Sim.new()
	check(Sim.valid_snapshot(snapshot) and restored.restore(snapshot),"a dive saved mid-lock restores")
	restored.paused=false;run_for(restored,1.0)
	check(restored.outcome.is_empty() and restored.sirens[0].lock>=3.9,"the restored dive keeps its lock")
	run_for(restored,3.0)
	check(restored.outcome=="lost","the restored dive's lock fires on schedule")
	TrialRules.override("FIRST_DIVE_LOCK_SECONDS",4.0)
	var old=fire_fixture();run_for(old,4.5)
	check(old.outcome=="lost","rule off: the first dive's lock fires at 4 s as before")
	TrialRules.reset()
# Sim.advance caps one call at 0.25 s: step in tenths.
func run_for(s,seconds:float)->void:
	for n in roundi(seconds*10.0):s.advance(0.1)
# Rule 4: a new lock pauses once, whatever the accessibility setting says.
func locking_host():
	var host=Host.new();host.sim.start(0);PlayerDive.launch_drones(host.sim)
	var sim=host.sim;var aid=Aids.new();aid.bind(host)
	sim.elapsed=10.;sim.mission.structures=[];sim.mission.depth_geometry={}
	sim.sirens[0].target=1
	sim.contacts={0:{"pos":sim.units[1].pos+Vector2(60,0),"time":10.,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
	sim.paused=false
	return [host,aid]
func lock_pause_case():
	Settings.apply(Store.sanitize({}))
	TrialRules.reset()
	var pair=locking_host();var host=pair[0];var aid=pair[1];var sim=host.sim
	aid.observe()
	check(sim.paused,"rule 4 on: a new lock pauses the game with the accessibility setting off")
	check(aid.auto_pause.line(sim)==Words.TEXT.paused_lock and sim.message=="AUTO PAUSE: LOCK WARNING","the reason line reads PAUSED: a Siren is locking on")
	sim.paused=false;aid.auto_pause.clear()
	for n in 5:sim.elapsed+=.1;sim.contacts[0].time=sim.elapsed;aid.observe()
	check(not sim.paused,"resuming does not pause again for the same lock")
	# Critic 13 Nov: the same lock re-paused at each fresh report after a quiet gap longer than LOCK_CLEAR_SECONDS.
	for n in 25:sim.elapsed+=.1;aid.observe()
	sim.contacts[0].time=sim.elapsed;sim.contacts[0].lock=2.6;aid.observe()
	check(not sim.paused,"a lock still rising after a quiet gap between reports is the same lock: no second pause")
	sim.contacts[0].lock=.1
	sim.contacts.clear();aid.observe();sim.elapsed+=Aids.LOCK_CLEAR_SECONDS+.01
	sim.contacts={0:{"pos":sim.units[1].pos+Vector2(60,0),"time":sim.elapsed,"mode":"LOCKING","lock":.1,"target":1,"band":sim.units[1].band}}
	aid.observe()
	check(sim.paused,"a lock that starts after the last one ended pauses again")
	sim.paused=false;sim.contacts[0].target=0;sim.contacts[0].pos=sim.units[0].pos+Vector2(60,0);sim.contacts[0].band=sim.units[0].band
	aid.observe()
	check(sim.paused,"a lock on another craft is a new lock")
	# Off: with the rule off the accessibility setting alone decides.
	TrialRules.override("PAUSE_ON_EVERY_LOCK",false)
	pair=locking_host();host=pair[0];aid=pair[1];sim=host.sim
	aid.observe()
	check(not sim.paused,"rule 4 off, setting off: a new lock does not pause")
	Settings.apply(Store.sanitize({"auto_pause_lock":true}))
	pair=locking_host();host=pair[0];aid=pair[1];sim=host.sim
	aid.observe()
	check(sim.paused and sim.message=="AUTO PAUSE: LOCK WARNING","rule 4 off, setting on: the accessibility pause still works")
	TrialRules.reset()
	Settings.apply(Store.sanitize({}))
# Rule 5: a craft held by rock pauses once for that hold.
func blocked_case():
	Settings.apply(Store.sanitize({}))
	TrialRules.reset()
	var host=Host.new();host.sim.start(0);var sim=host.sim;var aid=Aids.new();aid.bind(host)
	sim.paused=false
	aid.observe()
	check(not sim.paused,"nothing held: no pause")
	sim.units[0]["edge_hold"]="Rock ahead blocks this leg";sim.units[0].hold="HOLD"
	aid.observe()
	check(sim.paused and aid.auto_pause.line(sim)=="PAUSED: rock blocks QUIETUS's route","rule 5 on: a rock hold pauses with its reason: "+aid.auto_pause.line(sim))
	sim.paused=false;aid.auto_pause.clear();aid.observe();aid.observe()
	check(not sim.paused,"the same hold does not pause again after the player resumes")
	sim.units[0].erase("edge_hold");aid.observe()
	sim.units[0]["edge_hold"]="No way along this rock";aid.observe()
	check(sim.paused,"a new hold, after the old one ended, pauses again")
	TrialRules.override("PAUSE_WHEN_BLOCKED",false)
	var other=Host.new();other.sim.start(0);other.sim.paused=false;var next=Aids.new();next.bind(other)
	other.sim.units[0]["edge_hold"]="Rock ahead blocks this leg"
	next.observe()
	check(not other.sim.paused,"rule 5 off: a rock hold does not pause")
	TrialRules.reset()
# Rule 6: the Expedition rider. Career has its own variable and keeps its default.
func rider_case():
	TrialRules.reset()
	var expedition=ExpeditionSession.new()
	check(expedition.accept_rider==false,"rule 6 on: an Expedition's rider starts off")
	RiderChoice.toggle(expedition,func():pass)
	check(expedition.accept_rider==true,"the player can still switch the rider on")
	expedition.free()
	TrialRules.override("EXPEDITION_RIDER_DEFAULT_ON",true)
	var old=ExpeditionSession.new()
	check(old.accept_rider==true,"rule 6 off: an Expedition's rider starts on as before")
	old.free()
	TrialRules.reset()
	var career=CareerSession.new()
	check(career.accept_rider==true,"Naval Career's rider default is unchanged")
	career.free()
# Rules 1 and 3 through the real game: the wheel holds time; a finished route pauses.
func make_game():
	root.size=Vector2i(1280,720);await process_frame
	var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(0);await settle()
	game.sim.sirens=[]
	if game.mission_hud.hints.panel.visible:game.mission_hud.hints.dismiss()
	game.sim.paused=false
	return game
func game_cases():
	Settings.apply(Store.sanitize({}))
	TrialRules.reset()
	var game=await make_game();var sim=game.sim
	# Rule 1 on.
	var before:float=sim.elapsed
	game._process(0.5)
	check(sim.elapsed>before,"time runs with no menu open")
	game.mission_hud.open("craft");game._refresh()
	before=sim.elapsed
	game._process(0.5);game._process(0.5)
	check(is_equal_approx(sim.elapsed,before) and not sim.paused,"rule 1 on: an open wheel holds dive time and leaves sim.paused alone")
	# Critic 13 Nov: the plate read PAUSED while only the wheel held time, so closing the wheel "unpaused" the dive.
	check(Words.pause_reason(game)==Words.TEXT.held_menu and game.pause_button.text.contains(Words.TEXT.held),"the plate reads HELD, not PAUSED, while only a menu holds time: "+game.pause_button.text)
	game.mission_hud.dismiss();game._refresh()
	game._process(0.5)
	check(sim.elapsed>before and not sim.paused and Words.pause_reason(game)=="","closing the menu lets time run again")
	# The player's own pause stays the player's.
	game.mission_hud.open("craft");game._pause();game.mission_hud.dismiss();game._refresh()
	check(sim.paused,"a pause the player made stays after the menu closes")
	check(game.pause_button.text.begins_with(Words.TEXT.act_run) and not game.pause_button.text.contains(Words.TEXT.held),"a dive the player paused offers RUN, not HELD: "+game.pause_button.text)
	game._pause()
	# An automatic pause (a new lock, a route's end) stays when the wheel is opened and closed over it.
	game.request_auto_pause("lock");game.mission_hud.open("craft");game._refresh()
	check(game.pause_button.text.begins_with(Words.TEXT.act_run) and not game.pause_button.text.contains(Words.TEXT.held),"the wheel over an automatic pause still offers RUN, not HELD: "+game.pause_button.text)
	game.mission_hud.dismiss();game._refresh();before=sim.elapsed;game._process(0.5)
	check(sim.paused and is_equal_approx(sim.elapsed,before),"closing the wheel does not release an automatic pause")
	game._pause()
	# Rule 1 off.
	TrialRules.override("WHEEL_HOLDS_TIME",false)
	game.mission_hud.open("craft");game._refresh()
	before=sim.elapsed;game._process(0.5)
	check(sim.elapsed>before,"rule 1 off: an open wheel no longer holds time")
	game.mission_hud.dismiss();game._refresh()
	TrialRules.reset()
	# Rule 3 on: a craft that reaches the end of its route pauses the game.
	sim.paused=true;sim.command("select",{"unit":0});sim.command("route",{"point":sim.units[0].pos+Vector2(60,0)});sim.paused=false;game._refresh()
	var frames=0
	while not sim.paused and frames<400:game._process(0.1);frames+=1
	check(sim.paused and sim.units[0].route.is_empty(),"rule 3 on: the finished route paused the game")
	check(Words.pause_reason(game)=="PAUSED: QUIETUS finished its route","the reason line names the craft: "+Words.pause_reason(game))
	check("QUIETUS has stopped: its route is finished." in game.mission_hud.intent.text,"the status line keeps the route-end line: "+game.mission_hud.intent.text)
	game._pause();game._refresh()
	for n in 10:game._process(0.1)
	check(not sim.paused,"resuming does not pause again")
	# ALL STOP and a recall are not route ends: only a route that ran out pauses.
	# Rule 3 off.
	TrialRules.override("PAUSE_AT_ROUTE_END",false)
	sim.paused=true;sim.command("route",{"point":sim.units[0].pos+Vector2(60,0)});sim.paused=false;game._refresh()
	frames=0
	while not sim.units[0].route.is_empty() and frames<400:game._process(0.1);frames+=1
	for n in 5:game._process(0.1)
	check(sim.units[0].route.is_empty() and not sim.paused,"rule 3 off: the finished route does not pause")
	TrialRules.reset()
	game.queue_free();await settle()
