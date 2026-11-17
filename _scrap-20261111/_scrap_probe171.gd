extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
func _initialize():
	var s=Sim.new();s.start(3,"endurance");s.sirens=[]
	for i in s.mission.objectives.size():
		var o=s.mission.objectives[i]
		print("OBJ ",i," ",o.name," ",o.pos," opt=",o.get("optional",false)," req=",o.get("requires",[])," cand=",preload("res://src/campaign/sorley_rescue.gd").camera_candidate(s,o))
	print("REACH ",Photo.reach(s,0)," start ",s.units[0].pos)
	quit()
