extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
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
func guard_choice()->void:
 var berth=Sim.new();berth.start(7);berth.units[0].pos=Vector2(380,760);berth.units[0].silent=true
 advance(berth,.8);check(berth.command("camera"),"quiet western berth stance still starts the existing local decode against actual guards")
 advance(berth,4.1)
 check(berth.all_records() and berth.hull==100 and not berth.rendezvous_context().released and berth.command("route",{"point":berth.mission.extraction}),"quiet berth path keeps its packet and can choose ordinary recovery without a new release action")
 advance(berth,25)
 check(berth.outcome=="won" and berth.hull==100 and berth.units[1].alive and berth.units[2].alive,"unreleased quiet route remains physically finishable with the real sentinel and no tool use")
 # Matched tactical fixture, not a deployment journey: both branches start with
 # the same legitimately acquired source, craft, guard and command state.
 var seed=Sim.new();seed.start(7)
 seed.units[0].pos=Vector2(440,360);seed.units[0].silent=true
 seed.units[1].pos=Vector2(650,1120);seed.units[1].silent=true
 seed.units[2].pos=Vector2(380,760);advance(seed,.8)
 seed.units[2].pos=Vector2(1800,2180);seed.units[2].vel=Vector2.ZERO
 seed.command("select",{"unit":1});seed.paused=true
 var quiet=Sim.new();var released=Sim.new()
 check(quiet.restore(seed.snapshot()) and released.restore(seed.snapshot()),"matched quiet/release fixture starts from identical accepted public knowledge and real guards")
 check(released.command("rendezvous_release"),"scout-operated berth release is a real optional decision")
 for sim in [quiet,released]:check(sim.command("route",{"point":Vector2(650,1500)}),"operator can explicitly withdraw through ordinary physical route commands")
 advance(quiet,1);advance(released,1)
 check(quiet.sirens[1].mode=="DORMANT" and released.sirens[1].mode=="INVESTIGATE" and released.sirens[1].target==-1 and released.sirens[1].goal.distance_to(Vector2(650,1000))<90,"finite release reaches the sentinel through normal hearing without granting visual target")
 print("MATCHED RELEASE 1s guard quiet=",quiet.sirens[1].pos,"/",quiet.sirens[1].mode," released=",released.sirens[1].pos,"/",released.sirens[1].mode," heard_goal=",released.sirens[1].goal)
 advance(quiet,7);advance(released,7)
 check(not quiet.rendezvous_receiver(0).ready and released.rendezvous_receiver(0).ready and quiet.units[0].pos==released.units[0].pos,"same northern Quietus stance gains actual local moving packet access only after explicit release")
 check(released.units[1].alive and released.hull==100 and released.tools==quiet.tools and not released.noises.any(func(n):return n.label=="BERTH RELEASE"),"planned operator withdrawal survives real guard response and emission expires without tool expenditure")
 released.command("select",{"unit":0});check(released.command("camera"),"northern staged Quietus can receive during actual guard diversion")
 advance(released,4.1)
 check(released.all_records() and released.hull==100 and released.units[1].alive,"real sentinel continuation permits the distinct exposed-release and staged-intercept tactic")
 print("MATCHED RELEASE 12.1s guard=",released.sirens[1].pos,"/",released.sirens[1].mode," hull=",released.hull," drone_alive=",released.units[1].alive," packet=",released.all_records())
