extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,t):
 s.paused=false
 for i in roundi(t*60):s.advance(Sim.STEP)
 s.paused=true
func fixture(role):
 var s=Sim.new();s.start(22);s.sirens=s.sirens.slice(0,1);s.sirens[0].type=role;s.Industry.initialize(s)
 s.sirens[0].pos=Vector2(600,2200);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].band=1
 s.units[0].pos=Vector2(600,2050);s.units[1].alive=false;s.units[2].alive=false
 return s
func _initialize():
 check(ResourceLoader.exists("res://src/simulation/industrial_threats.gd"),"industrial enemy state machines exist")
 if not ResourceLoader.exists("res://src/simulation/industrial_threats.gd"):finish();return
 var s=fixture("interceptor");tick(s,.1)
 check(s.sirens[0].industry.phase=="windup","interceptor winds up from legitimate local sight")
 var aim=s.sirens[0].industry.aim;s.units[0].pos=Vector2(350,2050);tick(s,.5)
 check(s.sirens[0].industry.aim==aim,"windup commits stale observation rather than hidden current position")
 var copy=Sim.new();check(copy.restore(s.snapshot()),"partial committed burst snapshot restores")
 var before=s.snapshot();s.advance(3.);check(s.snapshot()==before,"pause freezes committed enemy phases")
 tick(s,2.0);check(s.sirens[0].pos.x==600. and s.hull==100.,"physical burst follows frozen line and misses relocated craft")
 s=fixture("warden");tick(s,2.8)
 check(s.sirens[0].industry.patches.size()==1 and Sim.valid_snapshot(s.snapshot()),"warden creates bounded saveable actual danger patch")
 s.units[0].pos=Vector2(350,2050);tick(s,7.)
 check(s.sirens[0].industry.patches.is_empty(),"finite warden danger expires without persistent invisible field")
 for role in ["interceptor","warden"]:
  s=fixture(role);s.units[0].band=2;tick(s,.2)
  check(s.sirens[0].industry.phase=="idle","quiet other-depth craft does not invent target "+role)
  s.units[0].band=1;s.units[0].pos=s.sirens[0].pos-Vector2(120,0);s.units[0].angle=0;s.contacts={};s._observe()
  check(s.command("knock",{"target":0}),"real torpedo launches at acquired "+role);tick(s,1.)
  check(s.sirens[0].get("pin_time",0)>7. and Sim.valid_snapshot(s.snapshot()),"physical pin save is finite "+role)
  tick(s,9.);check(s.sirens[0].get("pin_time",0)==0 and s.sirens[0].stun==0,"physical pin expires "+role)
 finish()
func finish():print("INDUSTRIAL THREATS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
