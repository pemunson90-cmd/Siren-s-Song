extends SceneTree
# Deterministic headless timing probe. Timings are evidence, never pass/fail thresholds.
# -- --seconds=180 --operations=19,22,23,24,25,26,27,28,29,16 --profile
# Idle standard fleets retain live enemies and ordinary resource/outcome rules.
const Sim=preload("res://src/simulation/simulation.gd")
class Profiled extends "res://src/simulation/simulation.gd":
 var costs={}
 func note(key,start):costs[key]=int(costs.get(key,0))+Time.get_ticks_usec()-start
 func _terrain_observe()->void:
  var at=Time.get_ticks_usec();super._terrain_observe();note("terrain_observe",at)
 func _threats(dt:float)->bool:
  var at=Time.get_ticks_usec();var result=super._threats(dt);note("threats",at);return result
 func _observe()->void:
  var at=Time.get_ticks_usec();super._observe();note("observe_inclusive",at)
 func _move(u:Dictionary,dt:float,speed:float,holding:bool,report_collision:bool=true,player_craft:bool=false)->void:
  var at=Time.get_ticks_usec();super._move(u,dt,speed,holding,report_collision,player_craft);note("move_inclusive",at)
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var seconds=1.;var operations=[19,29];var profile=false
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--seconds="):seconds=float(arg.trim_prefix("--seconds="))
  if arg.begins_with("--operations="):
   operations=[]
   for item in arg.trim_prefix("--operations=").split(","):operations.append(int(item))
  if arg=="--profile":profile=true
 for operation in operations:
  var objects_before=int(Performance.get_monitor(Performance.OBJECT_COUNT))
  var s=Profiled.new() if profile else Sim.new();var at=Time.get_ticks_usec();s.start(operation,"endurance")
  var setup_usec=Time.get_ticks_usec()-at;s.paused=false
  if profile:s.costs={}
  var ticks=0;var episodes=1;var total_usec=0;var max_usec=0;var hashes=[]
  while ticks<roundi(seconds*60):
   if not s.outcome.is_empty():
    hashes.append(var_to_bytes(s.snapshot()).hex_encode().sha256_text())
    s.start(operation,"endurance");s.paused=false;episodes+=1
   at=Time.get_ticks_usec();s.advance(Sim.STEP);var cost=Time.get_ticks_usec()-at
   total_usec+=cost;max_usec=maxi(max_usec,cost);ticks+=1
  check(s.elapsed>0 and Sim.valid_snapshot(s.snapshot()),"measured operation retains a valid real simulation "+str(operation))
  hashes.append(var_to_bytes(s.snapshot()).hex_encode().sha256_text())
  var row={"operation":operation,"ticks":ticks,"simulated_seconds":seconds,"episodes":episodes,"setup_usec":setup_usec,"mean_step_usec":float(total_usec)/ticks,"max_step_usec":max_usec,"snapshots":hashes}
  if profile:row["inclusive_cost_usec"]=s.costs
  s=null
  row["retained_objects_delta"]=int(Performance.get_monitor(Performance.OBJECT_COUNT))-objects_before
  print("PERFORMANCE ",JSON.stringify(row))
  await process_frame
 print("PERFORMANCE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
