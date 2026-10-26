extends "res://src/persistence/save_store.gd"
# Separate challenge profile. Reuse checked atomic writes without opening campaign files.
const Records=preload("res://src/campaign/challenges/challenge_records.gd")
func valid(data:Dictionary)->bool:
	return data.get("version")==1 and data.has("challenges") and Records.valid(data.challenges)
static func restore(host)->void:
	if host.has_meta("challenge_archive_loaded"):return
	var archive=load("res://src/campaign/challenges/challenge_archive.gd").new()
	archive.path=host.store.path+".challenges"
	var saved=archive.load_game()
	host.challenge_records=saved.get("challenges",{}).duplicate(true)
	host.set_meta("challenge_archive_loaded",true)
	host.set_meta("challenge_save_error",archive.warning)
static func persist(host)->bool:
	var archive=load("res://src/campaign/challenges/challenge_archive.gd").new()
	archive.path=host.store.path+".challenges"
	var ok=archive.save({"version":1,"challenges":host.challenge_records.duplicate(true)})
	host.set_meta("challenge_save_error","" if ok else archive.warning)
	return ok
