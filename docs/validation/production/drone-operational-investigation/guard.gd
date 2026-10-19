extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Listener=preload("res://passive_listener.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(0);s.paused=false;var receiver=Listener.new();receiver.configure(s)
 var empty=receiver.sample(s,1);check(empty.bearings.is_empty() and "unknown" in empty.state,"silence never means absence of threats")
 s.sirens[0].pos=Vector2(400,700);s.sirens[0].vel=Vector2(78,0)
 var read=receiver.sample(s,1);check(not read.bearings.is_empty(),"unmasked nearby modeled engine emits a bearing")
 check(read.bearings.all(func(b):return b.keys().all(func(k):return k in ["bearing_degrees","spread_degrees","time"])),"bearing carries no emitter identity exactposition role intention or lock")
 var before=s.snapshot();s.sirens[0].goal=Vector2(1500,900);s.sirens[0].mode="BEAM";var observed=receiver.sample(s,1)
 check(observed==read,"hidden goal and combat mode cannot alter acoustic reading")
 s.units[2].pos=Vector2(300,700);s.units[2].vel=Vector2(96,0)
 read=receiver.sample(s,1);check(read.bearings.is_empty() and read.known_emissions_present,"louder ownengine in same20degree sector masks weak arrival")
 s.units[1].vel=Vector2(20,0);check(receiver.sample(s,1).state.begins_with("MOVING"),"moving the receiver sacrifices array reading")
 s.paused=true;before=s.snapshot();receiver.sample(s,1);check(before==s.snapshot(),"observer preserves simulation and paused state")
 print("LISTENER SCRATCH GUARDS ",checks," FAILURES ",failures);quit(1 if failures else 0)
