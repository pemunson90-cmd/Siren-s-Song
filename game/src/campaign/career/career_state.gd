extends RefCounted
# Separate career economy, regional evidence and fitted fleet. No ending resolver.
# Campaign archives never contain this career state.
const Table=preload("res://src/campaign/career/career_table.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Ops=preload("res://src/campaign/operation_catalog.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Riders=preload("res://src/campaign/career/riders.gd")
static func new_career()->Dictionary:
	var standing={}
	for faction in Table.FACTIONS:standing[faction]=0
	return {"version":1,"standing":standing,"economy":Economy.new_state(),"fitted":Equipment.default_loadout(),
		"progress":{"completed":[],"facts":{},"entitlements":[]},"active":"","in_flight":false,"serial":0,"recovered":0,"lost":0,"report":"Choose a regional contract. Each recovery improves standing; higher trust opens regional work."}
static func open(state:Dictionary,id:String)->bool:
	return Table.CONTRACTS.has(id) and state.standing[Table.CONTRACTS[id].faction]>=Table.CONTRACTS[id].get("standing",Table.MIN_STANDING)
static func rider_offer(state:Dictionary,id:String)->Dictionary:
	return Riders.offer(Riders.Table.SEED,int(state.serial)+1,id)
static func launch(state:Dictionary,id:String,accept_rider:bool=true)->Dictionary:
	var next=state.duplicate(true)
	if state.in_flight or not open(state,id):return next
	var racks=Economy.Losses.racks(next.economy,next.get("tool_racks",Racks.template("endurance")))
	# Career has no loadout picker; its public frontend always launches endurance.
	var extra=Racks.cost(racks,"endurance",next.economy)
	var cost=Economy.refit_cost(next.economy,next.fitted)
	for key in extra:cost[key]=cost.get(key,0)+extra[key]
	if not Racks.reason(next.fitted,racks).is_empty() or not Economy.can_pay(next.economy,cost):return state.duplicate(true)
	if not Economy.charge_launch(next.economy,next.fitted):return state.duplicate(true)
	Economy.pay(next.economy,extra)
	next.tool_racks=racks
	next.active=id;next.in_flight=true;next.serial+=1
	next.rider=rider_offer(state,id) if accept_rider else {}
	return next
static func settle(state:Dictionary,result:Dictionary)->Dictionary:
	if not state.in_flight:return state.duplicate(true)
	var next=state.duplicate(true);var contract=Table.CONTRACTS[state.active]
	var won=result.get("outcome","")=="won"
	Economy.settle(next.economy,{"key":"career_%d"%state.serial,"outcome":"won" if won else "lost","first":contract.op not in state.progress.completed,"hull":result.hull,"alive":result.alive,"recovered":0,"artifact":false})
	next.standing[contract.faction]=clampi(next.standing[contract.faction]+(Table.SUCCESS if won else Table.LOSS),Table.MIN_STANDING,Table.MAX_STANDING)
	if won:
		next.recovered+=1
		for key in contract.reward:next.economy.stock[key]=mini(Economy.Table.CAP,next.economy.stock[key]+contract.reward[key])
		if contract.op not in next.progress.completed:next.progress.completed.append(contract.op)
		var mission:Dictionary=result.get("mission",{})
		if Ops.valid_facts(contract.op,mission.get("expedition_facts",{})):next.progress.facts.merge(mission.get("expedition_facts",{}),true)
		next.progress=Research.hold(state.progress,Research.recovered(next.progress,mission))
	else:next.lost+=1
	var assignment:Dictionary=state.get("rider",{})
	var rider_line=""
	if not assignment.is_empty():
		var earned=won and Riders.earned(assignment,result.get("rider",{}))
		if earned:
			var bonus=Riders.Table.ROWS[assignment.id]
			for key in bonus.pay:next.economy.stock[key]=mini(Economy.Table.CAP,next.economy.stock[key]+bonus.pay[key])
			next.standing[contract.faction]=clampi(next.standing[contract.faction]+bonus.standing,Table.MIN_STANDING,Table.MAX_STANDING)
		rider_line="\nRIDER %s · BONUS %s"%["PASSED" if earned else "FAILED",Riders.bonus_text(assignment) if earned else "NONE"]
	next.report="%s · %s\nSTANDING %s%d → %d · CONTRACT PAY %s\n%s%s"%[Table.FACTIONS[contract.faction],"RECOVERED" if won else "LOST", "+" if state.standing[contract.faction]>=0 else "",state.standing[contract.faction],next.standing[contract.faction],Economy.fmt(contract.reward) if won else "NONE",next.economy.report,rider_line]
	if next.has("rider"):next.rider={}
	next.active="";next.in_flight=false
	return next
static func interrupted(state:Dictionary)->Dictionary:
	return settle(state,{"outcome":"lost","hull":0.,"alive":[false,false]}) if state.in_flight else state.duplicate(true)
static func manufacture(state:Dictionary,item:String)->bool:
	if not Equipment.ITEMS.has(item) or item in state.progress.entitlements or item in Economy.Table.ALIEN:return false
	if not Economy.pay(state.economy,Economy.item_cost(item,state.economy)):return false
	state.progress.entitlements.append(item);return true
static func valid(value)->bool:
	if not value is Dictionary or value.size()!=11+int(value.has("rider"))+int(value.has("tool_racks")) or not value.has_all(["version","standing","economy","fitted","progress","active","in_flight","serial","recovered","lost","report"]):return false
	if value.has("tool_racks") and not Racks.valid(value.tool_racks):return false
	if not value.version is int or value.version!=1 or not Economy.valid(value.economy) or not Equipment.valid_fitting(value.fitted):return false
	if not value.standing is Dictionary or value.standing.size()!=Table.FACTIONS.size():return false
	for faction in Table.FACTIONS:
		if not value.standing.get(faction) is int or value.standing[faction]<Table.MIN_STANDING or value.standing[faction]>Table.MAX_STANDING:return false
	for key in ["serial","recovered","lost"]:
		if not value[key] is int or value[key]<0 or value[key]>1000000:return false
	if not value.in_flight is bool or not value.active is String or (value.active not in Table.CONTRACTS and value.active!=""):return false
	if value.in_flight!=(not value.active.is_empty()) or value.serial!=value.recovered+value.lost+int(value.in_flight):return false
	if value.in_flight and not open(value,value.active):return false
	if value.has("rider"):
		if not Riders.valid(value.rider):return false
		if not value.rider.is_empty() and (not value.in_flight or value.rider.contract!=value.active or value.rider.serial!=value.serial or value.rider.seed!=Riders.Table.SEED):return false
	if not value.report is String or value.report.length()>2000:return false
	var p=value.progress
	if not p is Dictionary or not p.has_all(["completed","facts","entitlements"]) or p.size()!=(4 if p.has("research") else 3):return false
	if not p.completed is Array or not p.facts is Dictionary or not p.entitlements is Array:return false
	for id in p.completed:
		if not id is int or not Table.CONTRACTS.values().any(func(c):return c.op==id) or p.completed.count(id)!=1:return false
	for key in p.facts:
		if not key is String or key not in Ops.fact_keys() or not p.facts[key] is String:return false
	for item in p.entitlements:
		if not item is String or not Equipment.ITEMS.has(item) or p.entitlements.count(item)!=1:return false
	if not Research.valid(p):return false
	for item in Equipment.all_items(value.fitted):
		if item not in p.entitlements:return false
	return Economy.lock_frames(value.economy,p,value.fitted)==value.fitted
