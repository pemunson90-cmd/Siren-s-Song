extends RefCounted
# WP-48: tells the player, once, that a craft has run out of route and stopped. It reads the dive and
# never changes it: no pause, no rule. A craft qualifies when it was moving along a route at the last look
# and its route is now empty while time is running. Replacing a route, ALL STOP, a drone going aboard,
# a loss and hull damage in the same moment do not count, so a more urgent message is never overwritten.
const Words=preload("res://src/presentation/hud_words.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
var was_moving:Dictionary={}
var notices:Array=[]
var clock:=-1.0
var hull:=-1.0
var mission=null
func observe(sim)->void:
	if not is_same(mission,sim.mission) or sim.elapsed<clock:
		mission=sim.mission;was_moving.clear();notices.clear();clock=sim.elapsed;hull=float(sim.hull)
	var damaged:bool=float(sim.hull)<hull
	var running:bool=sim.elapsed>clock and not sim.paused and sim.outcome.is_empty()
	for i in sim.units.size():
		var u=sim.units[i]
		var moving:bool=u.alive and not u.route.is_empty() and u.vel.length()>Words.MOVING_SPEED
		if was_moving.get(i,false) and u.route.is_empty() and running and not damaged and u.alive and not sim.DroneBay.aboard(u) and not AllStop.stopped(u) and not AllStop.restarting(u):
			notices.append({"text":Words.TEXT.route_end%u.name.to_upper(),"until":sim.elapsed+Words.ROUTE_END_SECONDS})
		was_moving[i]=moving
	clock=sim.elapsed;hull=float(sim.hull)
# The lines to show now. An urgent display (a threat, a lock banner) hides them without consuming them.
func lines(sim,urgent:bool)->Array:
	notices=notices.filter(func(n):return n.until>sim.elapsed)
	if urgent:return []
	return notices.map(func(n):return n.text)
