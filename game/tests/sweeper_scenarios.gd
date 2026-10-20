extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
static func tick(s,t):
 s.paused=false
 for n in roundi(t*60):s.advance(1./60)
 s.paused=true
static func run(t):
 pin_lifecycle(t,"sweeper")
 pin_lifecycle(t,"patroller")
 var s=Sim.new();s.start(0);s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0];e.type="sweeper";e.pos=Vector2(450,700);e.home=e.pos;e.goal=e.pos;e.route=[];e.suspicion=0.;e.stun=0.
 s.units[0].pos=Vector2(250,700)
 for i in [1,2]:s.units[i].alive=false
 tick(s,1)
 t.check(e.get("sweep",{}).get("charge",0)>0,"sweeper telegraphs before any return")
 t.check(e.get("known_band",-1)==-1 and s.hull==100,"charge grants no hidden acquisition or beam damage")
 tick(s,2);var saved=s.snapshot()
 t.check(not e.sweep.pending.is_empty(),"physical sweep queues echo rather than instant acquisition")
 t.check(Sim.valid_snapshot(saved),"pending enemy sweep validates")
 s.units[0].pos=Vector2(200,850)
 tick(s,2)
 t.check(e.get("last_known",Vector2.ZERO).distance_to(Vector2(250,700))<1,"received echo retains emission-time point")
 t.check(s.hull==100,"real relocation evades stale return strike")

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
