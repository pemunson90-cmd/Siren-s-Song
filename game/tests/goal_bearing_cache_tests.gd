extends SceneTree
# PERF fix 3 equivalence: goal_bearing.gd now caches the marker placement (candidate build, sort and
# blocked-rect scan) keyed on ocean size, goal direction and blocked rects. The old per frame logic is the
# oracle below (old_info). Timing is printed, never asserted.
const GoalBearing=preload("res://src/presentation/goal_bearing/goal_bearing.gd")
const STYLE={"margin":16.,"height":42.,"width":210.,"font":16,"step":48.}
class Unit extends RefCounted:
	var pos:=Vector2.ZERO
class FakeSim extends RefCounted:
	var outcome:Dictionary={}
	var units:Array=[Unit.new()]
	var corridors:Array=[]
	func extraction_corridors()->Array:return corridors
class FakeOcean extends RefCounted:
	var sim=FakeSim.new()
	var presenting_mission:=true
	var size:=Vector2(1280,720)
	var ui_blocked_rects:Array=[]
	var sites:Array=[]
	var origin:=Vector2.ZERO
	var scale:=1.0
	func observable_sites()->Array:return sites
	func screen_position(world:Vector2)->Vector2:return (world-origin)*scale
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
# The previous implementation, verbatim apart from returning info instead of mutating a node.
static func old_info(ocean)->Dictionary:
	if ocean==null or ocean.sim==null or not ocean.presenting_mission or not ocean.sim.outcome.is_empty():return {}
	var sim=ocean.sim;var goals=ocean.observable_sites().filter(func(site):return not site.get("captured",false) and not site.get("own_origin",false))
	if goals.is_empty():goals=sim.extraction_corridors()
	if goals.is_empty():return {}
	var goal=goals[0];var target=ocean.screen_position(goal.pos)
	var bounds=Rect2(Vector2.ONE*STYLE.margin,ocean.size-Vector2.ONE*STYLE.margin*2)
	if bounds.grow(-STYLE.height).has_point(target):return {}
	var direction=(target-ocean.size/2).normalized()
	var half=Vector2(minf(STYLE.width,bounds.size.x),STYLE.height)/2
	var free=bounds.grow_individual(-half.x,-half.y,-half.x,-half.y)
	var distance=(free.size/2).x/maxf(absf(direction.x),.0001)
	distance=minf(distance,(free.size/2).y/maxf(absf(direction.y),.0001))
	var preferred=free.get_center()+direction*distance
	var candidates=[preferred]
	for x in range(0,int(free.size.x)+1,int(STYLE.step)):
		candidates.append(Vector2(free.position.x+x,free.position.y));candidates.append(Vector2(free.position.x+x,free.end.y))
	for y in range(0,int(free.size.y)+1,int(STYLE.step)):
		candidates.append(Vector2(free.position.x,free.position.y+y));candidates.append(Vector2(free.end.x,free.position.y+y))
	candidates.sort_custom(func(a,b):return a.distance_squared_to(preferred)<b.distance_squared_to(preferred))
	for point in candidates:
		var rect=Rect2(point-half,half*2)
		if ocean.ui_blocked_rects.any(func(block):return block.intersects(rect.grow(4))):continue
		var metres=sim.units[0].pos.distance_to(goal.pos)
		return {"rect":rect,"distance":metres,"target":goal.pos,"direction":direction,"text":("SEARCH" if goal.get("unknown",false) else "GOAL")+" · %dm"%roundi(metres)}
	return {}
func _initialize():call_deferred("run")
func run():
	var rng=RandomNumberGenerator.new();rng.seed=4242
	var marker=GoalBearing.new();var ocean=FakeOcean.new();marker.ocean=ocean
	var mismatches=0;var frames=0;var shown=0;var hidden=0
	var sizes=[Vector2(1280,720),Vector2(720,1280),Vector2(412,915),Vector2(900,480),Vector2(260,300)]
	for n in 6000:
		if n%40==0:ocean.size=sizes[rng.randi_range(0,sizes.size()-1)]
		if n%25==0:
			ocean.ui_blocked_rects=[]
			for i in rng.randi_range(0,9):ocean.ui_blocked_rects.append(Rect2(Vector2(rng.randf_range(0,ocean.size.x),rng.randf_range(0,ocean.size.y)),Vector2(rng.randf_range(20,300),rng.randf_range(20,200))))
		if n%7==0:ocean.origin=Vector2(rng.randf_range(-600,600),rng.randf_range(-600,600));ocean.scale=rng.randf_range(0.4,1.6)
		ocean.sim.units[0].pos+=Vector2(rng.randf_range(-3,3),rng.randf_range(-3,3))
		if n%90==0:
			var pos=Vector2(rng.randf_range(-800,2400),rng.randf_range(-800,1800))
			ocean.sites=[{"pos":pos,"unknown":rng.randf()<.5,"captured":rng.randf()<.1}] if rng.randf()<.9 else []
			ocean.sim.corridors=[{"pos":pos+Vector2(50,50)}] if rng.randf()<.5 else []
			ocean.sim.outcome={} if rng.randf()<.95 else {"won":true}
			ocean.presenting_mission=rng.randf()<.95
		marker._process(0.0)
		var expected=old_info(ocean);frames+=1
		if expected.is_empty():
			hidden+=1
			if not marker.info.is_empty() or marker.visible:mismatches+=1;printerr("MISMATCH hidden frame ",n)
		else:
			shown+=1
			if var_to_str(marker.info)!=var_to_str(expected) or not marker.visible:mismatches+=1;printerr("MISMATCH info frame ",n)
	check(mismatches==0,"marker info and visibility identical to old logic on %d frames (%d shown, %d hidden)"%[frames,shown,hidden])
	check(shown>500 and hidden>500,"both shown and hidden paths were exercised")
	# Timing: steady camera, goal off screen, 8 blocked rects (the audit's frame).
	marker.free()
	ocean=FakeOcean.new();marker=GoalBearing.new();marker.ocean=ocean
	ocean.sites=[{"pos":Vector2(3000,-200)}]
	for i in 8:ocean.ui_blocked_rects.append(Rect2(Vector2(20+i*140,600),Vector2(120,90)))
	var at=Time.get_ticks_usec()
	for f in 2000:old_info(ocean)
	var t_old=Time.get_ticks_usec()-at
	at=Time.get_ticks_usec()
	for f in 2000:marker._process(0.0)
	var t_new=Time.get_ticks_usec()-at
	print("TIMING goal_bearing steady frame: old=%.1f us new=%.1f us (%.2fx)"%[t_old/2000.0,t_new/2000.0,float(t_old)/maxf(1.0,t_new)])
	ocean.sim.units[0].pos=Vector2.ZERO
	at=Time.get_ticks_usec()
	for f in 2000:
		ocean.origin=Vector2(f%97,f%53);old_info(ocean)
	t_old=Time.get_ticks_usec()-at
	at=Time.get_ticks_usec()
	for f in 2000:
		ocean.origin=Vector2(f%97,f%53);marker._process(0.0)
	t_new=Time.get_ticks_usec()-at
	print("TIMING goal_bearing moving camera frame (worst case, cache misses): old=%.1f us new=%.1f us (%.2fx)"%[t_old/2000.0,t_new/2000.0,float(t_old)/maxf(1.0,t_new)])
	marker.free()
	print("GOAL BEARING CACHE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
