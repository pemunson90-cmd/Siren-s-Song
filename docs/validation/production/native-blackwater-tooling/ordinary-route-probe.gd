extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
func _initialize():
	for distance in [190,210]:
		var s=Simulation.new();s.start(2,"endurance");s.command("select",{"unit":1});var route=s.command("route",{"point":Vector2(760,200+distance)});s.paused=false
		for n in 900:
			s.advance(1.0/60)
			if s.units[1].route.is_empty() and s.units[1].vel.length()<2:break
		print("PROBE route=",route," distance=",distance," time=",s.elapsed," alive=",s.units[1].alive," hull=",s.hull," pos=",s.units[1].pos," velocity=",s.units[1].vel.length()," sample=",s.command("camera"))
		for n in 125:s.advance(1.0/60)
		print("PROBE earned=",s.mission.objectives[0].captured," alive=",s.units[1].alive," hull=",s.hull," outcome=",s.outcome)
	quit()
