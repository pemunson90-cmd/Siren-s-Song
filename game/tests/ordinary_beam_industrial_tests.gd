extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Feedback=preload("res://src/presentation/contact_feedback.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func beam_fixture():
 var s=Sim.new();s.start(22)
 var guard=s.sirens[0].duplicate(true);guard.erase("industry");guard.type="sentinel";guard.pos=Vector2(630,2100);guard.home=guard.pos;guard.goal=guard.pos;guard.vel=Vector2.ZERO;guard.route=[]
 s.sirens=[guard];s.units[0].pos=Vector2(860,2100);s.units[1].alive=false;s.units[2].alive=false;s.contacts={}
 tick(s,4.2);s._observe()
 return s
func _initialize():
 var s=beam_fixture();var body=s.mission.iron_choir.load
 check(s.sirens[0].get("recipient_target",false) and s.sirens[0].target==-1 and s.sirens[0].lock>=4 and body.hull<100 and s.hull==100,"real ordinary beam acquires and damages industrial hull independently of Quietus")
 check(s.contacts.has(0) and s.contacts[0].get("recipient_target",false),"acquired beam contact projects non-player target ownership")
 if not s.contacts.has(0):finish();return
 var contact=s.contacts[0].duplicate(true);var seen=s.mission.iron_choir.seen.duplicate(true)
 var endpoint=s.contact_target(contact)
 check(not endpoint.is_empty() and endpoint.get("pos")==seen.pos and endpoint.get("hull")==seen.hull and endpoint.get("alive",false),"ordinary industrial beam resolves its cached observed hull endpoint")
 var rows=Feedback.entries(s.contacts,s.elapsed,s.units,s.line_clear,s.contact_target)
 check(rows.size()==1 and rows[0].urgent and body.name in rows[0].text and "FIRING" in rows[0].text,"visible real industrial beam warning identifies its actual target")
 body.pos+=Vector2(25,0);body.hull=55.
 endpoint=s.contact_target(contact)
 check(endpoint.get("pos")==seen.pos and endpoint.get("hull")==seen.hull,"endpoint never samples unobserved live hull mutations")
 body.alive=false;endpoint=s.contact_target(contact)
 check(endpoint.get("alive",false) and endpoint.get("pos")==seen.pos,"unobserved hull loss cannot leak through the cached endpoint")
 body.alive=true
 if not endpoint.is_empty():endpoint.pos=Vector2.ZERO
 check(s.mission.iron_choir.seen.pos==seen.pos,"public endpoint cannot mutate cached industrial observation")
 body.pos=seen.pos;tick(s,Sim.STEP);s._observe()
 var restored=Sim.new();var ok=restored.restore(s.snapshot())
 check(ok,"real industrial beam and cached target restore current snapshot")
 if ok:check(restored.contact_target(restored.contacts[0]).get("pos")==restored.mission.iron_choir.seen.pos,"restored observed industrial beam resolves its own cached hull")
 s.units[0].pos=Vector2(300,2350);tick(s,.2)
 check(s.contact_target(contact).is_empty(),"hidden industrial hull provides no live beam endpoint from a stale fix")
 rows=Feedback.entries({0:contact},s.elapsed,s.units,s.line_clear,s.contact_target)
 check(rows.size()==1 and not rows[0].urgent,"hidden hull suppresses live beam warning without revealing current truth")
 var unseen=Sim.new();unseen.start(22)
 check(unseen.contact_target({"recipient_target":true,"target":-1}).is_empty(),"unobserved industrial hull cannot supply a beam endpoint")
 s=beam_fixture();contact=s.contacts[0].duplicate(true);s.mission.iron_choir.load.hull=1.;tick(s,.2);s._observe()
 check(s.outcome=="lost" and not s.mission.iron_choir.load.alive and s.contact_target(contact).is_empty(),"real industrial hull destruction removes the usable beam endpoint")
 check(s.contact_target({"target":0})==s.units[0] and s.contact_target({"target":1})==s.units[1] and s.contact_target({"target":-1}).is_empty(),"controlled-craft endpoints retain actor identity without non-player aliasing")
 var recipient=Sim.new();recipient.start(13);recipient.sirens=[];recipient.units[0].pos=Vector2(1840,390);recipient.units[1].alive=false;recipient.units[2].alive=false;recipient._observe()
 endpoint=recipient.contact_target({"recipient_target":true,"target":-1})
 check(endpoint.get("pos")==recipient.mission.warning_recipient.body.pos and endpoint.get("alive",false),"ordinary observed warning-recipient endpoint remains intact")
 recipient.units[0].pos=Vector2(300,2350)
 check(recipient.contact_target({"recipient_target":true,"target":-1}).is_empty(),"ordinary hidden warning recipient still supplies no live endpoint")
 finish()
func finish():print("ORDINARY BEAM INDUSTRIAL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
