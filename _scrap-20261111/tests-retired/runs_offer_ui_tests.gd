extends "res://tests/challenges_ui_tests.gd"
# Staged recovery, actual injected screen touches at both Fold7 shapes. No claim
# of physical-phone ergonomics or genuine operation completion in this UI test.
const State=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Modes=preload("res://src/presentation/runs/modes_frontend.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const RunTable=preload("res://src/campaign/runs/run_table.gd")
func offer_case(shape,choice):
	root.size=shape;await settle()
	var path="user://offer-ui-%d-%d.save"%[shape.x,choice]
	for file in [path,path+".runs",path+".career"]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
	var host=load("res://scenes/main.tscn").instantiate();host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path=path;root.add_child(host);await settle()
	host._show_campaign();host._save_archive();await settle()
	var campaign_bytes=FileAccess.get_file_as_bytes(path)
	var career=FileAccess.open(path+".career",FileAccess.WRITE);career.store_string("career resources preserved");career.close()
	var snapshot=host.sim.snapshot()
	var front=Front.new();host.add_child(front);front.setup(host,true)
	var initial=State.new_run(12345)
	var pending=Offers.prepare(State.settle(State.launch(initial),{"op":State.current_operation(initial),"outcome":"won","time":40.,"hull":80.,"tools":initial.stock,"story":{}}))
	check(Archive.persist(host,pending),"staged recovered offers persist")
	Modes.start(front);await settle()
	var session=host.get_node("ExpeditionSession")
	var scale:float=Vector2(root.size).y/session.get_viewport_rect().size.y
	check(session.screen=="expedition_offers" and session.ui_touch_height*scale*160./session.ui_density_dpi()>=48.,"reload opens mandatory choice with at least 48 physical dp "+str(shape))
	check(button(session,"run_begin")==null,"pending offer has no launch bypass")
	var id:String=pending.offers.pending[choice]
	var first=button(session,"run_offer_"+str(pending.offers.pending[0]))
	check(first!=null and session.scroll.get_global_rect().encloses(first.get_global_rect()),"first complete offer target fits opening screen")
	for offer in pending.offers.pending:
		var b=button(session,"run_offer_"+offer)
		check(b!=null and b.size.y>=session.ui_touch_height,"48dp choice target "+offer)
		if b!=null:
			session.scroll.ensure_control_visible(b);await settle()
			check(session.scroll.get_global_rect().encloses(b.get_global_rect()),"offer fully reachable by scrolling "+offer)
	# Escape and Android Back preserve the unresolved saved choice.
	await escape_key()
	check(session.run_state==pending and Archive.restore(host)==pending,"Escape preserves same offer slate")
	session.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
	check(session.run_state==pending and session.screen=="expedition_offers","Android Back preserves choice page")
	await press(session,"run_return");await settle()
	check(host.get_node_or_null("ExpeditionSession")==null,"touch returns without selecting")
	Modes.start(front);await settle();session=host.get_node("ExpeditionSession")
	check(session.run_state==pending and session.screen=="expedition_offers","return/reopen cannot reroll")
	host.store.suspended=true
	await press(session,"run_offer_"+id)
	check(session.run_state==pending and session.screen=="expedition_offers","failed choice save grants no resources")
	host.store.suspended=false
	var capture=OS.get_environment("SIRENS_068_CAPTURE_DIR")
	if not capture.is_empty() and DisplayServer.get_name()!="headless":
		session.scroll.scroll_vertical=0;await settle();await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(capture+"/offers-%dx%d-%d.png"%[shape.x,shape.y,choice])==OK,"rendered choice screenshot")
	await press(session,"run_offer_"+id)
	var picked=Offers.choose(pending,id)
	check(session.screen=="expedition_menu" and session.run_state==picked and Archive.restore(host)==picked,"touch picks exact saved resources and route "+id)
	check(session.sim.mission.id==State.current_operation(picked),"selected authored operation previews")
	var rack_tool="";var rack_slot=""
	for tool in RunTable.TOOLS:
		for slot in Racks.UNITS:
			if rack_tool.is_empty() and int(session.tool_racks[slot].get(tool,0))>0:rack_tool=tool;rack_slot=slot
	var rack_count=int(session.tool_racks[rack_slot][rack_tool])
	await press(session,"mode_rack_remove_"+rack_slot+"_"+rack_tool)
	check(session.tool_racks[rack_slot][rack_tool]==rack_count-1 and session.run_state.tool_racks[rack_slot][rack_tool]==rack_count-1,"expedition rack remove touch syncs finite run stock")
	await press(session,"mode_rack_add_"+rack_slot+"_"+rack_tool)
	check(session.tool_racks[rack_slot][rack_tool]==rack_count and session.run_state.tool_racks[rack_slot][rack_tool]==rack_count,"expedition rack add touch restores allocation")
	check(button(session,"mode_rack_add_"+rack_slot+"_"+rack_tool).disabled,"expedition rack add remains blocked at finite stock limit")
	await press(session,"run_return");Modes.start(front);await settle();session=host.get_node("ExpeditionSession")
	check(session.screen=="expedition_menu" and session.run_state==picked,"picked reload has no second grant or slate")
	await press(session,"run_begin")
	check(session.screen=="mission" and session.run_state.in_flight and session.sim.paused,"touch begins next authored operation paused")
	var launched_racks:Dictionary=session.run_state.tool_racks
	check(session.sim.mission.tool_racks==launched_racks,"simulation starts with the authoritative launched racks")
	check(session.run_state.stock==picked.stock,"launch retains selected stock including unloaded reserves")
	var allocations_fit_stock=true
	for tool in RunTable.TOOLS:
		var allocated=Racks.total(launched_racks,tool)
		if allocated>picked.stock[tool]:allocations_fit_stock=false
		if tool in preload("res://src/equipment/field_tools.gd").field_ids():
			if not session.sim.mission.field_tools.counts.has(tool) or session.sim.mission.field_tools.counts[tool]!=allocated:allocations_fit_stock=false
		else:
			if not session.sim.tools.has(tool) or session.sim.tools[tool]!=allocated:allocations_fit_stock=false
	check(allocations_fit_stock,"launched rack allocations fit selected finite stock and simulation counts")
	check(host.sim.snapshot()==snapshot and FileAccess.get_file_as_bytes(path)==campaign_bytes and FileAccess.get_file_as_string(path+".career")=="career resources preserved","campaign simulation/archive and career bytes unchanged")
	session._return();await settle();host.queue_free();await settle()
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for choice in 3:await offer_case(shape,choice)
	print("RUNS OFFER UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
