extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const Observed=preload("res://tests/fixtures/blackwater_first_extract.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func tick(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func loss_and_resample()->void:
 var lost=current_observed_fixture();lost.sirens=[];lost.mission.blackwater_delivery.carriers=[[],[0],[1]]
 var position=lost.units[1].pos;lost.units[1].alive=false;tick(lost,Sim.STEP)
 var sites=lost.salvage_sites()
 check(sites.size()==1 and sites[0].item=="blackwater_buffer_1" and sites[0].pos==position and sites[0].packets==[0],"lost data carrier leaves one known own-position buffer wreck without erasing the field record")
 lost.units[0].pos=Vector2(760,330);lost.units[0].vel=Vector2.ZERO;lost.command("select",{"unit":0})
 check(lost.camera_context().ready and lost.command("camera"),"Quietus can reacquire an already recorded missing packet at the original receiver")
 var record=lost.mission.objectives[0].duplicate(true);var launch=lost.mission.courier_launch;var record_events=lost.events.filter(func(e):return e.type=="record").size()
 tick(lost,2.1)
 check(lost.mission.objectives[0]==record and lost.mission.courier_launch==launch and lost.events.filter(func(e):return e.type=="record").size()==record_events,"resample preserves the first field evidence and glider launch without a duplicate archive event")
 check(lost.blackwater_delivery_status().packets[0].aboard and lost.salvage_sites().is_empty(),"real resample secures Q's packet while redundant wreck data no longer blocks the mission")
func combined_wreck()->void:
 var sim=Sim.new();sim.start(2,"endurance",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}});sim.sirens=[]
 sim.units[1].pos=Vector2(760,330);sim.command("select",{"unit":1});sim.command("camera");tick(sim,2.1)
 sim.units[1].alive=false;tick(sim,Sim.STEP)
 var sites=sim.salvage_sites()
 check(sites.size()==1 and sites[0].item=="drone_sampler" and sites[0].get("packets",[])==[0],"co-located launched kit and raw data use one existing wreck marker and module ID")
 sim.units[0].pos=Vector2(760,360);sim.units[0].vel=Vector2.ZERO;sim.command("select",{"unit":0})
 check(sim.command("salvage",{"item":"drone_sampler"}),"one ordinary audible winch begins combined wreck recovery")
 tick(sim,4.1)
 check(sim.blackwater_delivery_status().packets[0].aboard and sim.module_recovery_status().cargo[0]==["drone_sampler"] and sim.salvage_sites().is_empty(),"one4s winch recovers co-located inactive kit and exchange buffer to the same living carrier")
func glider_buffer()->void:
 var sim=Sim.new();sim.start(2);sim.sirens=[];sim.units[0].pos=Vector2(760,330);sim.command("camera");tick(sim,2.1);tick(sim,12)
 sim.units[2].pos=Vector2(1120,620);sim.units[2].vel=Vector2.ZERO;sim.command("select",{"unit":2})
 check(sim.blackwater_context(1).get("source","")=="courier" and sim.command("camera"),"a real drone interception preserves the accepted moving glider receiver")
 tick(sim,2.1)
 check(sim.blackwater_delivery_status().cargo[2]==[1] and not sim.all_records(),"glider REPLY is physically buffered by its actual receiving drone")
 sim.units[0].pos=Vector2(1120,650);sim.units[0].vel=Vector2.ZERO
 check(sim.command("blackwater_handoff",{"carrier":2}) and sim.all_records(),"local glider data handoff combines with Quietus's request without another objective")
