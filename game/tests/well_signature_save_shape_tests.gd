extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;print("FAIL ",label)
	else:print("PASS ",label)
func _initialize():
	var source=Sim.new();source.start(4);source.mission.objectives[0].captured=true
	var valid=source.snapshot()
	check(Sim.valid_snapshot(valid) and Sim.new().restore(valid),"ordinary revision1 Well restores with all three objectives")
	for count in [0,1,2,4]:
		var data=valid.duplicate(true)
		if count>3:data.mission.objectives.append(data.mission.objectives[2].duplicate(true))
		else:data.mission.objectives.resize(count)
		check(not Sim.valid_snapshot(data) and not Sim.new().restore(data),"revised Well rejects objective count %d before simulation resumes"%count)
	for revision in [1.0,true,"1"]:
		var data=valid.duplicate(true);data.mission.well_revision=revision
		check(not Sim.valid_snapshot(data) and not Sim.new().restore(data),"Well revision must be integer1, rejects variant type %d"%typeof(revision))
	var legacy=valid.duplicate(true)
	for key in ["well_revision","well_reference","well_observation"]:legacy.mission.erase(key)
	legacy.mission.objectives.resize(2)
	var restored=Sim.new()
	check(Sim.valid_snapshot(legacy) and restored.restore(legacy) and restored.mission==legacy.mission,"legacy Well without revision keeps its existing accepted mission shape unchanged")
	print("WELL SAVE SHAPE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
