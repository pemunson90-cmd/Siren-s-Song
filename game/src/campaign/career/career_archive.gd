extends "res://src/persistence/save_store.gd"
# Independent checked atomic sidecar, pinned to the physical profile store.
# Valid interrupted dives resume paused; legacy snapshots retain loss recovery.
# Revert: remove the frontend seam; campaign saves never contain this ledger.
const Active=preload("res://src/campaign/mode_active.gd")
const State=preload("res://src/campaign/career/career_state.gd")
func valid(data:Dictionary)->bool:
	return data.get("version") is int and data.version==1 and data.has("career") and State.valid(data.career) and not data.career.is_empty()
static func _available(host)->bool:
	if host.store.suspended or host.store.path.is_empty():
		host.set_meta("career_save_error","Profile storage is unavailable. Career archive retained.")
		return false
	return true
static func restore(host)->Dictionary:
	if not _available(host):return {}
	if preload("res://src/debug/dev_state.gd").marked(host):
		return preload("res://src/campaign/mode_dev.gd").restore(host,"career",load("res://src/campaign/career/career_archive.gd").new())
	var location:String=host.store.path+".career"
	if host.get_meta("career_archive_path","")==location:
		var cached:Dictionary=host.get_meta("career_archive_state",{}).duplicate(true)
		if host.get_meta("career_archive_dirty",false):persist(host,cached,host.get_meta("career_active",{}))
		return cached
	var archive=load("res://src/campaign/career/career_archive.gd").new();archive.path=location
	var saved=archive.load_game();var state:Dictionary=saved.get("career",{}).duplicate(true)
	host.set_meta("career_archive_path",location);host.set_meta("career_archive_state",state)
	host.set_meta("career_archive_locked",saved.is_empty() and not archive.warning.is_empty())
	host.set_meta("career_archive_dirty",false)
	host.set_meta("career_save_error",archive.warning)
	host.set_meta("career_recovery_notice","")
	var envelope=saved.get("active",{})
	var resumable=Active.valid(envelope,state,"career")
	host.set_meta("career_active",envelope.duplicate(true) if resumable else {})
	if state.get("in_flight",false) and not resumable:
		host.set_meta("career_recovery_notice","Could not restore, run kept at last checkpoint. The interrupted dive is recorded as a loss; choose another contract." if saved.has("active") else "Legacy interrupted dive has no snapshot. A loss was recorded; choose another contract.")
	if state.get("in_flight",false) and not resumable:
		state=State.interrupted(state)
		# Conversion is final in memory even when storage fails. A later restore retries
		# the contract loss write instead of exposing the pre-crash dive as a playable state.
		host.set_meta("career_archive_state",state.duplicate(true));host.set_meta("career_archive_dirty",true)
		persist(host,state)
	return state.duplicate(true)
static func persist(host,state:Dictionary,envelope:Dictionary={})->bool:
	if not _available(host):return false
	if preload("res://src/debug/dev_state.gd").marked(host):
		return preload("res://src/campaign/mode_dev.gd").persist(host,"career",state,envelope,load("res://src/campaign/career/career_archive.gd").new())
	var archive=load("res://src/campaign/career/career_archive.gd").new();archive.path=host.store.path+".career"
	if host.get_meta("career_archive_path","")!=archive.path:restore(host)
	if host.get_meta("career_archive_locked",false):
		host.set_meta("career_save_error","Career archive is unreadable. Original files retained; select another profile to start a career.")
		return false
	var held:Dictionary=host.get_meta("career_archive_state",{})
	if host.get_meta("career_archive_dirty",false) and not held.get("in_flight",false) and held!=state:
		host.set_meta("career_save_error","Previous result still needs saving. Retry save before advancing or launching.")
		return false
	if not envelope.is_empty() and not Active.valid(envelope,state,"career"):
		host.set_meta("career_save_error","Dive snapshot rejected; previous checkpoint retained.")
		return false
	var candidate={"version":1,"career":state.duplicate(true)}
	if not envelope.is_empty():candidate.active=envelope.duplicate(true)
	# Pin the exact candidate before IO. Retry never settles or records again.
	host.set_meta("career_archive_path",archive.path);host.set_meta("career_archive_state",state.duplicate(true))
	host.set_meta("career_active",envelope.duplicate(true));host.set_meta("career_archive_dirty",true)
	var ok=archive.save(candidate)
	if ok:
		host.set_meta("career_archive_path",archive.path);host.set_meta("career_archive_state",state.duplicate(true))
		host.set_meta("career_archive_dirty",false)
		if not envelope.is_empty():host.set_meta("career_recovery_notice","")
	host.set_meta("career_save_error","" if ok else archive.warning)
	return ok