func data_winch_and_save()->void:
 var sim=Sim.new();sim.start(2);sim.sirens=[];sim.command("select",{"unit":1})
 for site in [0,1]:
  sim.units[1].pos=sim.mission.objectives[site].pos+Vector2(0,130);sim.units[1].vel=Vector2.ZERO
  sim.command("camera");tick(sim,2.1)
 sim.units[1].alive=false;tick(sim,Sim.STEP)
 sim.units[0].pos=sim.units[1].pos+Vector2(0,30);sim.units[0].vel=Vector2.ZERO
 check(sim.command("salvage",{"item":"blackwater_buffer_1"}),"buffer-only wreck uses the ordinary local salvage command")
 tick(sim,.8)
 check(sim.blackwater_delivery_status().jobs[0].get("duration",0)==4 and not sim.command("camera"),"data winch exposes its real4s task and blocks conflicting SAMPLE")
 sim.paused=true;var before=sim.snapshot();sim.advance(100)
 check(sim.snapshot()==before,"pause freezes partial buffer recovery")
 var store=Store.new();store.path="user://blackwater-delivery-tests.save"
 var data={"version":1,"unlocked":2,"completed":[0,1],"upgrade":"endurance","settings":{},"active":sim.snapshot()}
 check(store.save(data) and store.load_game()==data,"ordinary checksummed binary save roundtrips carried/dropped data and partial buffer winch")
 var copy=Sim.new();check(copy.restore(store.load_game().get("active",{})),"partial buffer winch restores through ordinary current snapshot")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 tick(sim,3.3);tick(copy,3.3)
 check(sim.all_records() and copy.all_records() and sim.salvage_sites().is_empty() and Sim.valid_snapshot(copy.snapshot()),"restored one-winch recovery delivers both packet buffers without a duplicate or extra wait")
 var impossible=before.duplicate(true);impossible.mission.blackwater_delivery.wrecks={};impossible.mission.blackwater_delivery.jobs=[{},{},{}]
 check(not Sim.valid_snapshot(impossible),"recorded current packets must still have physical custody or actual Quietus delivery")
 impossible=before.duplicate(true);impossible.captures[0]={"target":0,"elapsed":.5}
 check(not Sim.valid_snapshot(impossible),"a current craft cannot restore simultaneous buffer winch and SAMPLE work")
 var cancelled=Sim.new();cancelled.restore(before)
 check(cancelled.command("route",{"point":cancelled.units[0].pos+Vector2(100,100)}) and cancelled.blackwater_delivery_status().jobs[0].is_empty(),"accepted paused route replacement immediately cancels buffer winch")
 tick(cancelled,4)
 check(not cancelled.all_records(),"cancelled physical recovery cannot later grant missing data")
 cancelled.units[0].pos=Vector2(760,330);cancelled.units[0].vel=Vector2.ZERO;cancelled.command("camera");tick(cancelled,.5);cancelled.paused=true
 var resumed=Sim.new()
 check(Sim.valid_snapshot(cancelled.snapshot()) and resumed.restore(bytes_to_var(var_to_bytes(cancelled.snapshot()))),"partial resample of retained evidence restores with physical raw buffer still missing")
 tick(resumed,1.6)
 check(resumed.blackwater_delivery_status().packets[0].aboard and not resumed.blackwater_delivery_status().packets[1].aboard,"restored resample secures exactly its own missing packet")
 var bad=before.duplicate(true);bad.mission.erase("blackwater_delivery")
 check(not Sim.valid_snapshot(bad),"current Blackwater save cannot delete physical delivery state")
 for value in [[],{}, {"aboard":[0,0],"carriers":[[],[],[]],"wrecks":{},"jobs":[{},{},{}]}]:
  bad=before.duplicate(true);bad.mission.blackwater_delivery=value
  check(not Sim.valid_snapshot(bad),"malformed or duplicated packet custody rejects cleanly")
func current_observed_fixture():
 # Explicit source-known mechanic staging from historical poses, NOT a save
 # migration or a new earned journey. Keep the immutable observed export intact.
 var sim=Observed.make()
 for actor in sim.units+sim.sirens:actor["band"]=1;actor["transition"]={}
 for id in sim.sirens.size():sim.sirens[id]["acoustic_tone"]=180.+id*17.
 for noise in sim.noises:noise["band"]=1
 sim.sonar=sim.Sonar.initial();sim._build_navigation();sim._configure_terrain();sim._configure_depth_charts()
 return sim
func physical_return()->void:
 var sim=current_observed_fixture();sim.mission.blackwater_delivery.carriers=[[],[0],[1]]
 for carrier in [1,2]:
  sim.command("select",{"unit":carrier});check(sim.command("route",{"point":sim.units[0].pos}),"observed distant carrier accepts a real homeward route with original guards and spent EMPs")
 sim.paused=false
 var impacts=0
 for step in 2700:
  var old_hull=sim.hull
  sim.advance(Sim.STEP)
  if sim.hull<old_hull:
   check(sim.units[0].get("hit_at",-1)==sim.elapsed and old_hull-sim.hull<=Sim.COLLISION_MAX_DAMAGE,"return hull loss is a bounded physical collision")
   impacts+=1
  for carrier in [1,2]:
   if sim.blackwater_handoff_context(carrier).ready:sim.command("select",{"unit":carrier});sim.command("blackwater_handoff",{"carrier":carrier})
  if not sim.outcome.is_empty():break
 check(sim.outcome=="won" and sim.hull>0 and sim.units.all(func(u):return u.alive) and sim.tools.emp==0 and sim.elapsed>25,"historical15.63s poses staged in current model complete physical return with real guards and spent EMPs")
 check(impacts>0 and sim.hull<100,"incoming docking carriers now incur collision damage without changing the return route")
 print("OBSERVED RETURN outcome=",sim.outcome," elapsed=",sim.elapsed," hull=",sim.hull," EMP=",sim.tools.emp)
