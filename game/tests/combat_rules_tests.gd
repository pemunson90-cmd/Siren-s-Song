extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func beam_fixture():
 var s=Sim.new();s.start(2);s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 s.units[0].pos=Vector2(900,840);s.units[1].alive=false;s.units[2].alive=false
 s.sirens=[s.sirens[0]];var e=s.sirens[0]
 e.pos=Vector2(1060,840);e.home=e.pos;e.goal=e.pos;e.route=[];e.stun=0.;e.lock=0.;e.target=-1
 s.contacts={};s.known={};return s
func run(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func _initialize():
 # Beam: the lock builds as warning, then one shot destroys Quietus.
 var s=beam_fixture();var e=s.sirens[0];run(s,2.0)
 check(s.outcome.is_empty() and s.hull==100.0 and e.lock>1.0,"lock builds with no harm during the warning")
 run(s,3.5)
 check(s.outcome=="lost" and s.hull==0.0 and s.message==Sim.VAPORIZED_TEXT,"fired beam vaporizes Quietus at once")
 s=beam_fixture();e=s.sirens[0];e.type="sentinel";e.angle=PI;e.lock=4.;e.target=0
 s.units[1].alive=true;s.units[1].pos=Vector2(1400,840)
 var second=e.duplicate(true);second.pos=Vector2(1560,840);second.home=second.pos;second.goal=second.pos;second.target=1;s.sirens.append(second)
 run(s,Sim.STEP)
 check(s.hull==0 and not s.units[1].alive and s.message==Sim.VAPORIZED_TEXT,"simultaneous drone beam loss preserves Quietus vaporization cause")
 # Broken lock: losing line of sight drains the lock and nothing dies.
 s=beam_fixture();e=s.sirens[0];run(s,3.0)
 s.mission.structures=[Rect2(970,700,20,300)];s._build_navigation();run(s,4.0)
 check(s.outcome.is_empty() and e.lock<1.0,"cover breaks the lock before it fires")
 # EMP-style knockdown zeroes the lock.
 s=beam_fixture();e=s.sirens[0];run(s,3.0);e.stun=12.0;e.lock=0.0;run(s,3.0)
 check(s.outcome.is_empty() and s.hull==100.0,"disrupted siren cannot fire")
 # Drones still die at once to a beam.
 s=beam_fixture();s.units[1].alive=true;s.units[1].pos=Vector2(900,840);s.units[0].pos=Vector2(400,2000);e=s.sirens[0];run(s,6.0)
 check(not s.units[1].alive and s.outcome.is_empty(),"drone beam kill is unchanged and does not end the dive")
 # Collision damage scaling.
 s=beam_fixture();var u=s.units[0]
 check(s.collision_damage(5.0)==0.0 and s.collision_damage(Sim.COLLISION_SAFE_SPEED)==0.0,"slow bump is free")
 check(s.collision_damage(78.0)>10.0 and s.collision_damage(78.0)<Sim.COLLISION_MAX_DAMAGE+0.01,"cruise-speed impact hurts but is capped")
 check(s.collision_damage(500.0)<=Sim.COLLISION_MAX_DAMAGE and Sim.COLLISION_MAX_DAMAGE<100.0,"no single impact destroys Quietus")
 s._course_collision(u,true,6.0)
 check(s.hull==100.0,"slow collision leaves hull intact")
 s._course_collision(u,true,70.0);var after=s.hull
 check(after<100.0 and s.message.begins_with("Hull strike"),"fast collision damages hull and reports it")
 s._course_collision(u,true,70.0)
 check(s.hull==after,"hit cooldown prevents a per-frame drain")
 s.elapsed+=Sim.COLLISION_COOLDOWN+0.1;s._course_collision(u,true,70.0)
 check(s.hull<after,"damage resumes after the cooldown")
 s=beam_fixture();s.units[1].alive=true;s._course_collision(s.units[1],true,70.0)
 check(s.hull==100.0,"drone impacts never touch Quietus hull")
 # Real physical impact: fast craft driven at charted rock.
 s=beam_fixture();s.mission.rocks=[];s.mission.structures=[Rect2(1000,700,60,300)];s._build_navigation()
 s.units[0].pos=Vector2(950,840);s.units[0].vel=Vector2(78,0);s.units[0].route=[];s.sirens[0].pos=Vector2(300,2200);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 run(s,3.0)
 check(s.hull<100.0 and s.hull>=100.0-Sim.COLLISION_MAX_DAMAGE,"real fast impact into cover cost hull within the cap")
 s=beam_fixture();s.mission.structures=[Rect2(1000,700,60,300)];s._build_navigation()
 s.units[0].vel=Vector2(6,0);s.units[0].pos=Vector2(960,840);s.sirens[0].pos=Vector2(300,2200);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 run(s,3.0)
 check(s.hull==100.0,"real slow bump into cover costs nothing")
 print("COMBAT RULES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
