extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func tick(s,seconds):
 for i in roundi(seconds*60):s.advance(1.0/60)
func make():
 var s=Sim.new();s.start(2)
 # Isolated reception rules. Unmodified ordinary-threat comparisons live outside.
 for enemy in s.sirens:enemy.stun=200.0
 return s
func request(s):
 s.units[0].pos=Vector2(760,330);s.units[0].vel=Vector2.ZERO
 s.command("camera");s.paused=false;tick(s,2.05)
func _initialize():
 var s=make()
 check(s.mission.get("courier_revision",0)==1,"fresh Blackwater offers a physical optional southern reply carrier")
 check(s.mission.get("courier_launch",99)==-1,"no carrier voyage starts before a recovered request")
 request(s)
 check(s.mission.objectives[0].captured and absf(s.mission.courier_launch-2.0)<0.001,"actual completed request launches one finite reply carrier")
 check("southern" in s.mission.objectives[0].evidence.to_lower() and "CARRIER" in s.message,"earned request teaches the optional southern carrier without replacing sonar fallback")
 check(not s.blackwater_context(1).ready,"waiting at recovered REQUEST cannot silently receive the distant carrier")
 check(s.has_method("courier_feedback"),"carrier has an earned local observation interface")
 if not s.has_method("courier_feedback"):
  print("COURIER CHECKS ",checks," FAILURES ",failures);quit(1);return
 check(s.courier_feedback().is_empty(),"request does not globally reveal the remote carrier position")
 var points=[Vector2(1360,480),Vector2(1120,560),Vector2(740,740),Vector2(360,760)]
 for i in range(1,points.size()):check(s.segment_safe(points[i-1],points[i],8),"entire authored carrier segment has physical clearance %d"%i)
 tick(s,12)
 s.units[0].pos=Vector2(1120,620);s.units[0].vel=Vector2.ZERO
 var context=s.blackwater_context(1)
 check(context.ready and context.get("source","")=="courier","local southern intercept receives moving reply far outside static relay range")
 check("CARRIER" in s.camera_context().text,"SAMPLE readiness identifies moving carrier instead of the distant relay")
 var before=s.snapshot();s.camera_context();s.courier_feedback()
 check(before==s.snapshot(),"carrier feedback and readiness never mutate mission state")
 check(s.command("camera"),"ordinary SAMPLE starts at a locally heard moving archive")
 tick(s,0.8);s.paused=true;before=s.snapshot();s.advance(100)
 check(before==s.snapshot(),"pause freezes carrier motion and partial reception")
 var store=preload("res://src/persistence/save_store.gd").new();store.path="user://test-courier.save"
 var data={"version":2,"unlocked":2,"completed":[0,1],"upgrade":"endurance","settings":{},"active":s.snapshot()}
 var persisted=store.save(data);var saved=store.load_game()
 check(persisted and saved==data,"actual archive persists launch time and partial moving reception")
 for suffix in ["",".tmp",".bak"]:DirAccess.remove_absolute(store.path+suffix)
 var restored=Sim.new();check(restored.restore(saved.get("active",{})),"partial moving reception restores through actual snapshot")
 check(restored.courier_feedback()==s.courier_feedback(),"restored voyage retains exact position and receiver provenance")
 restored.paused=false;tick(restored,1.3)
 check(restored.mission.objectives[1].captured,"restored partial intercept completes the original reply record")
 check(not restored.noises.any(func(n):return n.label=="CAMERA"),"quiet glider reception never fabricates an optical or motor emission")
 s=make();request(s);tick(s,12);s.units[0].pos=Vector2(1120,620);s.units[0].vel=Vector2.ZERO;s.command("camera");tick(s,0.5)
 s.units[0].pos=Vector2(140,800);tick(s,0.1)
 check(not s.mission.objectives[1].captured and s.capture_unit<0 and s.capture_time==0,"losing local carrier reception interrupts unfinished sample")
 s=make();request(s);tick(s,12);s.units[0].pos=Vector2(1120,620);s.units[0].vel=Vector2(60,0);s.command("camera");tick(s,0.1)
 check(s.capture_time==0,"intercept requires settled hydrophones rather than drive-by reception")
 s=make();request(s);tick(s,12);s.units[0].pos=Vector2(1120,620);s.units[0].vel=Vector2.ZERO
 s.mission.rocks.append(Rect2(1060,586,120,16));s._build_navigation()
 check(not s.blackwater_context(1).ready and s.courier_feedback().is_empty(),"physical cover blocks the carrier signal and its live chart dot")
 s=make();request(s);tick(s,30);s.units[0].pos=Vector2(740,740);s.units[0].vel=Vector2.ZERO
 var observed=s.courier_feedback();var direction=Vector2.from_angle(observed.angle)
 s.units[0].pos=observed.pos-direction*150;s.command("camera");tick(s,1)
 check(not s.mission.objectives[1].captured and s.capture_unit<0,"a moving carrier can leave range before two settled seconds complete")
 s=make();request(s);tick(s,12);s.units[0].pos=Vector2(1120,760);s.units[0].vel=Vector2.ZERO;s.command("ping")
 check(not s.blackwater_context(1).ready,"sonar outside static relay reach cannot invent a carrier replay extension")
 s=make();request(s);tick(s,12);s.units[0].pos=Vector2(1120,620);s.units[0].alive=false
 check(s.courier_feedback().is_empty(),"dead receiver cannot keep a remote carrier live")
 s=make();request(s);tick(s,60);s.units[0].pos=Vector2(360,760)
 check(s.courier_feedback().is_empty() and not s.blackwater_context(1).ready,"missed finite voyage does not leave a permanent free western reply")
 s.units[0].pos=Vector2(1360,350);s.units[0].vel=Vector2.ZERO
 check(s.command("camera"),"missing carrier preserves original eastern passive relay fallback")
 tick(s,2.05);check(s.all_records(),"eastern fallback still secures full exchange after missed intercept")
 s=make();s.units[0].pos=Vector2(1360,350);s.command("camera");s.paused=false;tick(s,2.05);request(s)
 check(s.all_records() and s.mission.courier_launch<0,"reply-first order needs no carrier voyage or additional objective")
 s=make();request(s);var malformed=s.snapshot();malformed.mission.courier_launch=NAN
 check(not Sim.valid_snapshot(malformed),"nonfinite carrier launch cannot enter a restored save")
 malformed=s.snapshot();malformed.mission.courier_launch=s.elapsed+1
 check(not Sim.valid_snapshot(malformed),"future carrier launch cannot reset the finite opportunity")
 malformed=s.snapshot();malformed.mission.objectives[0].captured=false
 check(not Sim.valid_snapshot(malformed),"carrier cannot restore without an earned request")
 malformed=s.snapshot();malformed.mission.objectives=[]
 check(not Sim.valid_snapshot(malformed),"malformed courier objective shape rejects without a snapshot crash")
 var legacy=s.snapshot();legacy.mission.erase("courier_revision");legacy.mission.erase("courier_launch")
 var old=Sim.new();check(old.restore(legacy) and not old.mission.has("courier_revision"),"existing Blackwater saves gain no new encounter or timing")
 print("COURIER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
