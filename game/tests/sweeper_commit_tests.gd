extends SceneTree
const Sim = preload("res://src/simulation/simulation.gd")
const Sweeper = preload("res://src/simulation/sonar_sweeper.gd")
const Fixtures = preload("res://tests/depth_sonar_scenarios.gd")
var checks = 0
var failures = 0

func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL ", label)

func fixture(competing = false, same_step = false):
	var s = Fixtures.fixture()
	var e = s.sirens[0]
	e.type = "sweeper"
	e.pos = Vector2(350, 700)
	e.home = e.pos
	e.goal = e.pos
	if competing:
		s.units[1].alive = true
		s.units[1].pos = Vector2(450 if same_step else 550, 700)
	# Produce real return packets with ordinary travel times and unit ordering.
	Sweeper.advance(s, e, 0.0)
	e.sweep.charge = 2.5
	Sweeper.advance(s, e, 0.0)
	check(e.sweep.pending.size() == (2 if competing else 1), "active sweep emits each eligible return")
	return s

func deliver(s, at_time, dt = 0.0):
	s.elapsed = at_time
	Sweeper.advance(s, s.sirens[0], dt)

func single_and_staggered():
	for competing in [false, true]:
		var s = fixture(competing)
		var e = s.sirens[0]
		var arrival = e.sweep.pending[0].due
		deliver(s, arrival)
		check(e.sweep.strike.pos == s.units[0].pos and e.sweep.strike.remaining == 1.5, "first delivered return arms the ordinary 1.5 second strike")
		var peer = e.duplicate(true)
		peer.type = "sentinel"
		peer.erase("sweep")
		peer.attention_time = 0.0
		s.sirens.append(peer)
		deliver(s, arrival + .75, .75)
		check(e.sweep.strike.pos == s.units[0].pos and is_equal_approx(e.sweep.strike.remaining, .75), "staggered competing return cannot replace target or reset countdown")
		if competing:
			check(e.last_known == s.units[1].pos and e.goal == s.units[1].pos and e.suspicion == .6 and e.attention_time == 7.0, "later return still updates detection and suspicion")
			check(peer.last_known == s.units[1].pos and peer.goal == s.units[1].pos and peer.attention_time == 5.0, "later return still shares its stale report with a peer")
		deliver(s, arrival + 1.5, .75)
		check(s.hull == 78.0 and e.sweep.strike.is_empty(), "original strike fires on time for 22 hull with or without a competing craft")
		check(s.units[1].battery == 100.0, "competing craft is not substituted as strike target")

func simultaneous():
	var s = fixture(true, true)
	var e = s.sirens[0]
	var arrival = e.sweep.pending[0].due
	# Existing reverse packet traversal delivers drone A first on a same-step tie.
	deliver(s, arrival, .25)
	check(e.sweep.strike.pos == s.units[1].pos and is_equal_approx(e.sweep.strike.remaining, 1.25), "same-step first processed return keeps its target and countdown")
	check(e.last_known == s.units[0].pos, "same-step remaining return still updates detection")
	deliver(s, arrival + 1.25, 1.25)
	check(s.hull == 100.0 and s.units[1].battery == 72.0, "same-step tie delivers only the committed strike")

func pause_and_restore():
	var s = fixture(true)
	var e = s.sirens[0]
	deliver(s, e.sweep.pending[0].due, .25)
	var before = s.snapshot()
	s.advance(1.0)
	check(s.snapshot() == before, "pause freezes armed target countdown and pending returns")
	var copy = Sim.new()
	var restored = copy.restore(before)
	check(restored and copy.snapshot() == before, "existing save schema roundtrips armed strike and competing pending return")
	if not restored: return
	for live in [s, copy]:
		deliver(live, live.elapsed + .75, .75)
		check(live.sirens[0].sweep.strike.pos == live.units[0].pos and is_equal_approx(live.sirens[0].sweep.strike.remaining, .5), "restored competing return keeps original target and remaining delay")
		live.paused = false
		for n in 31: live.advance(Sim.STEP)
		live.paused = true
		check(live.hull == 78.0, "live simulation fires committed strike after resume")
	check(s.snapshot() == copy.snapshot(), "restored continuation matches uninterrupted simulation")

func disruption_and_rearm():
	var s = fixture(true)
	var e = s.sirens[0]
	deliver(s, e.sweep.pending[0].due)
	check(s.command("emp") and s.tools.emp == 1, "ordinary disruption spends one finite EMP")
	Sweeper.advance(s, e, .1)
	check(e.sweep.strike.is_empty() and e.sweep.pending.is_empty(), "disruption breaks commitment and discards outstanding returns")
	Sweeper.advance(s, e, 12.0)
	Sweeper.advance(s, e, 0.0)
	# A later ordinary sweep is free to choose a new target after recovery.
	s.units[0].pos = Vector2(900, 700)
	s.units[1].pos = Vector2(450, 700)
	e.sweep.cooldown = 0.0
	e.sweep.charge = 2.5
	Sweeper.advance(s, e, 0.0)
	var next_arrival = e.sweep.pending.back().due
	deliver(s, next_arrival)
	check(e.sweep.strike.pos == s.units[1].pos, "new sweep can commit to another craft after disruption")
	deliver(s, next_arrival + 1.5, 1.5)
	check(s.hull == 100.0 and s.units[1].battery == 72.0, "broken original strike deals no hull damage")
	# Once a strike fires, another delivered return may arm a new strike.
	deliver(s, next_arrival + 4.0)
	check(not e.sweep.strike.is_empty() and e.sweep.strike.pos == s.units[0].pos and e.sweep.strike.remaining == 1.5, "later return may arm after the previous strike fires")

func missed_strike():
	var s = fixture()
	var e = s.sirens[0]
	deliver(s, e.sweep.pending[0].due)
	s.units[0].pos += Vector2(0, 100)
	deliver(s, s.elapsed + 1.5, 1.5)
	check(s.hull == 100.0 and e.sweep.strike.is_empty(), "leaving the committed position avoids damage and expires the strike")
	e.sweep.cooldown = 0.0
	e.sweep.charge = 2.5
	Sweeper.advance(s, e, 0.0)
	deliver(s, e.sweep.pending[0].due)
	check(e.sweep.strike.pos == s.units[0].pos and e.sweep.strike.remaining == 1.5, "a new sweep may arm after the old strike misses")

func _initialize():
	single_and_staggered()
	simultaneous()
	pause_and_restore()
	disruption_and_rearm()
	missed_strike()
	print("SWEEPER COMMIT CHECKS ", checks, " FAILURES ", failures)
	quit(1 if failures else 0)
