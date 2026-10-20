extends RefCounted
const Sim=preload("res://src/simulation/simulation.gd")
static func tick(s,t):
 s.paused=false
 for n in roundi(t*60):s.advance(1./60)
 s.paused=true
static func run(t):
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
