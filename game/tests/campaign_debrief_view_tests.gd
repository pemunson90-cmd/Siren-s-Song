extends SceneTree
const View=preload("res://src/presentation/expedition_operations.gd")
class Outcome:
 extends RefCounted
 var mission:Dictionary={}
 var outcome="lost"
 var elapsed=12.
 var hull=100.
 var message="Local field notes survived."
class Host:
 extends Node
 var sim=Outcome.new()
 var expedition={"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"known carrier"},"completed":[6]}
 var recovered_evidence={}
 var panel_box=Node.new()
 var rows=[]
 var actions=[]
 func _retain_evidence():pass
 func _menu_text(text,_size):rows.append(text)
 func _button(_parent,text,_callback,action):actions.append({"text":text,"action":action})
 func _briefing(_id):pass
 func _evidence_gallery(_id):pass
 func _show_campaign():pass
 func _save_archive():pass
 func _layout():pass
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 # Presentation fixtures exercise the real public recovery adapter; ordinary
 # Main earning/fitting/reload journeys are verified separately by its owner.
 var host=Host.new();root.add_child(host)
 host.sim.mission={"id":9,"expedition_revision":2,"recovered":false,"expedition_facts":{"wake_packet":"retained field note"}}
 check(View.debrief(host),"new onward loss uses expedition debrief rather than legacy linear-next behavior")
 check(host.expedition.get("notes",{}).has("wake_packet") and host.expedition.get("entitlements",[]).is_empty(),"loss presentation retains notes through owner API without awarding a fitting")
 check(host.rows.any(func(text):return "grants no new recovered fitting" in text),"failure explains notes versus recovered continuation and equipment")
 host.rows.clear();host.actions.clear();host.sim.outcome="won"
 host.sim.mission={"id":7,"expedition_revision":1,"consequence_revision":1,"recovered":true,"expedition_facts":{"rendezvous":"known packet"},"measured_reference":[.8,1.6,.8],"record":"Rendezvous observation recovered.","objectives":[],"chosen_route":"deep"}
 check(View.debrief(host),"successful Deep recovery remains handled by expedition presentation")
 check(host.rows.any(func(text):return "RECOVERED FITTING" in text and "CADENCE CORRELATOR" in text),"actual adapter result announces the new recovered fitting before launch choice")
 check(host.actions.any(func(action):return action.action=="next_expedition" and "Wake Crossing" in action.text),"continue action uses campaign-owned unlocked onward rather than arithmetic mission numbering")
 await process_frame;host.panel_box.free();host.queue_free();await process_frame
 print("CAMPAIGN DEBRIEF VIEW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
