extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
const Sweeper=preload("res://src/simulation/sweeper_senses.gd")
static func tick(s,t):
 s.paused=false
 for n in roundi(t*60):s.advance(1./60)
 s.paused=true
static func fixture(role:String,gap:float):
 var s=Sim.new();s.start(0);s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0];e.type=role;e.pos=Vector2(900,700);e.home=e.pos;e.goal=e.pos;e.route=[];e.suspicion=0.;e.stun=0.;e.patrol_points=[]
 s.sirens=[e];s.units[0].pos=e.pos-Vector2(gap,0)
 s.units[0].silent=false
 for i in [1,2]:s.units[i].alive=false
 return s
# Steps only the Siren senses with Quietus holding a given engine speed.
static func listen(s,seconds:float,speed:float):
 for n in roundi(seconds*60):
  s.units[0].vel=Vector2(speed,0);s.elapsed+=1./60;s._threats(1./60)
 s.units[0].vel=Vector2.ZERO
static func run(t):
 pin_lifecycle(t,"sweeper")
 pin_lifecycle(t,"patroller")
 # No sonar of its own: a close but unseen Quietus never causes charge, emission, echo or strike.
 var s=fixture("sweeper",400);s.mission.rocks=[Rect2(640,600,60,200)];s._build_navigation()
 tick(s,30)
 t.check(not s.sirens[0].has("sweep") and not s.noises.any(func(n):return n.label in ["ACTIVE SWEEP","ACTIVE SONAR"]) and s.hull==100,"sweeper emits no sonar and does no damage while Quietus is quiet and out of sight")
 t.check(not s.sonar.history.any(func(r):return r.classification in ["ACTIVE SWEEP","SWEEP WINDUP","RETURN CHARGE"]),"no sweep classifications are ever heard")
 # Normal Siren route: line of sight, then the four second lock, then the beam.
 s=fixture("sweeper",200);listen(s,1.,0.)
 t.check(s.sirens[0].lock>0.5 and s.sirens[0].mode=="LOCKING" and s.hull==100,"sight builds a lock first")
 listen(s,3.5,0.)
 t.check(s.sirens[0].mode=="BEAM" and s.hull==0 and s.outcome=="lost","lock completes into the normal beam")
 s=fixture("sweeper",200);listen(s,1.5,0.);s.units[0].pos=Vector2(150,150);listen(s,1.,0.)
 t.check(s.sirens[0].lock<1.0,"breaking sight decays the lock before the beam")
 # Wider ear than a patroller: same noisy Quietus at 700 m is heard by the sweeper only.
 var patrol=fixture("patroller",700);var sweep=fixture("sweeper",700)
 listen(patrol,.5,90.);listen(sweep,.5,90.)
 t.check(patrol.sirens[0].mode!="INVESTIGATE" and sweep.sirens[0].mode=="INVESTIGATE","sweeper hears throttle noise past a patroller's range")
 t.check(sweep.sirens[0].get("listen",{}).get("pos",Vector2.ZERO).distance_to(Vector2(200,700))<40,"sweeper records the heard spot")
 var quiet=fixture("sweeper",700);listen(quiet,3.,0.)
 t.check(quiet.sirens[0].mode!="INVESTIGATE" and not quiet.sirens[0].has("listen"),"a still Quietus is not heard")
 # Stale report: the sweeper walks to the heard spot and does not follow Quietus afterwards.
 var heard=sweep.sirens[0].listen.pos;sweep.units[0].pos=Vector2(300,150)
 tick(sweep,6)
 t.check(sweep.sirens[0].listen.pos==heard and sweep.sirens[0].goal.distance_to(heard)<100 and sweep.sirens[0].pos.distance_to(sweep.units[0].pos)>150,"investigation uses the stale heard spot, not live tracking")
 # Longer, slower: the sweeper keeps searching after a patroller has gone home.
 t.check(sweep.sirens[0].attention_time>patrol.sirens[0].get("attention_time",0.) and Sweeper.attention(sweep.sirens[0])>Sweeper.attention(patrol.sirens[0]),"sweeper investigates longer than a patroller")
 t.check(Sweeper.speed(sweep.sirens[0],48.)<48. and Sweeper.speed(patrol.sirens[0],48.)==48.,"sweeper investigates slower than a patroller")
 # The player-facing warning is a heard investigation with bearing and seconds.
 var warn=fixture("sweeper",300);warn.units[0].vel=Vector2(90,0);listen(warn,.5,90.);warn.sirens[0].mode="INVESTIGATE";warn.sonar.clock=0.
 warn.units[0].pos=Vector2(600,700);warn.units[0].vel=Vector2.ZERO;warn.sirens[0].pos=Vector2(900,700);warn.paused=false;warn.Sonar.advance(warn,.01);warn.paused=true
 t.check(warn.sonar.history.any(func(r):return r.classification==Sweeper.WARNING and absf(r.direction.x)>.9),"heard sweeper investigation is reported with a bearing")
 t.check(warn.events.any(func(e):return e.type=="sweep_received"),"heard sweeper investigation raises the received cue")
 # Idle sweeper with no authored lane holds its post; with an authored lane it walks it.
 var post=fixture("sweeper",900);post.units[0].pos=Vector2(1500,100);tick(post,40)
 t.check(post.sirens[0].pos.distance_to(Vector2(900,700))<1,"idle sweeper without an authored lane holds its post")
 var lane=fixture("sweeper",900);lane.units[0].pos=Vector2(1500,100);lane.sirens[0].patrol_points=[Vector2(700,700),Vector2(1100,700)];tick(lane,40)
 t.check(lane.sirens[0].pos.distance_to(Vector2(900,700))>40,"idle sweeper walks an authored lane")
 # Saves: new state validates, the retired sonar state is rejected.
 t.check(Sim.valid_snapshot(sweep.snapshot()),"sweeper with heard-spot state validates")
 var old=sweep.snapshot();old.sirens[0]["sweep"]={"cooldown":0.,"charge":0.,"emitting":0.,"pending":[],"strike":{}}
 t.check(not Sim.valid_snapshot(old),"retired active-sonar sweeper state is rejected")
 var bad=sweep.snapshot();bad.sirens[0].listen={"pos":Vector2(INF,0),"time":1.}
 t.check(not Sim.valid_snapshot(bad),"non-finite heard spot is rejected")
 bad=sweep.snapshot();bad.sirens[0].listen={"pos":Vector2(1,1)}
 t.check(not Sim.valid_snapshot(bad),"incomplete heard-spot state is rejected")
 bad=patrol.snapshot();bad.sirens[0].listen={"pos":Vector2(1,1),"time":0.}
 t.check(not Sim.valid_snapshot(bad),"only sweepers may carry heard-spot state")

