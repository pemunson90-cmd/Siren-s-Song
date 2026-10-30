extends RefCounted
# Optional mode snapshot envelope. Ledger validation belongs to the sidecar first.
# Revert: remove session/archive calls; absent envelopes retain interrupted-loss recovery.
const Sim=preload("res://src/simulation/simulation.gd")
const Run=preload("res://src/campaign/runs/run_state.gd")
const Career=preload("res://src/campaign/career/career_state.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Rider=preload("res://src/presentation/career/rider_dive.gd")
static func capture(mode:String,state:Dictionary,sim,previous:Dictionary={})->Dictionary:
	return {"version":1,"launch_id":previous.get("launch_id",Crypto.new().generate_random_bytes(16).hex_encode()),
		"mode":mode,"ledger":state.duplicate(true),"context":context_for(mode,state),"simulation":sim.snapshot(),"rider_runtime":sim.rider_snapshot()}
static func context_for(mode:String,state:Dictionary)->Dictionary:
	return Run.context(state) if mode=="runs" else {"completed":state.progress.completed.duplicate(),"facts":state.progress.facts.duplicate(true)}
static func valid(value,state:Dictionary,mode:String)->bool:
	if mode not in ["runs","career"]:return false
	if not (Run.valid(state) if mode=="runs" else Career.valid(state)):return false
	if not state.get("in_flight",false) or not value is Dictionary:return false
	if not value.has_all(["version","launch_id","mode","ledger","context","simulation","rider_runtime"]):return false
	if not value.version is int or value.version!=1 or value.mode!=mode or value.ledger!=state:return false
	if not value.launch_id is String or value.launch_id.length()!=32:return false
	for character in value.launch_id:
		if character not in "0123456789abcdef":return false
	if not value.simulation is Dictionary:return false
	var s:Dictionary=value.simulation
	# Guard numeric variants before the shared validators call typed feature hooks.
	for key in ["elapsed","oxygen","hull"]:
		var number=s.get(key)
		if not (number is int or number is float) or not is_finite(number) or number<0:return false
	if not Sim.valid_snapshot(s):return false
	# Developer simulations never become legitimate resumable/payment candidates.
	if s.mission.get("dev",false):return false
	if not Rider.valid_rider_snapshot(value.rider_runtime,s):return false
	var op:int=Run.current_operation(state) if mode=="runs" else Career.Table.CONTRACTS[state.active].op
	var context=context_for(mode,state)
	if value.context!=context:return false
	var fitted:Dictionary=Equipment.default_loadout() if mode=="runs" else state.fitted
	var expected=Sim.Missions.make(op,context)
	if s.mission.id!=op or s.mission.get("launch_context",{})!=expected.get("launch_context",{}) or s.mission.get("launch_equipment",{})!=fitted:return false
	if mode=="runs" and s.mission.get("run_seed")!=state.seed:return false
	# These isolated modes use fixed launch stock. Read its canonical table rather
	# than building navigation for another Simulation on every five-second save.
	var budget:Dictionary=state.stock.duplicate() if mode=="runs" else {}
	if mode=="career":
		for key in Tools.ids():
			if key not in Tools.field_ids() or Tools.is_enabled(key):budget[key]=Tools.loadout_count(key,"endurance")
	if state.has("tool_racks"):
		budget={}
		for key in Tools.ids():budget[key]=Racks.total(state.tool_racks,key)
	for key in Tools.field_ids():
		if not Tools.is_enabled(key):budget.erase(key)
	var counts:Dictionary=s.tools.duplicate();counts.merge(s.mission.get("field_tools",{}).get("counts",{}),true)
	if counts.size()!=budget.size():return false
	for key in counts:
		if not budget.has(key) or not counts[key] is int or counts[key]<0 or counts[key]>budget[key]:return false
		if int(value.rider_runtime.used.get(key,0))!=int(budget[key])-int(counts[key]):return false
	for key in value.rider_runtime.used:
		if not counts.has(key):return false
	# Legacy states keep pooled stock. New launches bind owner racks to their ledger;
	# canonical Simulation validation also preserves aggregate/owner equality.
	if s.mission.has("tool_racks")!=state.has("tool_racks"):return false
	if state.has("tool_racks"):
		for slot in Racks.UNITS:
			for key in Tools.ids():
				if int(s.mission.tool_racks[slot].get(key,0))>int(state.tool_racks[slot].get(key,0)):return false
	return true
static func restore_sim(sim,value:Dictionary,state:Dictionary,mode:String)->bool:
	if not valid(value,state,mode):return false
	if mode=="runs":sim.configure(state)
	else:sim.configure(state.get("rider",{}))
	if not sim.restore(value.simulation):return false
	sim.restore_rider(value.rider_runtime);sim.paused=true
	return true
