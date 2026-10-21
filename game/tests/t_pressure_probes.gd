extends "res://tests/x2_pressure_probes.gd"
# Run with -- --out=/absolute/outside-repo/directory and optional --ids=24,29.
# Enemy-seconds sample live phases every physics step, not perceived danger.
# The inherited policies remain blind to these diagnostic counters.
var pressure: Dictionary = {}
var previous_phase: Dictionary = {}

func run_probe(id: int, name: String):
 pressure = {"interceptor_windups":0,"interceptor_windup_seconds":0.0,"interceptor_burst_seconds":0.0,"warden_windups":0,"warden_windup_seconds":0.0,"warden_field_seconds":0.0}
 previous_phase = {}
 super.run_probe(id, name)
 row["industrial_pressure"] = pressure.duplicate()
 rows[-1] = row.duplicate(true)
 FileAccess.open(out_dir + "/op_%02d_%s.json" % [id,name],FileAccess.WRITE).store_string(JSON.stringify(row,"\t"))
 print("T_PRESSURE ",id," ",name," ",JSON.stringify(pressure))

func tick(seconds: float):
 var until = minf(BUDGET, sim.elapsed + seconds)
 while running() and sim.elapsed + .00001 < until:
  var before = sim.elapsed
  super.tick(minf(Sim.STEP, until - sim.elapsed))
  var dt = sim.elapsed - before
  for id in sim.sirens.size():
   var enemy = sim.sirens[id]
   if enemy.get("type","") not in ["interceptor","warden"]: continue
   var state = enemy.industry
   var role = enemy.type
   if state.phase == "windup":
    pressure[role + "_windup_seconds"] += dt
    if previous_phase.get(id,"") != "windup": pressure[role + "_windups"] += 1
   if role == "interceptor" and state.phase == "burst": pressure.interceptor_burst_seconds += dt
   if role == "warden" and not state.patches.is_empty(): pressure.warden_field_seconds += dt
   previous_phase[id] = state.phase
