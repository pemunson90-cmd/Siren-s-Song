extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
 var s=Sim.new();s.start(19,"endurance",{"fitted":{"quietus":"quietus_decoder","drone_a":"","drone_b":""}});s.sirens=[]
 s.units[0].pos=s.mission.glass_reach.work_pos+Vector2(0,-100)
 var accepted=s.command("glass_action",{"action":"gate"});s.paused=false
 for n in 126:s.advance(Sim.STEP)
 print("DECODER accepted=",accepted," gate_open=",s.mission.glass_reach.gate_open," structures=",s.mission.structures.size()," snapshot_valid=",Sim.valid_snapshot(s.snapshot())," noise=",s.noises)
 quit(0 if accepted and s.mission.glass_reach.gate_open and s.mission.structures.is_empty() and Sim.valid_snapshot(s.snapshot()) else 1)
