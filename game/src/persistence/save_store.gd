extends RefCounted
const Simulation=preload("res://src/simulation/simulation.gd")
const MAGIC := "QUIETUS_PASS0"
const VERSION := 2
var path := "user://quietus.save"
var warning := ""
func valid(data: Dictionary) -> bool:
	# Version 2 adds hull, chassis and typed mount loadouts. Version 1 archives
	# stay loadable: their single slot fittings read as standard frames.
	if data.get("version",0) not in [1,VERSION]: return false
	if not data.get("unlocked") is int or data.unlocked<0 or data.unlocked>5: return false
	if not data.get("completed") is Array or not data.get("settings") is Dictionary or not data.get("upgrade") is String: return false
	if data.has("intel") and not preload("res://src/campaign/photo_intel.gd").valid(data.intel):return false
	if data.has("expedition") and not preload("res://src/campaign/expedition_campaign.gd").valid(data.expedition):return false
	if data.has("fleet") and not preload("res://src/campaign/fleet_inventory.gd").valid(data.fleet,preload("res://src/equipment/craft_upgrades.gd").recovered(data.completed,data.get("expedition",{}),data.get("intel",{})),data.completed+data.get("expedition",{}).get("completed",[])):return false
	if data.has("equipment"):
		if not preload("res://src/campaign/campaign_consequences.gd").fitting_valid(data.equipment):return false
		for item in preload("res://src/equipment/equipment_catalog.gd").all_items(data.equipment):
			if item not in preload("res://src/equipment/craft_upgrades.gd").recovered(data.completed,data.get("expedition",{}),data.get("intel",{})):return false
	if data.has("evidence"):
		if not data.evidence is Dictionary: return false
		for key in data.evidence:
			var entry=data.evidence[key]
			if key not in preload("res://src/campaign/operation_catalog.gd").record_keys() or not entry is Dictionary or not entry.has_all(["name","caption","optical"]) or entry.optical!=key or not entry.name is String or not entry.caption is String: return false
			if entry.has("shots") and not preload("res://src/presentation/photo_view.gd").valid_shots(entry.shots):return false
	if data.has("active") and data.active!=null:
		if not data.active is Dictionary or not Simulation.valid_snapshot(data.active): return false
		if preload("res://src/campaign/operation_catalog.gd").definition(data.active.mission.id).campaign and data.active.mission.id not in preload("res://src/campaign/expedition_campaign.gd").available(data.completed,data.get("expedition",{})):return false
		var fitted=data.active.mission.get("launch_equipment",{})
		for item in preload("res://src/equipment/equipment_catalog.gd").all_items(fitted):
			if item not in preload("res://src/equipment/craft_upgrades.gd").recovered(data.completed,data.get("expedition",{}),data.get("intel",{})):return false
		var references=data.active.mission.get("launch_context",{}).get("references",{})
		if not references.is_empty() and references!=data.get("expedition",{}).get("references",{}):return false
	return true
func save(data: Dictionary) -> bool:
	if not valid(data): warning="Save rejected: unsupported or invalid archive."; return false
	var payload=var_to_bytes(data)
	var f=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if f==null: warning="Unable to write archive. Check device storage."; return false
	f.store_pascal_string(MAGIC); f.store_pascal_string(payload.hex_encode().sha256_text()); f.store_32(payload.size()); f.store_buffer(payload); f.flush(); f.close()
	if _read(path+".tmp").is_empty(): warning="Archive verification failed; previous save retained."; return false
	if FileAccess.file_exists(path):
		# Never replace a valid backup with an unreadable primary.
		if not _read(path).is_empty():
			DirAccess.remove_absolute(path+".bak")
			if DirAccess.rename_absolute(path,path+".bak")!=OK: warning="Unable to rotate archive backup."; return false
		else: DirAccess.remove_absolute(path)
	if DirAccess.rename_absolute(path+".tmp",path)!=OK: warning="Unable to commit archive."; return false
	return true
func _read(location: String) -> Dictionary:
	if not FileAccess.file_exists(location): return {}
	var f=FileAccess.open(location,FileAccess.READ)
	if f==null or f.get_length()>4000000 or f.get_length()<32: return {}
	if f.get_pascal_string()!=MAGIC: return {}
	var checksum=f.get_pascal_string(); var length=f.get_32()
	if length<=0 or length>f.get_length()-f.get_position(): return {}
	var payload=f.get_buffer(length)
	if payload.hex_encode().sha256_text()!=checksum: return {}
	var value=bytes_to_var(payload)
	if not value is Dictionary or not valid(value): return {}
	return value
func load_game() -> Dictionary:
	warning=""
	var primary=_read(path)
	if not primary.is_empty(): return primary
	var backup=_read(path+".bak")
	if not backup.is_empty(): warning="Primary archive was unreadable. Recovered previous backup."; return backup
	if FileAccess.file_exists(path) or FileAccess.file_exists(path+".bak"): warning="Archive is unreadable. Original files retained; starting a new operations session."
	return {}
