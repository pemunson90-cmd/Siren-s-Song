extends SceneTree
# Bounded live-physics probe. Source-known authored journey routes, not human play.
# No state edits after launch. Run with -- --out=/absolute/report/directory.
const Sim = preload("res://src/simulation/simulation.gd")
const BUDGET = 900.0
var sim
var policy = ""
var row = {}
var rows = []
var stop_reason = ""
var next_policy = 0.0
var last_defense = -100.0
var out_dir = "/workspace/work/claude-lanes-20261021/x2"

func issue(order: String, args: Dictionary = {}, unit: int = 0) -> bool:
	if not sim.units[unit].alive: return false
	sim.command("select", {"unit": unit})
	var accepted = sim.command(order, args)
	row.commands.append({"time": sim.elapsed, "unit": unit, "order": order, "args": str(args), "accepted": accepted, "message": sim.message})
	if accepted: row.accepted[order] = row.accepted.get(order, 0) + 1
	return accepted

func running() -> bool:
	return sim.outcome.is_empty() and sim.elapsed < BUDGET and stop_reason.is_empty()

func policy_tick():
	if sim.elapsed < next_policy: return
	next_policy = sim.elapsed + 1.0
	sim.command("select", {"unit":0})
	# Decisions use fresh observed contacts only; raw enemy metrics below are logging only.
	var threatened = false
	for c in sim.contacts.values():
		if sim.elapsed - c.time < 1.0 and c.get("lock", 0.0) >= 1.0: threatened = true
	if policy != "quietus_only" and threatened and sim.elapsed - last_defense > 8.0:
		var targets = sim.knockdown_targets()
		if policy == "aggressive" and not targets.is_empty() and sim.tools.knock > 0:
			issue("knock", {"target": targets[0].key}); last_defense = sim.elapsed
		elif sim.tools.emp > 0:
			issue("emp"); last_defense = sim.elapsed
		elif sim.tools.decoy > 0:
			for delta in [Vector2(140,0),Vector2(-140,0),Vector2(0,140),Vector2(0,-140)]:
				var p = sim.units[0].pos + delta
				if sim.decoy_target_valid(p): issue("decoy", {"point": p}); last_defense = sim.elapsed; break
	if policy == "aggressive":
		if int(sim.elapsed) % 20 == 0: issue("ping")
		if int(sim.elapsed) in [1,90] and sim.tools.recon > 0: issue("recon")
	elif policy == "drone_heavy" and int(sim.elapsed) % 25 == 0:
		for unit in [1,2]:
			if sim.units[unit].alive: issue("ping", {}, unit)
		if sim.tools.recon > 0 and int(sim.elapsed) in [25,100]:
			issue("recon", {}, 1 if sim.units[1].alive else 0)
	sim.command("select", {"unit":0})

func tick(seconds: float):
	var until = minf(BUDGET, sim.elapsed + seconds)
	sim.paused = false
	while running() and sim.elapsed + .00001 < until:
		policy_tick()
		sim.advance(Sim.STEP)
		var locked = false
		var beam = false
		for enemy in sim.sirens:
			row.peak_lock = maxf(row.peak_lock, enemy.lock)
			if enemy.get("target", -1) == 0 and enemy.lock > 0: locked = true
			if enemy.get("target", -1) == 0 and enemy.lock >= 4: beam = true
		if locked: row.quietus_locked_seconds += Sim.STEP
		if beam: row.quietus_beam_seconds += Sim.STEP
	sim.paused = true

func go(point: Vector2) -> bool:
	if not running(): return sim.outcome == "won"
	if not issue("route", {"point":point}): stop_reason = "controller_route_rejected"; return false
	# Independent, simultaneous drone legs. Quietus selection does not drive them.
	if policy == "drone_heavy":
		for unit in [1,2]:
			if sim.units[unit].alive:
				var scout = point + Vector2(0, -80 if unit == 1 else 80)
				issue("route", {"point":scout}, unit)
	var deadline = minf(BUDGET, sim.elapsed + 240.0)
	while running() and sim.elapsed < deadline:
		tick(.25)
		if sim.units[0].route.is_empty() and sim.units[0].vel.length() < 2:
			if sim.units[0].pos.distance_to(point) < 25: return true
			stop_reason = "controller_navigation_stop"; return false
	if sim.outcome == "won": return true
	if running(): stop_reason = "controller_leg_timeout"
	return false

