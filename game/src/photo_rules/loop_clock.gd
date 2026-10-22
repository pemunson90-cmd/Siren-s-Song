extends RefCounted
# PHOTO RULES / LOOP CLOCK. Unlock: a gait frame of a patrolling Siren at quality
# 0.45 or better, which files a `loop` finding (photo_findings.gd). The player then
# reads "LOOP 38s" for that Siren and, while a recent sighting exists, a ghost tick
# on the loop with "TURN ~12s".
#
# Fair by construction: the tick is dead reckoned at the patrol pace from the
# player's LAST CONTACT with that Siren (sim.contacts, which the simulation drops
# after 20 s), never from the Siren's live position. It is dropped when the Siren
# was last seen off its routine (investigating, searching, pinned) or when the
# player has since made a noise it would have heard, and it fades to STALE.
# Pure function of mission.photo.findings, sim.contacts, sim.noises and sim.elapsed.
const Table = preload("res://src/photo_rules/rule_table.gd")

static func points(finding: Dictionary) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for p in finding.get("pts", []):
		pts.append(Vector2(float(p[0]), float(p[1])))
	# A filed loop repeats its first point to close the polyline.
	if pts.size() > 2 and pts[0].is_equal_approx(pts[pts.size() - 1]):
		pts.remove_at(pts.size() - 1)
	return pts
static func cumulative(pts: PackedVector2Array) -> Array:
	var cum: Array = [0.0]
	for k in pts.size():
		cum.append(float(cum[k]) + pts[k].distance_to(pts[(k + 1) % pts.size()]))
	return cum
# Arc length along the closed loop of the point nearest to p, and its distance from the loop.
static func locate(pts: PackedVector2Array, cum: Array, p: Vector2) -> Dictionary:
	var best := {"s": 0.0, "d": INF}
	for k in pts.size():
		var a: Vector2 = pts[k]
		var b: Vector2 = pts[(k + 1) % pts.size()]
		var q: Vector2 = Geometry2D.get_closest_point_to_segment(p, a, b)
		var d: float = q.distance_to(p)
		if d < float(best.d):
			best = {"s": float(cum[k]) + a.distance_to(q), "d": d}
	return best
static func point_at(pts: PackedVector2Array, cum: Array, s: float) -> Vector2:
	var total: float = float(cum[cum.size() - 1])
	s = fposmod(s, total)
	for k in pts.size():
		if s <= float(cum[k + 1]):
			var seg: float = float(cum[k + 1]) - float(cum[k])
			return pts[k].lerp(pts[(k + 1) % pts.size()], 0.0 if seg <= 0.0 else (s - float(cum[k])) / seg)
	return pts[0]
# Seconds from arc length s to the next corner of the loop.
static func time_to_turn(cum: Array, s: float, speed: float) -> float:
	for k in range(1, cum.size()):
		if float(cum[k]) > s + 0.001:
			return (float(cum[k]) - s) / speed
	return 0.0
# True when the player has made a noise since that sighting that this Siren would have heard.
static func heard_us(sim, c: Dictionary) -> bool:
	for n in sim.noises:
		var scale: float = sim.Depth.transmission({"band": int(n.get("band", 1))}, {"band": int(c.get("band", 1))})
		if Vector2(n.pos).distance_to(c.pos) < float(n.radius) * scale:
			return true
	return false
# One entry per loop the player has filed.
static func entries(sim) -> Array:
	var result: Array = []
	if not Table.ENABLED:
		return result
	for f in sim.mission.get("photo", {}).get("findings", []):
		if f.kind != "loop" or not str(f.get("text", "")).contains(Table.LOOP_TEXT_KEY) or float(f.q) < Table.LOOP_MIN_Q:
			continue
		var i: int = int(str(f.id).trim_prefix("loop_"))
		if i < 0 or i >= sim.sirens.size() or str(sim.sirens[i].get("type", "patroller")) not in Table.LOOP_TYPES:
			continue
		var pts: PackedVector2Array = points(f)
		if pts.size() < 3:
			continue
		var cum: Array = cumulative(pts)
		var length: float = float(cum[cum.size() - 1])
		var entry := {"i": i, "pts": pts, "period": length / Table.PATROL_SPEED, "state": "stale", "at": Vector2.ZERO, "turn": -1.0, "age": INF}
		var c = sim.contacts.get(i)
		if c is Dictionary and str(c.get("source", "")) == "optical":
			var age: float = sim.elapsed - float(c.time)
			var where: Dictionary = locate(pts, cum, c.pos)
			if age <= Table.STALE_AFTER and str(c.get("mode", "")) not in Table.OFF_ROUTINE_MODES and float(where.d) <= Table.LOOP_SNAP and not heard_us(sim, c):
				var s: float = float(where.s) + Table.PATROL_SPEED * age
				entry.state = "live" if age <= Table.AGING_AFTER else "aging"
				entry.at = point_at(pts, cum, s)
				entry.turn = time_to_turn(cum, fposmod(s, length), Table.PATROL_SPEED)
				entry.age = age
		result.append(entry)
	return result
# The line the chart draws for an entry.
static func text(e: Dictionary) -> String:
	var n: int = int(e.i) + 1
	var period: int = roundi(float(e.period))
	match str(e.state):
		"live":
			return Table.TEXT.loop_turn % [n, period, ceili(float(e.turn))]
		"aging":
			return Table.TEXT.loop_aging % [n, period, ceili(float(e.turn))]
	return Table.TEXT.loop_stale % [n, period]
