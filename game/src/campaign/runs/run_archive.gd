extends "res://src/persistence/save_store.gd"
# Independent checked atomic sidecar, pinned to the physical profile store.
# Valid interrupted dives resume paused; legacy snapshots retain loss recovery.
# Revert: remove the frontend seam; campaign saves never contain this ledger.
const Records=preload("res://src/campaign/runs/run_records.gd")
const Active=preload("res://src/campaign/mode_active.gd")
const Shared=preload("res://src/campaign/mode_archive.gd")
const State=preload("res://src/campaign/runs/run_state.gd")
func valid(data:Dictionary)->bool:
	if not (data.get("version") is int and data.version==1 and data.has("run") and State.valid(data.run)):return false
	if data.has("records") and not Records.valid(data.records):return false
	if data.has("recorded"):
		if not data.recorded is bool or not data.has("records"):return false
		if data.recorded and (data.run.is_empty() or data.run.status=="active" or data.records.last.is_empty() or data.records.last[0]!=Records.summary(data.run)):return false
	return true
const CFG={"mode":"runs","key":"run","suffix":"runs","script":"res://src/campaign/runs/run_archive.gd","state":State,
	"unavailable":"Profile storage is unavailable. Run archive retained.",
	"locked":"Run archive is unreadable. Original files retained; select another profile to start an expedition.",
	"notice_snapshot":"Could not restore, run kept at last checkpoint. The interrupted dive is recorded as a loss; start a new expedition.",
	"notice_legacy":"Legacy interrupted dive has no snapshot. A loss was recorded; start a new expedition."}
static func _available(host)->bool:return Shared.available(CFG,host)
# Runs also keep the records ledger, and convert a finished run that was never recorded.
static func _read_records(host,saved:Dictionary)->void:
	host.set_meta("runs_records",saved.get("records",Records.empty()).duplicate(true))
	host.set_meta("runs_recorded",saved.get("recorded",false))
static func _unrecorded(host,state:Dictionary)->bool:
	return not state.is_empty() and state.status!="active" and not host.get_meta("runs_recorded",false)
static func _ledger(host,state:Dictionary)->Dictionary:
	var records:Dictionary=host.get_meta("runs_records",Records.empty()).duplicate(true)
	var recorded:bool=host.get_meta("runs_recorded",false) and state==host.get_meta("runs_archive_state",{})
	if not state.is_empty() and state.get("status")=="active":recorded=false
	elif not state.is_empty() and not recorded:
		records=Records.add(records,state);recorded=true
	return {"records":records,"recorded":recorded}
static func restore(host)->Dictionary:return Shared.restore(CFG,host,_read_records,_unrecorded)
static func persist(host,state:Dictionary,envelope:Dictionary={})->bool:return Shared.persist(CFG,host,state,envelope,_ledger)

static func records(host)->Dictionary:
	if preload("res://src/debug/dev_state.gd").marked(host):
		restore(host)
		return preload("res://src/campaign/mode_dev.gd").entry(host,"runs").get("records",Records.empty()).duplicate(true)
	restore(host)
	return host.get_meta("runs_records",Records.empty()).duplicate(true)

static func abandon(host)->Dictionary:
	var state=restore(host)
	if preload("res://src/debug/dev_state.gd").marked(host):return state
	if state.is_empty() or state.status!="active" or host.get_meta("runs_archive_dirty",false):return state
	var envelope:Dictionary=host.get_meta("runs_active",{})
	var ended:Dictionary
	if Active.valid(envelope,state,"runs"):
		var sim=load("res://src/campaign/runs/expedition_run.gd").new()
		Active.restore_sim(sim,envelope,state,"runs")
		ended=State.settle(state,sim.result(true))
	else:
		var launched=State.launch(state) if not state.in_flight else state
		ended=State.settle(launched,{"outcome":"lost","op":State.current_operation(state),"time":0.,"hull":100.,"tools":state.stock,"story":{}})
	persist(host,ended)
	return ended
