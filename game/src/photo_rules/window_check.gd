extends RefCounted
# PHOTO RULES / WINDOW CHECK. Unlock: a `cycle` finding (a feature that shows
# only in a window, for example the base hatches: 7 s of every 30). The chart and
# the camera line then compare the player's OWN route with that published cycle:
# "OPENS IN 12s · you arrive in 9s · WAIT 3s", or GO, or TOO LATE.
#
# Planning aid only. The arrival time is the selected craft's planned route (or,
# with no route, its distance to the subject less a viewing standoff) at the speed
# it is set to fly; the window is the finding's own period, open time and phase on
# the shared world clock. Nothing is saved, nothing is tracked, and the Priced
# Shots countdown is the same clock (photo_pricing.gd windows()).
const Table = preload("res://src/photo_rules/rule_table.gd")
# Distance at which a craft is taken to be in position when it has no route, metres.
const STANDOFF := 100.0

static func craft_speed(u: Dictionary, uid: int) -> float:
	if uid > 0:
		return float(Table.CRAFT_SPEED.drone)
	return float(Table.CRAFT_SPEED.silent) if u.get("silent", false) else float(Table.CRAFT_SPEED.cruise)
# Seconds for the craft to reach `target` along its route, or straight at it.
static func arrival(u: Dictionary, uid: int, target: Vector2) -> float:
	var speed: float = craft_speed(u, uid)
	var length: float = 0.0
	var route: Array = u.get("route", [])
	if route.is_empty():
		length = maxf(0.0, u.pos.distance_to(target) - STANDOFF)
	else:
		var at: Vector2 = u.pos
		for node in route:
			length += at.distance_to(node.pos)
			at = node.pos
	return length / speed
# State of one window for a craft arriving `arrive` seconds from now.
static func evaluate(clock: float, period: float, open: float, phase: float, arrive: float) -> Dictionary:
	var now: float = fposmod(clock + phase, period)
	var open_now: bool = now < open
	var then: float = fposmod(now + arrive, period)
	var head: String = Table.TEXT.window_open % ceili(open - now) if open_now else Table.TEXT.window_opens % ceili(period - now)
	var state := "wait"
	var wait: float = 0.0
	if then < open:
		state = "go" if open - then >= Table.GO_MARGIN else "late"
		wait = period - then
	else:
		wait = period - then
		state = "late" if wait > Table.WAIT_LIMIT else "wait"
	var line: String
	match state:
		"go":
			line = Table.TEXT.window_go % [head, ceili(arrive)]
		"wait":
			line = Table.TEXT.window_wait % [head, ceili(arrive), ceili(wait)]
		_:
			line = Table.TEXT.window_late % [head, ceili(arrive), ceili(wait if wait > 0.0 else period - then)]
	return {"state": state, "text": line, "wait": wait, "arrive": arrive}
static func entries(sim) -> Array:
	var result: Array = []
	if not Table.ENABLED:
		return result
	var uid: int = sim.selected
	var u: Dictionary = sim.units[uid]
	if not u.alive:
		return result
	for f in sim.mission.get("photo", {}).get("findings", []):
		if f.kind != "cycle" or not f.has("period") or not f.has("pos") or float(f.period) <= 0.0:
			continue
		var at := Vector2(float(f.pos[0]), float(f.pos[1]))
		var e: Dictionary = evaluate(sim.elapsed, float(f.period), float(f.get("open", 0.0)), float(f.get("phase", 0.0)), arrival(u, uid, at))
		e["pos"] = at
		e["id"] = str(f.id)
		result.append(e)
	return result
# One line for the camera text when the framed subject is a finding's own subject.
static func camera_line(sim, target_pos: Vector2) -> String:
	for e in entries(sim):
		if Vector2(e.pos).distance_to(target_pos) < 24.0:
			return str(e.text)
	return ""
