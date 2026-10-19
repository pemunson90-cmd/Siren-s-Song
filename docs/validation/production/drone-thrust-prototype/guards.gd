extends SceneTree
const Base=preload("res://src/simulation/simulation.gd")
var Experiment=load("/workspace/Siren-s-Song-drone-investigation/work/drone-thrust-prototype/thrust_sim.gd")
var failed=0
func check(ok:bool,label:String):
	print("PASS " if ok else "FAIL ",label)
	if not ok:failed+=1
func launch(s):
	s.start(1)
	for i in [0,1,2]:
		s.command("select",{"unit":i});s.command("route",{"point":Vector2(420,700+i*20)})
	s.paused=false
func _initialize():
	var base=Base.new();var same=Experiment.new();launch(base);launch(same)
	for i in 30:base.advance(0.1);same.advance(0.1)
	check(base.snapshot()==same.snapshot(),"default96 preserves exact entire three-second ordinary simulation snapshot")
	var slow=Experiment.new();slow.drone_thrust=60.0;launch(slow)
	var max_speed=0.0
	for i in 30:
		slow.advance(0.1);max_speed=maxf(max_speed,slow.units[1].vel.length())
	check(max_speed<=60.01 and max_speed>59.0,"requested60 changes actual drone motion, capped at60")
	check(slow.units[1].pos.distance_to(base.units[1].pos)>10,"lower thrust produces a real trajectory/time cost")
	check(slow.units[0].pos==base.units[0].pos and slow.units[0].vel==base.units[0].vel,"Quietus propulsion remains unchanged")
	check(slow.units[1].silent==base.units[1].silent and slow.tools==base.tools,"visual silent flag and finite stock unchanged")
	var paused=slow.snapshot();slow.paused=true;var frozen=slow.snapshot();slow.advance(2)
	check(slow.snapshot()==frozen,"paused prototype has no propulsion or world advance")
	var legacy=Base.new();legacy.start(1);legacy.mission.erase("acoustic_revision")
	var restored=Experiment.new();check(restored.restore(legacy.snapshot()) and restored.drone_thrust==96,"legacy restore defaults to unchanged96; prototype value not serialized")
	print("GUARDS failed=",failed);quit(1 if failed else 0)
