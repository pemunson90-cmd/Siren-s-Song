extends SceneTree
const Sound=preload("res://src/simulation/acoustic_paths.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func polygon(r:Rect2):return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
func _initialize():
	check(Sound.motion_radius(0)==0,"idle has no propulsion emission")
	check(Sound.motion_radius(25)>0 and Sound.motion_radius(49)<Sound.motion_radius(50) and Sound.motion_radius(50)<Sound.motion_radius(51),"speed range is continuous across old50 threshold")
	check(is_equal_approx(Sound.motion_radius(78),430) and is_equal_approx(Sound.motion_radius(39)*4,Sound.motion_radius(78)),"actual speed squared determines radius")
	var a=Sound.new();a.configure([],Vector2(1000,1000))
	var direct=a.arrivals(Vector2(700,500),Vector2(400,500),430)
	check(direct.size()==1 and direct[0].get("direct",false),"unobstructed audible path arrives directly")
	if not direct.is_empty():check(direct[0].goal!=Vector2(400,500),"hearing gives a coarse bearing/range goal rather than hidden exact emitter")
	check(a.arrivals(Vector2(900,500),Vector2(400,500),430).is_empty(),"out of range cannot hear")
	a.configure([polygon(Rect2(450,350,100,300))],Vector2(1000,1000))
	var two=a.arrivals(Vector2(700,500),Vector2(300,500),1500)
	check(two.size()==2,"basalt island yields distinct upper and lower arrival branches")
	for arrival in two:
		check(not arrival.direct and arrival.length>400 and arrival.strength<1500.0/400 and arrival.goal!=Vector2(300,500),"diffracted branch attenuates with longer path and masks source goal")
		for i in range(arrival.points.size()-1):check(a.clear(arrival.points[i],arrival.points[i+1]),"each actual path leg stays in water")
	check(a.arrivals(Vector2(700,500),Vector2(300,500),410).is_empty(),"short straight-line range cannot pass through basalt")
	if two.size()==2:
		check(Sound.choose(two,7)==Sound.choose(two,7),"ambiguous choice is reproducible")
		var both={}
		for seed in 20:both[Sound.choose(two,seed).goal]=true
		check(both.size()==2,"similarly supported arrivals permit either geometry-defined branch")
	a.configure([polygon(Rect2(450,-100,100,750))],Vector2(1000,1000))
	check(a.arrivals(Vector2(700,500),Vector2(300,500),1500).size()==1,"world-edge wall leaves only one physical arrival")
	a.configure([polygon(Rect2(450,-100,100,1200))],Vector2(1000,1000))
	check(a.arrivals(Vector2(700,500),Vector2(300,500),5000).is_empty(),"sealed terrain has no invented through-rock arrival")
	print("ACOUSTIC PATH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
