extends RefCounted
# A Store pins its selected path once. Old hosts cannot follow later selection.
static func resolve() -> Dictionary:
 var profiles = load("res://src/persistence/profiles/profile_store.gd").new()
 if not profiles.open():return {"path":"","warning":profiles.warning}
 return {"path":profiles.slot_path(profiles.state.active),"warning":""}
