extends SceneTree
# One focused suite for new sidecar fields, contract outcome math and live isolation.
# Outcomes below are staged technical fixtures, not claims of complete player voyages.
const State=preload("res://src/campaign/career/career_state.gd")
const Table=preload("res://src/campaign/career/career_table.gd")
const Archive=preload("res://src/campaign/career/career_archive.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const EconomyPanel=preload("res://src/presentation/economy_panel.gd")
const CareerFront=preload("res://src/presentation/career/career_frontend.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
	for n in 4:await process_frame
func press(node,id:String):
	var buttons=node.find_children("*","Button",true,false).filter(func(b):return b.get_meta("ui_action","")==id and b.is_visible_in_tree())
	check(buttons.size()==1,"touch action exists "+id)
	if buttons.size()!=1:return
	var button=buttons[0];var parent=button.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(button);await frames()
	check(button.size.y>=node.ui_touch_height if node.has_method("ui_density_dpi") else button.size.y>=48,"full-size touch target "+id)
	var point=button.get_global_rect().get_center()
	for down in [true,false]:
		var event=InputEventScreenTouch.new();event.position=point;event.index=0;event.pressed=down;root.push_input(event,true);await process_frame
		var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
	await frames()

func button(node,id:String):
	var matches=node.find_children("*","Button",true,false).filter(func(b):return b.get_meta("ui_action","")==id and b.is_visible_in_tree())
	return matches[0] if matches.size()==1 else null
func result(won:bool=true)->Dictionary:return {"outcome":"won" if won else "lost","hull":100.,"alive":[true,true]}
func run():
	var state=State.new_career()
	check(State.valid(state),"new career validates")
	var corrupt=state.duplicate(true);corrupt.standing.varne=11
	check(not State.valid(corrupt),"reject corrupt standing")
	corrupt=state.duplicate(true);corrupt.economy.stock.cells=-1
	check(not State.valid(corrupt),"reject corrupt economy")
	corrupt=state.duplicate(true);corrupt.serial=1
	check(not State.valid(corrupt),"reject inconsistent contract serial")
	for faction in Table.FACTIONS:
		var starter=Table.CONTRACTS.keys().filter(func(id):return Table.CONTRACTS[id].faction==faction and Table.CONTRACTS[id].get("standing",Table.MIN_STANDING)==Table.MIN_STANDING)[0]
		var higher=Table.CONTRACTS.keys().filter(func(id):return Table.CONTRACTS[id].faction==faction and Table.CONTRACTS[id].get("standing",Table.MIN_STANDING)==2)[0]
		var base=State.new_career();var before=base.economy.stock.duplicate()
		check(not State.open(base,higher),"regional contract starts closed "+faction)
		var launched=State.launch(base,starter)
		check(State.valid(launched) and launched.in_flight and base==State.new_career(),"launch is isolated and valid "+faction)
		check(launched.tool_racks==Racks.template("endurance"),"default Career launch uses the selected endurance loadout "+faction)
		var won=State.settle(launched,result())
		check(State.valid(won) and won.standing[faction]==2 and State.open(won,higher),"recovery opens regional work "+faction)
		check(won.economy.stock.scrap>before.scrap and won.recovered==1,"recovery pays existing resource "+faction)
		check(State.settle(won,result())==won,"result cannot pay twice "+faction)
		var lost=State.settle(State.launch(won,starter),result(false))
		check(State.valid(lost) and lost.standing[faction]==0 and not State.open(lost,higher),"loss closes trusted contract "+faction)
		for n in 8:lost=State.interrupted(State.launch(lost,starter))
		check(State.valid(lost) and lost.standing[faction]==Table.MIN_STANDING and State.open(lost,starter),"standing floors with a playable recovery job "+faction)
		for n in 10:lost=State.settle(State.launch(lost,starter),result())
		check(State.valid(lost) and lost.standing[faction]==Table.MAX_STANDING,"standing caps "+faction)
	var build=State.new_career();build.economy.stock={"scrap":99,"cells":99,"alloy":99}
	var module="quietus_tele_lens"
	# Use a catalog-backed conventional fitting, independent of naming changes.
	module=State.Equipment.ITEMS.keys().filter(func(item):return item not in Economy.Table.ALIEN)[0]
	check(State.manufacture(build,module) and State.valid(build) and not State.manufacture(build,module),"manufacturing uses resources and grants one fitting")
	check(Economy.buy_unlock(build.economy,"hull:quiet") and State.valid(build),"fleet uses existing frame economy")
	var research_state=State.new_career();research_state.standing.varne=4
	var atlas={"recovered":true,"id":16,"expedition_facts":{"glass_record_16":"received"}}
	research_state=State.settle(State.launch(research_state,"varne_atlas"),{"outcome":"won","hull":100.,"alive":[true,true],"mission":atlas})
	var mission={"recovered":true,"id":20,"expedition_facts":{"glass_record_20":"received"},"glass_reach":{"retrieved":true,"artifact":{"state":"recovered","id":"prism_core"}}}
	research_state=State.settle(State.launch(research_state,"varne_material"),{"outcome":"won","hull":100.,"alive":[true,true],"mission":mission})
	check(State.valid(research_state) and "prism_core" in State.Research.pending(research_state.progress),"physically recovered material and received evidence enable research")
	research_state.economy.stock.alloy=20
	research_state.progress=Economy.research(research_state.economy,research_state.progress,"prism_core")
	check(State.valid(research_state) and "quietus_prism" in research_state.progress.entitlements,"paid research grants actual fitting")
	var profiles=load("res://src/persistence/profiles/profile_store.gd").new()
	profiles.directory="user://career-test-profiles";profiles.legacy="user://career-legacy.save"
	check(profiles.open(),"isolated profile fixture opens")
	var path=profiles.slot_path(0)
	var host=load("res://scenes/main.tscn").instantiate()
	host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path=path;root.add_child(host);await frames()
	host.economy=Economy.new_state("standard",true);host._show_campaign();host._save_archive()
	# Main's runtime fixture intentionally disables archive writes; use the tested campaign serializer.
	host.capture_scenario="";host._save_archive();host.capture_scenario="runtime-test"
	var campaign_bytes=FileAccess.get_file_as_bytes(path);var snapshot=host.sim.snapshot()
	check(not campaign_bytes.is_empty() and Archive.persist(host,state),"career writes alongside an existing campaign")
	var side=Archive.new();side.path=path+".career"
	check(side.load_game().career==state,"new fields round trip")
	check(Archive.persist(host,build),"career backup created")
	var front=load("res://src/presentation/frontend/frontend.gd").new();host.add_child(front);front.setup(host,true)
	CareerFront.start(front);await frames()
	var session=host.get_node_or_null("CareerSession")
	check(session!=null and session.screen=="career_board" and host.process_mode==Node.PROCESS_MODE_DISABLED,"playable career opens and freezes campaign")
	if session!=null:
		session._select_contract("brannock_watch");session._begin();await frames()
		check(session.active_started and session.sim.paused and session.career_state.in_flight and session.sim.mission.id==0,"accept enters actual paused inherited operation")
		host.store.suspended=true;session.sim.outcome="won";session._debrief();await frames()
		var settled=session.career_state.duplicate(true)
		check(session.result_pending and session.save_failed and settled.recovered==1,"failed result save retains completed outcome")
		host.store.suspended=false;session._save_archive();session._debrief();await frames()
		check(not session.save_failed and session.career_state==settled and Archive.restore(host)==settled,"retry persists outcome exactly once")
		session._android_back();check(session.screen=="career_result","Back preserves result until explicit continuation")
		session.result_pending=false;session.active_started=false;session._show_campaign()
		session._select_contract("brannock_deep");session._begin();await frames();session._debrief(true);await frames()
		check(session.career_state.lost==1 and not State.open(session.career_state,"brannock_deep"),"abandonment changes live contract availability")
		session.result_pending=false;session.active_started=false;session._return();await frames()
	check(host.sim.snapshot()==snapshot and FileAccess.get_file_as_bytes(path)==campaign_bytes,"career results preserve campaign simulation and bytes")
	var saved=Archive.restore(host)
	check(saved.recovered==1 and saved.lost==1,"career persists across session return")
	check(profiles.package_bytes(0).is_empty(),"career preserves existing Ironman profile export guard")
	check(FileAccess.get_file_as_bytes(profiles.slot_path(1)+".career").is_empty(),"other physical profile remains separate")
	var plain=load("res://src/persistence/save_store.gd").new();plain.path=profiles.slot_path(1)
	check(plain.save({"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance"}),"ordinary profile fixture saves")
	var career_copy=Archive.new();career_copy.path=plain.path+".career"
	check(career_copy.save({"version":1,"career":saved}) and career_copy.save({"version":1,"career":saved}),"ordinary profile gets independent career and backup")
	var raw=profiles.snapshot(1);var pack=profiles.package_bytes(1)
	check(raw.has(".career") and raw.has(".career.bak") and profiles.parse_package(pack)==raw,"profile export/import carries career primary and backup")
	var legacy=raw.duplicate();legacy.erase(".career");legacy.erase(".career.bak")
	check(profiles._normalize_files(legacy)[".career"]==null,"older six-file profiles remain importable")
	# Simulate a fresh process reading an in-flight contract: settle the loss once.
	var pending=State.launch(saved,"brannock_watch");check(Archive.persist(host,pending),"interruption fixture persists launch")
	host.remove_meta("career_archive_path")
	var interrupted=Archive.restore(host)
	check(interrupted.lost==saved.lost+1 and not interrupted.in_flight and Archive.restore(host)==interrupted,"interrupted contract fails exactly once without resetting career")
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		root.size=shape;await frames()
		host.upgrade="survey"
		CareerFront.start(front);await frames();session=host.get_node_or_null("CareerSession")
		if session==null:check(false,"touch career session exists");continue
		await press(session,"career_supplies");check(session.screen=="career_supplies","touch opens supplies "+str(shape))
		await press(session,"career_board");await press(session,"career_fittings")
		check(session.screen=="career_fittings","touch opens fleet "+str(shape))
		var before_emp=session.tool_racks.quietus.get("emp",0)
		await press(session,"mode_rack_remove_quietus_emp")
		check(session.tool_racks.quietus.emp==before_emp-1 and session.career_state.tool_racks.quietus.emp==before_emp-1,"career rack remove touch commits between-dive stock")
		await press(session,"mode_rack_add_quietus_emp")
		check(session.tool_racks.quietus.emp==before_emp and session.career_state.tool_racks.quietus.emp==before_emp,"career rack add touch restores the selected allocation")
		session.save_failed=true;session._show_fittings();await frames()
		check(button(session,"mode_rack_add_quietus_emp").disabled and button(session,"mode_rack_remove_quietus_emp").disabled,"career rack touch controls retain save-failure guard")
		session.save_failed=false;session._show_fittings();await frames()
		await press(session,"mode_rack_add_quietus_emp")
		check(session.tool_racks.quietus.emp==before_emp+1,"career can add a charge beyond its endurance template by touch")
		await press(session,"career_board");await press(session,"career_contract_brannock_watch")
		check(session.screen=="career_briefing","touch selects contract "+str(shape))
		check(session.upgrade=="endurance","public Career session keeps its fixed endurance loadout despite campaign profile choice")
		var display_cost=EconomyPanel.launch_cost(session)
		var expected_cost=Economy.refit_cost(session.economy,EconomyPanel.fitted(session))
		var extra_cost=Racks.cost(session.tool_racks,"endurance",session.economy)
		for key in extra_cost:expected_cost[key]=expected_cost.get(key,0)+extra_cost[key]
		check(display_cost==expected_cost and extra_cost.get("scrap",0)>0,"Career display prices extra stock against its fixed endurance baseline")
		var stock_before=session.economy.stock.duplicate()
		await press(session,"career_begin")
		check(session.screen=="mission" and session.active_started,"touch launches actual operation "+str(shape))
		var paid=true
		for key in ["scrap","cells"]:if stock_before[key]-session.economy.stock[key]!=display_cost.get(key,0):paid=false
		check(paid,"Career debits the same selected-loadout cost shown before launch "+str(shape))
		check(session.sim.mission.tool_racks==session.career_state.tool_racks,"Career simulation starts with the rack allocations priced at launch")
		check(session.sim.tools.emp==before_emp+1 and session.sim.tools.recon==2,"Career simulation launches endurance rack counts including the extra EMP")
		root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await frames()
		check(session.screen=="career_board" and FileAccess.get_file_as_bytes(path)==campaign_bytes,"Android Back opens career board with campaign bytes intact")
		await press(session,"career_abandon");await press(session,"career_confirm_abandon")
		check(session.screen=="career_result","touch confirms contract loss "+str(shape))
		await press(session,"career_board");await press(session,"career_return")
		check(host.get_node_or_null("CareerSession")==null,"touch returns to modes "+str(shape))
	host.queue_free();await frames()
	print("CAREER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
