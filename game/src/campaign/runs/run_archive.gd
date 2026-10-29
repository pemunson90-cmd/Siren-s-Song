extends "res://src/persistence/save_store.gd"
# Independent checked atomic sidecar, pinned to the physical profile store.
# An interrupted dive loses the run; replayable between-stage progress survives.
# Revert: remove the frontend seam; campaign saves never contain this ledger.
const Records=preload("res://src/campaign/runs/run_records.gd")
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
		if host.get_meta("runs_archive_dirty",false):persist(host,cached)
		return cached
	var archive=load("res://src/campaign/runs/run_archive.gd").new();archive.path=location
	var saved=archive.load_game();var state:Dictionary=saved.get("run",{}).duplicate(true)
	host.set_meta("runs_records",saved.get("records",Records.empty()).duplicate(true))
	host.set_meta("runs_recorded",saved.get("recorded",false))
	host.set_meta("runs_archive_path",location);host.set_meta("runs_archive_state",state)
	host.set_meta("runs_archive_locked",saved.is_empty() and not archive.warning.is_empty())
	host.set_meta("runs_archive_dirty",false)
	host.set_meta("runs_save_error",archive.warning)
	if state.get("in_flight",false) or (not state.is_empty() and state.status!="active" and not host.get_meta("runs_recorded",false)):
		if preload("res://src/debug/dev_state.gd").marked(host):state.in_flight=false
		else:state=State.interrupted(state)
		# Conversion is final in memory even when storage fails. A later restore retries
		# the loss write instead of exposing the pre-crash dive as a playable state.
		host.set_meta("runs_archive_state",state.duplicate(true));host.set_meta("runs_archive_dirty",true)
		persist(host,state)
	return state.duplicate(true)
static func persist(host,state:Dictionary)->bool:
	if preload("res://src/debug/dev_state.gd").marked(host):
		if host.get_meta("runs_archive_path","")!=host.store.path+".runs":restore(host)
		host.set_meta("dev_runs_cache",true)
		# DEV runs remain usable for diagnosis, entirely in memory. Preserve the
		# ordinary sidecar and records while persist/restore callers share state.
		host.set_meta("runs_archive_path",host.store.path+".runs")
		host.set_meta("runs_archive_state",state.duplicate(true))
		host.set_meta("runs_archive_dirty",false);host.set_meta("runs_save_error","")
		return true
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
	var ok=archive.save({"version":1,"run":state.duplicate(true),"records":records,"recorded":recorded})
	if ok:
		host.set_meta("runs_records",records);host.set_meta("runs_recorded",recorded)
		host.set_meta("runs_archive_path",archive.path);host.set_meta("runs_archive_state",state.duplicate(true))
		host.set_meta("runs_archive_dirty",false)
	host.set_meta("runs_save_error","" if ok else archive.warning)
	return ok

static func records(host)->Dictionary:
	restore(host)
	return host.get_meta("runs_records",Records.empty()).duplicate(true)
