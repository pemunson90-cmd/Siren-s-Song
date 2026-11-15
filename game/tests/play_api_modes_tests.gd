extends SceneTree
# WP-136 (critic kit, 15 Nov 2026): the play API reaches Expedition and Naval Career (a session node on top of the frozen
# campaign host) by menu buttons only, and the fixes the fun testers asked for: answer by index, the torpedo target number,
# the chart and route_check inside a mode session. Headless, no pixel tap, no debug command.
const Api=preload("res://src/play_api/play_api.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func make():
	var game=load("res://scenes/main.tscn").instantiate()
	game.store.path="user://wp136-%d.save"%Time.get_ticks_usec()
	root.add_child(game);await settle()
	return game
func labels(s:Dictionary)->Array:
	var out:Array=[]
	for p in s.prompts:
		for b in p.buttons:out.append(b.label)
	return out
func press(game,label:String,index:int=-1)->Dictionary:
	var request:={"order":"answer","button":label}
	if index>=0:request["index"]=index
	var r=await Api.order(game,request)
	await settle()
	return r
func run():
	# --- Expedition: title, GAME MODES, EXPEDITIONS, seed, briefing, first operation ---
	var game=await make()
	var s:=Api.state(game)
	check(s.screen=="menu" and s.get("title_overlay","")=="title" and "START GAME" in labels(s),"the title lists START GAME")
	check((await press(game,"START GAME")).ok,"START GAME opens the game modes")
	s=Api.state(game)
	check(s.title_overlay=="modes" and "EXPEDITIONS" in labels(s) and "NAVAL CAREER" in labels(s),"GAME MODES lists EXPEDITIONS and NAVAL CAREER")
	check((await press(game,"EXPEDITIONS")).ok,"EXPEDITIONS opens")
	s=Api.state(game)
	check(s.title_overlay=="expeditions" and "NEW SEEDED EXPEDITION" in labels(s) and s.text.size()>0,"the Expeditions screen lists its text and its button")
	check((await press(game,"NEW SEEDED EXPEDITION")).ok,"NEW SEEDED EXPEDITION opens the seed screen")
	s=Api.state(game)
	check(s.title_overlay=="run_seed" and "START THIS SEED" in labels(s) and "RANDOM SEED" in labels(s),"the seed screen lists START THIS SEED")
	var go=await press(game,"START THIS SEED")
	check(go.ok,"START THIS SEED is accepted")
	s=Api.state(game)
	check(s.screen=="expedition_menu" and s.get("mode_session","")=="ExpeditionSession" and not s.has("title_overlay"),"after START THIS SEED the state is the Expedition briefing, not an empty title")
	check(s.prompts.size()==1 and s.prompts[0].kind=="screen" and labels(s).any(func(l):return str(l).begins_with("BEGIN OPERATION")) and s.text.size()>2,"the Expedition briefing lists its text and BEGIN OPERATION")
	var again=await Api.order(game,{"order":"start","operation":1})
	check(not again.ok and str(again.refusal).contains("ExpeditionSession"),"start does not open a Campaign operation under an open Expedition")
	# duplicate labels: the briefing has many + and - buttons
	var many:int=labels(s).filter(func(l):return l=="+").size()
	check(many>1,"the Expedition briefing has duplicate + buttons")
	var ambiguous=await press(game,"+")
	check(not ambiguous.ok and ambiguous.has("candidates") and str(ambiguous.refusal).contains("index"),"duplicate labels are refused and the refusal asks for an index")
	var pick_label:="+";var enabled_at:int=-1
	for candidate in ["+","−"]:
		var same:Array=s.prompts[0].buttons.filter(func(b):return b.label==candidate)
		for i in same.size():
			if same[i].enabled and enabled_at<0:enabled_at=i;pick_label=candidate
	var picked=await press(game,pick_label,maxi(enabled_at,0))
	# An enabled duplicate is pressed; if every one is greyed out the refusal must be the grey-out, not an ambiguity.
	check(picked.ok if enabled_at>=0 else not str(picked.get("refusal","")).contains("More than one"),"answer with an index presses that duplicate: "+str(picked.get("refusal","")))
	var bad_index=await press(game,"+",many+5)
	check(not bad_index.ok and str(bad_index.refusal).contains("index"),"an index past the end is refused in words")
	var begin=await press(game,"BEGIN OPERATION")
	check(begin.ok,"BEGIN OPERATION is accepted: "+str(begin.get("refusal","")))
	s=Api.state(game)
	check(s.screen=="mission" and s.get("mode_session","")=="ExpeditionSession" and s.operation.number>=1,"the Expedition's first operation is on the dive screen")
	check(s.chart.kind in ["opening","earned"] and s.crafts.size()==3 and s.oxygen.seconds_left>0,"state in an Expedition dive carries the chart, the crafts and oxygen")
	var ex=game.get_node("ExpeditionSession")
	var q:Vector2=ex.sim.units[0].pos
	var rc=await Api.order(game,{"order":"route_check","points":[[q.x+25,q.y]]})
	check(rc.ok and rc.legs.size()==1,"route_check works inside an Expedition dive")
	var ran=await Api.run(game,{"seconds":3.0})
	check(ran.ok and ran.game_seconds>0.0,"run advances the Expedition dive's own clock")
	game.queue_free();await settle()
	# --- Naval Career: board, contract briefing, first dive ---
	game=await make()
	await press(game,"START GAME")
	check((await press(game,"NAVAL CAREER")).ok,"NAVAL CAREER opens")
	s=Api.state(game)
	check(s.title_overlay=="career" and "START NAVAL CAREER" in labels(s) and s.text.size()>0,"the Career screen lists START NAVAL CAREER")
	check((await press(game,"START NAVAL CAREER")).ok,"START NAVAL CAREER is accepted")
	s=Api.state(game)
	check(s.screen=="career_board" and s.get("mode_session","")=="CareerSession" and labels(s).any(func(l):return str(l).begins_with("SHELF SIGNAL")),"after START NAVAL CAREER the state is the contract board with its contracts")
	check((await press(game,"SHELF SIGNAL")).ok,"a contract can be opened by its name")
	s=Api.state(game)
	check(s.screen=="career_briefing" and labels(s).any(func(l):return str(l).begins_with("ACCEPT CONTRACT")) and s.text.any(func(t):return str(t).contains("Photograph the signal spire")),"the Career contract briefing lists its text and ACCEPT CONTRACT")
	check((await press(game,"ACCEPT CONTRACT")).ok,"ACCEPT CONTRACT is accepted")
	s=Api.state(game)
	check(s.screen=="mission" and s.get("mode_session","")=="CareerSession" and s.has("chart"),"the Career dive screen reads through the same state")
	# --- the torpedo target number, on a fresh Campaign dive (the sim's own list, not the on-screen boxes) ---
	game.queue_free();await settle()
	game=await make()
	check((await Api.order(game,{"order":"start","operation":1})).ok,"campaign operation 1 starts for the torpedo check")
	var sim=game.sim;var q0:Vector2=sim.units[0].pos
	sim.tools["knock"]=2
	# Test fixture: Siren 0 sits 70 m from Quietus in its band, so the sim's own knock rules can accept the shot.
	sim.sirens[0].pos=q0+Vector2(70,0);sim.sirens[0].band=int(sim.units[0].band);sim.sirens[0].transition={};sim.sirens[0].stun=0.0
	sim.contacts[0]={"pos":q0+Vector2(70,0),"time":sim.elapsed,"mode":"PATROL","lock":0.0,"angle":0.0,"target":-1,"type":"patroller","band":int(sim.units[0].band),"transition":{},"source":"optical","confidence":1.0,"seen_by":[]}
	var clear:Array=sim.knockdown_targets().map(func(c):return int(c.key))
	check(clear.has(0),"the injected fresh contact is a clear knock target in the sim")
	if clear.has(0):
		var miss=await Api.order(game,{"order":"tool","tool":"knock","target":2})
		check(not miss.ok and miss.has("clear_targets") and "S1" in miss.clear_targets,"a torpedo at an S number that is not clear is refused and names the clear ones")
		var hit=await Api.order(game,{"order":"tool","tool":"knock","target":1})
		check(hit.ok,"a torpedo at target 1 (S1) is accepted when the sim lists S1 as clear: "+str(hit.get("refusal","")))
	game.queue_free();await settle()
	print("PLAY API MODES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
