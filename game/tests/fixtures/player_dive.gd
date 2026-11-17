extends RefCounted
# A5 (code audit, Pat approved 2026-11-12): shared set-up for tests that drive a
# player dive. On a player dive both drones start aboard Quietus (Pat,
# 2026-11-12) and enter the water only when launched. A test that needs a drone
# in the water calls launch_drones(), which uses the game's own launch (the
# drone appears beside Quietus, with the launch event), and then places or
# orders the drone as the test requires. Tests must not flip "alive" by hand to
# get a drone into the water: an aboard drone is carried back to Quietus on the
# next step.
const Bay=preload("res://src/simulation/drone_bay/drone_bay.gd")
# Launches every drone that is still aboard. Returns the refusal text of the
# first launch that failed, or "" when every aboard drone is now in the water.
static func launch_drones(sim)->String:
	for id in range(1,sim.units.size()):
		if not Bay.aboard(sim.units[id]):continue
		var refused:String=Bay.launch(sim,id)
		if refused!="":return refused
	return ""
# Player rules hide water the craft has not charted (Pat, 2026-11-12). A test
# that flies a scripted route through authored water, and is about something
# other than discovery, uses the game's own developer switch for known charts
# (ParityRules.debug_known, the console command "known"). Call with true before
# Simulation.start(); call with the returned previous value afterwards.
const Rules=preload("res://src/simulation/parity_rules/parity_rules.gd")
static func known_water(on:bool)->bool:
	var previous:bool=Rules.debug_known
	Rules.debug_known=on
	return previous