func handoff_guards()->void:
 var sim=Sim.new();sim.start(2);sim.mission.objectives[0].captured=true;sim.mission.blackwater_delivery.carriers[1]=[0];sim.units[1].pos=sim.units[0].pos+Vector2(30,0)
 check(sim.blackwater_handoff_context(1).ready,"a local settled own-data carrier exposes handoff readiness")
 sim.units[1].vel=Vector2(2,0);check(not sim.blackwater_handoff_context(1).ready,"carrier ground motion blocks local data connection")
 sim.units[1].vel=Vector2.ZERO;sim.units[0].vel=Vector2(0,2);check(not sim.blackwater_handoff_context(1).ready,"Quietus ground motion also blocks local data connection")
 sim.units[0].vel=Vector2.ZERO;sim.mission.structures=[Rect2(151,780,8,40)]
 check(not sim.blackwater_handoff_context(1).ready,"actual intervening structure blocks a local transfer despite nearby own coordinates")
 sim.mission.structures=[];sim.units[1].pos=sim.units[0].pos+Vector2(61,0)
 check(not sim.blackwater_handoff_context(1).ready,"data link cannot exceed its physical60m range")
func binary_roundtrip(sim)->bool:
 var store=Store.new();store.path="user://blackwater-concurrent-tests.save"
 var data={"version":1,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"active":sim.snapshot()}
 var saved=store.save(data);var loaded=store.load_game() if saved else {};var copy=Sim.new()
 var valid=saved and loaded==data and copy.restore(loaded.active)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 return valid
func concurrent_samples():
 var sim=Sim.new();sim.start(2);sim.sirens=[]
 sim.command("select",{"unit":1});sim.units[1].pos=Vector2(760,330);sim.command("camera");tick(sim,2.1)
 sim.command("select",{"unit":0});sim.units[0].pos=Vector2(1360,610);sim.command("camera");tick(sim,2.1)
 sim.command("select",{"unit":2});sim.units[2].pos=Vector2(760,330);sim.units[2].vel=Vector2.ZERO
 check(sim.command("route",{"point":Vector2(700,330)}) and sim.command("camera") and Sim.valid_snapshot(sim.snapshot()),"peer may hold its accepted route to resample REQUEST until its raw buffer reaches Quietus")
 sim.paused=true
 return sim
func concurrent_delivery()->void:
 var sim=concurrent_samples();sim.units[0].pos=sim.mission.extraction;sim.units[0].vel=Vector2.ZERO
 sim.units[1].pos=sim.units[0].pos+Vector2(30,0);sim.units[1].vel=Vector2.ZERO;sim.command("select",{"unit":1})
 var routes=sim.units.map(func(u):return u.route.duplicate(true));var tools=sim.tools.duplicate();var elapsed=sim.elapsed
 check(sim.command("blackwater_handoff",{"carrier":1}) and sim.captures[2].is_empty() and sim.units[2].hold=="","paused local delivery immediately ends the peer's now-redundant SAMPLE")
 check(sim.units.map(func(u):return u.route)==routes and sim.tools==tools and sim.elapsed==elapsed and sim.selected==1,"ending redundant work preserves accepted routes, tools, simulation time and selection")
 check(binary_roundtrip(sim),"same-time local handoff with a peer resampler roundtrips the real binary archive before ticking")
 tick(sim,Sim.STEP)
 check(sim.outcome=="won" and binary_roundtrip(sim),"normal extraction after concurrent handoff remains a restorable finished archive")
 for fitted in [{"quietus":"","drone_a":"","drone_b":""},{"quietus":"","drone_a":"drone_deep_cells","drone_b":""}]:
  var wreck=Sim.new();wreck.start(2,"endurance",{"fitted":fitted});wreck.sirens=[]
  wreck.command("select",{"unit":1});wreck.units[1].pos=Vector2(760,330);wreck.command("camera");tick(wreck,2.1)
  wreck.units[1].alive=false;tick(wreck,Sim.STEP)
  wreck.units[0].pos=Vector2(760,360);wreck.units[0].vel=Vector2.ZERO;wreck.command("select",{"unit":0})
  check(wreck.command("salvage",{"item":wreck.salvage_sites()[0].item}),"ordinary data or combined-kit winch starts while the field packet remains missing")
  tick(wreck,3.8);wreck.command("select",{"unit":2});wreck.units[2].pos=Vector2(760,330);wreck.units[2].vel=Vector2.ZERO
  check(wreck.command("camera"),"peer resampling may start during an existing wreck winch")
  tick(wreck,.3);wreck.paused=true
  check(wreck.blackwater_delivery_status().packets[0].aboard and wreck.captures[2].is_empty() and wreck.units[2].hold=="" and binary_roundtrip(wreck),"data-only and combined-kit collection end redundant resampling before the same-tick binary save")
 var other=Sim.new();other.start(2);other.sirens=[]
 other.command("select",{"unit":1});other.units[1].pos=Vector2(760,330);other.command("camera");tick(other,2.1)
 other.command("select",{"unit":2});other.units[2].pos=Vector2(1360,610);check(other.command("camera"),"a different packet may still be received during local REQUEST delivery")
 other.units[1].pos=other.units[0].pos+Vector2(30,0);other.units[1].vel=Vector2.ZERO;other.command("select",{"unit":1});other.paused=true
 check(other.command("blackwater_handoff",{"carrier":1}) and not other.captures[2].is_empty() and other.captures[2].target==1 and other.units[2].hold=="HOLD" and binary_roundtrip(other),"delivering REQUEST leaves an unrelated REPLY SAMPLE running and restorable")
