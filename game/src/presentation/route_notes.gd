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
# WP-118: a craft the player launched that stands with no orders while time runs. Not a craft that was told to wait (a hold,
# a job, a photograph), is changing depth, is at ALL STOP, is aboard, is recalled, or is Quietus waiting inside its recovery area.
const RECOVERY_REACH=65.0 # simulation.gd: Quietus recovers within this many metres of the extraction
static var _since:Dictionary={}
static var _clock:=-1.0
static var _sim_id:=0
static func _idle(sim,id:int)->bool:
	var u=sim.units[id]
	if not has_orders_free(sim,id) or not u.get("transition",{}).is_empty() or u.get("recall",false):return false
	if AllStop.stopped(u) or AllStop.restarting(u) or u.vel.length()>Words.MOVING_SPEED:return false
	return not (id==0 and sim.mission.has("extraction") and u.pos.distance_to(sim.mission.extraction)<RECOVERY_REACH)
static func has_orders_free(sim,id:int)->bool:
	var u=sim.units[id]
	return u.alive and not sim.DroneBay.aboard(u) and not has_orders(sim,id)
# The standing line while time runs: names every craft that has stood idle for IDLE_SECONDS, "" when none has.
static func idle_line(sim)->String:
	if sim.paused or not sim.outcome.is_empty() or sim.elapsed<_clock or sim.get_instance_id()!=_sim_id:
		_since.clear()
	_sim_id=sim.get_instance_id();_clock=sim.elapsed
	if sim.paused or not sim.outcome.is_empty():return ""
	var names:Array=[];var quietus:=false
	for id in sim.units.size():
		if not _idle(sim,id):
			_since.erase(id);continue
		if not _since.has(id):_since[id]=sim.elapsed
		if sim.elapsed-float(_since[id])>=Words.IDLE_SECONDS:
			names.append(str(sim.units[id].name).to_upper());quietus=quietus or id==0
	if names.is_empty():return ""
	var line:String=(Words.TEXT.idle_one if names.size()==1 else Words.TEXT.idle_many)%Words.TEXT.idle_and.join(names)
	return line+(Words.TEXT.idle_oxygen if quietus else "")
# The status line with the next step added once the record is secured and Quietus has no route.
static func home_step(sim,text:String)->String:
	var q=sim.units[0]
	if not text.contains(Words.TEXT.return_old) or not q.alive or not q.route.is_empty():return text
	return text.replace(Words.TEXT.return_old,Words.TEXT.return_steps)
static func run_line(sim)->String:
	if not sim.paused or not sim.outcome.is_empty():return ""
	var locks:Array=LockWarning.frames(sim)
	if not locks.is_empty():return Words.TEXT.run_lock%float(locks[0].remaining)
	var names:Array=[]
	for id in sim.units.size():
		if has_orders(sim,id):names.append(str(sim.units[id].name).to_upper())
	return Words.TEXT.run_orders%", ".join(names) if not names.is_empty() else Words.TEXT.run_none
