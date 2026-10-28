extends "res://src/persistence/save_store.gd"
# Independent checked atomic sidecar, pinned to the physical profile store.
# An interrupted dive loses the run; replayable between-stage progress survives.
# Revert: remove the frontend seam; campaign saves never contain this ledger.
const State=preload("res://src/campaign/runs/run_state.gd")
func valid(data:Dictionary)->bool:
	return data.get("version") is int and data.version==1 and data.has("run") and State.valid(data.run)
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
	host.set_meta("runs_archive_path",location);host.set_meta("runs_archive_state",state)
	host.set_meta("runs_archive_locked",saved.is_empty() and not archive.warning.is_empty())
	host.set_meta("runs_archive_dirty",false)
	host.set_meta("runs_save_error",archive.warning)
	if state.get("in_flight",false):
		state=State.interrupted(state)
		# Conversion is final in memory even when storage fails. A later restore retries
		# the loss write instead of exposing the pre-crash dive as a playable state.
		host.set_meta("runs_archive_state",state.duplicate(true));host.set_meta("runs_archive_dirty",true)
		persist(host,state)
	return state.duplicate(true)
static func persist(host,state:Dictionary)->bool:
	if not _available(host):return false
	var archive=load("res://src/campaign/runs/run_archive.gd").new();archive.path=host.store.path+".runs"
	if host.get_meta("runs_archive_path","")!=archive.path:restore(host)
	if host.get_meta("runs_archive_locked",false):
		host.set_meta("runs_save_error","Run archive is unreadable. Original files retained; select another profile to start an expedition.")
		return false
	var ok=archive.save({"version":1,"run":state.duplicate(true)})
	if ok:
		host.set_meta("runs_archive_path",archive.path);host.set_meta("runs_archive_state",state.duplicate(true))
		host.set_meta("runs_archive_dirty",false)
	host.set_meta("runs_save_error","" if ok else archive.warning)
	return ok
