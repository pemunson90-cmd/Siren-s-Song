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
 var distant=fixture("interceptor");distant.units[0].pos=Vector2(600,1800);distant._noise(distant.units[0].pos,600.,"ACTIVE SONAR",1.,1);tick(distant,.9)
 check(distant.sonar.history.any(func(row):return row.classification=="BURST WINDUP") and distant.contacts.is_empty(),"physically heard distant burst windup has visual bearing equivalent without hidden contact")
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
  check(s.command("emp"),"real EMP overlaps physical snare "+role);tick(s,2.)
  check(s.sirens[0].stun>s.sirens[0].pin_time and s.sirens[0].industry.patches.is_empty() and Sim.valid_snapshot(s.snapshot()),"longer EMP remains active without permanent pin/pressure "+role)
  tick(s,11.);check(s.sirens[0].get("pin_time",0)==0 and s.sirens[0].stun==0,"physical pin and longer EMP expire "+role)
  s=fixture(role);s.units[0].pos=Vector2(350,350);s.mission.iron_choir.load.pos=Vector2(600,2050);s.mission.iron_choir.load.hull=10.;tick(s,5.)
  check(s.outcome=="lost" and not s.mission.iron_choir.load.alive and s.hull==100.,"real "+role+" attack can destroy physical NPC load independently of Quietus")
 occupied_acquisition()
 finish()
func occupied_acquisition():
 var examples=[{"op":22,"role":"interceptor","band":1,"pos":Vector2(1550,2200),"transitions":[[0,1],[1,0],[2,1],[1,2]]},{"op":23,"role":"warden","band":2,"pos":Vector2(2400,1200),"transitions":[[1,2],[2,1]]}]
 for example in examples:
  for fitted in [false,true]:
   for transition in example.transitions:
    var s=Sim.new();s.start(example.op,"endurance",{"fitted":{"quietus":"quietus_pressure_sleeve" if fitted else "","drone_a":"","drone_b":""}})
    s.sirens=s.sirens.filter(func(e):return e.type==example.role);s.units[1].alive=false;s.units[2].alive=false;s.units[0].pos=example.pos;s.units[0].band=transition[0]
    var label=example.role+" "+str(transition)+(" sleeve" if fitted else " bare")
    check(s.command("depth",{"band":transition[1]}) and s.Depth.sight(s,s.sirens[0],s.units[0]),"actual transition occupies visible enemy water "+label)
    tick(s,.5);var state=s.sirens[0].industry
    check(state.phase=="windup" and state.band==example.band and state.aim==example.pos,"acquisition retains legitimately shared observed band "+label)
    var restored=Sim.new();var ok=restored.restore(s.snapshot())
    check(ok,"partly occupied acquisition snapshot restores "+label)
    if not ok:continue
    restored.units[0].pos=Vector2(350,350);tick(restored,1.)
    check(restored.sirens[0].industry.aim==example.pos and restored.sirens[0].industry.band==example.band,"lost-sight transition cannot retarget committed aim or depth "+label)
    tick(restored,9.)
    check(restored.sirens[0].industry.phase=="idle" and restored.sirens[0].industry.patches.is_empty() and Sim.valid_snapshot(restored.snapshot()),"incoming acquisition preserves finite attack/pressure lifecycle "+label)
 for role in ["interceptor","warden"]:
  var s=fixture(role);s.sirens[0].band=2;s.units[0].band=0
  check(s.command("depth",{"band":1}),"disjoint-band transition starts "+role);tick(s,.5)
  check(s.sirens[0].industry.phase=="idle","no shared occupied band does not grant visual acquisition "+role)
  s=fixture(role);s.units[0].band=0;s.mission.structures.append(Rect2(590,2100,20,20));s._build_navigation()
  check(s.command("depth",{"band":1}),"covered incoming transition starts "+role);tick(s,.5)
  check(s.sirens[0].industry.phase=="idle","terrain blocks acquisition despite shared occupied band "+role)
func finish():print("INDUSTRIAL THREATS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
