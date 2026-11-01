extends RefCounted
# Touch-first career menus use Main's existing scroll column and 48dp buttons.
# All spending uses the existing economy APIs.
const Table=preload("res://src/campaign/career/career_table.gd")
const State=preload("res://src/campaign/career/career_state.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const EquipmentView=preload("res://src/presentation/equipment_context.gd")
const Riders=preload("res://src/campaign/career/riders.gd")
static func heading(host,title:String,screen:String)->void:
	host.sim.paused=true;host.screen=screen;host._clear_menu();host._menu_text(title,30)
	host._menu_text(Economy.balance_text(host.economy),17)
	if host.save_failed:
		host._menu_text("SAVE PENDING · "+str(host.campaign_host.get_meta("career_save_error","")),17)
		host._button(host.panel_box,"RETRY SAVE",func():host._save_archive();host._show_campaign(),"career_retry")
	host.call_deferred("_layout")
static func show(host)->void:
	heading(host,"NAVAL CAREER / CONTRACT BOARD","career_board")
	if host.active_started:
		host._button(host.panel_box,"RESUME CONTRACT DIVE",host._enter_water,"career_resume")
		host._button(host.panel_box,"ABANDON CONTRACT · LOSE STANDING",func():confirm_abandon(host),"career_abandon")
		host._menu_text("Finish or abandon this contract before selecting another. Equipment changes apply between dives.",17)
		host._menu_text(host.sim.rider_status(),17)
		return
	host._button(host.panel_box,"RETURN TO MODES",host._return,"career_return")
	host._menu_text("RECOVERY: standing +%d and contract pay plus salvage. LOSS: standing %d and no contract pay. Recovery jobs remain open at every standing. Pay and tuning are provisional."%[Table.SUCCESS,Table.LOSS],16)
	for faction in Table.FACTIONS:
		host._menu_text("%s · STANDING %d"%[Table.FACTIONS[faction],host.career_state.standing[faction]],22)
		for id in Table.CONTRACTS:
			var c=Table.CONTRACTS[id]
			if c.faction!=faction:continue
			var available=State.open(host.career_state,id)
			var title=host.Simulation.Missions.make(c.op,host._launch_context(c.op)).title
			var button=host._button(host.panel_box,"%s\n%s · PAY %s"%[title.to_upper(),"OPEN" if available else "LOCKED · NEED STANDING %d"%c.get("standing",Table.MIN_STANDING),Economy.fmt(c.reward)],host._select_contract.bind(id),"career_contract_"+id)
			button.disabled=not available or host.save_failed
			host._menu_text(Riders.description(State.rider_offer(host.career_state,id)),16)
	host._button(host.panel_box,"SUPPLIES / RESEARCH",host._show_economy,"career_supplies")
	host._button(host.panel_box,"FLEET / FITTINGS",host._show_fittings,"career_fittings")
	host._menu_text("%d RECOVERED · %d LOST\n%s"%[host.career_state.recovered,host.career_state.lost,host.career_state.report],17)
static func confirm_abandon(host)->void:
	heading(host,"ABANDON THIS CONTRACT?","career_abandon")
	host._menu_text("This records a loss, reduces the client's standing and forfeits contract pay. Your regional career continues.",17)
	host._button(host.panel_box,"KEEP DIVING",host._enter_water,"career_keep")
	host._button(host.panel_box,"CONFIRM CONTRACT LOSS",func():host._debrief(true),"career_confirm_abandon")
static func briefing(host)->void:
	var c=Table.CONTRACTS[host.selected_contract]
	var mission=host.Simulation.Missions.make(c.op,host._launch_context(c.op))
	heading(host,"CAREER / "+mission.title.to_upper(),"career_briefing")
	host._menu_text("%s\n%s\n%s"%[Table.FACTIONS[c.faction],c.brief,mission.brief],18)
	host._menu_text("RECOVERY PAY · %s\nSTANDING %d · SUCCESS +%d / LOSS %d\nNEXT LAUNCH · %s"%[Economy.fmt(c.reward),host.career_state.standing[c.faction],Table.SUCCESS,Table.LOSS,Economy.fmt(preload("res://src/presentation/economy_panel.gd").launch_cost(host))],17)
	host._menu_text("Paused physical operation. Oxygen, film and field tools replenish each dive. Damage persists through the existing economy; bare standard equipment always launches free. Interrupted dives resume paused; abandoning records a contract loss.",16)
	var rider=State.rider_offer(host.career_state,host.selected_contract)
	host._menu_text(Riders.description(rider),17)
	if not rider.is_empty():
		host._button(host.panel_box,"RIDER · "+("ACCEPTED" if host.accept_rider else "DECLINED"),preload("res://src/presentation/rider_choice.gd").toggle.bind(host,briefing.bind(host)),"career_rider")
	var begin=host._button(host.panel_box,"ACCEPT CONTRACT · START PAUSED",host._begin,"career_begin")
	begin.disabled=host.save_failed or not preload("res://src/presentation/economy_panel.gd").can_begin(host)
	host._button(host.panel_box,"FLEET / FITTINGS",host._show_fittings,"career_fittings")
	host._button(host.panel_box,"BACK TO CONTRACT BOARD",host._show_campaign,"career_board")
static func spend(host,title:String,cost:Dictionary,action:Callable,id:String)->void:
	var button=host._button(host.panel_box,"%s · %s"%[title,Economy.fmt(cost)],host._change.bind(action,host._show_economy),id)
	button.disabled=host._mutations_blocked() or not Economy.can_pay(host.economy,cost)
static func supplies(host)->void:
	if host.active_started:return
	heading(host,"CAREER / SUPPLIES AND RESEARCH","career_supplies")
	host._button(host.panel_box,"BACK TO CONTRACT BOARD",host._show_campaign,"career_board")
	host._menu_text("Fleet condition and resources belong to this career. Research requires material physically recovered on a contract and its received record.",17)
	for target in Economy.TARGETS:
		spend(host,"REPAIR %s · %d%%"%[Economy.Table.LABELS[target],host.economy.cond[target]],Economy.repair_cost(host.economy,target),func():Economy.repair(host.economy,target),"career_repair_"+target)
	spend(host,"REFINE SCRAP TO ALLOY",Economy.refine_cost(host.economy),func():Economy.refine(host.economy),"career_refine")
	for material in Research.pending(host.expedition):
		spend(host,"RESEARCH "+Economy.target_name(Research.item_of(material)),Economy.research_cost(host.economy),func():
			host.career_state.progress=Economy.research(host.economy,host.expedition,material);host._bind_state()
		,"career_research_"+material)
	host._menu_text(Research.detail(host.expedition),16)
	host._menu_text("MANUFACTURE / CONVENTIONAL FITTINGS",22)
	for item in Catalog.ITEMS:
		if item in host._equipment_entitlements() or item in Economy.Table.ALIEN:continue
		spend(host,"BUILD "+Catalog.ITEMS[item].name,Economy.item_cost(item,host.economy),func():State.manufacture(host.career_state,item),"career_build_"+item)
static func fittings(host)->void:
	if host.active_started:return
	heading(host,"CAREER / FLEET DEVELOPMENT","career_fittings")
	host._button(host.panel_box,"BACK TO CONTRACT BOARD",host._show_campaign,"career_board")
	host._button(host.panel_box,"SUPPLIES / MANUFACTURE / RESEARCH",host._show_economy,"career_supplies")
	host._menu_text("Unlock hulls and chassis with existing alloy prices. Manufacture conventional modules or research recovered alien material, then fit it for the next dive.",17)
	_guard_fittings(host,EquipmentView.loadout(host,host.fitted_equipment,func(key,id):host._choose_equipment(key,id,-1)))
	preload("res://src/presentation/mode_racks_view.gd").show(host,false)
	_guard_fittings(host,EquipmentView.fitting(host,host._equipment_context(),func(key,id):host._choose_equipment(key,id,-1)))
static func _guard_fittings(host,buttons:Array)->void:
	for button in buttons:
		# Retain deferred dispatch and recheck when an already-rendered row is tapped.
		for connection in button.pressed.get_connections():
			var action:Callable=connection.callable
			button.pressed.disconnect(action)
			button.pressed.connect(host._apply_fitting.bind(action),CONNECT_DEFERRED)
		button.disabled=button.disabled or host._mutations_blocked()
