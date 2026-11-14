extends SceneTree
func _initialize():
	var Missions=load("res://src/campaign/missions.gd")
	for id in [1,0]:
		var m=Missions.make(id,{})
		var v=load("res://src/presentation/chart_preview.gd").new()
		v.setup(m,720.0,1.5)
		v.size=Vector2(800,187)
		var box=v.fit();var f=box.size.x/v.region.x
		var r=v.layout(box,f)
		print("PROBE op ",id," box ",box," f ",f)
		for mk in r.marks:print("PROBE mark ",mk.c," r ",mk.r," ring ",mk.ring," ",mk.texts)
		for l in r.labels:print("PROBE label ",l.text," ",l.rect)
		print("PROBE scale ",r.scale)
	print("PROBE CHECKS 0 FAILURES 0")
	quit()
