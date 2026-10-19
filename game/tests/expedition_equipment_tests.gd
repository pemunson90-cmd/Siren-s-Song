extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var sim=Sim.new();sim.start(7)
 var installed=sim.get_property_list().any(func(p):return p.name=="remote_decoy")
 check(installed,"simulation owns optional persistent fitted drone module state")
 if not installed:quit(1);return
 sim.call("start",7,"disruption",{"remote_decoy_unit":1})
 check(sim.remote_decoy=={"unit":1,"pod":{}},"next-dive equipment fits exactly one drone")
 sim.command("select",{"unit":1});var stock=sim.tools.decoy
 var point=sim.units[1].pos+Vector2(-80,0)
 check(sim.command("pod_place",{"point":point}) and sim.tools.decoy==stock-1 and sim.noises.is_empty(),"shared command hook commits an inert pod against ordinary finite stock")
 var snap=sim.snapshot();var restored=Sim.new();check(restored.restore(snap) and restored.snapshot()==snap,"equipped staged pod survives ordinary active snapshot restore")
 check(restored.command("pod_trigger") and restored.noises.size()==1 and restored.noises[0].label=="DECOY" and restored.noises[0].pos==point,"explicit restored-owner trigger emits ordinary decoy at committed pod position")
 restored.start(8,"endurance")
 check(restored.remote_decoy.is_empty() and not restored.snapshot().has("remote_decoy"),"a new unfitted dive clears old module/pod without introducing legacy save fields")
 var malformed=snap.duplicate(true);malformed.remote_decoy.unit=0
 check(not Sim.valid_snapshot(malformed),"Quietus cannot restore as an equipped drone owner")
 print("EXPEDITION EQUIPMENT CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
