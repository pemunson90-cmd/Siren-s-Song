extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,t):
 s.paused=false
 for n in roundi(t*60):s.advance(Sim.STEP)
 s.paused=true
func fixture(id=20):
 var s=Sim.new();s.start(id);s.sirens=[]
 s.units[1].pos=s.mission.glass_reach.work_pos+Vector2(0,35);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1})
 return s
func _initialize():
 var s=fixture();check(s.has_method("glass_context"),"local material and machinery work exists")
 if not s.has_method("glass_context"):finish();return
 var missing=s.snapshot();missing.mission.erase("glass_reach")
 check(not Sim.valid_snapshot(missing),"current new-region snapshot cannot omit its physical work/custody payload")
 check(s.command("glass_action",{"action":"recover"}),"actual local carrier starts audible material winch")
 tick(s,1);var before=s.snapshot();check(Sim.valid_snapshot(before),"partial material recovery is a valid current snapshot")
 var restored=Sim.new();var restored_ok=restored.restore(before);check(restored_ok,"partial material recovery restores")
 if not restored_ok:finish();return
 s.advance(30);check(before==s.snapshot(),"tactical pause freezes winch")
 s.command("select",{"unit":2});tick(s,3.2);tick(restored,3.2)
 check(s.mission.glass_reach.artifact.state=="cargo" and s.mission.glass_reach.artifact.carrier==1 and restored.mission.glass_reach.artifact.state=="cargo","worker/custody-local winch survives peer selection and restore")
 s.units[0].pos=s.units[1].pos+Vector2(30,0);s.command("select",{"unit":0})
 check(s.command("glass_action",{"action":"transfer","carrier":1}) and s.mission.glass_reach.artifact.carrier==0,"real local same-depth transfer puts material on Quietus")
 for kind in ["route","loss","band","blocked"]:
  s=fixture();s.command("glass_action",{"action":"recover"});tick(s,1.)
  if kind=="route":
   s.command("route",{"point":s.units[1].pos+Vector2(0,160)})
   check(s.mission.glass_reach.job.is_empty(),"accepted paused route immediately releases material work")
  if kind=="loss":s.units[1].alive=false
  if kind=="band":s.units[1].band=2
  if kind=="blocked":s.mission.structures.append(Rect2(s.units[1].pos-Vector2(10,20),Vector2(20,10)))
  tick(s,4.)
  check(s.mission.glass_reach.job.is_empty() and s.mission.glass_reach.artifact.state=="site","real "+kind+" interrupts material retrieval")
 s=fixture();s.command("glass_action",{"action":"recover"});tick(s,4.2);s.units[1].band=2;s.units[1].alive=false;tick(s,.1)
 check(s.mission.glass_reach.artifact.state=="wreck" and s.mission.glass_reach.artifact.band==2,"carrier loss leaves real material in its actual occupied water")
 s=fixture(18);s.units[0].pos=s.mission.glass_reach.work_pos+Vector2(0,35);s.command("select",{"unit":0})
 check(s.command("glass_action",{"action":"service"}),"bare Quietus can restore inhabited service without gear/tools")
 tick(s,8.2)
 check(s.mission.glass_reach.choice=="service" and s.mission.glass_reach.gate_open and s.mission.structures.is_empty(),"service choice opens physical water and commits only local account")
 check(Sim.valid_snapshot(s.snapshot()),"completed local service is saveable")
 finish()
func finish():print("GLASS WORK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
