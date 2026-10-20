extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func advance(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func fresh():
 var s=Sim.new();s.start(7);s.sirens=[];return s
func finish()->void:
 print("RENDEZVOUS TRANSPORT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=fresh()
 check(s.has_method("rendezvous_context"),"Deep7 has a physical mobile receiver with a permitted observation authority")
 if not s.has_method("rendezvous_context"):finish();return
 var Transport=load("res://src/simulation/rendezvous_transport.gd")
 var context=s.rendezvous_context()
 check(not context.vessel.known and not context.vessel.has("pos") and not context.control.known and context.course.is_empty(),"unlocated hull and control reveal no global coordinates or announced course")
 var initial=Transport.position(s.mission,0);advance(s,20)
 check(Transport.position(s.mission,s.elapsed)==initial and not s.command("rendezvous_release"),"elapsed time or distant command cannot secretly launch the tender")
 var points=Transport.POINTS
 for n in range(1,points.size()):check(s.segment_safe(points[n-1],points[n],24),"entire physical tender voyage has24m authored clearance")
 s.units[1].pos=Vector2(650,1120);s.command("select",{"unit":1});advance(s,.8)
 check(s.rendezvous_context().control.known and not s.rendezvous_context().vessel.known,"a nearby drone discovers control without acquiring an occluded distant hull")
 s.command("recon")
 check(s.rendezvous_context().vessel.known and s.mission.signal_sources[0].located and s.mission.objectives.size()==1,"finite local Survey keeps its useful immediate physical source fix")
 var before=s.snapshot();s.rendezvous_context();s.rendezvous_receiver();s.camera_context()
 check(s.snapshot()==before,"read-only tender and receiver feedback cannot acquire terrain or vessel knowledge")
 s.units[1].vel=Vector2(13,0)
 check(not s.command("rendezvous_release"),"departure control requires an actually settled local operator")
 s.units[1].vel=Vector2.ZERO;var route=s.units[1].route.duplicate(true);var hold=s.units[1].hold;var tools=s.tools.duplicate()
 check(s.command("rendezvous_release") and s.units[1].route==route and s.units[1].hold==hold and s.tools==tools,"explicit release starts the voyage without spending tools or rewriting player orders")
 check(s.noises.any(func(noise):return noise.label=="BERTH RELEASE" and noise.radius==950 and noise.time==6) and not s.command("rendezvous_release"),"one release has a real finite audible emission and cannot be repeated")
 var release=s.elapsed;advance(s,2)
 check(Transport.position(s.mission,s.elapsed).distance_to(initial)>40,"release changes the physical receiver position, not merely its image")
 # Stop Survey and move all receivers out of reach: marker must become stale.
 s.recon_time=0
 for unit in s.units:unit.pos=Vector2(1800,2180);unit.vel=Vector2.ZERO
 advance(s,.8);var stale=s.rendezvous_context().vessel;var site_pos=s.mission.objectives[0].pos;advance(s,4)
 var later=s.rendezvous_context().vessel
 check(stale.known and not stale.live and later.pos==stale.pos and later.phase==stale.phase and later.age>stale.age and s.mission.objectives[0].pos==site_pos,"unseen tender motion leaves both hull fix and gold objective position stale")
 s.units[0].pos=Vector2(440,600);s.units[0].vel=Vector2.ZERO;s.command("select",{"unit":0});advance(s,.8)
 check(s.rendezvous_context().vessel.live and s.camera_context().ready,"Quietus can acquire and intercept the real locally moving tender")
 check(s.command("camera"),"existing4s CAMERA begins local moving packet reception")
 advance(s,.5);s.paused=true;var snap=s.snapshot();s.advance(100)
 check(s.snapshot()==snap,"pause freezes transit and partial local reception")
 var copy=Sim.new();check(copy.restore(bytes_to_var(var_to_bytes(snap))),"mid-transit receiver and measured fixes restore in current binary snapshot")
 advance(s,4);advance(copy,4)
 check(s.mission.objectives[0].captured and copy.mission.objectives[0].captured and copy.rendezvous_context().vessel==s.rendezvous_context().vessel,"restored actual moving reception completes the same cadence record")
 check(s.mission.measured_reference==[.8,1.6,.8],"moving source preserves the earned cadence reference")
 advance(s,40)
 check(Transport.position(s.mission,s.elapsed)==points.back() and Transport.position(s.mission,s.elapsed+1000)==points.back(),"missed voyage has a permanent accessible refuge instead of an invisible expiry")
 var fallback=fresh();fallback.units[0].pos=Vector2(380,760);advance(fallback,.8)
 check(fallback.camera_context().ready and fallback.command("camera"),"Quietus-only quiet western berth approach remains a complete local fallback")
 advance(fallback,4.1);check(fallback.mission.objectives[0].captured and not fallback.rendezvous_context().released and fallback.mission.measured_reference==[.8,1.6,.8],"quiet decode does not require releasing or escorting the vessel")
 check(Sim.valid_snapshot(s.snapshot()) and Sim.valid_snapshot(fallback.snapshot()),"both tender outcomes retain valid mission/source/campaign state")
 finish()
