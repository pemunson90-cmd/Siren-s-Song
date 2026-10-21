extends RefCounted
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
# Opt-in new jobs only. The simulation still checks local reach, clear view,
# survival and interruption; existing photographs/receivers get no override.
static func capture_spec(unit_id:int,fitted:Dictionary,objective:Dictionary)->Dictionary:
 if unit_id not in [1,2] or not Catalog.has(fitted,unit_id,"drone_sampler") or objective.get("sampler_compatible",false)!=true:return {}
 return {"duration":8.0,"noise_radius":520.0}
