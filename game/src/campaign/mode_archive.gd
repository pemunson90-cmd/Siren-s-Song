extends RefCounted
# [AI-DESIGNED] A7 (code audit, Pat approved 2026-11-12)
# Shared restore/persist flow of the Career and Expedition sidecar archives.
# Each archive passes a config (meta prefix = mode name, payload key, its own script, state script, texts)
# and small hooks for what only that mode does; format, keys and wording stay in the mode's file.
const Active=preload("res://src/campaign/mode_active.gd")
const Dev=preload("res://src/campaign/mode_dev.gd")
static func available(cfg:Dictionary,host)->bool:
	if host.store.suspended or host.store.path.is_empty():
		host.set_meta(cfg.mode+"_save_error",cfg.unavailable)
		return false
	return true
# on_saved(host,saved) runs after a read; also_lost(host,state) adds a conversion condition.
static func restore(cfg:Dictionary,host,on_saved:Callable=Callable(),also_lost:Callable=Callable())->Dictionary:
	var mode:String=cfg.mode
	var script=load(cfg.script)
	if not available(cfg,host):return {}
	if preload("res://src/debug/dev_state.gd").marked(host):
		return Dev.restore(host,mode,script.new())
	var location:String=host.store.path+"."+cfg.suffix
	if host.get_meta(mode+"_archive_path","")==location:
		var cached:Dictionary=host.get_meta(mode+"_archive_state",{}).duplicate(true)
		if host.get_meta(mode+"_archive_dirty",false):script.persist(host,cached,host.get_meta(mode+"_active",{}))
		return cached
	var archive=script.new();archive.path=location
	var saved=archive.load_game();var state:Dictionary=saved.get(cfg.key,{}).duplicate(true)
	if on_saved.is_valid():on_saved.call(host,saved)
	host.set_meta(mode+"_archive_path",location);host.set_meta(mode+"_archive_state",state)
	host.set_meta(mode+"_archive_locked",saved.is_empty() and not archive.warning.is_empty())
	host.set_meta(mode+"_archive_dirty",false)
	host.set_meta(mode+"_save_error",archive.warning)
	host.set_meta(mode+"_recovery_notice","")
	var envelope=saved.get("active",{})
	var resumable=Active.valid(envelope,state,mode)
	host.set_meta(mode+"_active",envelope.duplicate(true) if resumable else {})
	if state.get("in_flight",false) and not resumable:
		host.set_meta(mode+"_recovery_notice",cfg.notice_snapshot if saved.has("active") else cfg.notice_legacy)
	if (state.get("in_flight",false) and not resumable) or (also_lost.is_valid() and also_lost.call(host,state)):
		state=cfg.state.interrupted(state)
		# Conversion is final in memory even when storage fails. A later restore retries
		# the loss write instead of exposing the pre-crash dive as a playable state.
		host.set_meta(mode+"_archive_state",state.duplicate(true));host.set_meta(mode+"_archive_dirty",true)
		script.persist(host,state)
	return state.duplicate(true)
# extras(host,state) runs after the lock check and returns extra payload fields; each is also kept in host meta mode_<field>.
static func persist(cfg:Dictionary,host,state:Dictionary,envelope:Dictionary,extras:Callable=Callable())->bool:
	var mode:String=cfg.mode
	var script=load(cfg.script)
	if not available(cfg,host):return false
	if preload("res://src/debug/dev_state.gd").marked(host):
		return Dev.persist(host,mode,state,envelope,script.new())
	var archive=script.new();archive.path=host.store.path+"."+cfg.suffix
	if host.get_meta(mode+"_archive_path","")!=archive.path:script.restore(host)
	if host.get_meta(mode+"_archive_locked",false):
		host.set_meta(mode+"_save_error",cfg.locked)
		return false
	var extra:Dictionary=extras.call(host,state) if extras.is_valid() else {}
	var held:Dictionary=host.get_meta(mode+"_archive_state",{})
	if host.get_meta(mode+"_archive_dirty",false) and not held.get("in_flight",false) and held!=state:
		host.set_meta(mode+"_save_error","Previous result still needs saving. Retry save before advancing or launching.")
		return false
	if not envelope.is_empty() and not Active.valid(envelope,state,mode):
		host.set_meta(mode+"_save_error","Dive snapshot rejected; previous checkpoint retained.")
		return false
	var candidate={"version":1,cfg.key:state.duplicate(true)}
	candidate.merge(extra)
	if not envelope.is_empty():candidate.active=envelope.duplicate(true)
	# Pin the exact candidate before IO. Retry never settles or records again.
	host.set_meta(mode+"_archive_path",archive.path);host.set_meta(mode+"_archive_state",state.duplicate(true))
	host.set_meta(mode+"_active",envelope.duplicate(true));host.set_meta(mode+"_archive_dirty",true)
	for field in extra:host.set_meta(mode+"_"+field,extra[field])
	var ok=archive.save(candidate)
	if ok:
		host.set_meta(mode+"_archive_path",archive.path);host.set_meta(mode+"_archive_state",state.duplicate(true))
		host.set_meta(mode+"_archive_dirty",false)
		if not envelope.is_empty():host.set_meta(mode+"_recovery_notice","")
	host.set_meta(mode+"_save_error","" if ok else archive.warning)
	return ok
