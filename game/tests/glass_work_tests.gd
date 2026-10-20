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
 decoder_locality()
 finish()
func gate_fixture(fitted:bool,unit:int,distance:float):
 var s=Sim.new();s.start(19,"endurance",{"fitted":{"quietus":"quietus_decoder" if fitted else "","drone_a":"","drone_b":""}});s.sirens=[]
 s.units[unit].pos=s.mission.glass_reach.work_pos-Vector2(0,distance);s.command("select",{"unit":unit})
 return s
func decoder_locality():
 var bare=gate_fixture(false,0,100.)
 check(not bare.command("glass_action",{"action":"gate"}) and bare.Glass.context(bare,"gate").range==60.,"bare Quietus cannot operate gate beyond manual60m range")
 for unit in [0,1,2]:
  var s=gate_fixture(true,unit,100.)
  var c=s.Glass.context(s,"gate")
  check(c.ready==(unit==0) and c.duration==(2. if unit==0 else 8.) and c.range==(120. if unit==0 else 60.),"only actual decoder carrier gets extended quiet gate context unit="+str(unit))
  if unit>0:
   check(not s.command("glass_action",{"action":"gate"}) and not s.mission.glass_reach.gate_open,"remote Quietus hardware cannot admit bare drone at100m unit="+str(unit))
 for unit in [0,1,2]:
  var s=gate_fixture(unit>0,unit,35.)
  check(s.command("glass_action",{"action":"gate"}) and s.mission.glass_reach.job.duration==8. and s.noises.any(func(n):return n.label=="REACH MACHINERY" and n.radius==520.),"bare local worker starts audible8s manual gate unit="+str(unit))
  tick(s,2.2)
  check(not s.mission.glass_reach.gate_open and not s.mission.structures.is_empty(),"bare manual work cannot open gate at decoder timing unit="+str(unit))
  s.command("select",{"unit":2 if unit==0 else 0})
  var restored=Sim.new();var ok=restored.restore(s.snapshot())
  check(ok,"unselected manual gate worker has restorable partial snapshot unit="+str(unit))
  if ok:
   tick(restored,6.)
   check(restored.mission.glass_reach.gate_open and restored.mission.structures.is_empty() and Sim.valid_snapshot(restored.snapshot()),"bare worker completes real8s gate after peer selection/restore unit="+str(unit))
 var s=gate_fixture(true,0,100.)
 check(s.command("glass_action",{"action":"gate"}) and s.noises.is_empty(),"local fitted Quietus starts quiet gate from100m")
 tick(s,.8);s.units[1].band=2;s.command("select",{"unit":1})
 var restored=Sim.new();var ok=restored.restore(s.snapshot())
 check(ok,"fitted Quietus work remains saveable with another-depth peer selected")
 if ok:
  tick(restored,1.4)
  check(restored.mission.glass_reach.gate_open and restored.mission.structures.is_empty() and restored.noises.is_empty() and Sim.valid_snapshot(restored.snapshot()),"actual fitted worker retains2s120m quiet benefit after peer selection/restore")
 s=gate_fixture(true,1,35.);s.command("glass_action",{"action":"gate"});tick(s,.2)
 s.units[1].pos=s.mission.glass_reach.work_pos-Vector2(0,100);s.command("select",{"unit":0});tick(s,.1)
 check(s.mission.glass_reach.job.is_empty() and not s.mission.glass_reach.gate_open,"ongoing bare drone range stays60m while fitted Quietus selected")
 s=gate_fixture(true,0,100.);s.mission.structures.append(Rect2(s.units[0].pos+Vector2(-10,30),Vector2(20,10)))
 check(not s.command("glass_action",{"action":"gate"}),"local decoder still requires physical clear water to gate")
func finish():print("GLASS WORK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
