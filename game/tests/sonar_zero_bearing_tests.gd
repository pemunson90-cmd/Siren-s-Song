extends SceneTree
const Sim = preload("res://src/simulation/simulation.gd")
const Sonar = preload("res://src/simulation/advanced_sonar.gd")
const SaveStore = preload("res://src/persistence/save_store.gd")
const Fixtures = preload("res://tests/depth_sonar_scenarios.gd")
var checks = 0
var failures = 0

func check(ok, label):
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL ", label)

func fixture(offset = Vector2.ZERO):
	var s = Fixtures.fixture()
	var enemy = s.sirens[0]
	enemy.type = "interceptor"
	enemy.pos = s.units[0].pos + offset
	enemy.home = enemy.pos
	enemy.goal = enemy.pos
	s.Industry.initialize(s)
	return s

func tick(s, seconds):
	s.paused = false
	for n in roundi(seconds * 60): s.advance(Sim.STEP)
	s.paused = true

func roundtrip(s, label):
	var snapshot = s.snapshot()
	check(Sonar.valid(snapshot) and Sim.valid_snapshot(snapshot), label + " snapshot validates before storage")
	var store = SaveStore.new()
	store.path = "user://sonar-zero-bearing-" + label + ".save"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(store.path + suffix)
	var envelope = {"version":1, "unlocked":0, "completed":[], "upgrade":"endurance", "settings":{}, "active":snapshot}
	check(store.save(envelope), label + " writes a real checksummed save")
	var loaded = store.load_game()
	check(loaded == envelope, label + " reads the same active game from disk")
	var restored = Sim.new()
	var ok = not loaded.is_empty() and restored.restore(loaded.active)
	check(ok, label + " restores the overlapping enemy and craft")
	if ok:
		check(restored.sirens[0].pos == restored.units[0].pos, label + " retains exact physical overlap")
		var before = restored.snapshot()
		restored.advance(1.0)
		check(before == restored.snapshot(), label + " restored game remains paused")
		Sonar.advance(restored, .6)
		check(Sonar.valid(restored.snapshot()), label + " next passive sample remains saveable")
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(store.path + suffix)

func passive_overlap():
	var s = fixture()
	# A real recovery phase keeps both bodies still through ordinary live ticks.
	s.sirens[0].industry.phase = "recovery"
	s.sirens[0].industry.remaining = 4.0
	s.sirens[0].industry.cooldown = 8.0
	tick(s, 1.0)
	check(s.sirens[0].pos == s.units[0].pos, "live interceptor recovery reproduces exact overlap")
	check(s.sonar.history.is_empty(), "coincident passive source supplies no invented bearing")
	roundtrip(s, "passive")

func active_overlap():
	var s = fixture()
	var reserve = s.oxygen
	check(s.command("ping"), "coincident source does not prevent a real sonar pulse")
	check(s.oxygen == reserve - .4 and s.sonar.listening_until[0] > s.elapsed, "pulse keeps its existing cost and listening window")
	check(not s.sonar.pending.any(func(packet): return packet.kind == "echo"), "coincident reflection supplies no directionless pending echo")
	roundtrip(s, "active")
	Sonar.advance(s, 0.0)
	check(s.sonar.history.is_empty() and Sonar.valid(s.snapshot()), "delivery tick cannot turn overlap into an invalid echo history")

func nearby_readings():
	for offset in [Vector2(.01, 0), Vector2(0, -.01)]:
		var s = fixture(offset)
		Sonar.advance(s, 0.0)
		check(s.sonar.history.size() == 1, "nearby noncoincident source still supplies a passive reading")
		if s.sonar.history.size() != 1: continue
		var row = s.sonar.history[0]
		check(row.direction == offset.normalized() and row.classification == "STATION TONE" and row.kind == "bearing", "nearby direction and classification stay unchanged")
		check(s.command("ping"), "nearby source admits the ordinary pulse")
		var echoes = s.sonar.pending.filter(func(packet): return packet.kind == "echo")
		check(echoes.size() == 1 and echoes[0].direction == offset.normalized(), "nearby active echo retains its true nonzero bearing")
		check(Sonar.valid(s.snapshot()), "nearby passive and pending active readings validate")

func independent_readings():
	var overlap = fixture()
	var control = fixture(Vector2(1000, 0))
	for s in [overlap, control]:
		var other = s.sirens[0].duplicate(true)
		other.erase("industry")
		other.type = "sentinel"
		other.acoustic_tone = 197.0
		other.pos = s.units[0].pos + Vector2(200, 0)
		other.home = other.pos
		other.goal = other.pos
		s.sirens.append(other)
		Sonar.advance(s, 0.0)
	check(control.sonar.history.size() == 1, "separate source produces the ordinary control reading")
	check(overlap.sonar.history == control.sonar.history, "coincident source leaves every other bearing field and history entry unchanged")
	check(overlap.sonar.history.back().classification == "PROPULSION", "normal machinery classification remains unchanged")

	var s = fixture()
	s.units[1].alive = true
	s.units[1].pos = s.units[0].pos + Vector2(0, 100)
	Sonar.advance(s, 0.0)
	check(s.sonar.history.size() == 1 and s.sonar.history[0].station == 1 and s.sonar.history[0].direction == Vector2.UP, "another receiver still hears the source that overlaps Quietus")

func pending_and_terrain():
	var s = fixture(Vector2(100, 0))
	check(s.command("ping"), "separated source produces an ordinary pending echo")
	var emitted: Vector2 = s.sirens[0].pos
	s.sirens[0].pos = s.units[0].pos
	s.sirens[0].home = s.units[0].pos
	s.sirens[0].goal = s.units[0].pos
	s.elapsed = 1.0
	Sonar.advance(s, 0.0)
	check(s.sonar.history.size() == 1 and s.sonar.history[0].kind == "echo" and s.sonar.history[0].direction == Vector2.RIGHT, "later overlap preserves the original emission-time echo bearing")
	check(s.contacts[0].pos == emitted and s.contacts[0].time == 0.0 and Sonar.valid(s.snapshot()), "later overlap preserves old echo position and time without an invalid passive row")
	var malformed = s.snapshot()
	malformed.sonar.history[0].direction = Vector2.ZERO
	check(not Sonar.valid(malformed), "validator still rejects a stored directionless bearing")

	s = fixture()
	s.units[0].band = 2
	s.sirens[0].band = 2
	check(s.command("ping"), "coincident source permits a pulse in a charted depth band")
	check(s.sonar.pending.any(func(packet): return packet.kind == "terrain") and not s.sonar.pending.any(func(packet): return packet.kind == "echo"), "omitting undefined echo leaves terrain returns intact")
	check(Sonar.valid(s.snapshot()), "terrain return beside coincident source remains saveable")

func _initialize():
	passive_overlap()
	active_overlap()
	nearby_readings()
	independent_readings()
	pending_and_terrain()
	print("SONAR ZERO BEARING CHECKS ", checks, " FAILURES ", failures)
	quit(1 if failures else 0)
