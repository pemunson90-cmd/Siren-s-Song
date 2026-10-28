extends RefCounted
# Pure deterministic offer ledger. All knobs are existing finite tool charges.
# The route swaps two remaining authored operations; no operation is rewritten.
# Revert: stop calling prepare; retain this module for sidecar replay validation.
const Table=preload("res://src/campaign/runs/offer_table.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
static func pending(state:Dictionary)->bool:
	return not state.get("offers",{}).get("pending",[]).is_empty()
static func draw(state:Dictionary)->Array:
	if state.status!="active" or state.cursor<=0:return []
	var rng=RandomNumberGenerator.new();rng.seed=int(state.seed)*31+int(state.cursor)*7919
	var remaining:int=state.operations.size()-state.cursor
	var alternate:int=state.cursor+rng.randi_range(1,remaining-1) if remaining>1 else state.cursor
	var tool:String=Table.BOONS[rng.randi_range(0,Table.BOONS.size()-1)]
	# Stable IDs encode the drawn authored route/boon, not mutable display text.
	return ["route:%d"%alternate,"refit","boon:"+tool]
static func prepare(state:Dictionary)->Dictionary:
	var next=state.duplicate(true)
	if not Table.enabled or next.status!="active" or next.in_flight or next.cursor==0:return next
	if not next.has("offers"):
		next.offers={"version":Table.VERSION,"start":next.cursor,"picks":{},"pending":draw(next)}
	return next
static func after_win(state:Dictionary)->void:
	if state.has("offers"):state.offers.pending=draw(state)
static func _grant(state:Dictionary,counts:Dictionary)->void:
	for key in counts:state.stock[key]=mini(Table.CAP,state.stock[key]+counts[key])
static func choose(state:Dictionary,id:String)->Dictionary:
	var next=state.duplicate(true)
	if not pending(next) or id not in next.offers.pending or next.in_flight or next.status!="active":return next
	if id.begins_with("route:"):
		var index=int(id.get_slice(":",1));var op=next.operations[next.cursor]
		next.operations[next.cursor]=next.operations[index];next.operations[index]=op
		next.stock[Table.ROUTE_COST]=maxi(0,next.stock[Table.ROUTE_COST]-1)
		_grant(next,Table.ROUTE_REWARD)
	elif id=="refit":_grant(next,Table.REFIT)
	else:_grant(next,{id.get_slice(":",1):Table.BOON_COUNT})
	next.offers.picks[str(next.cursor)]=id;next.offers.pending=[]
	return next
static func shape(value,result_count:int)->bool:
	if not value is Dictionary or value.size()!=4 or not value.has_all(["version","start","picks","pending"]):return false
	if not value.version is int or value.version!=Table.VERSION or not value.start is int or value.start<1 or value.start>result_count:return false
	if not value.picks is Dictionary or value.picks.size()>5 or not value.pending is Array or value.pending.size()>3:return false
	for key in value.picks:
		if not key is String or not value.picks[key] is String:return false
	for id in value.pending:
		if not id is String:return false
	return true
static func describe(state:Dictionary,id:String)->Dictionary:
	var op:int=state.operations[state.cursor]
	if id.begins_with("route:"):op=state.operations[int(id.get_slice(":",1))]
	var title:String=Catalog.make(op,{}).title
	if id.begins_with("route:"):
		return {"title":"ROUTE · "+title,"detail":"Next: %s. Spend up to 1 Decoy for 2 Disrupt charges."%title}
	if id=="refit":
		return {"title":"REPAIR KIT / REFIT","detail":"Next: %s. Gain 2 Hull patches and 1 Decoy. Use patches during a dive to repair collision damage."%title}
	var tool:String=id.get_slice(":",1)
	return {"title":"ONE-USE BOON · "+str(Tools.spec(tool).name),"detail":"Next: %s. Gain %d single-use %s charges. Unused charges carry."%[title,Table.BOON_COUNT,Tools.spec(tool).name]}
