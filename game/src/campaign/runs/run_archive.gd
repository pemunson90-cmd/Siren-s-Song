extends "res://src/persistence/save_store.gd"
# Independent checked atomic sidecar, pinned to the physical profile store.
# Valid interrupted dives resume paused; legacy snapshots retain loss recovery.
# Revert: remove the frontend seam; campaign saves never contain this ledger.
const Records=preload("res://src/campaign/runs/run_records.gd")
const Active=preload("res://src/campaign/mode_active.gd")
const State=preload("res://src/campaign/runs/run_state.gd")
func valid(data:Dictionary)->bool:
	if not (data.get("version") is int and data.version==1 and data.has("run") and State.valid(data.run)):return false
	if data.has("records") and not Records.valid(data.records):return false
	if data.has("recorded"):
		if not data.recorded is bool or not data.has("records"):return false
		if data.recorded and (data.run.is_empty() or data.run.status=="active" or data.records.last.is_empty() or data.records.last[0]!=Records.summary(data.run)):return false
	return true
static func _available(host)->bool:
	if host.store.suspended or host.store.path.is_empty():
		host.set_meta("runs_save_error","Profile storage is unavailable. Run archive retained.")
		return false
	return true
static func restore(host)->Dictionary:
	if not _available(host):return {}
	var location:String=host.store.path+".runs"
	if host.get_meta("runs_archive_path","")==location:
		var cached:Dictionary=host.get_meta("runs_archive_state",{}).duplicate(true)
		if host.get_meta("runs_archive_dirty",false):persist(host,cached,host.get_meta("runs_active",{}))
		return cached
	var archive=load("res://src/campaign/runs/run_archive.gd").new();archive.path=location
	var saved=archive.load_game();var state:Dictionary=saved.get("run",{}).duplicate(true)
	host.set_meta("runs_records",saved.get("records",Records.empty()).duplicate(true))
	host.set_meta("runs_recorded",saved.get("recorded",false))
	host.set_meta("runs_archive_path",location);host.set_meta("runs_archive_state",state)
	host.set_meta("runs_archive_locked",saved.is_empty() and not archive.warning.is_empty())
	host.set_meta("runs_archive_dirty",false)
	host.set_meta("runs_save_error",archive.warning)
	host.set_meta("runs_recovery_notice","")
	var envelope=saved.get("active",{})
	var resumable=Active.valid(envelope,state,"runs")
	host.set_meta("runs_active",envelope.duplicate(true) if resumable else {})
	if state.get("in_flight",false) and not resumable:
		host.set_meta("runs_recovery_notice","Could not restore, run kept at last checkpoint. The interrupted dive is recorded as a loss; start a new expedition." if saved.has("active") else "Legacy interrupted dive has no snapshot. A loss was recorded; start a new expedition.")
	if (state.get("in_flight",false) and not resumable) or (not state.is_empty() and state.status!="active" and not host.get_meta("runs_recorded",false)):
		state=State.interrupted(state)
		# Conversion is final in memory even when storage fails. A later restore retries
		# the loss write instead of exposing the pre-crash dive as a playable state.
		host.set_meta("runs_archive_state",state.duplicate(true));host.set_meta("runs_archive_dirty",true)
		persist(host,state)
	return state.duplicate(true)
static func persist(host,state:Dictionary,envelope:Dictionary={})->bool:
	if not _available(host):return false
	var archive=load("res://src/campaign/runs/run_archive.gd").new();archive.path=host.store.path+".runs"
	if host.get_meta("runs_archive_path","")!=archive.path:restore(host)
	if host.get_meta("runs_archive_locked",false):
		host.set_meta("runs_save_error","Run archive is unreadable. Original files retained; select another profile to start an expedition.")
		return false
	var records:Dictionary=host.get_meta("runs_records",Records.empty()).duplicate(true)
	var recorded:bool=host.get_meta("runs_recorded",false) and state==host.get_meta("runs_archive_state",{})
	if not state.is_empty() and state.get("status")=="active":recorded=false
	elif not state.is_empty() and not recorded:
		records=Records.add(records,state);recorded=true
	var held:Dictionary=host.get_meta("runs_archive_state",{})
	if host.get_meta("runs_archive_dirty",false) and not held.get("in_flight",false) and held!=state:
		host.set_meta("runs_save_error","Previous result still needs saving. Retry save before advancing or launching.")
		return false
	if not envelope.is_empty() and not Active.valid(envelope,state,"runs"):
		host.set_meta("runs_save_error","Dive snapshot rejected; previous checkpoint retained.")
		return false
	var candidate={"version":1,"run":state.duplicate(true),"records":records,"recorded":recorded}
	if not envelope.is_empty():candidate.active=envelope.duplicate(true)
	# Pin the exact candidate before IO. Retry never settles or records again.
	host.set_meta("runs_archive_path",archive.path);host.set_meta("runs_archive_state",state.duplicate(true))
	host.set_meta("runs_active",envelope.duplicate(true));host.set_meta("runs_archive_dirty",true)
	host.set_meta("runs_records",records);host.set_meta("runs_recorded",recorded)
	var ok=archive.save(candidate)
	if ok:
		host.set_meta("runs_records",records);host.set_meta("runs_recorded",recorded)
		host.set_meta("runs_archive_path",archive.path);host.set_meta("runs_archive_state",state.duplicate(true))
		host.set_meta("runs_archive_dirty",false)
		if not envelope.is_empty():host.set_meta("runs_recovery_notice","")
	host.set_meta("runs_save_error","" if ok else archive.warning)
	return ok

static func records(host)->Dictionary:
	restore(host)
	return host.get_meta("runs_records",Records.empty()).duplicate(true)

static func abandon(host)->Dictionary:
	var state=restore(host)
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
