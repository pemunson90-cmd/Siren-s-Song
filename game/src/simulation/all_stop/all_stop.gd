extends RefCounted
# ALL STOP: the engines-off state of Quietus.
#
# While stopped the hull ignores its course and its thrust is zero: it slows at
# COAST_DECEL (or drifts with a current), makes no motion noise, and keeps its
# route for later. The camera is untouched: an exposure holds the craft as before
# and the two compose (the hull coasts to rest, the exposure steadies as it does).
# Ordering the engines back, or plotting any new course, starts a restart: for
# RESTART_SECONDS thrust is held to RESTART_SPEED, then the state clears.
#
# SEAMS (remove this folder and these lines to revert; all_stop_table.gd
# ENABLED=false plays exactly as before):
#   simulation.gd  command():           "all_stop" order, and AllStop.after_order(...) at its end
#   simulation.gd  _tick():             AllStop.tick(self,dt)
#   simulation.gd  _move_in_band():     AllStop.shape(...) after _craft_speed, AllStop.decel(...) on braking
#   simulation.gd  _current_step():     AllStop.decel(...) on the water acceleration
#   simulation.gd  motion_radius():     AllStop.noise_scale(...)
#   simulation.gd  validation:          AllStop.valid(unit)
#   mission_hud.gd route menu:          the ALL STOP button and its label
# Save: an optional unit field "all_stop" = {"mode":"stopped"|"restart","t":seconds}.
# Absent means engines on. A build without this module ignores the key.
const Table = preload("res://src/simulation/all_stop/all_stop_table.gd")

static func state(u: Dictionary) -> String:
	var s = u.get("all_stop")
	return str(s.get("mode", "")) if s is Dictionary else ""
static func stopped(u: Dictionary) -> bool:
	return state(u) == "stopped"
static func restarting(u: Dictionary) -> bool:
	return state(u) == "restart"
static func available(sim) -> bool:
	return Table.ENABLED and sim.selected == 0
# The ALL STOP order: shut the engines down, or order them back.
static func command(sim) -> bool:
	if not Table.ENABLED:
		return false
	var u: Dictionary = sim.units[sim.selected]
	if sim.selected != 0:
		sim.message = Table.TEXT.refused_craft
		return false
	if stopped(u):
		return release(sim, u)
	if not u.get("transition", {}).is_empty():
		sim.message = Table.TEXT.refused_depth
		return false
	if sim.oxygen <= Table.ENTRY_OXYGEN:
		sim.message = Table.TEXT.refused_oxygen
		return false
	sim.oxygen -= Table.ENTRY_OXYGEN
	u["all_stop"] = {"mode": "stopped", "t": 0.0}
	sim.message = Table.TEXT.engage % Table.ENTRY_OXYGEN
	return true
# Orders the engines back: a timed restart at limited thrust.
static func release(sim, u: Dictionary) -> bool:
	if not stopped(u):
		return false
	sim.oxygen = maxf(0.0, sim.oxygen - Table.RESTART_OXYGEN)
	u["all_stop"] = {"mode": "restart", "t": Table.RESTART_SECONDS}
	# Hold station where the hull now is, not where it was when the engines stopped.
	u.erase("current_station")
	sim.message = Table.TEXT.restart % [ceili(Table.RESTART_SECONDS), Table.RESTART_OXYGEN]
	return true
# A new course with the engines off orders the restart. Called after the order succeeds.
static func after_order(sim, u: Dictionary, order: String) -> void:
	if order in Table.COURSE_ORDERS and stopped(u):
		release(sim, u)
# Advances the restart. Called once a step.
static func tick(sim, dt: float) -> void:
	var u: Dictionary = sim.units[0]
	if not restarting(u):
		return
	u.all_stop.t = float(u.all_stop.t) - dt
	if float(u.all_stop.t) <= 0.0:
		u.erase("all_stop")
# Thrust and course for this step. Stopped: no thrust and the course is held.
# Restarting: thrust held down. Otherwise unchanged.
static func shape(u: Dictionary, speed: float, holding: bool) -> Dictionary:
	if stopped(u):
		return {"speed": 0.0, "holding": true}
	if restarting(u):
		return {"speed": minf(speed, Table.RESTART_SPEED), "holding": holding}
	return {"speed": speed, "holding": holding}
# Rate at which the hull slows or the water carries it: the coast while stopped.
static func decel(u: Dictionary, base: float) -> float:
	return Table.COAST_DECEL if stopped(u) else base
static func noise_scale(u: Dictionary) -> float:
	if stopped(u):
		return Table.OFF_NOISE
	return Table.RESTART_NOISE if restarting(u) else 1.0
# Text for the order button.
static func label(sim) -> String:
	var u: Dictionary = sim.units[0]
	if stopped(u):
		return Table.TEXT.button_restart
	if restarting(u):
		return Table.TEXT.button_spinup % ceili(float(u.all_stop.t))
	return Table.TEXT.button_cost % Table.ENTRY_OXYGEN
static func valid(u: Dictionary) -> bool:
	if not u.has("all_stop"):
		return true
	var s = u.all_stop
	if not s is Dictionary or s.size() != 2 or not s.has_all(["mode", "t"]) or not s.mode is String or s.mode not in ["stopped", "restart"]:
		return false
	if not (s.t is float or s.t is int) or not is_finite(s.t) or s.t < 0.0 or s.t > Table.RESTART_SECONDS + 0.001:
		return false
	return true
