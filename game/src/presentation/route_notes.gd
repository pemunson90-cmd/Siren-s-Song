extends RefCounted
# WP-106 (round 8 critics): two read-only notes that say what the dive will do with the player's orders.
#   tag()       a route line the craft is not following says why on the chart ("ROUTE KEPT · HOLDING"). Critic A saw
#               a dashed route for about 25 s while Quietus stood still on a hold or a photograph and nothing said so.
#   run_line()  while the dive is stopped, the first thing RUN will do: a lock landing, else which craft have orders,
#               else that none has.
# No rule, order or saved value is touched. Words live in hud_words.gd.
const Words=preload("res://src/presentation/hud_words.gd")
const NoProgress=preload("res://src/presentation/no_progress.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const LockWarning=preload("res://src/presentation/lock_warning.gd")
# The chart tag for craft id, "" when it follows its route (or has none).
static func tag(sim,id:int)->String:
	var u=sim.units[id]
	if not u.alive or u.route.is_empty() or sim.DroneBay.aboard(u) or u.vel.length()>Words.MOVING_SPEED:return ""
	var hold:String=NoProgress.holding(sim,id)
	if not hold.is_empty():return Words.TEXT["tag_"+hold]
	if id<sim.captures.size() and not sim.captures[id].is_empty():return Words.TEXT.tag_photo
	if not u.get("transition",{}).is_empty():return Words.TEXT.tag_depth
	if AllStop.stopped(u) or AllStop.restarting(u):return Words.TEXT.tag_stop
	if not str(u.get("hold","")).is_empty():return Words.TEXT.tag_task
	return ""
# Whether a craft has something to do once time runs: a route, a hold or a job.
static func has_orders(sim,id:int)->bool:
	var u=sim.units[id]
	if not u.alive or sim.DroneBay.aboard(u):return false
	return not u.route.is_empty() or not str(u.get("hold","")).is_empty() or (id<sim.captures.size() and not sim.captures[id].is_empty())
static func run_line(sim)->String:
	if not sim.paused or not sim.outcome.is_empty():return ""
	var locks:Array=LockWarning.frames(sim)
	if not locks.is_empty():return Words.TEXT.run_lock%float(locks[0].remaining)
	var names:Array=[]
	for id in sim.units.size():
		if has_orders(sim,id):names.append(str(sim.units[id].name).to_upper())
	return Words.TEXT.run_orders%", ".join(names) if not names.is_empty() else Words.TEXT.run_none
