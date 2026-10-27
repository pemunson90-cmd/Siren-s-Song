extends RefCounted
# Presentation-only rollback. Disabled restores the original bed and master dynamics.
static var enabled := true
const RegionTable=preload("res://src/presentation/art/region_table.gd")
const BEDS := {
	"shelf": {"stream":preload("res://assets/audio/regions/shelf.wav"),"gain_db":-19.0},
	"divergence_deep": {"stream":preload("res://assets/audio/regions/divergence_deep.wav"),"gain_db":-20.0},
	"divergence_shelf": {"stream":preload("res://assets/audio/regions/divergence_shelf.wav"),"gain_db":-20.0},
	"confluence": {"stream":preload("res://assets/audio/regions/confluence.wav"),"gain_db":-20.0},
	"glass": {"stream":preload("res://assets/audio/regions/glass.wav"),"gain_db":-21.0},
	# Preserve the established Hunt ambience calibration for Iron operations.
	"iron": {"stream":preload("res://assets/audio/regions/iron.wav"),"gain_db":-17.0},
	"calder": {"stream":preload("res://assets/audio/regions/calder.wav"),"gain_db":-21.0},
}
static func bed(mission: Dictionary) -> Dictionary:
	if not enabled:return {}
	return BEDS.get(RegionTable.key(mission),BEDS.shelf)
