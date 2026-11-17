extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
func _initialize():call_deferred("run")
func run():
	var s=Sim.new();s.start(0);s.paused=true
	var a=Vector2(934,542);var b=s.units[0].pos
	print("rock_point ",HandPilot.rock_point(s,a,b)," polygon ",s.rock_shapes[0])
	s.units[0].pos=a
	print("route ",s.command("route",{"point":b}))
	var hull0=s.units[0].get("hull",-1)
	s.paused=false
	var minr=9999.0;var strikes=0
	for i in 4000:
		s.advance(0.1)
		if s.units[0].pos.distance_to(b)<20:break
		for p in s.rock_shapes:
			pass
	print("end pos ",s.units[0].pos," hull ",hull0," -> ",s.units[0].get("hull",-1)," t ",s.elapsed)
	print("events ",s.events.filter(func(e):return str(e.get("type","")).contains("contact")or str(e.get("type","")).contains("strike")).size())
	print("mission rocks ",s.mission.rocks)
	quit(0)