func course(points: Array) -> bool:
	for point in points:
		if not go(point): return false
	return true

func work(order: String, action: String, seconds: float = 8.25) -> bool:
	if not running(): return false
	if not issue(order, {"action":action}): stop_reason = "controller_work_rejected"; return false
	tick(seconds)
	return running()

func outside(point: Vector2) -> bool:
	if sim.units[0].pos.x < 600 and point.x < 600: return course([Vector2(250,point.y),point])
	if sim.units[0].pos.x < 600:
		if not course([Vector2(250,2250),Vector2(2200,2250)]): return false
	elif sim.units[0].pos.x < 1900:
		if not go(Vector2(2200,sim.units[0].pos.y)): return false
	if point.x < 600: return course([Vector2(2200,2250),Vector2(250,2250),point])
	return course([Vector2(2200,point.y),point])

func glass(id: int):
	if id in [15,18]:
		if not outside(sim.mission.glass_reach.work_pos + Vector2(0,35)): return
		if not work("glass_action", "vane" if id == 15 else "service"): return
	if not sim.mission.objectives[0].captured:
		if not outside(sim.mission.objectives[0].pos + Vector2(0,80)): return
		if not issue("camera"): stop_reason = "controller_camera_rejected"; return
		tick(sim.mission.objectives[0].duration + .25)
	if id in [17,20,21]:
		if not outside(sim.mission.glass_reach.work_pos + Vector2(0,35)): return
		if not work("glass_action", "recover",4.25): return
	outside(sim.mission.extraction)