static func pin_fixture(role:String):
 var s=Sim.new();s.start(4)
 s.units[0].pos=Vector2(1280,820);s.units[0].band=2;s.units[0].angle=0
 for id in [1,2]:s.units[id].alive=false
 s.sirens=s.sirens.filter(func(e):return e.type==role).slice(0,1)
 s.sirens[0].pos=Vector2(1380,820);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos;s.sirens[0].band=2
 s.command("select",{"unit":0});s.contacts={};s._observe()
 return s
static func impact(t,s,role):
 t.check(s.command("knock",{"target":0}),role+" admits a legitimately observed physical torpedo")
 tick(s,.8)
 t.check(s.projectiles.is_empty() and s.sirens[0].get("pin_time",0)>7 and s.tools.knock==1,role+" physical impact starts finite eight-second pin")
static func pin_lifecycle(t,role:String):
 var s=pin_fixture(role);impact(t,s,role);var e=s.sirens[0];var remaining=e.get("pin_time",0.)
 tick(s,1.)
 t.check(absf(e.get("pin_time",0.)-(remaining-1.))<.001 and e.mode=="PINNED" and e.vel==Vector2.ZERO,role+" pin clock advances while physical pin remains presented and immobile")
 s._observe()
 t.check(s.contacts[0].mode=="PINNED" and absf(s.contacts[0].get("pin_time",0.)-e.pin_time)<.001,role+" acquired contact presents current physical pin to shared renderer")
 var saved=s.snapshot();s.advance(20.)
 t.check(s.snapshot()==saved,role+" tactical pause freezes partial pin")
 t.check(Sim.valid_snapshot(saved),role+" actual partial-pin snapshot validates without relaxing invariants")
 var store=preload("res://src/persistence/save_store.gd").new();store.path="user://pin-lifecycle-"+role+".save"
 var envelope={"version":1,"unlocked":5,"completed":[0,1,2,3,4],"upgrade":"endurance","settings":{},"active":saved}
 var persisted=store.save(envelope);var loaded=store.load_game() if persisted else {};var copy=Sim.new()
 var restored=persisted and loaded==envelope and copy.restore(loaded.active)
 t.check(restored,role+" partial pin roundtrips real checksummed save and simulation restore")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 tick(s,7.)
 t.check(e.get("pin_time",0.)==0 and e.stun<=0 and e.mode not in ["PINNED","DISRUPTED"] and Sim.valid_snapshot(s.snapshot()),role+" bounded pin expires and live AI resumes with valid save")
 if restored:
  tick(copy,saved.sirens[0].pin_time-.05)
  t.check(copy.sirens[0].pin_time>0 and copy.sirens[0].mode=="PINNED",role+" restored pin retains its remaining physical lifetime")
  tick(copy,.2)
  t.check(copy.sirens[0].pin_time==0 and copy.sirens[0].stun<=0 and copy.sirens[0].mode not in ["PINNED","DISRUPTED"] and Sim.valid_snapshot(copy.snapshot()),role+" restored partial pin expires and resumes AI on schedule")
 s=pin_fixture(role);impact(t,s,role);e=s.sirens[0];remaining=e.pin_time
 t.check(s.command("emp") and e.mode=="PINNED",role+" EMP preserves existing physical pin presentation")
 tick(s,1.)
 t.check(absf(e.pin_time-(remaining-1.))<.001 and e.stun>10.9 and e.mode=="PINNED" and Sim.valid_snapshot(s.snapshot()),role+" overlapping longer EMP leaves independent pin lifetime and valid clocks")
 tick(s,7.1)
 t.check(e.pin_time==0 and e.stun>3.8 and e.mode=="DISRUPTED" and Sim.valid_snapshot(s.snapshot()),role+" pin resurfaces on time while longer EMP remains")
 tick(s,4.1)
 t.check(e.stun<=0 and e.mode not in ["PINNED","DISRUPTED"] and Sim.valid_snapshot(s.snapshot()),role+" AI resumes after overlapping EMP expires")
