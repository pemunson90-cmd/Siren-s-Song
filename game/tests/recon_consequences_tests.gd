extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func step(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):s.advance(1./60)
func _initialize():
 var s=Sim.new();s.start(0);s.units[1].pos=Vector2(1300,300);s.command("select",{"unit":1})
 check(s.command("camera"),"drone begins real local exposure")
 var before=s.snapshot();s.advance(1)
 check(s.snapshot()==before,"pause freezes pressure and exposure")
 step(s,4.1)
 check(s.mission.objectives[0].get("photo_quality",0)>.5 and Recon.grade(s.mission.objectives).grade in ["A","B"],"close drone obtains a strong actual photograph")
 check(Recon.state(s.mission).floor==8,"secured evidence establishes operational floor")
 check(s.has_method("recon_feedback"),"model exposes public recon consequences")
 if not s.has_method("recon_feedback"):
  print("RECON CONSEQUENCES CHECKS ",checks," FAILURES ",failures);quit(1);return
 var saved=s.snapshot();var copy=Sim.new();check(copy.restore(saved) and Recon.state(copy.mission)==Recon.state(s.mission),"pressure and actual photo survive current restore")
 var q=Sim.new();q.start(0);q.units[0].pos=Vector2(1300,300);q.command("camera");step(q,4.1)
 check(q.mission.objectives[0].get("photo_quality",0)>0.3 and q.mission.objectives[0].photo_craft=="QUIETUS","Quietus fallback remains usable and is credited as the photographer")
 var receiver={"pos":q.units[0].pos,"kind":"receiver","captured":true};q.mission.objectives.append(receiver);Recon.secured(q,receiver,0)
 check(not receiver.has("photo_quality"),"receiver does not manufacture a photograph")
 var remote=q.sirens[0];check(not remote.has("alert_floor"),"unheard covered photograph cannot buff remote guard")
 var guard={"suspicion":0.0,"stun":0.0,"target":-1};Recon.heard(guard,{"pulse":true,"record":0})
 check(guard.alert_floor>0 and guard.heard_records==[0],"local acoustic arrival earns lasting alert and only its heard record")
 var local=Sim.new();local.start(0);local.sirens=[guard]
 Recon.secured(local,local.mission.objectives[0],0)
 check(guard.alert_floor>.12,"secured evidence raises only the locally informed guard floor")
 q.sirens=[guard]
 var private_before=q.recon_feedback();guard["lock"]=4.0
 check(q.recon_feedback()==private_before,"hidden enemy lock cannot drive public heartbeat")
 q.contacts={0:{"time":q.elapsed,"lock":3.5}}
 check(q.recon_feedback().hostile,"fresh received lock drives hostile visual and audio cue")
 step(s,12)
 check(Recon.state(s.mission).hunt>=8,"quiet time cannot erase secured-evidence floor")
 var pulse=preload("res://src/audio/soundscape.gd").samples("heartbeat");var peak=0.0
 for value in pulse:peak=maxf(peak,absf(value))
 check(pulse.size()>1000 and peak>.01 and peak<.4,"threat heartbeat has bounded nonzero audio")
 print("RECON CONSEQUENCES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
