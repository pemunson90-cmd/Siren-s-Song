extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Copy=preload("res://src/presentation/acoustic_feedback.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	var s=Sim.new();s.start(0);var lines=Copy.rows(s.acoustic_feedback())
	check(lines.any(func(l):return "idle" in l),"idle means zero propulsion, never safe")
	s.units[0].vel=Vector2(78,0);lines=Copy.rows(s.acoustic_feedback())
	check(lines.any(func(l):return "430m" in l),"instrument exposes measured open-water own footprint")
	check(lines.any(func(l):return "OPEN WATER" in l and "basalt" in l),"footprint explicitly qualifies terrain uncertainty")
	var before=Copy.rows(s.acoustic_feedback());s.sirens.clear();s.mission.rocks=[];s._build_navigation()
	check(Copy.rows(s.acoustic_feedback())==before,"estimate cannot disclose hidden listeners or unknown terrain")
	s.units[0].vel=Vector2(0.25,0);check(not s.acoustic_feedback().motion.is_empty(),"tiny residual speed is an emission, not an idle claim")
	s.mission.erase("acoustic_revision");s.units[0].vel=Vector2(49,0);lines=Copy.rows(s.acoustic_feedback())
	check(lines.any(func(l):return "below threshold" in l),"legacy instrument retains old hearing semantics")
	print("ACOUSTIC FOOTPRINT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
