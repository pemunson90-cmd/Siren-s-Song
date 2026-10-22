extends SceneTree
# ALL STOP: engines off, coast to rest, zero throttle noise, a real cost, a timed
# restart, and composition with the camera hold. Everything the feature adds lives
# in src/simulation/all_stop/; these tests sit beside it.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const Table=preload("res://src/simulation/all_stop/all_stop_table.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func run(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
func fresh(id:int=0):
	var s=Sim.new();s.start(id,"endurance");s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	return s
# Quietus on a long clear leg at cruise, up to speed.
func cruising():
	var s=fresh(0)
	s.units[0].pos=Vector2(200,700);s.units[0].angle=0.0;s.units[0].silent=false
	s.command("route",{"point":Vector2(1000,700)})
	run(s,3.0)
	return s
func _initialize():
	# 1 / The table is a real cost, and engines off is silent.
	check(Table.ENABLED and Table.ENTRY_OXYGEN>0.0 and Table.RESTART_OXYGEN>0.0 and Table.RESTART_SECONDS>=3.0 and Table.COAST_DECEL<42.0 and Table.OFF_NOISE==0.0,"all stop costs oxygen and time, coasts slower than normal braking, and is silent")
	# 2 / The order: shuts the engines down for a price.
	var s=cruising()
	var v0:float=s.units[0].vel.length();var x0:float=s.units[0].pos.x;var o0:float=s.oxygen
	check(v0>30.0 and s.motion_radius(0)>100.0,"Quietus is moving and audible before the order (%.1f m/s, %.0f m)"%[v0,s.motion_radius(0)])
	check(s.command("all_stop") and AllStop.stopped(s.units[0]),"the ALL STOP order is accepted")
	check(is_equal_approx(o0-s.oxygen,Table.ENTRY_OXYGEN),"it draws %.1f oxygen at once"%Table.ENTRY_OXYGEN)
	check(s.motion_radius(0)==0.0,"throttle noise is zero the instant the engines are off, even while the hull still moves")
	# 3 / It coasts to rest over the distance the table gives, and keeps its route.
	run(s,v0/Table.COAST_DECEL+1.0)
	var glide:float=s.units[0].pos.x-x0
	var expected:float=v0*v0/(2.0*Table.COAST_DECEL)
	check(s.units[0].vel.length()<0.5,"the hull comes to rest")
	check(absf(glide-expected)<expected*0.25+12.0,"it glides about v squared over twice the deceleration (%.0f m, expected %.0f)"%[glide,expected])
	check(s.motion_radius(0)==0.0 and not s.units[0].route.is_empty(),"at rest it is silent and its route is kept")
	var rest:Vector2=s.units[0].pos
	run(s,4.0)
	check(s.units[0].pos.distance_to(rest)<0.5,"it stays where it stopped while the engines are off")
	# 4 / A normal HOLD brakes harder and is not the same thing.
	var h=cruising();var hx:float=h.units[0].pos.x;h.command("hold");run(h,v0/Table.COAST_DECEL+1.0)
	check(h.units[0].pos.x-hx<glide*0.6,"HOLD stops in a much shorter distance than the all-stop glide")
	# 5 / Ordering a new course starts a timed restart at limited thrust.
	var o1:float=s.oxygen
	check(s.command("route",{"point":Vector2(1000,700)}),"a new course is accepted with the engines off")
	check(AllStop.restarting(s.units[0]) and is_equal_approx(o1-s.oxygen,Table.RESTART_OXYGEN),"it orders the restart and draws the restart oxygen")
	run(s,3.0)
	check(s.units[0].vel.length()<=Table.RESTART_SPEED+1.0 and s.units[0].vel.length()>1.0,"thrust is held to %.0f m/s while the engines come back (%.1f)"%[Table.RESTART_SPEED,s.units[0].vel.length()])
	var peak:=0.0
	for n in ceili((Table.RESTART_SECONDS+3.0)*60):
		s.advance(1./60);peak=maxf(peak,s.units[0].vel.length())
	check(not s.units[0].has("all_stop"),"after the restart the state clears")
	check(peak>Table.RESTART_SPEED+5.0,"and the hull accelerates normally again (peak %.1f m/s)"%peak)
	# 6 / Toggling the order again also restarts.
	var t=cruising();t.command("all_stop");run(t,2.0)
	check(t.command("all_stop") and AllStop.restarting(t.units[0]),"ALL STOP again orders the engines back")
	# 7 / Refusals.
	var low=fresh();low.oxygen=0.5
	check(not low.command("all_stop") and not AllStop.stopped(low.units[0]) and low.message==Table.TEXT.refused_oxygen,"not enough air refuses")
	var dr=fresh();dr.units[1].alive=true;dr.selected=1
	check(not dr.command("all_stop") and not dr.units[1].has("all_stop"),"a drone cannot all stop")
	var dive=fresh();dive.units[0].transition={"to":2,"remaining":2.0}
	check(not dive.command("all_stop"),"no all stop during a depth change")
	# 8 / Composes with the camera hold: the exposure runs, the engines stay off.
	var spire=Vector2(1300,300);var facing=2.74
	var c=fresh();c.units[0].pos=spire+Vector2.from_angle(facing)*110;c.units[0].angle=facing+PI;c.units[0].vel=Vector2.ZERO
	c.command("all_stop")
	check(c.command("camera"),"the camera works with the engines off")
	run(c,6.0)
	check(c.mission.objectives[0].captured and AllStop.stopped(c.units[0]),"the exposure completes and the engines are still off afterwards")
	check(c.units[0].hold=="" and c.units[0].vel.length()<0.5,"the camera hold has released and the hull is at rest")
	# 9 / A current carries an engines-off hull and costs a station-keeping hull noise.
	var cur=fresh();cur.mission["currents"]=[{"center":Vector2(300,700),"radius":2000.0,"velocity":Vector2(10,0)}]
	cur.units[0].pos=Vector2(300,700);cur.units[0].vel=Vector2.ZERO;cur.units[0].angle=0.0
	var keep=fresh();keep.mission["currents"]=cur.mission.currents;keep.units[0].pos=Vector2(300,700);keep.units[0].vel=Vector2.ZERO;keep.units[0].angle=0.0
	keep.command("hold");run(keep,4.0)
	cur.command("all_stop");run(cur,4.0)
	check(cur.units[0].pos.x-300.0>20.0 and keep.units[0].pos.x-300.0<20.0,"an engines-off hull drifts with the current while HOLD keeps station")
	check(cur.motion_radius(0)==0.0,"the drifting hull makes no motion noise")
	# 10 / Saves: optional, validated.
	var st=cruising();st.command("all_stop")
	var snap=st.snapshot()
	var back=Sim.new();back.start(0,"endurance")
	check(back.restore(snap) and AllStop.stopped(back.units[0]),"a stopped hull restores stopped")
	var plain=cruising().snapshot()
	var again=Sim.new();again.start(0,"endurance")
	check(not plain.units[0].has("all_stop") and again.restore(plain),"a save without the field loads with the engines on")
	var bad=st.snapshot();bad.units[0].all_stop={"mode":"coasting","t":0.0}
	var r1=Sim.new();r1.start(0,"endurance")
	check(not r1.restore(bad),"an unknown mode is refused")
	var bad2=st.snapshot();bad2.units[1].all_stop={"mode":"stopped","t":0.0}
	var r2=Sim.new();r2.start(0,"endurance")
	check(not r2.restore(bad2),"a drone carrying the field is refused")
	var bad3=st.snapshot();bad3.units[0].all_stop={"mode":"restart","t":99.0}
	var r3=Sim.new();r3.start(0,"endurance")
	check(not r3.restore(bad3),"an out-of-range restart time is refused")
	# 11 / The button label reads the state.
	var lab=cruising()
	check(AllStop.label(lab).begins_with("ALL STOP"),"the label offers ALL STOP with its price")
	lab.command("all_stop");check(AllStop.label(lab).begins_with("ENGINES"),"and ENGINES RESTART once stopped")
	print("ALL STOP CHECKS ",checks," FAILURES ",failures)
	quit()
