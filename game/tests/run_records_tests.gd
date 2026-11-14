extends SceneTree
# Save-field suite: deterministic summaries, bounded history, real sidecar/profile
# roundtrips and stock touch-sized frontend callbacks. Outcomes here are staged.
const State=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Records=preload("res://src/campaign/runs/run_records.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Run=preload("res://src/campaign/runs/expedition_run.gd")
const Modes=preload("res://src/presentation/runs/modes_frontend.gd")
const Seed=preload("res://src/presentation/runs/seed_entry.gd")
const Briefing=preload("res://src/presentation/mode_briefing.gd")
const Words=preload("res://src/presentation/runs/run_words.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Names=preload("res://src/names.gd")
const Profiles=preload("res://src/persistence/profiles/profile_store.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func result(state,outcome="won"):
	return {"op":State.current_operation(state),"outcome":outcome,"time":12.,"hull":90.,"tools":state.stock.duplicate(),"story":{},"photo":.91}
func completed(seed_value:int,loss:bool=false)->Dictionary:
	var state=State.new_run(seed_value)
	while state.status=="active":
		if Offers.pending(state):state=Offers.choose(state,state.offers.pending[0])
		var r=result(state,"lost" if loss and state.cursor==1 else "won")
		for key in r.tools:r.tools[key]=maxi(0,r.tools[key]-1)
		state=Offers.prepare(State.settle(State.launch(state),r))
	return state
func settle():
	for i in 4:await process_frame
func button(front,id:String):
	for node in front.find_children("*","Button",true,false):
		if node.get_meta("ui_action","")==id:return node
	return null
func press(front,id:String):
	var b=button(front,id);check(b!=null,"button available "+id)
	if b!=null:b.emit_signal("pressed")
	await settle()
func _initialize():call_deferred("run")
func run():
	var archive=Archive.new();archive.path="user://records-model.runs"
	var records=Records.empty()
	for seed_value in [0,1,42,12345,2147483647]:
		var state=completed(seed_value)
		var row=Records.summary(state)
		check(State.valid(state) and Records.valid_summary(row) and row.depth==state.operations.size(),"full clear summary validated")
		check(completed(seed_value)==state and Records.summary(completed(seed_value))==row,"same seed, modifiers and picks replay deterministic sequence")
		var initial=State.new_run(seed_value)
		for key in State.Table.TOOLS:
			check(initial.stock[key]+row.gained[key]-row.spent[key]==state.stock[key],"capped grant and actual spending conserved "+key)
		check(row.operations.all(func(op):return op.photo==.91),"per-operation best photos retained")
		var lost=completed(seed_value,true);var loss=Records.summary(lost)
		check(Records.valid_summary(loss) and loss.status=="lost" and loss.depth==1 and loss.operations.size()==2,"loss summary includes unsuccessful final operation")
		records=Records.add(records,state)
		check(archive.save({"version":1,"run":state,"records":records,"recorded":true}) and archive.load_game().records==records,"checked summary history disk roundtrip")
		var bad=state.duplicate(true);bad.results[0].photo=NAN
		check(not State.valid(bad),"nonfinite photo rejected")
		bad=state.duplicate(true);bad.results[0].erase("photo")
		check(State.valid(bad) and Records.summary(bad).operations[0].photo==-1.,"legacy missing photo remains valid and explicit")
	for i in 12:records=Records.add(records,completed(i,true))
	check(Records.valid(records) and records.last.size()==10 and records.last[0].seed==11 and records.last[9].seed==2 and records.best_depth>=3,"history bounded newest ten and best depth retained")
	for field in ["last","best_depth"]:
		var bad=records.duplicate(true);bad[field]=null
		check(not archive.valid({"version":1,"run":{},"records":bad}),"corrupt records field rejected "+field)
	var too_many=records.duplicate(true);too_many.last.append(too_many.last[0])
	check(not Records.valid(too_many),"overlong history rejected rather than truncated on read")
	for field in ["seed","total","depth","status","loadout","scarcity","hunt_stage","spent","gained","operations"]:
		var bad=records.duplicate(true);bad.last[0][field]=null
		check(not Records.valid(bad),"malformed summary rejected "+field)
	var bad_photo=records.duplicate(true);bad_photo.last[0].operations[0].photo=2.
	check(not Records.valid(bad_photo),"out-of-range photo rejected")
	check(Seed.sanitize("12a3\n45")=="12345" and Seed.parse("")==-1 and Seed.parse("2147483648")==-1 and Seed.parse("2147483647")==2147483647 and Seed.parse("0000000000")==0,"bounded numeric seed sanitation and range")
	check(Seed.sanitize("9".repeat(100)).length()==10 and Seed.parse("??")==-1,"paste capped and non-ASCII digits rejected")
	var sim=Run.new();var initial=State.new_run(42);sim.configure(initial);sim.start(-1)
	sim.mission.objectives[0].captured=true;sim.mission.objectives[0].photo_quality=.65
	sim.mission.photo={"studies":[{"captured":true,"photo_quality":.93}]}
	check(sim.result().photo==.93,"best photograph includes secured Siren studies")
	var host=load("res://scenes/main.tscn").instantiate()
	host.capture_scenario="runtime-test";host.store.path="user://records-ui.save"
	for suffix in [".runs",".runs.bak",".runs.tmp"]:DirAccess.remove_absolute(host.store.path+suffix)
	root.add_child(host);await settle()
	# Frontend belongs to the campaign menu; runtime-test initially enters a dive.
	host._show_campaign()
	var front=load("res://src/presentation/frontend/frontend.gd").new();host.add_child(front);front.setup(host,true)
	var active=State.new_run(42);var lost=completed(42,true)
	check(Archive.persist(host,active) and Archive.persist(host,lost) and Archive.persist(host,lost) and Archive.records(host).last.size()==1,"terminal save retry records once")
	check(Archive.persist(host,active) and Archive.persist(host,lost) and Archive.records(host).last.size()==2,"distinct attempts with identical seed count separately")
	# Existing envelopes migrate without changing their run or duplicating completion.
	var legacy=Archive.new();legacy.path="user://records-legacy.save.runs"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(legacy.path+suffix)
	check(legacy.save({"version":1,"run":lost}),"legacy terminal envelope written")
	var legacy_host=load("res://scenes/main.tscn").instantiate();legacy_host.store.path="user://records-legacy.save"
	check(Archive.restore(legacy_host)==lost and Archive.records(legacy_host).last.size()==1 and Archive.restore(legacy_host)==lost,"legacy completion migrates exactly once")
	legacy_host.free()
	var cold=load("res://scenes/main.tscn").instantiate();cold.store.path=host.store.path
	check(Archive.restore(cold)==lost and Archive.records(cold).last.size()==2,"cold reopen preserves idempotence")
	cold.free()
	var before=Archive.records(host)
	host.store.suspended=true
	check(not Archive.persist(host,completed(1)) and host.get_meta("runs_records")==before,"failed write cannot award phantom history")
	host.store.suspended=false
	Modes.expeditions(front);await settle();await press(front,"run_summary")
	check(front.screen=="run_record","terminal reopen summary available")
	await press(front,"run_replay")
	check(front.screen=="run_seed","past run opens replay seed entry")
	var edit=front.find_child("ExpeditionSeed",true,false)
	check(edit!=null and edit.text=="42" and edit.max_length==10 and edit.custom_minimum_size.y>=48.,"replay seed and native touch input configured")
	if edit!=null:
		edit.text="2147483648";edit.text_changed.emit(edit.text)
		check(button(front,"run_seed_start").disabled,"out-of-range seed cannot start")
		edit.text="42";edit.text_changed.emit(edit.text)
	front.back();await settle()
	check(front.screen=="expeditions","Android Back from seed returns to expedition list")
	Modes.record_detail(front,Records.summary(lost));front.back();await settle()
	check(front.screen=="expeditions","Android Back from summary returns to expedition list")
	Modes.seed_screen(front,42);await settle()
	await press(front,"run_seed_start")
	check(Archive.restore(host)==active,"typed replay starts same sequence and modifiers")
	var opened=host.get_node_or_null("ExpeditionSession")
	check(opened!=null and opened.screen=="expedition_menu","START THIS SEED opens the new expedition's operation menu")
	Modes.expeditions(front);await settle()
	check(button(front,"run_record_0")!=null,"run history remains reachable during active run")
	Modes.seed_screen(front,5)
	check(front.screen=="expeditions" and Archive.restore(host)==active,"replay cannot overwrite active run")
	Modes.confirm_end(front,active);await press(front,"run_confirm_end")
	check(front.screen=="run_record" and Archive.restore(host).status=="lost","Modes END RUN exposes full loss summary")
	# The accepted rider grant joins offer/refill accounting without double counting.
	var rider_state=State.new_run(42);var launched=State.launch(rider_state,true)
	var rider_result=result(rider_state)
	rider_result.rider={"assignment":State.rider_assignment(launched),"passed":true}
	var rewarded=State.settle(launched,rider_result)
	var final_loss=State.settle(State.launch(rewarded),result(rewarded,"lost"))
	var reward_summary=Records.summary(final_loss)
	check(State.valid(final_loss) and Records.valid_summary(reward_summary),"rider reward ledger summary valid")
	for key in State.Table.TOOLS:
		check(rider_state.stock[key]+reward_summary.gained[key]-reward_summary.spent[key]==final_loss.stock[key],"rider grant conservation "+key)
	var profiles=Profiles.new();profiles.directory="user://records-profiles";profiles.legacy="user://records-no-legacy.save"
	DirAccess.make_dir_recursive_absolute(profiles.directory)
	for slot in Profiles.Rules.COUNT:
		for suffix in Profiles.Rules.SUFFIXES:DirAccess.remove_absolute(profiles.slot_path(slot)+suffix)
	check(profiles.open(),"isolated profile fixture opened")
	var files={}
	for suffix in Profiles.Rules.SUFFIXES:files[suffix]=null
	files[".runs"]=FileAccess.get_file_as_bytes(host.store.path+".runs")
	check(profiles.replace(0,files,true) and profiles.parse_package(profiles.package_bytes(0))==files,"records travel through validated profile export/import")
	var corrupt={"version":1,"run":lost,"records":records,"recorded":true}
	check(not archive.valid(corrupt),"recorded marker must match current terminal summary")
	# Plain words for what a scarcity means, from the run table's own numbers.
	var Tools=preload("res://src/equipment/field_tools.gd")
	var RacksView=preload("res://src/presentation/tool_racks_view.gd")
	for loadout in State.Table.LOADOUTS:
		check(Records.scarcity_line(loadout,0).begins_with("Supplied:") and Records.scarcity_line(loadout,0).contains("adds 2 of one tool"),"supplied line "+loadout)
		for level in [1,2]:
			var line=Records.scarcity_line(loadout,level);var held=State.Table.stock(loadout,level);var full=State.Table.stock(loadout,0)
			check(line.begins_with(State.Table.SCARCITY[level].capitalize()+":"),"scarcity name leads "+loadout+str(level))
			for key in State.Table.TOOLS:
				var name=Tools.spec(key).name
				var expected="no %s"%name if held[key]==0 else "%d %s"%[held[key],name]
				check((held[key]<full[key])==line.contains(expected),"line names short tool "+key+loadout+str(level))
		check(Records.scarcity_line(loadout,2).contains("recovered operations add no supplies"),"scarce run restocks nothing")
	check(Seed.setup_context(State.new_run(7)).contains(Records.scarcity_line(State.new_run(7).loadout,State.new_run(7).scarcity)),"seed screen states what the supplies mean")
	var hunt_row=Records.summary(completed(7));var ceiling=Records.hunt_ceiling(hunt_row.hunt_stage)
	check(ceiling.contains(Names.HUNT_STAGES[hunt_row.hunt_stage]) and Records.modifiers(hunt_row).contains(ceiling.to_upper()) and Records.HUNT_CEILING_NOTE.contains("at most"),"run record words the Hunt as a ceiling with its stage name")
	var briefing_racks=Briefing.carrying_line({Names.CRAFT_QUIETUS:{"decoy":3,"emp":2},Names.CRAFT_DRONE_A:{"sonobuoy":1},Names.CRAFT_DRONE_B:{}})
	check(briefing_racks=="Carrying: QUIETUS %s 2, %s 3; DRONE A %s 1."%[Tools.spec("emp").name.to_upper(),Tools.spec("decoy").name.to_upper(),Tools.spec("sonobuoy").name.to_upper()] and Briefing.carrying_line(Racks.empty())=="Carrying: no tools.","briefing carrying line lists each craft's tools with counts")
	check(RacksView.none_left({"emp":0,"decoy":3,"recon":0,"knock":0}).size()>=3 and RacksView.none_left({"emp":0,"decoy":3,"recon":0,"knock":0}).has(Tools.spec("emp").name) and not RacksView.none_left({"emp":0,"decoy":3}).has(Tools.spec("decoy").name),"empty tools gather into one list")
	# WP-86: every screen states the same Hunt numbers, kit, stock and dive ledger.
	for seed_value in [7,166421881,1234,99]:
		var fresh=State.new_run(seed_value);var starts=State.starting_hunt(fresh,State.current_operation(fresh))
		var hunt=Words.hunt_line(fresh)
		check(hunt.contains("stage %d (%s)"%[fresh.hunt_stage,Names.HUNT_STAGES[fresh.hunt_stage]]) and hunt.contains("operation 1 starts at stage %d (%s)"%[starts,Names.HUNT_STAGES[starts]]),"hunt line states ceiling and start for seed %d"%seed_value)
		check(Seed.setup_context(fresh).contains(hunt) and not Seed.setup_context(fresh).contains("Loadout:"),"seed screen uses the shared hunt line and kit words for seed %d"%seed_value)
	check(Words.kit_line(Names.LOADOUT_EMP).contains("more EMP") and Words.kit_line(Names.LOADOUT_ENDURANCE).contains("standard kit"),"kit line says what the loadout adds")
	var offered=State.new_run(7);offered.results=[result(offered)];offered.stock=offered.results[0].tools.duplicate()
	offered.stock.hull_patch+=2;offered.results[0].tools.recon=2;offered.results[0].tools.knock=2;offered.stock.recon=2;offered.stock.knock=2
	var offer_lines=Words.stock_lines(offered)
	check(offer_lines[0].contains(Tools.spec("recon").name) and offer_lines[0].contains(Tools.spec("knock").name),"the stock line lists every tool, Survey and Torpedo included")
	check(offer_lines.size()==2 and offer_lines[1].contains("+2 "+Tools.spec("hull_patch").name),"the stock line says what the recovery added")
	check(Words.spare_line({"emp":3,"hull_patch":3},{Names.CRAFT_QUIETUS:{"emp":3,"hull_patch":1}}).contains("2 "+Tools.spec("hull_patch").name) and Words.spare_line({"emp":3},{Names.CRAFT_QUIETUS:{"emp":3}})=="","tools held beyond the racks are named")
	var trade=Offers.describe(offered,"route:%d"%offered.operations[offered.operations.size()-1]).detail
	check(trade.contains("Trade 1 "+Tools.spec("decoy").name+" for 2 "+Tools.spec("emp").name+" charges"),"the route offer reads as a trade: "+trade)
	var dive=Words.dive_ledger({"emp":3,"decoy":3},{"emp":2,"decoy":3},{"emp":2,"decoy":3,"hull_patch":2})
	check(dive[0]=="THIS DIVE" and dive[1]=="Spent: 1 EMP." and dive[2]=="Earned: +2 Hull patch." and dive[3]=="Kept: 2 EMP, 3 Decoy, 2 Hull patch.","the dive ledger reads spent, earned, kept: "+str(dive))
	check(Words.dive_ledger({"emp":1},{"emp":1},{"emp":1})[1]=="Spent: nothing.","an unused dive spent nothing")
	host.queue_free();await settle()
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(archive.path+suffix)
	print("RUN RECORDS CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
