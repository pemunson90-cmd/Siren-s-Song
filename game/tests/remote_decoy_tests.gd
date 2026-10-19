extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
var Remote
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
 # Explicit mechanic fixture, not authored follow-on utility evidence.
 var s=Sim.new();s.start(0);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 s.units[0].pos=Vector2(150,850);s.units[1].pos=Vector2(500,600);s.units[1].angle=PI;s.units[2].alive=false
 var e=s.sirens[0];e.pos=Vector2(1100,600);e.home=e.pos;e.goal=e.pos;e.type="sentinel";e.route=[];e.patrol_points=[];e.stun=0.0;e.lock=0.0;e.target=-1;e.suspicion=0.0
 s.command("select",{"unit":1});return s
func advance(s,seconds:float):
 s.paused=false
 for n in int(round(seconds*60)):s.advance(1.0/60)
func packed(s,state:Dictionary)->Dictionary:
 var data=s.snapshot();data["remote_decoy"]=state.duplicate(true);return data
func finish():print("REMOTE DECOY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var path="res://src/simulation/remote_decoy.gd"
 Remote=load(path) if ResourceLoader.exists(path) else null
 check(Remote!=null,"remote carriage supports an inert finite-charge placement")
 if Remote==null:finish();return
 var s=fixture();var state=Remote.configure(1);var before=s.snapshot()
 check(Remote.command(s,state,"pod_place",{"point":Vector2(640,600)}) and s.tools.decoy==2 and s.noises.is_empty(),"accepted placement spends one ordinary charge and emits no lure")
 check(Remote.feedback(s,state).staged and Remote.feedback(s,state).pos==Vector2(640,600),"own staged position remains known without a sensor")
 check(not Remote.command(s,state,"pod_place",{"point":Vector2(600,600)}) and s.tools.decoy==2,"one carriage cannot place a second active pod")
 var staged=state.duplicate(true);s.advance(40)
 check(state==staged and s.snapshot().elapsed==before.elapsed and s.noises.is_empty(),"pause leaves inert pod and mission clocks unchanged")
 check(s.command("route",{"point":Vector2(200,600)}),"owner can receive an ordinary withdrawal route after staging")
 advance(s,5)
 check(s.units[1].pos.x<300 and state.pod.pos==Vector2(640,600) and s.noises.is_empty(),"pod remains inert where placed after physical owner withdrawal")
 var hidden_before=s.sirens[0].pos
 check(s._heard_arrival(s.sirens[0]).is_empty() and s.sirens[0].target==-1,"withdrawn owner is outside original motion and visual evidence")
 check(Remote.command(s,state,"pod_trigger") and s.tools.decoy==2 and state.pod.is_empty(),"living owner explicitly triggers later without spending a second charge")
 check(s.noises.size()==1 and s.noises[0].pos==Vector2(640,600) and s.noises[0].label=="DECOY" and s.noises[0].radius==1100.0 and s.noises[0].time==15.0,"trigger uses the existing fifteen-second acoustic emission at stored pod position")
 advance(s,3)
 check(s.sirens[0].mode=="INVESTIGATE" and s.sirens[0].pos.x<hidden_before.x-20 and s.sirens[0].target==-1,"ordinary listener physically follows delayed noise without seeing the hidden owner")
 check(not Remote.command(s,state,"pod_trigger") and s.tools.decoy==2,"trigger is one-shot per staged pod")
 advance(s,12.1);check(s.noises.is_empty(),"ordinary simulation expiry ends emission after fifteen seconds")
 s=fixture();state=Remote.configure(1)
 for point in [null,Vector2(NAN,600),Vector2(INF,600),Vector2(661,600),Vector2(-1,600),"water"]:
  check(not Remote.command(s,state,"pod_place",{"point":point}) and s.tools.decoy==3 and state.pod.is_empty(),"invalid placement never spends or stages: "+str(point))
 s.mission.structures=[Rect2(550,500,30,200)];s._build_navigation()
 check(not Remote.command(s,state,"pod_place",{"point":Vector2(640,600)}) and s.tools.decoy==3,"physical cover rejects unreachable placement without spend")
 s=fixture();state=Remote.configure(1);var canceled=s.snapshot()
 check(not Remote.command(s,state,"pod_cancel") and s.snapshot()==canceled and state.pod.is_empty(),"precommit cancellation has no placement, charge or noise side effects")
 s.command("select",{"unit":0})
 check(not Remote.command(s,state,"pod_place",{"point":Vector2(260,850)}) and s.tools.decoy==3,"unequipped Quietus cannot place the drone pod")
 s.command("select",{"unit":1});s.tools.decoy=0
 check(not Remote.command(s,state,"pod_place",{"point":Vector2(640,600)}),"empty ordinary stock cannot create a free pod")
 s=fixture();state=Remote.configure(1);Remote.command(s,state,"pod_place",{"point":Vector2(640,600)})
 s.command("select",{"unit":0})
 check(not Remote.command(s,state,"pod_trigger") and not state.pod.is_empty() and s.noises.is_empty(),"a different selected craft cannot trigger the equipped owner's pod")
 s.units[1].alive=false;s.command("select",{"unit":1})
 check(not Remote.command(s,state,"pod_trigger") and s.tools.decoy==2 and s.noises.is_empty() and not Remote.feedback(s,state).owner_alive,"lost owner strands the spent inert pod without a refund or transmission")
 check(Remote.valid(packed(s,state)),"lost-owner inert state remains saveable")
 s=fixture();state=Remote.configure(1);Remote.command(s,state,"pod_place",{"point":Vector2(640,600)})
 var data=packed(s,state);var store=SaveStore.new();store.path="user://remote-decoy-%d.save"%OS.get_process_id()
 var archive={"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","active":data}
 check(Remote.valid(data) and store.save(archive),"optional helper state survives the real checksummed archive format")
 var saved=store.load_game().active;var loaded=Sim.new();var loaded_state=saved.remote_decoy.duplicate(true)
 check(loaded.restore(saved) and Remote.valid(saved) and loaded_state==state,"snapshot adapter recovers unchanged pod/owner alongside real simulation state")
 loaded.units[1].pos=Vector2(200,600)
 check(Remote.command(loaded,loaded_state,"pod_trigger") and loaded.noises[0].pos==Vector2(640,600),"restored owner triggers the original saved point after relocation")
 loaded.paused=true;var paused=loaded.snapshot();loaded.advance(80)
 check(loaded.snapshot()==paused,"pause also freezes a restored active ordinary emission")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 var old=s.snapshot();check(Remote.valid(old) and Remote.configure(-1).is_empty() and Remote.configure(0).is_empty(),"old archives and missing/invalid equipment remain unchanged")
 for invalid in [{"unit":0,"pod":{}},{"unit":1.0,"pod":{}},{"unit":3,"pod":{}},{"unit":1,"pod":{"pos":Vector2(NAN,10)}},{"unit":1,"pod":{"pos":Vector2(2000,600)}},{"unit":1,"pod":{"pos":Vector2(10,10),"extra":true}}]:
  var bad=s.snapshot();bad["remote_decoy"]=invalid
  check(not Remote.valid(bad),"malformed optional state is rejected: "+str(invalid))
 var wide=s.snapshot();wide["remote_decoy"]={"unit":1,"pod":{"pos":Vector2(2100,2300)}}
 check(Remote.valid(wide,Vector2(2200,2400)) and not Remote.valid(wide),"explicit dynamic region bounds accept only a physically in-bounds pod")
 # A lure cannot cancel an already legitimate visual lock.
 s=fixture();state=Remote.configure(1);Remote.command(s,state,"pod_place",{"point":Vector2(640,600)})
 s.units[0].pos=Vector2(1000,600);Remote.command(s,state,"pod_trigger");advance(s,1)
 check(s.sirens[0].target==0 and s.sirens[0].mode=="LOCKING" and s.sirens[0].lock>0.9,"fresh sight and its beam priority outrank the staged lure")
 var ordinary=fixture();check(ordinary.command("decoy",{"point":Vector2(640,600)}) and ordinary.tools.decoy==2 and ordinary.noises[0].time==15.0,"ordinary immediate decoy remains unchanged and needs no module")
 s=fixture();state=Remote.configure(1);Remote.command(s,state,"pod_place",{"point":Vector2(640,600)})
 s.command("decoy",{"point":Vector2(640,600)});s.command("decoy",{"point":Vector2(640,600)})
 check(s.tools.decoy==0 and Remote.command(s,state,"pod_trigger") and s.tools.decoy==0 and s.noises.size()==3,"the final prepaid pod triggers with empty stock; total emissions still cost all three ordinary charges")
 s=fixture();state=Remote.configure(2);s.units[2].alive=true;s.units[2].pos=Vector2(500,600);s.command("select",{"unit":2})
 check(Remote.command(s,state,"pod_place",{"point":Vector2(640,600)}) and Remote.command(s,state,"pod_trigger"),"the same single-owner capability works when Drone B is fitted")
 check(Remote.command(s,state,"pod_place",{"point":Vector2(600,600)}) and s.tools.decoy==1,"an emptied carriage reuses only the remaining ordinary stock")
 finish()
