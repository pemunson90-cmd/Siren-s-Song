extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func fixture(legacy=false):
	var s=Sim.new();s.start(0);s.mission.rocks=[];s.mission.objectives[0].pos=Vector2(1400,900);s._build_navigation()
	if legacy:s.mission.erase("acoustic_revision")
	for u in s.units:u.alive=false
	s.units[0].alive=true;s.units[0].pos=Vector2(300,500)
	var e=s.sirens[0];e.pos=Vector2(650,500);e.home=e.pos;e.goal=e.pos;e.type="sentinel";e.route=[]
	return s
func _initialize():
	var s=fixture();check(s.mission.get("acoustic_revision",0)==1,"new dive opts into acoustic model")
	s.units[0].vel=Vector2(60,0);s._threats(Sim.STEP)
	check(s.sirens[0].suspicion==0,"moderate actual speed cannot announce a fixed430m radius")
	s.units[0].vel=Vector2(78,0);s._threats(Sim.STEP)
	check(s.sirens[0].suspicion>0 and s.sirens[0].goal!=s.units[0].pos,"cruise audible without visual lock or exact hidden location")
	check(s.sirens[0].lock==0 and s.sirens[0].target==-1 and s.contacts.is_empty(),"hearing alone cannot grant visual beam or player contact")
	var old=fixture(true);old.units[0].vel=Vector2(60,0);old._threats(Sim.STEP)
	check(old.sirens[0].goal==old.units[0].pos and old.sirens[0].suspicion>0,"legacy no-revision retains old threshold and goal")
	s=fixture();s.mission.rocks=[Rect2(450,350,100,300)];s._build_navigation();s._noise(s.units[0].pos,1600,"TEST PULSE",1);s._threats(Sim.STEP)
	check(s.sirens[0].suspicion>0 and s.sirens[0].goal!=s.units[0].pos and not s.line_clear(s.sirens[0].pos,s.units[0].pos),"generic noise around basalt yields an arrival corner goal")
	var before=s.snapshot();s.advance(5)
	check(s.snapshot()==before,"pause freezes noises and acoustic investigation")
	var restored=Sim.new();check(restored.restore(before),"fresh acoustic state remains restorable")
	s.paused=false;restored.paused=false
	for n in 60:s.advance(Sim.STEP);restored.advance(Sim.STEP)
	check(s.snapshot()==restored.snapshot(),"restore rebuilds transient graph with identical future acoustic decisions")
	var own=s.acoustic_feedback();s.sirens[0].goal=Vector2(42,24);s.sirens[0].mode="BEAM";s.sirens[0].suspicion=1
	check(s.acoustic_feedback()==own,"own feedback does not expose hidden listener arrival or intent")
	s=fixture();s.units[0].vel=Vector2(78,0);var f=s.acoustic_feedback()
	check(f.motion.size()==1 and is_equal_approx(f.motion[0].get("radius",0),430),"own footprint derives actual speed and common open-water reference")
	for role in ["patroller","sentinel","hunter"]:
		s=fixture();s.sirens[0].type=role;s.units[0].vel=Vector2(78,0);s._threats(Sim.STEP)
		var heard_goal:Vector2=s.sirens[0].get("last_known",Vector2.ZERO)
		s.units[0].vel=Vector2.ZERO;s.units[0].pos=Vector2(140,900);s._threats(Sim.STEP)
		check(s.sirens[0].get("last_known")==heard_goal and heard_goal!=Vector2(140,900),role+" retains heard inference, never current hidden pilot goal")
		s=fixture();s.sirens[0].type=role;s.units[0].pos=s.sirens[0].pos+Vector2(-100,0);s._threats(1.0)
		check(s.hull==100 and s.sirens[0].lock==1.0,role+" visual lock still gives full telegraph")
		s.sirens[0].stun=2;s._threats(1.0)
		check(s.sirens[0].lock==0 and s.hull==100,role+" disrupted listener cannot lock or beam")
	var invalid=fixture().snapshot();invalid.mission.acoustic_revision=true
	check(not Sim.valid_snapshot(invalid),"malformed fresh acoustic revision is rejected without changing legacy acceptance")
	print("ACOUSTIC HEARING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
