extends RefCounted
# Between-operation economy controls: balances, costs, preset, repair, manufacturing,
# research and frame unlocks. Main owns state; every action saves and redraws so prices
# stay current. Nothing here changes sensing, pause or combat.
# Seams: CampaignFlow (operations entry, briefing launch, debrief settle, new campaign preset),
# Main._show_economy forwarder, EquipmentContext frame rows. Android Back returns to
# Operations through Main's ordinary rule. Revert: economy_table.enabled=false hides it all.
const Economy=preload("res://src/campaign/economy.gd")
const Table=preload("res://src/campaign/economy_table.gd")
const Save2Table=preload("res://src/persistence/save_states/save2_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Inventory=preload("res://src/campaign/fleet_inventory.gd")
static func _redraw(host,action:Callable)->void:
	var reading_position=host.scroll.scroll_vertical
	action.call()
	host._save_archive()
	show(host)
	var heading=host.panel_box.get_child(0)
	(func():
		await host.get_tree().process_frame
		if is_instance_valid(heading) and heading.get_parent()==host.panel_box:host.scroll.scroll_vertical=reading_position
	).call_deferred()
static func _spend_button(host,text:String,cost:Dictionary,action:Callable,id:String)->Button:
	var button=host._button(host.panel_box,"%s · %s"%[text,Economy.fmt(cost)],func():_redraw(host,action),id)
	button.disabled=not Economy.can_pay(host.economy,cost)
	return button
# Operations entry: a supplies button.
static func entry(host)->void:
	if Table.enabled:host._button(host.panel_box,"SUPPLIES",host._show_economy,"economy")
# The preset choice, shown at the top of Operations while the campaign is pristine.
static func pristine_picker(host)->void:
	if not Table.enabled or not host._campaign_pristine():return
	picker(host,host.economy,func(id,iron):
		host.economy=Economy.new_state(id,iron);host._save_archive();host._show_campaign())
# Preset buttons and the Ironman flag for a campaign that has not started.
static func picker(host,e:Dictionary,changed:Callable)->void:
	host._menu_text("CAMPAIGN PRESET · %s%s"%[Economy.preset(e).name," · IRONMAN" if e.ironman else ""],17)
	for id in Table.ORDER:
		var chosen=e.preset==id
		var button=host._button(host.panel_box,"%s%s · %s"%[Table.PRESETS[id].name," · SELECTED" if chosen else "",Table.PRESETS[id].note],
			func():changed.call(id,e.ironman),"eco_pick_"+id)
		button.disabled=chosen
	host._button(host.panel_box,"IRONMAN · ON (TAP TO TURN OFF)" if e.ironman else "IRONMAN · OFF (TAP TO TURN ON)",
		func():changed.call(e.preset,not e.ironman),"eco_pick_ironman")
	host._menu_text("Ironman charges every fitting on every launch and locks the preset once play begins.\n"+Save2Table.IRONMAN_LINE,14)
# Erase confirmation: the next campaign's preset is chosen here and applied by new_campaign.
static func draft_picker(host)->void:
	if not Table.enabled:return
	if not host.has_meta("economy_draft"):host.set_meta("economy_draft",Economy.new_state())
	picker(host,host.get_meta("economy_draft"),func(id,iron):
		host.set_meta("economy_draft",Economy.new_state(id,iron));host._confirm_new_campaign())
static func take_draft(host)->Dictionary:
	var draft=host.get_meta("economy_draft",Economy.new_state())
	if host.has_meta("economy_draft"):host.remove_meta("economy_draft")
	return draft
# ---- launch ----------------------------------------------------------------
static func fitted(host)->Dictionary:
	return Economy.lock_frames(host.economy,host.expedition,host.fitted_equipment)
static func launch_cost(host)->Dictionary:
	return Economy.refit_cost(host.economy,fitted(host))
static func begin_text(host)->String:
	var cost=launch_cost(host)
	if Economy.can_pay(host.economy,cost):return "ENTER WATER\nSTART PAUSED"
	return "NEED %s\nOR FIT BARE"%Economy.shortfall(host.economy,cost)
static func can_begin(host)->bool:
	return Economy.can_pay(host.economy,launch_cost(host))
# Launch through Main's ordinary start, then pay for the refit and apply craft condition.
static func begin(host,index:int)->void:
	if not Table.enabled:
		host._start_mission(index)
		return
	if not can_begin(host):return
	host.fitted_equipment=fitted(host)
	var cost_fit=host.fitted_equipment.duplicate(true)
	host._start_mission(index)
	if host.screen=="mission" and host.active_started:
		Economy.charge_launch(host.economy,cost_fit);Economy.apply_launch(host.economy,host.sim)
static func briefing_line(host)->String:
	if not Table.enabled:return ""
	return "%s · %s · NEXT LAUNCH %s"%[Economy.balance_text(host.economy),Economy.preset(host.economy).name,Economy.fmt(launch_cost(host))]
# ---- settlement ------------------------------------------------------------
# Called once per debrief before campaign recovery changes research material.
static func settle(host,first_recovery:bool,fleet_before:Dictionary)->void:
	if not Table.enabled or host.sim.mission==null:return
	var mission=host.sim.mission;var won=host.sim.outcome=="won"
	host.fleet=Economy.absorb_losses(host.economy,fleet_before,host.fleet)
	var state=mission.get("glass_reach",mission.get("iron_choir",{}))
	var artifact=mission.get("recovered",false) and state.get("retrieved",false) and state.get("artifact",{}).get("state","")=="recovered"
	artifact=artifact and state.artifact.get("id","") not in host.expedition.get("research",{}).get("materials",[])
	var recovered=mission.get("module_recovery",{}).get("result",{}).get("recovered",[])
	Economy.settle(host.economy,{"outcome":host.sim.outcome,"hull":host.sim.hull,"alive":[host.sim.units[1].alive,host.sim.units[2].alive],
		"first":first_recovery and won,"recovered":recovered.size() if first_recovery and won else 0,"artifact":artifact,
		"key":"%d|%s|%d"%[host.mission_index,host.sim.outcome,roundi(host.sim.elapsed*100.)]})
# ---- the supplies screen -----------------------------------------------------
static func show(host)->void:
	var e=host.economy
	host.screen="economy";host.sim.paused=true;host._clear_menu()
	host._button(host.panel_box,"BACK TO OPERATIONS",host._show_campaign,"back")
	host._menu_text("SUPPLIES / COSTS",30)
	host._menu_text("%s\nPRESET · %s · %s%s"%[Economy.balance_text(e),Economy.preset(e).name,Economy.preset(e).note," · IRONMAN" if e.ironman else ""],16)
	host._menu_text(e.report,14)
	if e.ironman:
		host._button(host.panel_box,"PRESET LOCKED · IRONMAN",func():pass,"eco_preset").disabled=true
		host._menu_text(Save2Table.IRONMAN_LINE,15)
	else:
		var next=Table.ORDER[(Table.ORDER.find(e.preset)+1)%Table.ORDER.size()]
		host._button(host.panel_box,"PRESET · %s → %s"%[Economy.preset(e).name,Table.PRESETS[next].name],
			func():_redraw(host,func():Economy.cycle_preset(e)),"eco_preset")
		var armed=host.get_meta("economy_iron_armed",false)
		host._menu_text(Save2Table.IRONMAN_LINE,15)
		host._button(host.panel_box,"CONFIRM IRONMAN · CANNOT BE UNDONE" if armed else "IRONMAN · OFF → ON (ONE WAY)",
			_ironman.bind(host),"eco_ironman")
	host._menu_text("NEXT LAUNCH REFIT · %s\nA craft keeps what it carried last launch for free. A bare standard Quietus always launches free."%
		Economy.fmt(launch_cost(host)),15)
	_repairs(host)
	_manufacturing(host)
	_research(host)
	_unlocks(host)
	_spend_button(host,"REFINE SCRAP TO %d ALLOY"%Table.REFINE.alloy,Economy.refine_cost(e),func():Economy.refine(e),"eco_refine")
	host._button(host.panel_box,"STRIP ALL TO BARE · FREE",func():_redraw(host,func():host.fitted_equipment=Catalog.default_loadout()),"eco_bare")
	if e.last_fit!=host.fitted_equipment:
		host._button(host.panel_box,"REVERT TO LAST LAUNCH FIT · FREE",func():_redraw(host,_revert_last.bind(host)),"eco_last")
	host.call_deferred("_layout")
static func _ironman(host)->void:
	if host.get_meta("economy_iron_armed",false):
		host.remove_meta("economy_iron_armed");_redraw(host,Economy.set_ironman.bind(host.economy))
	else:
		host.set_meta("economy_iron_armed",true);show(host)
static func _revert_last(host)->void:
	var available=Inventory.available(host._equipment_entitlements(),host.fleet)
	host.fitted_equipment=Inventory.reconcile_fitting(host.economy.last_fit,available)
static func _do_research(host,material:String)->void:
	host.expedition=Economy.research(host.economy,host.expedition,material);host._sync_craft_upgrades()
static func _repairs(host)->void:
	var e=host.economy
	for target in Table.TARGETS:
		var cost=Economy.repair_cost(e,target)
		if cost.is_empty():
			host._menu_text("%s · CONDITION %d%%"%[Table.LABELS[target],e.cond[target]],14)
			continue
		_spend_button(host,"REPAIR %s · %d%%"%[Table.LABELS[target],e.cond[target]],cost,func():Economy.repair(e,target),"eco_repair_"+target)
static func _manufacturing(host)->void:
	var e=host.economy;var lost=Economy.lost_items(host.fleet)
	for item in host._equipment_entitlements():
		if not Catalog.ITEMS.has(item):continue
		var cost=Economy.item_cost(item,e);var name=Catalog.ITEMS[item].name
		if item in lost:
			_spend_button(host,"REBUILD LOST %s"%name,cost,func():host.fleet=Economy.rebuild(e,host.fleet,item),"eco_make_"+item)
		elif e.spares.get(item,0)>0:
			host._menu_text("SPARE %s · BUILT. It replaces this fitting if lost in a dive."%name,14)
		elif Economy.spare_allowed(item):
			_spend_button(host,"BUILD SPARE %s"%name,cost,func():Economy.build_spare(e,item),"eco_make_"+item)
static func _research(host)->void:
	var e=host.economy
	for material in Research.pending(host.expedition):
		var item=Research.item_of(material);var name=Economy.target_name(item)
		_spend_button(host,"RESEARCH %s"%name,Economy.research_cost(e),_do_research.bind(host,material),"eco_research_"+material)
static func _unlocks(host)->void:
	var e=host.economy;var seen=[]
	for unit in [0,1]:
		for id in Catalog.frames(unit):
			var unlock=Economy.unlock_of(unit,id)
			if unlock.is_empty() or unlock in seen or Economy.is_unlocked(e,host.expedition,unlock):continue
			seen.append(unlock)
			_spend_button(host,"UNLOCK %s"%Catalog.frames(unit)[id].name.to_upper(),Economy.unlock_cost(e,unlock),
				func():Economy.buy_unlock(e,unlock),"eco_unlock_"+unlock.replace(":","_"))
