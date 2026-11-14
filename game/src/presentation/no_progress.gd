extends RefCounted
# A craft with a route that is not getting anywhere (critic 14 Nov: Quietus sat against a ridge with a route
# set while oxygen fell, and nothing said so). This file decides two things and changes no rule:
#   stalled()  a live craft under way on its own route has come no closer than STALL_METRES to its next point
#              for STALL_SECONDS of dive time (so a craft pinned by a current, or pushed back, counts too).
#              Craft that are meant to stand still never count: a held craft (HOLD, a job, a contact guard),
#              a depth change, ALL STOP, a drone aboard, a craft taking a photograph.
#   why()      the reason in plain words (the keys of hud_words.gd): the current is stronger than the drive,
#              rock blocks the leg, or the leg is closed at this depth and another depth is open.
# auto_pause.gd turns a stall into the one automatic pause of trial rule 5 (trial_rules.gd PAUSE_WHEN_BLOCKED).
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const STALL_SECONDS=4.0
const STALL_METRES=3.0
# Inside this distance of its next point a craft is about to arrive, not stuck.
const ARRIVING_METRES=14.0
const HULL_MARGIN=12.0
# True when craft id has been stalled for STALL_SECONDS. watch holds each craft's best distance to its next point
# and when it was reached.
static func stalled(sim,id:int,watch:Dictionary)->bool:
	var u=sim.units[id]
	if not _under_way(sim,id,u):
		watch.erase(id);return false
	var distance:float=u.pos.distance_to(u.route[0].pos)
	var seen=watch.get(id)
	# A new next point (an arrival, a new order) starts the look again, as does any real progress.
	if distance<ARRIVING_METRES or seen==null or not seen.point.is_equal_approx(u.route[0].pos) or distance<=float(seen.best)-STALL_METRES:
		watch[id]={"point":u.route[0].pos,"best":distance,"t":sim.elapsed};return false
	return sim.elapsed-float(seen.t)>=STALL_SECONDS
static func _under_way(sim,id:int,u:Dictionary)->bool:
	if not u.alive or u.route.is_empty() or not str(u.get("hold","")).is_empty() or not u.get("transition",{}).is_empty():return false
	if AllStop.stopped(u) or AllStop.restarting(u) or sim.DroneBay.aboard(u):return false
	return not (id<sim.captures.size() and not sim.captures[id].is_empty())
# The reason a craft's leg does not go. {"key": a key of hud_words.gd AUTO_PAUSE_KEYS, "extra": the depth that is open}.
# held: the craft holds because rock blocks the leg (hand_pilot's edge_hold), so the plain rock line is the default.
static func why(sim,id:int,held:bool=false)->Dictionary:
	var u=sim.units[id]
	if u.route.is_empty():return {"key":"blocked" if held else "stuck","extra":""}
	var point:Vector2=u.route[0].pos
	var open:=_open_depth(sim,u,point)
	if open.closed:
		if open.band>=0:return {"key":"blocked_band" if held else "stuck_band","extra":sim.Depth.NAMES[open.band]}
		return {"key":"blocked" if held else "stuck_rock","extra":""}
	if held:return {"key":"blocked","extra":""}
	if sim.current_at(u.pos).length()>0.1 and sim.propulsion_speed(u)>1.0:return {"key":"stuck_current","extra":""}
	return {"key":"stuck","extra":""}
# {"closed": the straight leg to the point is not clear at the craft's own depth, "band": another depth that is
# clear, or -1}. Geometry is read per depth, then the selected craft's depth is restored.
static func _open_depth(sim,u:Dictionary,point:Vector2)->Dictionary:
	sim._use_band(u.band)
	var closed:bool=not sim.segment_safe(u.pos,point,HULL_MARGIN)
	var found:=-1
	if closed:
		for band in 3:
			if band==u.band:continue
			sim._use_band(band)
			if not sim.blocked(u.pos,HULL_MARGIN) and not sim.blocked(point,HULL_MARGIN) and sim.segment_safe(u.pos,point,HULL_MARGIN):found=band;break
	sim._use_band(sim.units[sim.selected].band)
	return {"closed":closed,"band":found}