func finish()->void:
 print("BLACKWATER DELIVERY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=current_observed_fixture()
 check(s.has_method("blackwater_delivery_status"),"Blackwater exposes physically carried exchange delivery separately from locally retained records")
 if not s.has_method("blackwater_delivery_status"):finish();return
 # Replay the observed first-extraction condition with the measured records
 # still on A/B. This is a source-known reconstruction, not player input replay.
 s.mission.blackwater_delivery.carriers=[[],[0],[1]]
 tick(s,Sim.STEP)
 check(s.outcome.is_empty() and not s.all_records() and not s.departure_context().available,"actual15.633s record flags plus home Quietus cannot auto-win with distant buffers")
 check(s.mission.objectives.all(func(o):return o.captured) and s.blackwater_delivery_status().packets.all(func(p):return p.recorded and not p.aboard),"local field evidence survives while physical mission delivery remains incomplete")
 check(not s.command("blackwater_handoff",{"carrier":1}),"remote archive knowledge cannot transfer a physical buffer across the sector")
 var before=s.snapshot();s.blackwater_delivery_status();s.blackwater_handoff_context(1);s.salvage_sites()
 check(s.snapshot()==before,"delivery and salvage feedback are read-only")
 s.units[1].pos=s.units[0].pos+Vector2(30,0);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1})
 check(s.command("blackwater_handoff",{"carrier":1}) and s.blackwater_delivery_status().packets[0].aboard and not s.blackwater_delivery_status().complete,"one actual local transfer puts only that carried packet aboard Quietus")
 check(not s.command("blackwater_handoff",{"carrier":1}) and s.blackwater_delivery_status().cargo[0]==[0],"repeated handoff cannot duplicate a packet or completion credit")
 s.units[2].pos=s.units[0].pos+Vector2(0,-30);s.units[2].vel=Vector2.ZERO;s.command("select",{"unit":2})
 var routes=s.units.map(func(u):return u.route.duplicate(true));var holds=s.units.map(func(u):return u.hold)
 check(s.command("blackwater_handoff",{"carrier":2}) and s.blackwater_delivery_status().complete and s.units.map(func(u):return u.route)==routes and s.units.map(func(u):return u.hold)==holds,"explicit local transfer finishes delivery without rewriting routes or holds")
 tick(s,Sim.STEP)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"normal recovery completes only after actual exchange reaches home Quietus with valid current state")
 var solo=Sim.new();solo.start(2);check("retained" not in solo.blackwater_delivery_status().text,"fresh operation status does not claim unrecorded field notes");solo.sirens=[];solo.units[1].alive=false;solo.units[2].alive=false
 for site in [0,1]:
  solo.units[0].pos=solo.mission.objectives[site].pos+Vector2(0,130);solo.units[0].vel=Vector2.ZERO
  check(solo.command("camera"),"Quietus-only actual fixed receiver SAMPLE remains available")
  tick(solo,2.1)
 check(solo.blackwater_delivery_status().complete and solo.all_records() and solo.mission.courier_launch>=0,"Quietus directly carries both genuine samples and REQUEST still launches the accepted glider")
 loss_and_resample();combined_wreck();glider_buffer();data_winch_and_save();physical_return();handoff_guards();concurrent_delivery()
 finish()
