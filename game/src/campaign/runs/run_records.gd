extends RefCounted
# Bounded own-state summaries in the existing .runs envelope. No campaign fields.
# Revert: remove summary/seed UI seams; retain validators for existing sidecars.
const State=preload("res://src/campaign/runs/run_state.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const LIMIT=10
const RESOURCE_CAP=108
static func empty()->Dictionary:return {"best_depth":0,"last":[]}
static func counts()->Dictionary:
	var out={}
	for key in Table.TOOLS:out[key]=0
	return out
static func delta(before:Dictionary,after:Dictionary,spent:Dictionary,gained:Dictionary)->void:
	for key in Table.TOOLS:
		spent[key]+=maxi(0,before[key]-after[key]);gained[key]+=maxi(0,after[key]-before[key])
static func summary(state:Dictionary)->Dictionary:
	if state.is_empty() or not State.valid(state) or state.status=="active":return {}
	var spent=counts();var gained=counts();var operations=[]
	var replay=State.new_run(state.seed)
	for result in state.results:
		if Offers.pending(replay) and state.offers.picks.has(str(replay.cursor)):
			var picked=Offers.choose(replay,state.offers.picks[str(replay.cursor)])
			delta(replay.stock,picked.stock,spent,gained);replay=picked
		State._replay_rider(replay,state)
		delta(replay.stock,result.tools,spent,gained)
		replay=State._apply(replay,result)
		delta(result.tools,replay.stock,spent,gained)
		operations.append({"op":result.op,"outcome":result.outcome,"photo":result.get("photo",-1.)})
		if state.has("offers") and replay.cursor==state.offers.start and not replay.has("offers"):
			replay.offers={"version":1,"start":replay.cursor,"picks":{},"pending":Offers.draw(replay)}
	return {"seed":state.seed,"depth":state.cursor,"total":state.operations.size(),"status":state.status,
		"loadout":state.loadout,"scarcity":state.scarcity,"hunt_stage":state.hunt_stage,
		"spent":spent,"gained":gained,"operations":operations}
static func valid_counts(value)->bool:
	if not value is Dictionary or value.size()!=Table.TOOLS.size():return false
	for key in Table.TOOLS:
		if not value.get(key) is int or value[key]<0 or value[key]>RESOURCE_CAP:return false
	return true
static func valid_summary(value)->bool:
	if not value is Dictionary or value.size()!=10 or not value.has_all(["seed","depth","total","status","loadout","scarcity","hunt_stage","spent","gained","operations"]):return false
	if not value.seed is int or value.seed<0 or value.seed>Table.MAX_SEED:return false
	var initial=State.new_run(value.seed)
	for key in ["loadout","scarcity","hunt_stage"]:
		if value[key]!=initial[key] or typeof(value[key])!=typeof(initial[key]):return false
	if not value.total is int or value.total!=initial.operations.size() or not value.depth is int or value.depth<0 or value.depth>value.total:return false
	if value.status not in ["won","lost"] or (value.status=="won" and value.depth!=value.total) or (value.status=="lost" and value.depth>=value.total):return false
	if not valid_counts(value.spent) or not valid_counts(value.gained):return false
	if not value.operations is Array or value.operations.size()!=value.depth+int(value.status=="lost"):return false
	var seen=[]
	for i in value.operations.size():
		var row=value.operations[i]
		if not row is Dictionary or row.size()!=3 or not row.has_all(["op","outcome","photo"]):return false
		if not row.op is int or row.op not in initial.operations or row.op in seen:return false
		if row.outcome!=("won" if i<value.depth else "lost") or not State._number(row.photo,-1.,1.):return false
		seen.append(row.op)
	return true
static func valid(value)->bool:
	if not value is Dictionary or value.size()!=2 or not value.has_all(["best_depth","last"]):return false
	if not value.best_depth is int or value.best_depth<0 or value.best_depth>6 or not value.last is Array or value.last.size()>LIMIT:return false
	for row in value.last:
		if not valid_summary(row) or row.depth>value.best_depth:return false
	return true
static func add(records:Dictionary,state:Dictionary)->Dictionary:
	var out=records.duplicate(true);var row=summary(state)
	if not valid(out) or row.is_empty():return out
	out.best_depth=maxi(out.best_depth,row.depth);out.last.push_front(row)
	out.last.resize(mini(LIMIT,out.last.size()))
	return out
static func modifiers(row:Dictionary)->String:
	return "%s LOADOUT / %s / STARTING HUNT %d"%[row.loadout.to_upper(),Table.SCARCITY[row.scarcity].to_upper(),row.hunt_stage]
static func photo_text(quality:float)->String:
	if quality<0.:return "NO PHOTO RECORDED"
	return "%s / %d%%"%["A" if quality>=.85 else "B" if quality>=.6 else "C",roundi(quality*100)]
