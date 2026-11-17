extends SceneTree
# WP-125 (Pat, 14 Nov 2026, "Q4 that sounds fine ... a balanced lever for easy medium and hard difficulties"): after an
# EMP stun ends a Siren cannot start a new lock for 12 s (accessible), 8 s (standard) or 4 s (survival).
const Sim=preload("res://src/simulation/simulation.gd")
const Tuning=preload("res://src/simulation/tuning.gd")
const EconomyTable=preload("res://src/campaign/economy_table.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
# The combat suite's beam fixture: one Siren 160 m from Quietus with a clear line.
func fixture(preset:String,role:String="patroller"):
	var s=Sim.new();s.start(2);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
	if preset!="":s.mission["difficulty_preset"]=preset
	s.units[0].pos=Vector2(900,840);s.units[1].alive=false;s.units[2].alive=false
	s.sirens=[s.sirens[0]];var e=s.sirens[0]
	e.type=role;e.pos=Vector2(1060,840);e.home=e.pos;e.goal=e.pos;e.route=[];e.stun=0.;e.lock=0.;e.target=-1
	s.contacts={};s.known={};return s
func run(s,seconds:float)->void:
	s.paused=false
	for n in roundi(seconds*60):s.advance(Sim.STEP)
func _initialize():
	var table:Dictionary=Tuning.EMP_LOCK_GRACE_BY_PRESET
	check(table.size()==3 and table.accessible==12.0 and table.standard==8.0 and table.survival==4.0,"the one table: accessible 12, standard 8, survival 4")
	for id in EconomyTable.ORDER:check(table.has(id),"every economy preset has a grace: "+id)
	for preset in ["accessible","standard","survival"]:
		check(fixture(preset).emp_lock_grace()==table[preset],"the dive reads the grace of its preset "+preset)
	check(fixture("").emp_lock_grace()==8.0,"a mode with no preset uses the standard value")
	check(fixture("nonsense").emp_lock_grace()==8.0,"an unknown preset uses the standard value")
	for role in ["patroller","sentinel"]:
		for preset in ["accessible","standard","survival"]:grace_case(preset,role)
	# A Siren the stun did not affect locks as before: no EMP, the lock builds at once.
	var s=fixture("accessible");var e=s.sirens[0];run(s,2.0)
	check(e.lock>1.0 and not e.has("lock_grace"),"a Siren no stun affected builds its lock unchanged")
	# An EMP out of range of one Siren leaves it alone while the stunned one is held.
	s=fixture("standard");e=s.sirens[0]
	var other=e.duplicate(true);other.pos=Vector2(900,1400);other.home=other.pos;other.goal=other.pos;other.angle=-PI/2
	s.sirens.append(other)
	run(s,3.0);check(s.command("emp"),"EMP accepted")
	check(not s.sirens[1].get("emp_hit",false) or s.sirens[1].stun>0.,"the second Siren is judged by whether the pulse reached it")
	# Saves keep the grace clock.
	s=fixture("survival");e=s.sirens[0];run(s,3.0);s.command("emp");run(s,12.2)
	check(e.get("lock_grace",0.)>0.,"grace is running in the saved state")
	var saved=s.snapshot();var restored=Sim.new()
	check(Sim.valid_snapshot(saved) and restored.restore(saved) and is_equal_approx(float(restored.sirens[0].get("lock_grace",-1.)),float(e.lock_grace)),"a saved dive restores the grace clock")
	print("EMP LOCK GRACE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func grace_case(preset:String,role:String)->void:
	var grace:float=Tuning.EMP_LOCK_GRACE_BY_PRESET[preset]
	var s=fixture(preset,role);var e=s.sirens[0];run(s,3.0)
	check(e.lock>1.0,"%s %s: a lock was building"%[preset,role])
	check(s.command("emp"),"%s %s: EMP accepted"%[preset,role])
	run(s,Tuning.EMP_STUN-1.0)
	check(e.stun>0.0 and e.lock==0.0,"%s %s: held while stunned"%[preset,role])
	run(s,1.2)
	check(e.stun<=0.0 and e.get("lock_grace",0.)>grace-0.5 and e.lock_grace<=grace,"%s %s: stun over, grace starts at %.0f s: %s"%[preset,role,grace,str(e.get("lock_grace",-1.))])
	run(s,grace-1.0)
	check(e.lock==0.0 and s.outcome.is_empty(),"%s %s: no lock inside the grace"%[preset,role])
	run(s,2.0)
	check(e.lock>0.5,"%s %s: a lock may start after the grace (lock %.2f)"%[preset,role,e.lock])
