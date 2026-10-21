extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func fixture():
	var s=Sim.new();s.start(0)
	s.sirens=[];s.mission.rocks=[];s.mission.structures=[];s.mission.depth_geometry={};s.mission.erase("earned_terrain")
	s._build_navigation();s._configure_terrain();s._configure_depth_charts()
	for id in [1,2]:s.units[id].alive=false
	s.units[0].pos=Vector2(500,500);s.units[0].vel=Vector2(78,0)
	return s
func tick(s,seconds):
	s.paused=false
	for n in roundi(seconds*60):s.advance(Sim.STEP)
	s.paused=true
func _initialize():
	var s=fixture();var u=s.units[0]
	s._course_collision(u,false,78.)
	check(s.hull==100.,"chart clearance stop is not a physical impact")
	s=fixture();u=s.units[0];s._course_collision(u,true,78.)
	check(is_equal_approx(u.vel.length(),19.5),"physical collision retains V7 quarter-speed slowdown")
	var saved=s.snapshot();var restored=Sim.new()
	check(Sim.valid_snapshot(saved) and restored.restore(saved),"partial hit cooldown restores without migration")
	var hull=s.hull;s.paused=true;s.advance(5.)
	check(s.snapshot()==saved,"pause freezes collision cooldown and motion")
	restored._course_collision(restored.units[0],true,78.)
	check(restored.hull==hull,"restoring cannot bypass active hit cooldown")
	for value in [-1.,1.,NAN,"bad"]:
		var invalid=saved.duplicate(true);invalid.units[0].hit_at=value
		check(not Sim.valid_snapshot(invalid),"malformed or future hit clock rejects "+str(value))
	for band in [1,2]:
		s=fixture();s.units[1].alive=true;s.units[1].pos=Vector2(527,500);s.units[1].vel=Vector2.ZERO;s.units[1].band=band
		tick(s,.4)
		check(s.hull<100. if band==1 else s.hull==100.,"physical hull collision respects settled depth "+str(band))
		check(s.units[1].alive,"collision leaves existing drone damage rules intact")
	s=fixture();s.units[1].alive=true;s.units[1].pos=Vector2(522,500);s.units[1].vel=Vector2.ZERO
	u=s.units[0];u.pos=Vector2(497,500);u.vel=Vector2(6,0);tick(s,.4)
	check(s.hull==100.,"slow physical hull bump remains harmless")
	s=fixture();s.units[1].alive=true;s.units[1].vel=Vector2(78,0)
	s._course_collision(s.units[1],true,78.)
	check(s.hull==100. and s.units[1].vel==Vector2.ZERO,"drone terrain collision keeps its existing stop and damage rules")
	s=fixture();u=s.units[0];s.mission.currents=[{"center":u.pos,"radius":1000.,"velocity":Vector2(10,0)}]
	s.units[1].alive=true;s.units[1].pos=Vector2(527,500);u.water_velocity=Vector2(68,0);u.pos+=Vector2(4,0)
	s._hull_contacts(u,Vector2(500,500),Vector2(78,0))
	check(u.vel.length()<20. and u.water_velocity.is_equal_approx(u.vel-s.current_at(u.pos)),"hull collision applies its impulse to current-relative velocity too")
	s._current_step(u,Sim.STEP,Vector2.ZERO,42.,Vector2(10,0),true,true)
	check(u.vel.length()<21.,"current integrator preserves collision slowdown on the next step")
	s=fixture();u=s.units[0];u.vel=Vector2.ZERO;s.units[1].alive=true;s.units[1].pos=Vector2(570,500)
	check(s.command("route",{"point":Vector2(570,500)}),"existing waypoint at another craft accepts normally")
	tick(s,8.)
	check(u.pos.distance_to(Vector2(570,500))<12 and u.route.is_empty(),"hull impact slows the craft without adding permanent waypoint exclusion")
	print("COLLISION BOUNDARIES CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
