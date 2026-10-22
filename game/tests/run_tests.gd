extends SceneTree
const Simulation = preload("res://src/simulation/simulation.gd")
var failures := 0
var checks := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", message)
func _initialize() -> void:
	var s = Simulation.new()
	s.start(0)
	var before = s.snapshot()
	s.advance(10.0)
	check(before == s.snapshot(), "tactical pause freezes every simulation clock")
	s.command("route", {"point":Vector2(220,800)})
	s.paused = false
	for i in 180: s.advance(1.0/60.0)
	check(s.units[0].pos.x > 150, "ordinary route commands propel submarine with inertia")
	preload("res://tests/core_scenarios.gd").run(self)
	preload("res://tests/persistence_scenarios.gd").run(self)
	preload("res://tests/campaign_scenarios.gd").run(self)
	preload("res://tests/audio_scenarios.gd").run(self)
	preload("res://tests/attention_scenarios.gd").run(self)
	preload("res://tests/split_channel_scenarios.gd").run(self)
	preload("res://tests/waypoint_scenarios.gd").run(self)
	preload("res://tests/foundry_scenarios.gd").run(self)
	preload("res://tests/finale_scenarios.gd").run(self)
	preload("res://tests/patrol_scenarios.gd").run(self)
	preload("res://tests/siren_role_scenarios.gd").run(self)
	preload("res://tests/acoustic_scenarios.gd").run(self)
	preload("res://tests/observed_contact_scenarios.gd").run(self)
	preload("res://tests/blackwater_scenarios.gd").run(self)
	preload("res://tests/operation_catalog_scenarios.gd").run(self)
	preload("res://tests/depth_sonar_scenarios.gd").run(self)
	preload("res://tests/sweeper_scenarios.gd").run(self)
	preload("res://tests/opening_depth_scenarios.gd").run(self)
	preload("res://tests/frontend_scenarios.gd").run(self)
	print("CHECKS ", checks, " FAILURES ", failures)
	quit(1 if failures else 0)
