extends SceneTree
const Sim = preload("res://src/simulation/simulation.gd")
var checks = 0
var failures = 0

func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL ", label)

func tick(s, seconds):
	s.paused = false
	for n in roundi(seconds * 60): s.advance(Sim.STEP)
	s.paused = true

func fixture(role = "interceptor"):
	var s = Sim.new()
	s.start(22)
	s.sirens = s.sirens.slice(0, 1)
	var e = s.sirens[0]
	e.type = role
	s.Industry.initialize(s)
	e.pos = Vector2(600, 2200)
	e.home = e.pos
	e.goal = e.pos
	e.route = []
	s.units[0].pos = Vector2(600, 2050)
	for id in [1, 2]: s.units[id].alive = false
	return s

func moving_fixture():
	var s = fixture()
	s.sirens[0].stun = 1.0
	check(s.command("route", {"point":Vector2(1000, 2050)}), "real horizontal route accepted")
	tick(s, 1.05)
	check(s.sirens[0].industry.phase == "windup" and s.units[0].vel.x > 40, "windup acquires actual moving craft after finite disruption")
	return s

func patrol():
	var s = Sim.new()
	s.start(22)
	s.sirens = s.sirens.slice(0, 1)
	for id in [1, 2]: s.units[id].alive = false
	var e = s.sirens[0]
	var start: Vector2 = e.pos
	tick(s, 3.0)
	check(e.pos.distance_to(start) > 20 and e.industry.phase == "idle", "unalerted interceptor traverses its authored patrol")
	check(s.Depth.clear(s, start, e.pos, e.band, 12) and s.hull == 100, "patrol respects physical water without inventing distant acquisition")
	var saved = s.snapshot()
	s.advance(5.0)
	check(saved == s.snapshot() and Sim.valid_snapshot(saved), "patrol remains saveable and freezes in tactical pause")
	s = Sim.new()
	s.start(22)
	s.sirens = s.sirens.slice(0, 1)
	for id in [1, 2]: s.units[id].alive = false
	e = s.sirens[0]
	e.patrol_points = [e.home]
	start = e.pos
	tick(s, 3.0)
	check(e.pos == start and e.route.is_empty(), "exhausted authored patrol never invents a procedural destination")

func committed_interception():
	var s = moving_fixture()
	var e = s.sirens[0]
	check(e.industry.aim.x > s.units[0].pos.x + 50, "visual commit leads observed motion instead of harmlessly chasing its wake")
	tick(s, 3.5)
	check(s.hull == 80, "unchanged straight course intersects one committed burst")

	s = moving_fixture()
	e = s.sirens[0]
	var aim: Vector2 = e.industry.aim
	var saved = s.snapshot()
	var restored = Sim.new()
	check(Sim.valid_snapshot(saved) and restored.restore(saved), "moving visual commit uses the existing snapshot shape")
	s.advance(5.0)
	check(saved == s.snapshot(), "pause freezes predicted commit without consuming its warning")
	check(s.command("hold"), "real braking order accepted during windup")
	tick(s, 3.5)
	check(e.industry.aim == aim and s.hull == 100, "braking during warning evades fixed aim without hidden retargeting")
	if not restored.units.is_empty():
		restored.command("hold")
		tick(restored, 3.5)
		check(restored.sirens[0].industry.aim == aim and restored.hull == 100, "restored commit preserves the same physical escape")

func evidence_limits():
	var s = moving_fixture()
	var e = s.sirens[0]
	# Obstruct the projected crossing after real motion has been established.
	s.mission.structures.append(Rect2(680, 2010, 30, 80))
	s._build_navigation()
	e.industry = s.Industry.initial()
	var observed: Vector2 = s.units[0].pos
	s.Industry.advance(s, e, Sim.STEP)
	check(e.industry.phase == "windup" and e.industry.aim == observed, "terrain-obstructed prediction falls back to the acquired point")

	s = fixture()
	e = s.sirens[0]
	s.units[0].pos = Vector2(600, 1800)
	check(s.command("route", {"point":Vector2(1000, 1800)}) and s.command("ping"), "unseen moving source emits real finite sonar")
	var arrival = s._heard_arrival(e)
	check(not arrival.is_empty(), "physical distant pulse reaches interceptor")
	tick(s, .1)
	check(e.industry.phase == "windup" and e.industry.aim == arrival.goal, "hearing alone commits received point without borrowing hidden velocity")

	s = fixture()
	s.units[0].band = 2
	tick(s, .5)
	check(s.sirens[0].industry.phase == "idle" and s.hull == 100, "another settled depth grants no visual prediction")

func charge_cues():
	for role in ["interceptor", "warden"]:
		var s = fixture(role)
		s.units[0].pos = Vector2(600, 1740)
		check(s.command("ping"), role + " distant target emits actual sonar")
		tick(s, .05)
		check(s.sirens[0].industry.phase == "windup", role + " acquires heard point inside engagement range")
		var cue = "carrier_received" if role == "interceptor" else "factory"
		check(s.events.any(func(event): return event.type == cue and event.get("receiver", -1) == 0 and event.has("direction")), role + " target beyond450m receives a physical directional charge cue")
		check(s.hull == 100 and s.contacts.is_empty(), role + " warning precedes damage without granting a hidden optical fix")

func _initialize():
	patrol()
	committed_interception()
	evidence_limits()
	charge_cues()
	print("T PRESSURE CHECKS ", checks, " FAILURES ", failures)
	quit(1 if failures else 0)
