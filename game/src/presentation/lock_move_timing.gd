extends RefCounted
# What each counter-move on the lock card does about THIS lock, from the simulation's own rules, so a move that
# cannot land before the lock completes is visible before it is tapped (critic 14 Nov: a decoy was launched with
# 0.1 s left on a lock and Quietus was lost). Presentation only: the moves stay allowed and nothing is changed.
#   silent  takes effect at once (the craft's sight radius shrinks the same step), and ends the lock only if the
#           Siren is beyond the silent sight distance (photo_pricing_table.gd SIREN_SIGHT_SILENT, widened by Hunt).
#   emp     takes effect at once: every Siren in range loses its lock (weapon_orders.gd; the card lists it only
#           when the Siren is in range).
#   decoy   a Siren that already sees the craft keeps locking while a decoy sounds (simulation.gd: a sighting
#           overrides what it hears), so a decoy cannot end a lock that has started.
const Words=preload("res://src/presentation/hud_words.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const HuntPressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
# Seconds from the tap until the move takes effect, by order. A move not listed never ends a lock.
const DELAY={"silent": 0.0, "emp": 0.0}
# The moves worth offering against a lock that is running: a move not in DELAY (the decoy) cannot end it, so the card
# does not list it. A decoy only draws Sirens that have not seen the craft (Words.TEXT.decoy_note says so).
static func useful(moves:Array)->Array:
	return moves.filter(func(m):return DELAY.has(str(m.order)))
# {"line": the second line of the move's button, "in_time": whether the move can end the lock before it completes}.
# row is one of ThreatRead.lock_rows(); move is one of its "moves".
static func read(sim,row:Dictionary,move:Dictionary)->Dictionary:
	var order:String=str(move.order)
	if not DELAY.has(order):return {"line":Words.TEXT.move_decoy,"in_time":false}
	if order=="silent":
		var near:float=Pricing.SIREN_SIGHT_SILENT*HuntPressure.scale(sim.mission)
		if sim.units[int(row.craft)].pos.distance_to(row.siren_pos)<near:
			return {"line":Words.TEXT.move_close%roundi(near),"in_time":false}
	var delay:float=float(DELAY[order])
	if delay>=float(row.remaining):return {"line":Words.TEXT.move_after%delay,"in_time":false}
	return {"line":Words.TEXT.move_now if delay<=0.0 else Words.TEXT.move_after%delay,"in_time":true}
