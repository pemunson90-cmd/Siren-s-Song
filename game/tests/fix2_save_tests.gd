extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds:float)->void:
 s.paused=false
 for n in ceili(seconds*60):s.advance(1.0/60.0)
 s.paused=true
func _initialize():
 var s=Sim.new();s.start(1);s.sirens=[]
 var o=s.mission.objectives[0]
 s.units[0].pos=o.pos+Vector2(0,60);s.units[0].angle=-PI/2;s.units[0].vel=Vector2.ZERO
 check(s.command("frame",{"mode":"tight","focus":"housing"}) and s.command("camera"),"first housing exposure starts through ordinary orders")
 tick(s,5.0)
 check(o.captured and s.captures[0].is_empty(),"first usable frame completes before the retake")
 check(s.command("frame",{"mode":"tight","focus":"clock"}) and s.command("camera"),"ordinary camera permits a retake for the missing clock")
 tick(s,0.25)
 var active=s.snapshot()
 check(not active.captures[0].is_empty() and o.captured,"the original record remains secured during a partial retake")
 check(Sim.valid_snapshot(active),"a legitimate in-flight photo retake validates")
 var store=Store.new();store.path="user://fix2-retake.save"
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 var envelope={"version":1,"unlocked":1,"completed":[0],"upgrade":"endurance","settings":{},"active":active}
 check(store.save(envelope),"the partial retake saves atomically")
 var saved=store.load_game();var restored=Sim.new()
 check(saved.has("active") and restored.restore(saved.active),"the saved partial retake reloads without losing the original record")
 if not restored.units.is_empty():
  check(not restored.captures[0].is_empty() and restored.mission.objectives[0].captured,"reload retains both the first frame and ongoing exposure")
  tick(restored,5.0)
  check(restored.captures[0].is_empty() and Sim.valid_snapshot(restored.snapshot()),"the restored exposure finishes and remains valid")
 var malformed=active.duplicate(true);malformed.captures[0].elapsed=INF
 check(not Sim.valid_snapshot(malformed),"non-finite retake clocks remain rejected")
 malformed=active.duplicate(true);malformed.captures[0].elapsed=100.0
 check(not Sim.valid_snapshot(malformed),"over-duration retakes remain rejected")
 malformed=active.duplicate(true);malformed.mission.objectives[0].erase("subject")
 check(not Sim.valid_snapshot(malformed),"captured non-photographic work cannot masquerade as a retake")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 print("FIX2 SAVE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
