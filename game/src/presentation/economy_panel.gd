extends RefCounted
const Names=preload("res://src/names.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const FitCard=preload("res://src/presentation/fit_surface/fit_card.gd")
# Between-operation economy controls: balances, costs, preset, repair, manufacturing,
# research and frame unlocks. Main owns state; every action saves and redraws so prices
# stay current. Nothing here changes sensing, pause or combat.
# Seams: CampaignFlow (operations entry, briefing launch, debrief settle, new campaign preset),
# Main._show_economy forwarder, EquipmentContext frame rows. Android Back returns to
# Operations through Main's ordinary rule. Revert: economy_table.enabled=false hides it all.
const Options=preload("res://src/campaign/economy_options.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Table=preload("res://src/campaign/economy_table.gd")
const Save2Table=preload("res://src/persistence/save_states/save2_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Inventory=preload("res://src/campaign/fleet_inventory.gd")
const PrepColumns=preload("res://src/presentation/prep_columns.gd")
const Hulls=preload("res://src/equipment/hulls.gd")
const HAVE_LINE="You have: %s."
const SOURCES_LINE="Scrap and cells come from each dive's salvage; alloy comes from alien material you recover, or from refining %d scrap into %d alloy."
const SHORT_LINE="You are short by %s."
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
const IRONMAN_RISK="Ironman permanently loses unrecovered drones and fittings. Replacements cost supplies. Empty bays can launch. Ironman charges every fitting on every launch and locks the preset once play begins."
const EASIER_LINE="An easier preset cannot be switched back."
const BARE_LINE="Clears every fitting from the next launch. You keep them all."
const HEADING_DIFFICULTY="DIFFICULTY"
const ARMED_EASIER="economy_easier_armed"
# What a frame changes against the standard frame of its unit, worked out from the frame table itself.
# A hull has life support, speed and pulse cost; a drone has battery and passive reach.
static func frame_effect(unit:int,id:String)->String:
	var frames=Catalog.frames(unit);var base=frames.standard;var frame=frames[id];var parts=[]
	_ratio(parts,frame.noise/base.noise,"motion sound %d%% %s","higher","lower")
	_ratio(parts,frame.endurance/base.endurance,("life support" if unit==0 else "battery")+" %d%% %s","longer","shorter")
	_ratio(parts,frame.get("speed",1.0)/base.get("speed",1.0),"%d%% %s","faster","slower")
	_ratio(parts,frame.get("reach",1.0)/base.get("reach",1.0),"passive reach %d%% %s","longer","shorter")
	_ratio(parts,frame.get("pulse",1.0)/base.get("pulse",1.0),"SONAR pulses %d%% %s","dearer","cheaper")
	for mount in Hulls.MOUNT_TYPES:
		if mount=="CARGO":continue
		var have=frame.mounts.count(mount);var standard=base.mounts.count(mount)
		if have==0 and standard>0:parts.append("no %s mount"%mount.to_lower())
		elif have>standard:parts.append("%d %s mounts"%[have,mount.to_lower()])
	if frame.cargo!=base.cargo:parts.append("no winch cargo" if frame.cargo==0 else "%d cargo %s (standard %d)"%[frame.cargo,"place" if frame.cargo==1 else "places",base.cargo])
	if frame.power!=base.power:parts.append("power %d (standard %d)"%[frame.power,base.power])
	if parts.is_empty():return "Same as the standard frame."
	var line="; ".join(parts)
	return line[0].to_upper()+line.substr(1)+"."
static func _ratio(parts:Array,ratio:float,pattern:String,up:String,down:String)->void:
	var pct=roundi(absf(ratio-1.0)*100.0)
	if pct>0:parts.append(pattern%[pct,up if ratio>1.0 else down])
static func _spend_button(host,text:String,cost:Dictionary,action:Callable,id:String,note:String="")->Button:
	var button=host._button(host.panel_box,"%s · %s"%[text,Economy.fmt(cost)],func():_redraw(host,action),id)
	button.disabled=not Economy.can_pay(host.economy,cost)
	if not note.is_empty():host._menu_text(note,14)
	# A dim button says why, in the words the frame cards on Fittings use.
	if button.disabled:host._menu_text(SHORT_LINE%Economy.shortfall(host.economy,cost),14)
	return button
# One plain line of what the player holds, and the first time per visit where each kind comes from.
static func currency_text(e:Dictionary)->String:
	return HAVE_LINE%" · ".join(Table.RES.map(func(key):return "%d %s"%[e.stock.get(key,0),Table.NAMES[key].to_lower()]))
static func currency(host,fresh:bool)->void:
	currency_line(host)
	if fresh:currency_hint(host)
static func currency_line(host)->void:
	if Table.enabled:host._menu_text(currency_text(host.economy),16)
static func currency_hint(host)->void:
	if Table.enabled:host._menu_text(SOURCES_LINE%[Table.REFINE.scrap,Table.REFINE.alloy],14)
# Operations entry: a supplies button.
static func entry(host)->void:
	if Table.enabled:
		host._button(host.panel_box,"SUPPLIES",host._show_economy,"economy")
		if not host._campaign_pristine() or host.active_started or Options.state(host.economy).started:
			_easier_picker(host,host._show_campaign)
static func _easier_picker(host,redraw:Callable)->void:
	var e=host.economy
	var pending=Options.state(e).pending
	if not pending.is_empty():host._menu_text("%s is queued. It takes effect at the next dock after a dive; the current dive keeps its rules."%Table.PRESETS[pending].name.capitalize(),14)
	for id in Options.choices(e):
		# The change cannot be undone, so the first tap arms it and the second applies it.
		var armed=host.get_meta(ARMED_EASIER,"")==id
		host._button(host.panel_box,("CONFIRM EASIER: %s · CANNOT BE UNDONE" if armed else "MAKE IT EASIER: %s, FROM THE NEXT DOCK")%Table.PRESETS[id].name,func():
			if not armed:
				host.set_meta(ARMED_EASIER,id);redraw.call();return
			host.remove_meta(ARMED_EASIER)
			if Options.request(e,id):host._save_archive();redraw.call()
		,"eco_easier_"+id)
	if not Options.choices(e).is_empty():host._menu_text(EASIER_LINE,14)

# The preset choice, shown at the top of Operations while the campaign is pristine.
static func pristine_picker(host)->void:
	if not Table.enabled or not host._campaign_pristine() or host.active_started or Options.state(host.economy).started or not host.economy.settled.is_empty():return
	picker(host,host.economy,func(id,iron,custom):
		host.economy=_choice(id,iron,custom);host._save_archive();host._show_campaign())
# Preset buttons and the Ironman flag for a campaign that has not started.
static func picker(host,e:Dictionary,changed:Callable)->void:
	host._menu_text("CAMPAIGN PRESET · %s%s"%[Options.label(e)," · IRONMAN" if e.ironman else ""],17)
	for id in Table.ORDER:
		var chosen=e.preset==id
		var button=host._button(host.panel_box,"%s%s · %s"%[FitCard.CHOSEN+" · " if chosen else "",Table.PRESETS[id].name,Table.PRESETS[id].note],
			func():changed.call(id,e.ironman,Options.state(e).custom),"eco_pick_"+id)
		button.disabled=chosen
		UiStyle.apply_card(button,chosen,false)
	host._button(host.panel_box,"IRONMAN · ON (TAP TO TURN OFF)" if e.ironman else "IRONMAN · OFF (TAP TO TURN ON)",
		func():changed.call(e.preset,not e.ironman,Options.state(e).custom),"eco_pick_ironman")
	host._menu_text(IRONMAN_RISK+"\n"+Save2Table.IRONMAN_LINE,14)
	var custom=Options.state(e).custom
	host._button(host.panel_box,"ADVANCED / "+("OFF" if custom.is_empty() else "ON / CUSTOM"),func():
		var values={}
		if custom.is_empty():
			for key in Table.ADVANCED:values[key]=Table.ADVANCED[key].default
		changed.call(e.preset,e.ironman,values)
	,"eco_advanced")
	if not custom.is_empty():
		host._menu_text("CUSTOM campaign recorded permanently. Repair affects repairs only; income scales salvage. Starting stock scales 8 scrap / 10 cells / 0 alloy.",14)
		for key in Table.ADVANCED:
			var rule=Table.ADVANCED[key]
			host._button(host.panel_box,"%s / %.2fx (%.2f to %.2f)"%[{"repair":"REPAIR COST","income":"INCOME","start":"STARTING STOCK"}[key],custom[key],rule.min,rule.max],func():
				var values=custom.duplicate();values[key]=rule.min if values[key]>=rule.max else values[key]+rule.step
				changed.call(e.preset,e.ironman,values)
			,"eco_advanced_"+key)
static func _choice(id:String,iron:bool,custom:Dictionary)->Dictionary:
	var e=Economy.new_state(id,iron);Options.configure(e,custom);return e
# Erase confirmation: the next campaign's preset is chosen here and applied by new_campaign.
static func draft_picker(host)->void:
	if not Table.enabled:return
	if not host.has_meta("economy_draft"):host.set_meta("economy_draft",Economy.new_state())
	picker(host,host.get_meta("economy_draft"),func(id,iron,custom):
		host.set_meta("economy_draft",_choice(id,iron,custom));host._confirm_new_campaign())
static func take_draft(host)->Dictionary:
	var draft=host.get_meta("economy_draft",Economy.new_state())
	if host.has_meta("economy_draft"):host.remove_meta("economy_draft")
	return draft
# ---- launch ----------------------------------------------------------------
static func fitted(host)->Dictionary:
	return Economy.Losses.fitting(host.economy,Economy.lock_frames(host.economy,host.expedition,host.fitted_equipment))
static func launch_cost(host)->Dictionary:
	var cost=Economy.refit_cost(host.economy,fitted(host))
	var extra=preload("res://src/equipment/tool_racks.gd").cost(Economy.Losses.racks(host.economy,host.tool_racks),host.upgrade,host.economy)
	for key in extra:cost[key]=cost.get(key,0)+extra[key]
	return cost
static func begin_text(host)->String:
	var why=preload("res://src/equipment/tool_racks.gd").reason(fitted(host),Economy.Losses.racks(host.economy,host.tool_racks))
	if not why.is_empty():return "UNLOAD TOOLS / CARGO FULL"
	var cost=launch_cost(host)
	if Economy.can_pay(host.economy,cost):return "ENTER WATER\nSTART PAUSED"
	return "NEED %s\nOR FIT BARE"%Economy.shortfall(host.economy,cost)
static func can_begin(host)->bool:
	return preload("res://src/equipment/tool_racks.gd").reason(fitted(host),Economy.Losses.racks(host.economy,host.tool_racks)).is_empty() and Economy.can_pay(host.economy,launch_cost(host))
# Launch through Main's ordinary start, then pay for the refit and apply craft condition.
static func begin(host,index:int)->void:
	if not Table.enabled:
		host._start_mission(index)
		return
	if not can_begin(host):return
	host.fitted_equipment=fitted(host)
	var cost_fit=host.fitted_equipment.duplicate(true)
	var tool_cost=preload("res://src/equipment/tool_racks.gd").cost(Economy.Losses.racks(host.economy,host.tool_racks),host.upgrade,host.economy)
	var previous=host.sim.mission
	host._start_mission(index)
	if host.screen=="mission" and host.active_started and not is_same(previous,host.sim.mission):
		Economy.pay(host.economy,tool_cost)
		Economy.charge_launch(host.economy,cost_fit);Economy.apply_launch(host.economy,host.sim)
		host._save_archive()
static func briefing_line(host)->String:
	if not Table.enabled:return ""
	return "%s · %s · NEXT LAUNCH %s"%[Economy.balance_text(host.economy),Options.label(host.economy),Economy.fmt(launch_cost(host))]+("\nEMPTY DRONE BAYS: "+", ".join(Economy.Losses.state(host.economy).drones.map(func(id):return "A" if id==1 else "B")) if Economy.Losses.active(host.economy) and not Economy.Losses.state(host.economy).drones.is_empty() else "")
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
	Economy.settle(host.economy,{"outcome":host.sim.outcome,"hull":host.sim.hull,"alive":[host.sim.DroneBay.home(host.sim.units[1]),host.sim.DroneBay.home(host.sim.units[2])],
		"mission":mission,"first":first_recovery and won,"recovered":recovered.size() if first_recovery and won else 0,"artifact":artifact,
		"blackwater_handoff":preload("res://src/simulation/blackwater_delivery.gd").handoff_paid(mission),
		"key":"%d|%s|%d"%[host.mission_index,host.sim.outcome,roundi(host.sim.elapsed*100.)]})
	if Economy.Losses.active(host.economy):
		for item in Economy.Losses.state(host.economy).last:
			if item not in Economy.Losses.state(host.economy).modules:host.fleet=Inventory.rebuild(host.fleet,item)
# ---- the supplies screen -----------------------------------------------------
# WP-62: on a wide screen what you hold and what the next launch costs are the left column, and the repairs and
# purchases the right (PrepColumns, as on Fittings). A narrow screen keeps the one list in its old order.
static func show(host)->void:
	# A redraw after a purchase is not a new visit, so the first-visit note stays away.
	var fresh=host.screen!="economy"
	host.screen="economy";host.sim.paused=true;host._clear_menu()
	PrepColumns.back_line(host,"SUPPLIES / COSTS","BACK TO OPERATIONS",host._show_campaign,"back")
	var columns=PrepColumns.open(host,show.bind(host))
	var left=columns[0];var right=columns[1];var wide=PrepColumns.is_wide(host)
	# A confirmation armed on an earlier visit does not carry over.
	if fresh:
		for key in [ARMED_EASIER,"economy_iron_armed"]:
			if host.has_meta(key):host.remove_meta(key)
	PrepColumns.into(host,left,_holdings.bind(host,fresh))
	PrepColumns.into(host,left,_launch_note.bind(host))
	PrepColumns.into(host,right,_purchases.bind(host))
	# The risky one-way choices come last, under their own heading.
	PrepColumns.into(host,right,_preset_controls.bind(host))
	host.call_deferred("_layout")
# What the player holds: supplies, preset, the last dive's report and the crew.
static func _holdings(host,fresh:bool)->void:
	var e=host.economy
	currency(host,fresh)
	host._menu_text("PRESET · %s · %s%s"%[Options.label(e),Economy.preset(e).note," · IRONMAN" if e.ironman else ""],16)
	# A dive that can be resumed is the current state; the default "No dive yet" report would be false.
	var diving=host.active_started and host.sim.outcome.is_empty()
	if diving:host._menu_text(host.CampaignFlow.in_progress_line(host),14)
	if not (diving and e.report.begins_with("No dive yet")):host._menu_text(e.report,14)
	preload("res://src/presentation/crew/crew_view.gd").supplies(host)
# The campaign preset and the one-way Ironman switch.
static func _preset_controls(host)->void:
	var e=host.economy
	host._menu_text(HEADING_DIFFICULTY,17)
	if e.ironman:
		host._button(host.panel_box,"PRESET LOCKED · IRONMAN",func():pass,"eco_preset").disabled=true
		host._menu_text(Save2Table.IRONMAN_LINE,15)
	else:
		_easier_picker(host,show.bind(host))
		var armed=host.get_meta("economy_iron_armed",false)
		host._menu_text(IRONMAN_RISK+"\n"+Save2Table.IRONMAN_LINE,15)
		var iron_button=host._button(host.panel_box,"CONFIRM IRONMAN · CANNOT BE UNDONE" if armed else "IRONMAN · OFF → ON (ONE WAY)",
			_ironman.bind(host),"eco_ironman")
		if not Options.state(e).pending.is_empty():
			iron_button.disabled=true
			iron_button.text="IRONMAN / EASIER PRESET QUEUED"
			host._menu_text("Easier preset queued; Ironman can be enabled after the next dock.",14)
# The note sits inside the same side margin as the cards, clear of the panel edge.
static func _launch_note(host)->void:
	var note=MarginContainer.new();note.add_theme_constant_override("margin_left",UiStyle.PREP_TEXT_INSET);note.add_theme_constant_override("margin_right",UiStyle.PREP_TEXT_INSET)
	var note_box=VBoxContainer.new();note.add_child(note_box);host.panel_box.add_child(note)
	PrepColumns.into(host,note_box,func():host._menu_text("NEXT LAUNCH REFIT · %s\nA craft keeps what it carried last launch for free. A bare standard Quietus always launches free."%
		Economy.fmt(launch_cost(host)),15))
# Repairs, manufacturing, research, unlocks and the free refits.
static func _purchases(host)->void:
	var e=host.economy
	_repairs(host)
	_manufacturing(host)
	_research(host)
	_unlocks(host)
	_spend_button(host,"REFINE SCRAP TO %d ALLOY"%Table.REFINE.alloy,Economy.refine_cost(e),func():Economy.refine(e),"eco_refine")
	host._button(host.panel_box,"STRIP ALL TO BARE · FREE",func():_redraw(host,func():host.fitted_equipment=Catalog.default_loadout()),"eco_bare")
	host._menu_text(BARE_LINE,14)
	if e.last_fit!=host.fitted_equipment:
		host._button(host.panel_box,"REVERT TO LAST LAUNCH FIT · FREE",func():_redraw(host,_revert_last.bind(host)),"eco_last")
static func _ironman(host)->void:
	if host.get_meta("economy_iron_armed",false):
		host.remove_meta("economy_iron_armed");_redraw(host,Economy.set_ironman.bind(host.economy))
	else:
		host.set_meta("economy_iron_armed",true);show(host)
static func _revert_last(host)->void:
	var available=Inventory.available(host._equipment_entitlements(),host.fleet,host.economy)
	host.fitted_equipment=Inventory.reconcile_fitting(host.economy.last_fit,available)
static func _do_research(host,material:String)->void:
	var spent=host.expedition.get("research",{}).get("spent",[]).size()
	host.expedition=Economy.research(host.economy,host.expedition,material);host._sync_craft_upgrades()
	if host.get("sound")!=null and host.expedition.get("research",{}).get("spent",[]).size()>spent:host.sound.event_cue("research_complete")
static func _repairs(host)->void:
	var e=host.economy
	for target in Table.TARGETS:
		if (target==Names.CRAFT_DRONE_A and Economy.Losses.missing(e,1)) or (target==Names.CRAFT_DRONE_B and Economy.Losses.missing(e,2)):
			host._menu_text("%s / BAY EMPTY / MANUFACTURE REPLACEMENT"%Table.LABELS[target],14);continue
		var cost=Economy.repair_cost(e,target)
		if cost.is_empty():
			host._menu_text("%s · CONDITION %d%%"%[Table.LABELS[target],e.cond[target]],14)
			continue
		_spend_button(host,"REPAIR %s · %d%%"%[Table.LABELS[target],e.cond[target]],cost,func():Economy.repair(e,target),"eco_repair_"+target)
static func _manufacturing(host)->void:
	var e=host.economy;var lost=Economy.lost_items(host.fleet)
	if Economy.Losses.active(e):lost=lost+Economy.Losses.state(e).modules
	for id in [1,2]:
		if Economy.Losses.missing(e,id):_spend_button(host,"MANUFACTURE DRONE %s"%("A" if id==1 else "B"),Economy.drone_cost(e),func():Economy.rebuild_drone(e,id),"eco_drone_%d"%id)
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
				func():Economy.buy_unlock(e,unlock),"eco_unlock_"+unlock.replace(":","_"),frame_effect(unit,id))