func iron(id: int):
	match id:
		22,25:
			if id == 25:
				if not course([Vector2(350,600),Vector2(750,600)]): return
				if not work("choir_action","service"): return
			if not go(Vector2(750,2050)): return
			if not issue("choir_action",{"action":"west"}): stop_reason = "controller_release_rejected"; return
			if not course([Vector2(750,600),Vector2(750,300)] + ([Vector2(2500,450)] if id == 22 else [])): return
			while running() and not sim.mission.iron_choir.receipt: tick(.25)
			course([Vector2(350,300),Vector2(300,2350)])
		23:
			for site in sim.mission.iron_choir.sites:
				if not go(site.pos + Vector2(0,35)) or not work("choir_action",site.id): return
			course([Vector2(2750,700),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)])
		24:
			if not go(Vector2(750,2140)) or not work("choir_action","attach",0): return
			if not course([Vector2(750,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]): return
			if not work("choir_action","bypass"): return
			course([Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)])
		26:
			if not course([Vector2(350,350),Vector2(1450,465)]): return
			issue("depth",{"band":2}); tick(4.25)
			if not work("choir_action","recover",4.25): return
			issue("depth",{"band":1}); tick(4.25)
			course([Vector2(1450,350),Vector2(350,350),Vector2(300,2350)])
		27:
			if not go(Vector2(750,1790)) or not work("choir_action","attach",0): return
			if not course([Vector2(750,700),Vector2(1250,700)]): return
			if not work("choir_action","cradle") or not work("choir_action","recover",4.25): return
			course([Vector2(750,700),Vector2(350,700),Vector2(300,2350)])
		28:
			if not go(Vector2(750,2140)) or not work("choir_action","attach",0): return
			if not course([Vector2(750,550),Vector2(700,500)]) or not work("choir_action","land"): return
			course([Vector2(350,500),Vector2(300,2350)])
		29:
			if not course([Vector2(300,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]): return
			if not work("choir_action","reconnect"): return
			course([Vector2(2750,500),Vector2(2750,2450),Vector2(300,2450),Vector2(300,2350)])

func opening():
	for objective in sim.mission.objectives:
		if not go(objective.pos + Vector2(0,80)): return
		if not issue("camera"): stop_reason = "controller_camera_rejected"; return
		tick(objective.get("duration",4.0) + .25)
	go(sim.mission.extraction)

func run_probe(id: int, name: String):
	policy = name; stop_reason = ""; next_policy = 0; last_defense = -100
	row = {"operation":id,"policy":name,"budget_seconds":BUDGET,"route_knowledge":"source-known authored journeys; opening direct authored objective coordinates","commands":[],"accepted":{},"peak_lock":0.0,"quietus_locked_seconds":0.0,"quietus_beam_seconds":0.0}
	sim = Sim.new()
	sim.start(id,"endurance")
	if policy == "quietus_only":
		# Initial scenario only: absent drones, not losses or earned profile.
		sim.units[1].alive = false; sim.units[2].alive = false
	if policy == "aggressive": issue("silent")
	if policy == "drone_heavy":
		for unit in [1,2]: issue("silent",{},unit); issue("drone_drive",{"mode":"transit"},unit)
	if id >= 22: iron(id)
	elif id >= 14: glass(id)
	else: opening()
	if running() and sim.outcome.is_empty(): tick(1.0)
	if running() and sim.departure_context().get("available",false):
		issue("depart",{"confirm":true})
	row.outcome = sim.outcome if not sim.outcome.is_empty() else "budget_timeout" if sim.elapsed >= BUDGET else stop_reason if not stop_reason.is_empty() else "controller_incomplete"
	row.seconds = sim.elapsed; row.hull = sim.hull; row.oxygen = sim.oxygen; row.message = sim.message
	row.quietus_position = str(sim.units[0].pos)
	row.tools_remaining = sim.tools.duplicate(); row.tools_spent = {}
	for key in sim.tools: row.tools_spent[key] = {"emp":2,"decoy":3,"recon":2,"knock":2}[key] - sim.tools[key]
	row.drone_losses = 0 if policy == "quietus_only" else int(not sim.units[1].alive) + int(not sim.units[2].alive)
	row.quietus_lost = sim.hull <= 0
	row.load_hull = sim.mission.get("iron_choir",{}).get("load",{}).get("hull",null)
	row.load_alive = sim.mission.get("iron_choir",{}).get("load",{}).get("alive",null)
	row.snapshot_valid = Sim.valid_snapshot(sim.snapshot())
	rows.append(row.duplicate(true))
	FileAccess.open(out_dir + "/op_%02d_%s.json" % [id,name],FileAccess.WRITE).store_string(JSON.stringify(row,"\t"))
	print("X2_ROW ",id," ",name," outcome=",row.outcome," t=",snapped(sim.elapsed,.01)," hull=",snapped(sim.hull,.01)," drone_losses=",row.drone_losses)

func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var ids = [0,3,5] + range(14,30)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--ids="):
			ids = []; for value in arg.trim_prefix("--ids=").split(","): ids.append(int(value))
	for id in ids:
		for name in ["cautious","aggressive","drone_heavy","quietus_only"]: run_probe(id,name)
	FileAccess.open(out_dir + "/rows.json",FileAccess.WRITE).store_string(JSON.stringify(rows,"\t"))
	var csv = FileAccess.open(out_dir + "/rows.csv",FileAccess.WRITE)
	csv.store_csv_line(PackedStringArray(["operation","policy","outcome","seconds","hull","oxygen","drone_losses","emp","decoy","recon","knock","ping","locked_seconds","beam_seconds","peak_lock","load_hull","load_alive","snapshot_valid"]))
	for r in rows:
		csv.store_csv_line(PackedStringArray([str(r.operation),r.policy,r.outcome,str(r.seconds),str(r.hull),str(r.oxygen),str(r.drone_losses),str(r.tools_spent.emp),str(r.tools_spent.decoy),str(r.tools_spent.recon),str(r.tools_spent.knock),str(r.accepted.get("ping",0)),str(r.quietus_locked_seconds),str(r.quietus_beam_seconds),str(r.peak_lock),str(r.load_hull),str(r.load_alive),str(r.snapshot_valid)]))
	quit(0)
