extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
func _initialize():
	var s=Sim.new();s.start(3,"endurance");s.sirens=[]
	var c=s.mission.objectives[1].pos;var b=s.mission.objectives[2].pos
	for p in [Vector2(1400,640),Vector2(1400,700),Vector2(1420,700),Vector2(1400,860),Vector2(1330,900),Vector2(1420,880),Vector2(1450,900),Vector2(1350,650),Vector2(1380,720)]:
		print("PT ",p," c=",s.Depth.optical_clear(s,p,c,s.units[0].band)," b=",s.Depth.optical_clear(s,p,b,s.units[0].band)," dc=",p.distance_to(c)," db=",p.distance_to(b)," ac=",rad_to_deg(p.angle_to_point(c))," ab=",rad_to_deg(p.angle_to_point(b)))
	quit()
