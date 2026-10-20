extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
func tick(s,seconds):
 s.paused=false
 for i in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func _initialize():
 # Optional hardware physically fitted only to Quietus must not operate from a remote bare drone.
 for fitted in [false,true]:
  var s=Sim.new();s.start(19,"endurance",{"fitted":{"quietus":"quietus_decoder" if fitted else "","drone_a":"","drone_b":""}});s.sirens=[]
  s.units[1].pos=s.mission.glass_reach.work_pos-Vector2(0,100);s.command("select",{"unit":1})
  var c=s.Glass.context(s,"gate")
  print("REMOTE DECODER fitted=",fitted," Q=",s.units[0].pos," worker=",s.units[1].pos," context=",c)
  check(not c.ready,"remote bare drone lacks Quietus-only decoder beyond manual range fitted="+str(fitted))
  var accepted=s.command("glass_action",{"action":"gate"});tick(s,2.2)
  check(not accepted and not s.mission.glass_reach.gate_open,"remote bare drone cannot quietly open real gate fitted="+str(fitted))
 # Actor-local material recovery survives differing peer selection and current save/restore.
 var s=Sim.new();s.start(20);s.sirens=[];var a=s.mission.glass_reach.artifact
 s.units[1].pos=a.pos+Vector2(0,35);s.units[2].band=2;s.command("select",{"unit":1})
 check(s.command("glass_action",{"action":"recover"}),"live bare drone starts real local material winch")
 tick(s,.8);s.command("select",{"unit":2});var copy=Sim.new()
 check(copy.restore(s.snapshot()),"unselected active material worker restores current save")
 tick(s,3.4);tick(copy,3.4)
 check(a.state=="cargo" and a.carrier==1 and copy.mission.glass_reach.artifact.carrier==1,"peer selection and restore preserve actual physical material custody")
 # A real loss leaves a recoverable depth-local object; wrong-depth transfer never teleports it.
 s.units[1].band=2;s.units[1].alive=false;tick(s,.1)
 check(a.state=="wreck" and a.band==2 and a.carrier==-1,"lost material remains at carrier's actual depth")
 s.units[0].pos=a.pos+Vector2(0,35);s.command("select",{"unit":0})
 check(not s.command("glass_action",{"action":"recover"}),"MIDDLE Quietus cannot winch DEEP physical material")
 s.units[0].band=2;s.command("select",{"unit":0})
 check(s.command("glass_action",{"action":"recover"}),"same-band Quietus can resume physical wreck winch")
 tick(s,4.2)
 check(a.state=="cargo" and a.carrier==0 and Sim.valid_snapshot(s.snapshot()),"recovered deep material maintains valid current custody")
 # Local physical departure must not depend on a selected craft's other band.
 for band in [0,2]:
  s=Sim.new();s.start(20);s.sirens=[]
  a=s.mission.glass_reach.artifact;a.state="cargo";a.carrier=1
  s.units[0].pos=s.mission.extraction;s.units[1].pos=s.mission.extraction+Vector2(25,0);s.units[2].band=band
  s.command("select",{"unit":0});var before=s.Glass.can_extract(s,s.extraction_corridors()[0]);var fleet=s.ModuleRecovery.departure(s,s.extraction_corridors()[0])
  s.command("select",{"unit":2})
  check(before and s.Glass.can_extract(s,s.extraction_corridors()[0]) and s.ModuleRecovery.departure(s,s.extraction_corridors()[0])==fleet,"new mouth material/fleet receipt invariant under selected band="+str(band))
 # New stationary roles retain finite physical snare and current-save semantics.
 for role in ["buoy","relay"]:
  s=Sim.new();s.start(14);s.sirens=s.sirens.filter(func(e):return e.type==role)
  s.units[0].pos=s.sirens[0].pos-Vector2(120,0);s.units[0].angle=0
  s.units[1].alive=false;s.units[2].alive=false;s.contacts={};s._observe()
  var launched=s.command("knock",{"target":0});tick(s,1.)
  check(launched and s.projectiles.is_empty() and s.sirens[0].get("pin_time",0)>7. and Sim.valid_snapshot(s.snapshot()),"actual "+role+" snare impact preserves valid finite physical state")
  tick(s,9.)
  check(s.sirens[0].get("pin_time",0)==0 and s.sirens[0].stun<=0 and s.sirens[0].mode not in ["PINNED","DISRUPTED"] and Sim.valid_snapshot(s.snapshot()),role+" finite snare expires and listening/report AI resumes")
 print("INDEPENDENT GLASS CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
