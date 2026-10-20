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
 var lost=Observed.make();lost.sirens=[];lost.mission.blackwater_delivery.carriers=[[],[0],[1]]
 var position=lost.units[1].pos;lost.units[1].alive=false;tick(lost,Sim.STEP)
 var sites=lost.salvage_sites()
 check(sites.size()==1 and sites[0].item=="blackwater_buffer_1" and sites[0].pos==position and sites[0].packets==[0],"lost data carrier leaves one known own-position buffer wreck without erasing the field record")
 lost.units[0].pos=Vector2(760,330);lost.units[0].vel=Vector2.ZERO;lost.command("select",{"unit":0})
 check(lost.camera_context().ready and lost.command("camera"),"Quietus can reacquire an already recorded missing packet at the original receiver")
 tick(lost,2.1)
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
 var bad=before.duplicate(true);bad.mission.erase("blackwater_delivery")
 check(not Sim.valid_snapshot(bad),"current Blackwater save cannot delete physical delivery state")
 for value in [[],{}, {"aboard":[0,0],"carriers":[[],[],[]],"wrecks":{},"jobs":[{},{},{}]}]:
  bad=before.duplicate(true);bad.mission.blackwater_delivery=value
  check(not Sim.valid_snapshot(bad),"malformed or duplicated packet custody rejects cleanly")
func finish()->void:
 print("BLACKWATER DELIVERY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=Observed.make()
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
 s.units[2].pos=s.units[0].pos+Vector2(0,-30);s.units[2].vel=Vector2.ZERO;s.command("select",{"unit":2})
 var routes=s.units.map(func(u):return u.route.duplicate(true));var holds=s.units.map(func(u):return u.hold)
 check(s.command("blackwater_handoff",{"carrier":2}) and s.blackwater_delivery_status().complete and s.units.map(func(u):return u.route)==routes and s.units.map(func(u):return u.hold)==holds,"explicit local transfer finishes delivery without rewriting routes or holds")
 tick(s,Sim.STEP)
 check(s.outcome=="won" and Sim.valid_snapshot(s.snapshot()),"normal recovery completes only after actual exchange reaches home Quietus with valid current state")
 var solo=Sim.new();solo.start(2);solo.sirens=[];solo.units[1].alive=false;solo.units[2].alive=false
 for site in [0,1]:
  solo.units[0].pos=solo.mission.objectives[site].pos+Vector2(0,130);solo.units[0].vel=Vector2.ZERO
  check(solo.command("camera"),"Quietus-only actual fixed receiver SAMPLE remains available")
  tick(solo,2.1)
 check(solo.blackwater_delivery_status().complete and solo.all_records() and solo.mission.courier_launch>=0,"Quietus directly carries both genuine samples and REQUEST still launches the accepted glider")
 loss_and_resample();combined_wreck();glider_buffer();data_winch_and_save()
 finish()
