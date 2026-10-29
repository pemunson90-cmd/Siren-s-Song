extends RefCounted
# 070/101 composition seam. DEV copies never own a durable sidecar candidate.
# Revert alongside the archive/session DEV seams; retain ordinary Active validators.
static func key(host,mode:String)->String:return host.store.path+"."+mode
static func entry(host,mode:String)->Dictionary:
	return host.get_meta("dev_mode_cache",{}).get(key(host,mode),{})
static func put(host,mode:String,value:Dictionary)->void:
	var cache:Dictionary=host.get_meta("dev_mode_cache",{})
	cache[key(host,mode)]=value.duplicate(true);host.set_meta("dev_mode_cache",cache)
	host.set_meta("dev_runs_cache",true)
static func active(host,mode:String)->Dictionary:
	return entry(host,mode).get("active",{}).duplicate(true)
static func restore(host,mode:String,archive)->Dictionary:
	var copy=entry(host,mode)
	if not copy.is_empty():return copy.state.duplicate(true)
	var location=key(host,mode)
	if host.get_meta(mode+"_archive_path","")==location:
		copy={"state":host.get_meta(mode+"_archive_state",{}),"active":host.get_meta(mode+"_active",{}),"records":host.get_meta("runs_records",preload("res://src/campaign/runs/run_records.gd").empty())}
	else:
		# Read checked primary/backup without transaction recovery or loss conversion.
		archive.path=location
		var saved=archive._read(location)
		if saved.is_empty():saved=archive._read(location+".bak")
		copy={"state":saved.get("run" if mode=="runs" else "career",{}),"active":saved.get("active",{}),"records":saved.get("records",preload("res://src/campaign/runs/run_records.gd").empty())}
	put(host,mode,copy)
	return copy.state.duplicate(true)
static func persist(host,mode:String,state:Dictionary,envelope:Dictionary,archive)->bool:
	# A successful memory-only edit cannot acknowledge a failed legitimate write.
	if host.get_meta(mode+"_archive_dirty",false):
		host.set_meta(mode+"_save_error","DEV cannot commit the pending checkpoint. Original candidate retained.")
		return false
	var payload={"version":1,"run" if mode=="runs" else "career":state}
	if not archive.valid(payload):return false
	if not envelope.is_empty() and not preload("res://src/campaign/mode_active.gd").valid(envelope,state,mode):return false
	restore(host,mode,archive)
	var copy=entry(host,mode).duplicate(true)
	copy.state=state.duplicate(true);copy.active=envelope.duplicate(true)
	put(host,mode,copy)
	return true # Explicitly ephemeral; mode sessions never use this as durable IO.
