extends RefCounted
# Field tool orders (sonobuoy, silt_screen, hull_patch, relay_buoy). Called after Simulation.command's guards.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by removing these table rows and this family; no rule changes elsewhere.
const Effects=preload("res://src/simulation/field_tool_effects.gd")

static func command(sim, order: String, args: Dictionary) -> bool:
	match order:
		"sonobuoy","silt_screen","hull_patch","relay_buoy":return Effects.use(sim,order,args)
		_:return false
