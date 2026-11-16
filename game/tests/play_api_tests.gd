extends SceneTree
# WP-123 (Pat, 14 Nov: "a direct controller for the workers or critics ... they should be able to drive headlessly").
# The proof: Campaign operation 01 played to a recovered result through the play API only (state, order, run), with no
# pixel tap and no debug command, plus the guards that make the API honest: state never names an unreceived Siren,
# `truth` is debug-only and marked, an order does only what a player can, a refusal carries the game's own words.
const Api=preload("res://src/play_api/play_api.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
func make():
	var game=load("res://scenes/main.tscn").instantiate()
	game.store.path="user://wp123-%d.save"%Time.get_ticks_usec()
	root.add_child(game);await settle()
	return game
# Every number the player's contact list may hold: only Sirens it has received appear in state.
func no_hidden_sirens(game,s:Dictionary,label:String):
	var text:=JSON.stringify(s)
	check(not s.has("truth") and not text.contains("TESTING ONLY"),label+": no truth block without the flag")
	var received:Array=s.contacts.map(func(c):return int(c.id))
	for id in received:check(game.sim.contacts.has(id),label+": a listed contact is a received contact")
	for i in game.sim.sirens.size():
		if i in received:continue
		var p:Vector2=game.sim.sirens[i].pos
		check(not text.contains("[%s,%s]"%[snappedf(p.x,0.1),snappedf(p.y,0.1)]),label+": an unreceived Siren's position is not in state")
		check(not text.contains("\"S%d "%(i+1)) and not text.contains("S%d PATROLLER"%(i+1)),label+": an unreceived Siren is not named")
# Answers a tip card the way a player would (GOT IT), whatever is open.
var emps_used:=0
func answer_tips(game,state:Dictionary)->Dictionary:
	for p in state.prompts:
		if p.kind=="tip":
			var r=await Api.order(game,{"order":"answer","button":"GOT IT"})
			check(r.ok,"GOT IT answers an open tip card")
			state=Api.state(game)
	# A tester plays what it reads: a lock warning on Quietus is answered with an EMP pulse (the player's own tool), then the dive goes on.
	if not state.locks.is_empty() and state.tools.left.get("emp",0)>0:
		var r=await Api.order(game,{"order":"tool","tool":"emp","craft":"QUIETUS"})
		if r.ok:emps_used+=1
		state=Api.state(game)
	return state
func run():
	var game=await make()
	# --- the title and the menus: text and buttons, no pixels ---
	var s0:=Api.state(game)
	check(s0.screen=="menu" and s0.has("text") and s0.prompts.size()==1,"before a dive the state names the screen and its buttons")
	check(s0.prompts[0].buttons.size()>0,"the title offers buttons by label")
	var refused=await Api.order(game,{"order":"route","points":[[300,300]]})
	check(not refused.ok and str(refused.refusal).contains("No dive"),"a dive order with no dive running is refused in words")
	var locked=await Api.order(game,{"order":"start","operation":3})
	check(not locked.ok and str(locked.refusal).contains("locked"),"an operation that is not unlocked cannot be started")
	# --- start operation 01 as the screens do ---
	var started=await Api.order(game,{"order":"start","operation":1})
	check(started.ok and game.screen=="mission" and game.sim.paused,"start opens operation 01 paused, as ENTER WATER does")
	var s1:=Api.state(game)
	check(s1.screen=="mission" and s1.operation.number==1 and s1.time.state=="paused","state: mission screen, operation 01, paused")
	check(s1.crafts.size()==3 and s1.crafts[0].name=="QUIETUS" and s1.crafts[1].aboard and s1.crafts[2].aboard,"state: three craft, the drones aboard")
	check(s1.has("oxygen") and s1.has("hull") and s1.oxygen.seconds_left>0 and s1.has("extraction") and s1.has("tools") and s1.has("hunt") and s1.has("strip"),"state carries oxygen, hull, extraction, tools, Hunt and the strip")
	check(s1.objectives.size()==1 and s1.objectives[0].has("search_radius") and s1.objectives[0].label.begins_with("UNKNOWN"),"state: the objective is a search area with its radius, named as the chart names it")
	check(s1.contacts.is_empty() and game.sim.sirens.size()>0,"no Siren is listed before any is received")
	no_hidden_sirens(game,s1,"at start")
	# truth is an opt-in for debug builds, clearly marked
	var truth:=Api.state(game,{"truth":true})
	if OS.is_debug_build():
		check(truth.has("truth") and str(truth.truth.WARNING).contains("TESTING ONLY") and truth.truth.sirens.size()==game.sim.sirens.size(),"truth:true in a debug build adds the marked real Siren list")
	else:
		check(not truth.has("truth") and truth.has("truth_refused"),"truth:true in a release build is refused")
	# --- orders refuse in the game's own words ---
	var early_photo=await Api.order(game,{"order":"photo"})
	check(not early_photo.ok and str(early_photo.refusal).contains("Search the dashed area"),"photo with no subject in reach is refused with the camera's own words")
	var depth_same=await Api.order(game,{"order":"depth","band":"middle"})
	check(not depth_same.ok and str(depth_same.refusal).contains("adjacent band"),"depth to the band it is already in is refused in the game's words (one band at a time, no instant dive)")
	var bad_craft=await Api.order(game,{"order":"route","craft":"NOBODY","points":[[300,300]]})
	check(not bad_craft.ok,"an unknown craft is refused")
	# --- WP-136: the chart, route_check, a drone still aboard, the flash report (the torpedo target is in play_api_modes_tests) ---
	check(s1.has("chart") and s1.chart.kind in ["opening","earned"],"state carries the chart the player can see")
	if s1.chart.kind=="opening":
		check(s1.chart.rock is Array and not s1.chart.rock.is_empty() and s1.chart.rock[0] is Array and s1.chart.rock[0][0].size()==2,"opening chart lists the briefed rock as polygons in chart metres")
	var q0:Vector2=game.sim.units[0].pos
	var rock_edge:Array=s1.chart.rock[0][0] if s1.chart.kind=="opening" else [q0.x,q0.y]
	var legs_before:int=game.sim.route_goals(0).size()
	var rc=await Api.order(game,{"order":"route_check","craft":"QUIETUS","points":[[q0.x+30,q0.y],[rock_edge[0],rock_edge[1]]]})
	check(rc.ok and rc.legs.size()==2 and rc.has("crosses_charted_rock") and rc.legs[0].has("crosses_charted_rock"),"route_check answers per leg whether it crosses charted rock")
	check(game.sim.route_goals(0).size()==legs_before and game.sim.units[0].pos==q0,"route_check plots nothing and moves nothing")
	var clear_leg=await Api.order(game,{"order":"route_check","points":[[q0.x+20,q0.y]]})
	check(clear_leg.ok and not clear_leg.crosses_charted_rock,"a short leg in open water reads clear")
	var aboard_route=await Api.order(game,{"order":"route","craft":"DRONE A","points":[[q0.x+60,q0.y]]})
	check(not aboard_route.ok and str(aboard_route.refusal).contains("deploy it first") and game.sim.DroneBay.aboard(game.sim.units[1]),"a route for a drone still aboard is refused and does not launch it")
	# WP-162: with drone A in the water and selected, `deploy` launches drone B (still aboard) instead of refusing.
	var dep_a=await Api.order(game,{"order":"deploy","craft":"DRONE A"})
	var dep_b=await Api.order(game,{"order":"deploy"})
	check(dep_a.ok and dep_b.ok and not game.sim.DroneBay.aboard(game.sim.units[2]),"deploy with drone A out and selected launches drone B instead of refusing")
	var flash_try=await Api.order(game,{"order":"photo","flash":true})
	check(flash_try.has("flash") and flash_try.flash.has("fired") and flash_try.flash.fitted==false and flash_try.flash.fired==false and str(flash_try.flash.get("why_not","")).contains("No flash unit"),"photo with flash:true reports that no flash fired and why")
	# an order is no teleport: it plots a route and the craft stays where it is until time runs
	var start_pos:Vector2=game.sim.units[0].pos
	var plotted=await Api.order(game,{"order":"route","craft":"QUIETUS","points":[[400,760],[800,640],[1100,560],[1200,470]]})
	check(plotted.ok and plotted.points_accepted==4 and game.sim.units[0].pos==start_pos,"route plots four legs and moves nothing by itself")
	check(Api.state(game).crafts[0].route.size()==4,"state shows the craft's four route points")
	check(not game.sim.queue_mode,"the route order puts the TAPS toggle back as it found it")
	# run: the dive runs at speed 4, stops at anything that needs an answer
	# WP-170: a speed a release player cannot choose is refused, never reaching the debug console (which marks the profile DEV).
	var odd=await Api.order(game,{"order":"speed","speed":3.0})
	check(not odd.ok and not odd.has("marked_dev") and is_equal_approx(game.time_speed,1.0),"speed 3 is refused with a plain refusal and no DEV mark: "+str(odd.get("refusal","")))
	var out:=Api.run(game,{"seconds":10.0,"speed":4.0})
	check(out.ok and out.has("state") and out.has("events") and out.has("messages") and out.game_seconds>0.0,"run returns the state, events and messages")
	check(game.sim.paused and out.state.time.state=="paused","run leaves the dive paused so nothing runs between commands")
	var rate:float=out.game_seconds_per_real_second
	print("PLAY API run rate: ",rate," game seconds per real second (first run, speed 4)")
	check(out.game_seconds>=9.9 or out.stopped!="time_elapsed","run covers the asked game seconds or says why it stopped")
	# --- drive to the objective with commands only ---
	var s:Dictionary=out.state
	var guard_runs:=0
	while guard_runs<12 and s.screen=="mission" and not (s.crafts[0].route.is_empty() and s.crafts[0].speed<1.0):
		guard_runs+=1
		s=await answer_tips(game,s)
		out=Api.run(game,{"seconds":10.0,"speed":4.0})
		s=out.state
		no_hidden_sirens(game,s,"run %d"%guard_runs)
		if out.stopped in ["dive_ended","craft_lost"]:break
	check(s.screen=="mission" and s.outcome=="","Quietus reached the search area alive")
	check(s.camera.ready,"in reach the camera context is ready (state.camera.ready)")
	var near:bool=game.sim.units[0].pos.distance_to(game.sim.mission.objectives[0].pos)<260.0
	check(near,"Quietus is within camera reach of the spire")
	# --- photograph it ---
	var shot=await Api.order(game,{"order":"photo","insist":true})
	check(shot.ok,"photo starts an exposure: "+str(shot.get("refusal","")))
	var exposure:=Api.state(game)
	check(exposure.crafts[0].has("exposure"),"state shows the exposure under way")
	var tries:=0
	while tries<10 and not Api.state(game).objectives[0].status=="FILED":
		tries+=1
		var look:Dictionary=await answer_tips(game,Api.state(game))
		if not look.crafts[0].has("exposure"):await Api.order(game,{"order":"photo","insist":true}) # an exposure a lock interrupted is taken again
		out=Api.run(game,{"seconds":6.0,"speed":2.0})
		if out.stopped in ["dive_ended","craft_lost"]:break
	var filed:=Api.state(game)
	check(filed.objectives[0].status=="FILED","the objective reads FILED once the frame is secured")
	check(filed.objectives[0].has("photo_grade") and filed.objectives[0].photo_grade in ["A","B","C"],"state carries the filed photo's grade")
	# WP-150: the reported percent is the filed record's quality (what the dive message and result show), not the best single frame.
	check(filed.objectives[0].has("photo_percent") and filed.objectives[0].photo_percent==roundi(float(game.sim.mission.objectives[0].photo_quality)*100.),"state photo percent is the filed record quality")
	check(filed.extraction.records_complete,"state: the records are complete, Quietus may head for extraction")
	# --- route home, run until the result screen ---
	var home=await Api.order(game,{"order":"route","craft":"QUIETUS","points":[[1100,560],[800,640],[400,760],[140,800]]})
	check(home.ok,"route home is accepted")
	guard_runs=0
	s=filed
	while guard_runs<16 and s.screen=="mission":
		guard_runs+=1
		s=await answer_tips(game,s)
		out=Api.run(game,{"seconds":10.0,"speed":4.0})
		s=out.state
		if out.stopped=="craft_lost":break
	check(s.screen=="debrief" and game.sim.outcome=="won","the dive ends recovered: the state names the result screen")
	check(game.completed.has(0) and s.text.any(func(t):return str(t).contains("ARCHIVE RECOVERED")),"the result screen says ARCHIVE RECOVERED and operation 01 is recovered")
	check(s.prompts.size()==1 and s.prompts[0].buttons.size()>0,"the result screen lists its buttons")
	var after=await Api.order(game,{"order":"route","points":[[300,300]]})
	check(not after.ok,"no dive order works on the result screen")
	# --- the hub is reachable through its button's label too ---
	var labels:Array=s.prompts[0].buttons.map(func(b):return b.label)
	var back_label:String=""
	for l in labels:
		if str(l).to_upper().contains("OPERATIONS"):back_label=l
	if not back_label.is_empty():
		var back=await Api.order(game,{"order":"answer","button":back_label})
		check(back.ok,"answer presses a screen button by its label")
	check(game.get_node_or_null("Frontend")==null,"no pixel tap and no title overlay were needed")
	game.queue_free();await settle()
	print("PLAY API CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
