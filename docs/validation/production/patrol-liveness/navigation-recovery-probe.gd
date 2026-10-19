extends SceneTree
func _initialize():
 var s=preload("res://src/simulation/simulation.gd").new(); s.start(2)
 var p=Vector2(1351.367,643.4868); s.units[0].pos=p
 print("RECOVERY blocked12=",s.blocked(p,12)," blocked24=",s.blocked(p,24))
 for goal in [Vector2(1430,600),Vector2(1430,500),Vector2(1500,600),Vector2(1250,550),Vector2(140,800)]:
  print("RECOVERY goal=",goal," accepted=",s.command("emergency",{"point":goal})," path=",s.units[0].route)
 quit()
