extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Store=preload("res://src/persistence/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var old=Sim.new();old.start(7);old.mission.erase("consequence_revision");old.mission.erase("measured_reference")
 check(Sim.valid_snapshot(old.snapshot()),"old active Deep snapshot restores without invented reference")
 var sim=Sim.new();sim.start(9,"disruption",{"context":{"references":{"return_cadence":[0.8,1.6,0.8]}},"fitted":{"quietus":"quietus_correlator","drone_a":"","drone_b":""}})
 check(sim.has_method("equipment_feedback"),"public fitted equipment feedback exists")
 var bad=sim.snapshot();bad.mission.launch_equipment.drone_a="drone_sampler";bad.mission.launch_equipment.drone_b="drone_sampler"
 check(not Sim.valid_snapshot(bad),"one physical sampler cannot be duplicated in active save")
 var progress={"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6,7]}
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"disruption","settings":{},"expedition":progress,"active":sim.snapshot()}
 check(not Store.new().valid(data),"unearned active hardware/reference rejected despite earned mission access")
 var sampler=Sim.new();sampler.start(10,"disruption",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}})
 sampler.units[1].pos=sampler.mission.objectives[0].pos+Vector2(0,80);sampler.command("select",{"unit":1})
 check(sampler.camera_context().ready,"equipped drone may operate explicit compatible receiver")
 sampler.command("emp") # Real finite counterplay keeps this save-duration fixture alive during exposure.
 sampler.command("camera")
 check(sampler.noises.any(func(n):return n.label=="CAMERA"),"sampler operation has actual ordinary audible camera cost")
 sampler.paused=false
 for i in 270:sampler.advance(1.0/60)
 check(not sampler.mission.objectives[0].captured,"drone sampling costs longer than Quietus four seconds")
 var restored=Sim.new();check(restored.restore(sampler.snapshot()),"in-flight sampler work saves real duration and frozen fitting")
 restored.paused=false
 for i in 240:restored.advance(1.0/60)
 check(restored.mission.objectives[0].captured,"restored sampler finishes at its eight-second physical exposure")
 print("CAMPAIGN EQUIPMENT SAVE ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
