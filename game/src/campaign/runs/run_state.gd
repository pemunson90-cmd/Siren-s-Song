extends RefCounted
# Pure expedition ledger. Seed, resources, recovered facts and outcomes are isolated
# from the campaign. Only recovered stages earn resupply; a loss is terminal.
# Revert: remove the mode seam. Keep sidecar validation when disabling the mode.
const Racks=preload("res://src/equipment/tool_racks.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Table=preload("res://src/campaign/runs/run_table.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Offers=preload("res://src/campaign/runs/run_offers.gd")
const Riders=preload("res://src/campaign/career/riders.gd")
# Expedition bonuses are carried supplies, isolated from career/campaign money.
const RIDER_PAY=Riders.Table.EXPEDITION_PAY
static func rider_offer(state:Dictionary)->Dictionary:
	return Riders.offer(state.seed,state.cursor+1,"expedition_%d"%current_operation(state))
static func rider_assignment(state:Dictionary)->Dictionary:
	return Riders.seeded(state.seed,state.cursor+1,"expedition_%d"%current_operation(state)) if state.get("riders",{}).get("choices",{}).get(str(state.cursor),false) else {}
static func rider_bonus_text(assignment:Dictionary)->String:
	if assignment.is_empty():return "NONE"
	var pay:Dictionary=RIDER_PAY[assignment.id]
	var key:String=pay.keys()[0]
	return "+%d %s charge"%[pay[key],preload("res://src/equipment/field_tools.gd").spec(key).name]
static func new_run(seed:int)->Dictionary:
	seed=posmod(seed,Table.MAX_SEED+1)
	var rng=RandomNumberGenerator.new();rng.seed=seed
	var pool=Table.POOL.duplicate()
	for i in range(pool.size()-1,0,-1):
		var j=rng.randi_range(0,i);var swap=pool[i];pool[i]=pool[j];pool[j]=swap
	pool.resize(rng.randi_range(3,6))
	var loadout:String=Table.LOADOUTS[rng.randi_range(0,Table.LOADOUTS.size()-1)]
	var scarcity=rng.randi_range(0,2)
	return {"version":1,"seed":seed,"operations":pool,"cursor":0,"status":"active","in_flight":false,
		"loadout":loadout,"scarcity":scarcity,"hunt_stage":rng.randi_range(0,2),
		"stock":Table.stock(loadout,scarcity),"story":{"recovered":[],"facts":{}},"results":[]}
static func current_operation(state:Dictionary)->int:
	return int(state.operations[state.cursor]) if not state.is_empty() and state.status=="active" and state.cursor<state.operations.size() else -1
static func launch(state:Dictionary,accept_rider=null)->Dictionary:
	if not valid(state) or state.is_empty() or state.status!="active" or state.in_flight or Offers.pending(state):return state.duplicate(true)
	var racks=state.get("tool_racks",Racks.from_stock(state.stock))
	if not Racks.available(racks,state.stock) or not Racks.reason(Equipment.default_loadout(),racks).is_empty():return state.duplicate(true)
	var next=state.duplicate(true);next.in_flight=true;next.tool_racks=racks.duplicate(true)
	if (accept_rider is bool and Riders.Table.enabled) or next.has("riders"):
		if not next.has("riders"):next.riders={"start":next.cursor,"choices":{}}
		next.riders.choices[str(next.cursor)]=accept_rider==true and not rider_offer(state).is_empty()
	return next
static func context(state:Dictionary)->Dictionary:
	return {"run_seed":state.seed,"completed":state.story.recovered.duplicate(),"facts":state.story.facts.duplicate(true)}
static func starting_hunt(state:Dictionary,op:int)->int:
	var cap:float=Hunt.CAPS[op] if op>=0 and op<Hunt.CAPS.size() else 1.
	var stage=int(state.hunt_stage)
	while stage>0 and Hunt.SCALES[stage]>cap:stage-=1
	return stage
static func _number(value,low:float,high:float)->bool:
	return (value is int or value is float) and is_finite(value) and value>=low and value<=high
static func _stock(value)->bool:
	if not value is Dictionary or value.size()!=Table.TOOLS.size():return false
	for key in Table.TOOLS:
		if not value.get(key) is int or value[key]<0 or value[key]>9:return false
	return true
static func _result(value,op:int,stock:Dictionary)->bool:
	if not value is Dictionary or not value.has_all(["op","outcome","time","hull","tools","story"]):return false
	if not value.op is int or value.op!=op or value.outcome not in ["won","lost"]:return false
	if value.has("photo") and not _number(value.photo,-1.,1.):return false
	if not _number(value.time,0.,604800.) or not _number(value.hull,0.,100.) or not _stock(value.tools):return false
	for key in Table.TOOLS:
		if value.tools[key]>stock[key]:return false
	return Catalog.valid_facts(op,value.story)
static func _apply(state:Dictionary,result:Dictionary)->Dictionary:
	var next=state.duplicate(true)
	# Ending the run at an unresolved offer is a base loss with no rider launch.
	if next.has("riders") and not next.riders.choices.has(str(next.cursor)):next.riders.choices[str(next.cursor)]=false
	next.results.append(result.duplicate(true));next.in_flight=false;next.stock=result.tools.duplicate()
	next.erase("tool_racks")
	if result.outcome=="lost":
		next.status="lost"
		if next.has("offers"):next.offers.pending=[]
		return next
	next.story.recovered.append(result.op)
	next.story.facts.merge(result.story,true)
	var assignment=rider_assignment(state)
	if not assignment.is_empty() and result.get("rider",{}).get("passed",false):
		for tool in RIDER_PAY[assignment.id]:next.stock[tool]=mini(9,next.stock[tool]+RIDER_PAY[assignment.id][tool])
	# One deterministic supply type per successful recovery. Scarce runs get none.
	var key:String=Table.TOOLS[posmod(int(next.seed)+int(next.cursor),Table.TOOLS.size())]
	next.stock[key]=mini(9,next.stock[key]+Table.RESUPPLY[next.scarcity])
	next.cursor+=1
	if next.cursor==next.operations.size():next.status="won"
	Offers.after_win(next)
	return next
static func settle(state:Dictionary,result:Dictionary)->Dictionary:
	if not valid(state) or state.is_empty() or state.status!="active":return state.duplicate(true)
	# The existing Modes END RUN action can abandon a pending choice, but cannot
	# launch or win past it. It supplies this exact zero-time abandonment result.
	var ending_offer=Offers.pending(state) and result.get("outcome")=="lost" and result.get("time")==0. and result.get("hull")==100. and result.get("tools")==state.stock and result.get("story")=={}
	if not state.in_flight and not ending_offer:return state.duplicate(true)
	if not _result(result,current_operation(state),state.stock):return state.duplicate(true)
	if not _rider_result(state,result):return state.duplicate(true)
	return _apply(state,result)
static func _rider_result(state:Dictionary,result:Dictionary)->bool:
	if not result.has("rider"):return true # Legacy or interrupted dives earn no bonus.
	var r=result.rider
	return r is Dictionary and r.size()==2 and r.has_all(["assignment","passed"]) and r.passed is bool and r.assignment==rider_assignment(state) and (not r.passed or (not r.assignment.is_empty() and result.outcome=="won"))
static func interrupted(state:Dictionary)->Dictionary:
	if not state.get("in_flight",false):return state.duplicate(true)
	return settle(state,{"op":current_operation(state),"outcome":"lost","time":0.,"hull":0.,"tools":state.stock.duplicate(),"story":{}})
static func valid(value)->bool:
	if not value is Dictionary:return false
	if value.is_empty():return true
	if not value.has_all(["version","seed","operations","cursor","status","in_flight","loadout","scarcity","hunt_stage","stock","story","results"]):return false
	if value.has("tool_racks") and (not _stock(value.stock) or not value.tool_racks is Dictionary or not Racks.available(value.tool_racks,value.stock) or not Racks.reason(Equipment.default_loadout(),value.tool_racks).is_empty()):return false
	if not value.version is int or value.version!=1 or not value.seed is int or value.seed<0 or value.seed>Table.MAX_SEED:return false
	if not value.operations is Array or not value.cursor is int or not value.in_flight is bool or not value.results is Array or value.results.size()>6:return false
	if not value.scarcity is int or not value.hunt_stage is int or not value.loadout is String:return false
	for op in value.operations:
		if not op is int:return false
	var expected=new_run(value.seed)
	if value.has("riders"):
		var ledger=value.riders
		if not ledger is Dictionary or ledger.size()!=2 or not ledger.has_all(["start","choices"]):return false
		if not ledger.start is int or ledger.start<0 or ledger.start>value.results.size() or not ledger.choices is Dictionary:return false
		var count:int=value.results.size()+int(value.in_flight)-ledger.start
		if count<1 or ledger.choices.size()!=count:return false
		for i in range(ledger.start,ledger.start+count):
			if not ledger.choices.get(str(i)) is bool:return false
	if value.has("offers") and not Offers.shape(value.offers,value.results.size()):return false
	for key in ["loadout","scarcity","hunt_stage"]:
		if value[key]!=expected[key]:return false
	for result in value.results:
		if Offers.pending(expected) and not (result is Dictionary and result.get("outcome")=="lost" and result.get("time")==0. and result.get("hull")==100. and result.get("tools")==expected.stock and result.get("story")=={}):
			var pick=value.offers.picks.get(str(expected.cursor),"")
			if pick not in expected.offers.pending:return false
			expected=Offers.choose(expected,pick)
		_replay_rider(expected,value)
		if expected.status!="active" or not _result(result,current_operation(expected),expected.stock) or not _rider_result(expected,result):return false
		expected=_apply(expected,result)
		if value.has("offers") and expected.cursor==value.offers.start and not expected.has("offers"):
			if expected.status!="active":return false
			expected.offers={"version":1,"start":expected.cursor,"picks":{},"pending":Offers.draw(expected)}
	if Offers.pending(expected) and value.offers.picks.has(str(expected.cursor)):
		expected=Offers.choose(expected,value.offers.picks[str(expected.cursor)])
	if value.has("offers") and expected.get("offers",{})!=value.offers:return false
	if value.in_flight:_replay_rider(expected,value)
	if value.has("riders") and expected.get("riders",{})!=value.riders:return false
	for key in ["operations","cursor","status","stock","story"]:
		if value[key]!=expected[key]:return false
	return not value.in_flight or (value.status=="active" and not Offers.pending(value))
static func _replay_rider(expected:Dictionary,value:Dictionary)->void:
	if not value.has("riders") or expected.cursor<value.riders.start:return
	if not expected.has("riders"):expected.riders={"start":value.riders.start,"choices":{}}
	expected.riders.choices[str(expected.cursor)]=value.riders.choices[str(expected.cursor)]
