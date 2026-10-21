extends SceneTree
# Local fixtures isolate causality. Unchanged-guard voyages are tested separately.
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Endings=preload("res://src/campaign/endings.gd")
const BERTH=Vector2(1840,440)
const HOME=Vector2(2420,240)
const PANEL=Vector2(1840,380)
class ArrivalDebrief:
 extends RefCounted
 var sim
 var ui_touch_height=48.
 var panel_box=VBoxContainer.new()
 var lines=[]
 func _menu_text(value:String,_font:int):lines.append(value)
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func advance(s,seconds:float):
 s.paused=false
 for frame in ceili(seconds*60):s.advance(1./60.)
 s.paused=true
func fresh(proof:String=""):
 var s=Sim.new();s.start(13,"endurance",{"context":{"thread":"shelf","facts":{"warning_chain":proof}}});s.sirens=[];return s
func progress(thread:String="shelf")->Dictionary:
 return {"version":2,"route":thread,"routes":[thread],"facts":{thread:"Recovered branch","confluence_route":"overt"},"completed":[6,8,10,11] if thread=="shelf" else [6,7,9,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":thread}
func transmit(s):
 s.units[0].pos=Vector2(1840,1080);s.units[0].vel=Vector2.ZERO
 check(s.command("camera"),"actual chosen-origin transmission starts")
 advance(s,6.2)
func acknowledge(s):
 s.units[0].pos=BERTH+Vector2(-100,0);s.units[0].vel=Vector2.ZERO;advance(s,.8)
 check(s.command("camera"),"earned local reply remains a real reception")
 advance(s,4.2)
func post_arrival_loss(arrival:Dictionary):
 # Targeted transition fixture, not an unmodified-guard voyage. The recipient
 # genuinely travelled and was observed; only the guard/own observation sites
 # are staged. All hull damage and failure use the normal threat tick.
 var s=Sim.new();check(s.restore(arrival),"observed refuge arrival restores before post-arrival threat")
 var store=Store.new();store.path="user://warning-recipient-post-arrival.save"
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 var archive={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress(),"active":s.snapshot()}
 check(store.save(archive) and store.load_game()==archive,"active recipient arrival binary archive round-trips before Quietus recovery")
 var template=Sim.new();template.start(13);var guard=template.sirens[2].duplicate(true)
 guard.pos=HOME+Vector2(130,0);guard.home=guard.pos;guard.goal=guard.pos;guard.route=[];guard.patrol_points=[]
 s.sirens=[guard];s.units[1].pos=HOME+Vector2(-100,-210);s.units[1].vel=Vector2.ZERO;s.units[2].pos=Vector2(600,2200)
 advance(s,6)
 check(s.mission.warning_recipient.body.hull>0 and s.mission.warning_recipient.body.hull<100 and s.sirens[0].get("recipient_target",false),"ordinary acquired beam damages the arrived recipient while the observer stays outside acquisition range")
 archive.active=s.snapshot()
 check(store.save(archive) and store.load_game()==archive,"damaged live recipient at refuge remains a serializable active dive")
 advance(s,6)
 var status=s.warning_recipient_status();var lost=s.snapshot()
 check(s.outcome=="lost" and status.arrived and status.receipt and not status.recipient.alive and status.recipient.hull==0 and status.recipient.phase=="lost","post-arrival beam death retains truthful historical arrival and locally observed current death")
 check(Sim.valid_snapshot(lost),"legitimate arrived-then-destroyed lost snapshot remains valid")
 var invalid=lost.duplicate(true);invalid.outcome=""
 check(not Sim.valid_snapshot(invalid),"dead recipient cannot become an active dive by dropping its lost outcome")
 invalid.outcome="won"
 check(not Sim.valid_snapshot(invalid),"historical arrival cannot turn a destroyed recipient into a won dive")
 var debrief=ArrivalDebrief.new();debrief.sim=s
 preload("res://src/presentation/warning_recipient_view.gd").arrival(debrief)
 check(debrief.lines.any(func(line):return "LOST AFTER ARRIVAL" in line) and debrief.lines.any(func(line):return "no campaign outcome" in line) and not debrief.lines.any(func(line):return "RECIPIENT AT REFUGE" in line),"loss debrief distinguishes received historical arrival from the recipient's subsequent destruction")
 check(debrief.panel_box.get_child_count()==1 and not debrief.panel_box.get_child(0).arrival_data.recipient.alive,"arrival illustration receives the observed deceased hull rather than a living recipient")
 debrief.panel_box.free()
 archive.active=lost;archive.expedition=Campaign.recover(progress(),s.mission)
 check(not (13 in archive.expedition.completed) and not archive.expedition.facts.has("warning_arrival") and Endings.resolve(archive.expedition).is_empty(),"post-arrival destruction awards no new recovered facts or campaign ending")
 check(store.save(archive) and store.load_game()==archive,"actual binary save and reload preserve post-arrival recipient loss")
 var restored=Sim.new();check(restored.restore(lost) and restored.outcome=="lost" and restored.warning_recipient_status()==status,"post-arrival lost model restores its history and deceased current projection")
 var loaded=store.load_game();var binary=Sim.new()
 check(not loaded.is_empty() and loaded.active==lost and binary.restore(loaded.active) and binary.outcome=="lost","binary-loaded failed dive restores without falling back to the older living arrival")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
func _initialize():call_deferred("run")
func run():
 var s=fresh()
 check(s.has_method("warning_recipient_status"),"Open Warning exposes physical recipient state rather than ending at a fixed ACK")
 if not s.has_method("warning_recipient_status"):finish();return
 var report=s.warning_recipient_status()
 check(s.units.size()==3 and not report.recipient.known and not report.recipient.has("pos"),"separate recipient is not a fourth playable craft or an unseen hull projection")
 check(not s.command("warning_depart",{"course":"exposed"}),"remote unreceived warning cannot launch the recipient")
 s.units[0].pos=PANEL;s.units[0].vel=Vector2.ZERO;advance(s,.1)
 check(not s.command("warning_depart",{"course":"exposed"}),"local sight alone cannot replace actual warning reception")
 var gate=s.warning_recipient_status().gate.rect
 check(s.blocked(gate.get_center(),12) and not s.line_clear(gate.get_center()-Vector2(0,120),gate.get_center()+Vector2(0,120)),"closed service gate blocks actual hulls and sight")
 transmit(s);acknowledge(s)
 report=s.warning_recipient_status()
 check(report.recipient.known and report.recipient.live and report.recipient.pos.distance_to(BERTH)<.01,"actual local sensing identifies berthed physical recipient")
 check(not s.all_records() and not report.arrived,"warning plus local ACK cannot complete a nondeparted recipient")
 advance(s,20)
 check(s.warning_recipient_status().recipient.pos.distance_to(BERTH)<.01,"recipient waits indefinitely for a deliberate course instead of an imposed launch timer")
 check(not s.command("warning_depart",{"course":"sheltered"}),"closed sheltered course cannot teleport a hull through its gate")
 s.units[0].pos=PANEL;s.units[0].vel=Vector2.ZERO
 check(s.command("warning_gate"),"bare Quietus with no proof opens local service gate without finite kit")
 check(not s.blocked(gate.get_center(),12) and s.line_clear(gate.get_center()-Vector2(0,120),gate.get_center()+Vector2(0,120)),"manual release actually changes water and sight geometry")
 check(s.noises.any(func(n):return n.label=="WARNING SERVICE GATE"),"manual gate has a real local audible cost")
 check(s.command("warning_depart",{"course":"sheltered"}),"explicit local choice releases sheltered transit")
 var at=s.warning_recipient_status().recipient.pos;advance(s,1)
 check(s.warning_recipient_status().recipient.pos.distance_to(at)>1 and s.warning_recipient_status().recipient.pos.distance_to(HOME)>100,"recipient moves continuously rather than jumping to refuge")
 var snapshot=s.snapshot();s.advance(20);check(s.snapshot()==snapshot,"tactical pause freezes recipient motion and hull")
 var store=Store.new();store.path="user://warning-recipient-test.save"
 var archive={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":progress(),"active":snapshot}
 check(store.save(archive) and store.load_game()==archive,"actual current binary archive preserves mid-transit hull and gate")
 var restored=Sim.new();check(restored.restore(store.load_game().active),"mid-transit binary snapshot restores")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 advance(s,2);advance(restored,2)
 check(s.warning_recipient_status()==restored.warning_recipient_status(),"restored physical voyage keeps exact position and state")
 s.units[0].pos=Vector2(600,2000);s.units[1].alive=false;s.units[2].alive=false
 advance(s,65)
 report=s.warning_recipient_status()
 check(s.mission.warning_recipient.body.pos.distance_to(HOME)<16 and not report.arrived and not report.receipt and s.outcome.is_empty(),"unobserved real arrival waits at refuge without inventing a received success")
 check(not report.recipient.live and report.recipient.age>0,"remote vessel remains a stale measured fix, never an announced live tracker")
 s.units[0].pos=HOME;s.units[0].vel=Vector2.ZERO;advance(s,.8)
 check(s.warning_recipient_status().receipt and s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"local arrival receipt plus actual Quietus recovery finishes the physical operation")
 var malformed=s.snapshot();malformed.mission.warning_recipient.receipt=false
 check(not Sim.valid_snapshot(malformed),"a won archive cannot invent recipient arrival")
 malformed=s.snapshot();malformed.mission.warning_recipient.body.angle=NAN
 check(not Sim.valid_snapshot(malformed),"new recipient hull rejects an invalid physical orientation")
 malformed=s.snapshot();malformed.mission.warning_recipient.seen.time="invalid"
 check(not Sim.valid_snapshot(malformed),"malformed new hull observation is rejected cleanly")
 malformed=s.snapshot();malformed.mission.signal_sources=[]
 check(not Sim.valid_snapshot(malformed),"recipient delivery cannot load without its actual warning source")
 var recovered=Campaign.recover(progress(),s.mission)
 check(recovered.facts.get("warning_arrival","")=="sheltered" and recovered.facts.get("warning_service","")=="manual","first successful recovery commits actual recipient course and manual work")
 check(Endings.resolve(recovered).id=="surface_reckoning" and "recipient" in Endings.resolve(recovered).story.to_lower(),"Shelf ending retains distinct identity and depicts its achieved physical warning outcome")
 var deep=Campaign.recover(progress("deep"),s.mission)
 check(Endings.resolve(deep).id=="beacon_pact" and Endings.resolve(deep).story!=Endings.resolve(recovered).story,"Deep outcome keeps its distinct authored aftermath after the same achieved transit")
 var independent=fresh();transmit(independent);acknowledge(independent)
 independent.units[0].pos=PANEL;independent.units[0].vel=Vector2.ZERO;independent.command("warning_gate");independent.command("warning_depart",{"course":"sheltered"})
 independent.units[0].pos=Vector2(600,2000);independent.units[1].pos=HOME;independent.units[1].vel=Vector2.ZERO
 advance(independent,65)
 check(independent.warning_recipient_status().receipt and independent.outcome.is_empty(),"living drone can observe real arrival without impersonating independent Quietus recovery")
 post_arrival_loss(independent.snapshot())
 independent.hull=0;advance(independent,.1)
 check(independent.outcome=="lost" and Campaign.recover(progress(),independent.mission).facts.get("warning_arrival","").is_empty(),"recipient arrival followed by Q loss grants no new campaign result")
 var unheard=fresh("service_local_receipt");unheard.units[0].pos=Vector2(320,1680);unheard.units[0].vel=Vector2.ZERO
 check(unheard.acoustic_paths.arrivals(BERTH,unheard.units[0].pos,2000.).is_empty(),"western origin fixture has no physical arrival through the breakwaters")
 unheard.command("camera");advance(unheard,6.2)
 check(not unheard.mission.warning_recipient.delivered and unheard.blocked(unheard.warning_recipient_status().gate.rect.get_center(),12),"an unheard completed warning cannot use credential or change remote machinery")
 var credential=fresh("service_local_receipt")
 check(credential.blocked(credential.warning_recipient_status().gate.rect.get_center(),12),"prior credential alone cannot silently pre-open remote machinery")
 transmit(credential)
 check(not credential.blocked(credential.warning_recipient_status().gate.rect.get_center(),12),"CURRENT physically delivered warning carries earned credential to operate connected gate")
 var unknown=fresh("mast_transmission_external_unknown");transmit(unknown)
 check(unknown.blocked(unknown.warning_recipient_status().gate.rect.get_center(),12),"unknown prior mast reception supplies no invented remote operation")
 acknowledge(unknown)
 check(unknown.command("warning_depart",{"course":"exposed"}),"exposed course remains a deliberate ungated alternative")
 advance(unknown,1)
 check(unknown.warning_recipient_status().course=="exposed" and unknown.warning_recipient_status().recipient.pos.distance_to(BERTH)>1,"exposed choice causes a different actual transit")
 unknown.units[0].pos=HOME;unknown.units[0].vel=Vector2.ZERO;advance(unknown,110)
 var replay=Campaign.recover(recovered,unknown.mission)
 check(unknown.outcome=="won" and replay.facts.get("warning_arrival","")=="sheltered","completed replay cannot rewrite first physical recipient outcome with exposed course")
 # An ordinary guard sees a real non-player target. Q stays behind berth cover.
 var victim=fresh();transmit(victim);acknowledge(victim);advance(victim,8)
 var guard=Sim.new();guard.start(13)
 victim.sirens=[guard.sirens[2].duplicate(true)]
 victim.sirens[0].pos=Vector2(1720,440);victim.sirens[0].home=Vector2(1720,440);victim.sirens[0].goal=Vector2(1720,440);victim.sirens[0].route=[];victim.sirens[0].patrol_points=[]
 victim.units[0].pos=Vector2(1920,440);victim.units[0].vel=Vector2.ZERO
 check(victim.command("warning_depart",{"course":"exposed"}),"vulnerable launch can enter a real guard's watched channel")
 advance(victim,6.0)
 check(victim.sirens[0].get("recipient_target",false) and victim.sirens[0].target==-1 and victim.warning_recipient_status().recipient.hull<100,"ordinary uninterrupted four-second beam damages separately owned recipient hull")
 var lethal=Sim.new();check(lethal.restore(victim.snapshot()),"live separate-target beam restores in current transit snapshot");advance(lethal,10)
 check(not lethal.mission.warning_recipient.body.alive and lethal.outcome=="lost","real recipient destruction fails operation instead of granting an invulnerable arrival")
 victim.command("emp");var hull=victim.mission.warning_recipient.body.hull;advance(victim,1)
 check(victim.mission.warning_recipient.body.hull==hull and victim.sirens[0].lock==0,"ordinary disruption interrupts actual recipient beam damage")

 var qlost=fresh();transmit(qlost);acknowledge(qlost);qlost.units[0].pos=PANEL;qlost.command("warning_gate");qlost.command("warning_depart",{"course":"sheltered"})
 qlost.hull=0;advance(qlost,.02)
 check(qlost.outcome=="lost" and not qlost.warning_recipient_status().receipt,"Quietus loss cannot award a successful recipient operation")
 finish()
func finish():
 print("WARNING RECIPIENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