func solo_refuge()->void:
 # Isolate gear-independent voyage/route/receiver/extraction composition.
 var solo=fresh();solo.units[1].alive=false;solo.units[2].alive=false
 solo.tools={"emp":0,"knock":0,"decoy":0,"recon":0};solo.units[0].pos=Vector2(650,1120);solo.units[0].silent=true
 advance(solo,.8)
 check(solo.command("rendezvous_release") and solo.command("route",{"point":Vector2(440,360)}),"bare Quietus alone can operate the control then commit a normal interception route")
 advance(solo,20)
 check(solo.rendezvous_receiver(0).ready and solo.command("camera"),"actual independent-craft physics reaches a settled mobile receiver without any optional gear or living drone")
 advance(solo,4.1)
 check(solo.all_records() and solo.command("route",{"point":solo.mission.extraction}),"late interception can finish after arrival at permanent refuge and accept recovery route")
 advance(solo,20)
 check(solo.outcome=="won" and solo.mission.measured_reference==[.8,1.6,.8] and Sim.valid_snapshot(solo.snapshot()),"bare solo release route physically extracts the same earned reference")
 var progress={"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6]}
 var recovered=Campaign.recover(progress,solo.mission)
 check(Campaign.valid(recovered) and 9 in Campaign.available([0,1,2,3,4,5],recovered) and recovered.references.return_cadence==[.8,1.6,.8],"tender recovery preserves the actual Deep-to-Wake campaign handoff")
 check(Campaign.recover(recovered,solo.mission)==recovered,"replaying tender recovery does not duplicate or rewrite earned campaign state")
func paused_release_save()->void:
 var sim=fresh();sim.units[1].pos=Vector2(650,1120);sim.command("select",{"unit":1})
 advance(sim,.25);sim.paused=true
 check(sim.command("recon"),"paused local Survey acquires the berth at the current simulation instant")
 var measured=sim.mission.rendezvous_transport.seen.duplicate(true);var time=sim.elapsed
 check(sim.command("rendezvous_release") and sim.elapsed==time,"paused berth release consumes no simulation time after Survey")
 check(sim.mission.rendezvous_transport.seen==measured,"release preserves the preceding physical observation without inventing a new measurement")
 var store=Store.new();store.path="user://rendezvous-paused-release-tests.save"
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"disruption","settings":{},"expedition":{"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6]},"active":sim.snapshot()}
 check(store.save(data) and store.load_game()==data,"same-time paused Survey then release roundtrips through the actual binary save store")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
func save_integrity(snap:Dictionary)->void:
 var store=Store.new();store.path="user://rendezvous-transport-tests.save"
 var progress={"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6]}
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"disruption","settings":{},"expedition":progress,"active":snap}
 check(store.save(data) and store.load_game()==data,"mid-transit capture and stale/measured state survive the ordinary checksummed binary archive")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 var missing=fresh().snapshot();missing.mission.erase("rendezvous_transport")
 check(not Sim.valid_snapshot(missing),"fresh current Deep save requires its physical transport state")
 var bad=snap.duplicate(true);bad.mission.erase("rendezvous_transport")
 check(not Sim.valid_snapshot(bad),"current Deep transport state cannot be deleted to restore an immobile receiver")
 for value in [[],"bad",{}, {"released_at":NAN,"control_known":true,"seen":{}}, {"released_at":snap.elapsed+1,"control_known":true,"seen":{}}, {"released_at":0.0,"control_known":false,"seen":{}}, {"released_at":-1.0,"control_known":true,"seen":{"pos":Vector2.ZERO}}]:
  bad=snap.duplicate(true);bad.mission.rendezvous_transport=value
  check(not Sim.valid_snapshot(bad),"malformed or unsupported release/observation state cleanly rejects")
 bad=snap.duplicate(true);bad.mission.rendezvous_transport.seen.pos+=Vector2(10,0)
 check(not Sim.valid_snapshot(bad),"saved observation must agree with physical voyage at its recorded measurement time")
 bad=snap.duplicate(true);bad.mission.objectives[0].pos+=Vector2(10,0)
 check(not Sim.valid_snapshot(bad),"saved gold objective must retain the last actual measured hull position")
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
 check(not s.rendezvous_receiver(0).ready,"remote Survey acquisition cannot grant Quietus local packet reception")
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
 var blocked=fresh();blocked.units[0].pos=Vector2(540,420);blocked.command("recon")
 check(blocked.rendezvous_context().vessel.known and not blocked.rendezvous_receiver(0).ready,"finite Survey can fix a covered hull without permitting reception through its berth structure")
 blocked.units[0].pos=Vector2(380,760);advance(blocked,.8);blocked.command("camera");advance(blocked,.5)
 blocked.units[0].pos=Vector2(1800,2180);advance(blocked,.1)
 check(blocked.capture_feedback().unit<0 and not blocked.all_records(),"leaving actual local range interrupts partial tender reception despite a known marker")
 guard_choice();solo_refuge();save_integrity(snap);paused_release_save()
 finish()
