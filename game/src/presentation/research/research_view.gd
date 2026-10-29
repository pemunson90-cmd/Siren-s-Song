extends RefCounted
# RESEARCH view: every research material in glass_research.gd RECIPES with whether it is recovered,
# what it unlocks, its cost from the economy, and pending / paid / complete. Paying for a pending
# project calls the existing Economy.research action (alloy, preset-scaled); no new rule here.
# Seam: archive_nav.gd entry and tabs. Reads host.expedition, host.economy; saves only via that action.
const Table=preload("res://src/presentation/archive/archive_table.gd")
const Nav=preload("res://src/presentation/archive/archive_nav.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Economy=preload("res://src/campaign/economy.gd")
const EconomyTable=preload("res://src/campaign/economy_table.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Items=preload("res://src/equipment/equipment_catalog.gd")
static func material_name(material:String)->String:
	return material.replace("_"," ").to_upper()
# What finishing the project provides, in plain words.
static func unlocks(material:String)->String:
	var item=Research.item_of(material)
	var name=Economy.target_name(item)
	if name==item:name=item.replace("_"," ").replace("hull:","").replace("chassis:","").to_upper()
	return "unlocks the %s frame"%name if not Research.grants_fitting(item) else "unlocks the %s fitting"%name
static func state_of(expedition:Dictionary,material:String)->String:
	var state=expedition.get("research",{})
	if material in state.get("spent",[]):return "COMPLETE"
	if material in Research.pending(expedition):return "PENDING"
	if material in state.get("materials",[]):return "RECOVERED"
	return "NOT RECOVERED"
# One plain explanation of why a recovered project is not yet payable.
static func waiting(expedition:Dictionary,material:String)->String:
	var recipe=Research.RECIPES[material]
	if recipe.evidence not in expedition.get("facts",{}):return "Awaiting the received regional account for this material."
	if recipe.operation not in expedition.get("completed",[]):return "Awaiting recovery of the operation that holds it."
	if Research.grants_fitting(recipe.item) and not Items.ITEMS.has(recipe.item):return "Awaiting its fitting design."
	return ""
static func rows(host)->Array:
	var result=[]
	for material in Research.RECIPES:
		var recipe=Research.RECIPES[material]
		result.append({"material":material,"state":state_of(host.expedition,material),"name":material_name(material),
			"unlocks":unlocks(material),"operation":recipe.operation,"title":str(Catalog.make(recipe.operation).get("title","UNKNOWN")).to_upper()})
	return result
static func show(host)->void:
	var reading_position=host.scroll.scroll_vertical if host.screen=="research" else 0
	host.screen="research";host.sim.paused=true;host._clear_menu()
	Nav.header(host,"research")
	host._menu_text("RESEARCH",30)
	var economy_on=EconomyTable.enabled
	host._menu_text("%s\nRecovered alien material is consumed in research. A finished project unlocks one optional fitting or frame."%
		(Economy.balance_text(host.economy) if economy_on else "Research completes by itself when material and account are both recovered."),15)
	var cost=Economy.research_cost(host.economy)
	for row in rows(host):
		var detail="%s · %s\nFound in: %s"%[row.state,row.unlocks,row.title]
		var waits="" if row.state!="RECOVERED" else waiting(host.expedition,row.material)
		if row.state=="PENDING" and economy_on:detail+="\nCost: %s"%Economy.fmt(cost)
		elif row.state=="COMPLETE":detail+="\nPaid and complete."
		if not waits.is_empty():detail+="\n"+waits
		host._menu_text(row.name,20)
		host._menu_text(detail,15)
		if row.state=="PENDING" and economy_on:
			var label="RESEARCH %s · %s"%[row.name,Economy.fmt(cost)]
			var button=host._button(host.panel_box,label,_pay.bind(host,row.material),"research_"+row.material)
			button.disabled=not Economy.can_pay(host.economy,cost)
	host.call_deferred("_layout")
	(func():
		await host.get_tree().process_frame
		if host.screen=="research":host.scroll.scroll_vertical=reading_position
	).call_deferred()
static func _pay(host,material:String)->void:
	host.expedition=Economy.research(host.economy,host.expedition,material)
	host._sync_craft_upgrades();host._save_archive();show(host)
