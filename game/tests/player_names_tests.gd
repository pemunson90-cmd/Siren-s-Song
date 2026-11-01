extends SceneTree
# Player-facing run text must not show internal ids (snake_case) or codenames.
# Scans the rendered Label/Button text of the real expedition screens, plus the data tables behind them.
const State=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Records=preload("res://src/campaign/runs/run_records.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const Summary=preload("res://src/presentation/runs/run_summary_view.gd")
const Riders=preload("res://src/campaign/career/riders.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
var checks=0
var failures=0
var snake=RegEx.new()
var word=RegEx.new()
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func codenames()->Array:
	# Internal ids taken from source tables: tool keys, rider ids, offer boons, loadout ids.
	var out=[]
	for k in Table.TOOLS:out.append(str(k))
	for k in Riders.Table.ROWS.keys():out.append(str(k))
	for k in Table.LOADOUTS:out.append(str(k))
	for k in Offers.Table.BOONS:out.append(str(k))
	return out
func pattern_leaks(text:String)->bool:
	return snake.search(text)!=null
func listed_leaks(text:String)->bool:
	var low=text.to_lower()
	var words=word.search_all(text)
	for id in codenames():
		if id.contains("_"):
			if low.contains(id):return true
		elif text.strip_edges()==id:return true # A label that is only the lowercase bare id; display names are capitalised.
		elif id=="emp":
			# Not an English word: the player-facing name is Disrupt.
			for m in words:
				if m.get_string().to_lower()==id:return true
		# Other bare ids (decoy, recon, survey) are plain English inside prose.
	return false
func leaks(text:String)->bool:
	return pattern_leaks(text) or listed_leaks(text)
func clean(text:String,label:String)->void:
	check(not leaks(text),"no internal id in "+label+": "+text)
	check(not text.contains("—"),"no em dash in "+label)
func completed(seed_value:int)->Dictionary:
	var state=State.new_run(seed_value)
	while state.status=="active":
		if Offers.pending(state):state=Offers.choose(state,state.offers.pending[0])
		state=Offers.prepare(State.settle(State.launch(state),won(state)))
	return state
func won(state:Dictionary)->Dictionary:
	return {"op":State.current_operation(state),"outcome":"won","time":12.,"hull":90.,"tools":state.stock.duplicate(),"story":{},"photo":.91}
func frames():
	for n in 4:await process_frame
func scan(node:Node,label:String)->int:
	var seen=0
	for child in node.get_children():
		if child is Label or child is Button:
			seen+=1;clean(child.text,label+" ["+child.get_class()+"]")
		seen+=scan(child,label)
	return seen
func screen(state:Dictionary,seed_value:int,step:int,debrief:bool,terminal:bool=false)->void:
	var path="user://138-names.save"
	var host=load("res://scenes/main.tscn").instantiate()
	host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path=path
	root.add_child(host);await frames()
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd"))
	session.campaign_host=host;session.run_state=(State.launch(state) if debrief else state).duplicate(true)
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await frames()
	var tag="seed %d step %d"%[seed_value,step]
	var seen=scan(session.panel_box,tag+" screen "+str(session.screen))
	if debrief:
		session.sim.outcome="won";session._debrief();await frames()
		seen+=scan(session.panel_box,tag+" result")
	if terminal:
		# Completed run: render the real result screen with the terminal summary lines.
		session.run_state=completed(seed_value);session.recorded=true;session._result_menu();await frames()
		check(session.run_state.status!="active" and session.screen=="expedition_result","terminal result reached: "+tag)
		seen+=scan(session.panel_box,tag+" terminal summary")
		check(scan(session.panel_box,tag+" terminal recount")>8,"terminal summary lines rendered: "+tag)
	check(seen>0,tag+" rendered labels")
	host.queue_free();await frames()
func _initialize():call_deferred("run")
func run():
	snake.compile("[A-Za-z0-9]+_[A-Za-z0-9_]+")
	word.compile("[A-Za-z0-9]+")
	# Matcher self-checks. The regex alone must catch ids so table lookups cannot mask it.
	check(pattern_leaks("unknown_id"),"regex catches unknown_id")
	check(pattern_leaks("see SILT_SCREEN now"),"regex catches uppercase id")
	check(not pattern_leaks("Silt Archive"),"regex passes plain words")
	check(not pattern_leaks("EXPEDITION · SEED 4 / 3 OF 5"),"regex passes header text")
	check(leaks("unknown_id") and not leaks("Silt Archive"),"leaks self-check")
	check(listed_leaks("knock") and listed_leaks("recon") and listed_leaks("survey"),"list catches labels that are a bare id")
	check(listed_leaks("fire the emp now") and listed_leaks("EMP burst"),"list catches emp")
	check(not listed_leaks("Recon Drone") and not listed_leaks("Decoy") and not listed_leaks("a southern survey mouth"),"list passes display names and prose")
	for op in 41:
		if Catalog.definition(op).is_empty():continue
		var m=Catalog.make(op,{})
		if m.is_empty():continue
		clean(str(m.title).to_upper(),"expedition header op %d"%op)
		clean(str(m.title),"title op %d"%op)
		clean(str(m.brief),"brief op %d"%op)
	for key in Table.TOOLS:clean(Summary.Tools.spec(key).name,"tool "+key)
	for id in Riders.Table.ROWS.keys():
		var a={"id":id}
		clean(Riders.description(a,Riders.bonus_text(a)),"rider "+id)
	for s in 12:
		var row=Records.summary(completed(s+1))
		check(not row.is_empty(),"summary %d"%s)
		clean(Records.modifiers(row),"modifiers seed %d"%s)
		for line in Summary.lines(row):clean(line,"summary line seed %d"%s)
	# Real screens: expedition menu, offers and result for each stage of several seeds.
	for s in 6:
		var st=State.new_run(s+1)
		var step=0
		while st.status=="active":
			await screen(st,s+1,step,true,st.cursor==st.operations.size()-1)
			if Offers.pending(st):st=Offers.choose(st,st.offers.pending[0])
			st=Offers.prepare(State.settle(State.launch(st),won(st)))
			step+=1
	print("PLAYER NAMES CHECKS %d FAILURES %d"%[checks,failures])
	quit(1 if failures>0 else 0)
