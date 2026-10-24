extends "res://tests/t_pressure_probes.gd"
# External evidence wrapper only. Match tick's existing epsilon at budget boundary.
# No position, time, route, controller policy or simulation-state adjustment.
func running()->bool:
 return super.running() and sim.elapsed+.00001<BUDGET
func run_probe(id:int,name:String):
 super.run_probe(id,name)
 if sim.outcome.is_empty() and sim.elapsed+.00001>=BUDGET:
  row.outcome="budget_timeout"
  rows[-1]=row.duplicate(true)
  FileAccess.open(out_dir+"/op_%02d_%s.json"%[id,name],FileAccess.WRITE).store_string(JSON.stringify(row,"\t"))
  print("BOUNDED_BUDGET_TIMEOUT ",id," ",name," actual_elapsed=",sim.elapsed)
