extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Program=preload("res://src/simulation/route_program.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func advance(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
func fresh(fitted:Dictionary={"quietus":"","drone_a":"drone_sampler","drone_b":"drone_deep_cells"}):
 var s=Sim.new();s.start(0,"endurance",{"fitted":fitted,"fleet_commit":true});s.sirens=[];s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
 s.units[1].pos=Vector2(300,800);s.units[2].pos=Vector2(500,800)
 return s
func finish()->void:
 print("MODULE RECOVERY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func _initialize():
 var s=fresh();var loss_pos=s.units[1].pos;s.units[1].battery=0;advance(s,Sim.STEP)
 check(s.has_method("salvage_sites") and not s.salvage_sites().is_empty(),"actual battery loss of a fitted drone leaves its known physical module")
 if not s.has_method("salvage_sites"):finish();return
 var sites=s.salvage_sites();check(sites.size()==1 and sites[0].item=="drone_sampler" and sites[0].pos==loss_pos,"salvage reports only the launched module at the last own-craft position")
 s.units[1].pos+=Vector2(100,0);advance(s,.5)
 check(s.salvage_sites()==sites,"dead carrier drops its installed module exactly once")
 check(not s.salvage_context("drone_sampler",0).ready,"distant craft cannot recover remote salvage")
 s.units[0].pos=loss_pos+Vector2(50,0);s.units[0].vel=Vector2(3,0)
 check(not s.command("salvage",{"item":"drone_sampler"}),"moving craft must settle before starting the winch")
 s.units[0].vel=Vector2.ZERO;s.mission.structures=[Rect2(320,770,10,60)];s._build_navigation()
 check(not s.salvage_context("drone_sampler").ready,"local recovery respects physical line of sight")
 s.mission.structures=[];s._build_navigation();s.command("route",{"point":Vector2(450,800)});var goals=s.route_goals()
 check(s.command("salvage",{"item":"drone_sampler"}) and s.units[0].hold=="HOLD" and s.noises.any(func(n):return n.label=="RECOVERY WINCH" and n.radius==520),"explicit local winch holds the accepted route and emits real audible noise")
 var snap=s.snapshot();s.paused=true;snap=s.snapshot();s.advance(20)
 check(s.snapshot()==snap,"pause freezes module position and retrieval work")
 var restored=Sim.new();check(restored.restore(bytes_to_var(var_to_bytes(snap))),"active salvage restores through current binary simulation save")
 advance(s,2);advance(restored,2)
 check(s.module_recovery_status().jobs[0].elapsed>1.9 and s.module_recovery_status().result.is_empty(),"four-second retrieval is genuine held work rather than instant refitting")
 check(restored.module_recovery_status()==s.module_recovery_status() and restored.units==s.units,"restored winch continues with the same physical work and carriers")
 advance(s,2.1)
 check(s.salvage_sites().is_empty() and "drone_sampler" in s.module_recovery_status().cargo[0] and not s.units[1].alive and s.mission.launch_equipment.quietus=="","completed recovery moves one inert module to Quietus without resurrection or fitting")
 check(s.route_goals()==goals,"recovery completion retains the route program")
 # The surviving drone can rescue a module; its subsequent loss drops both only once.
 var relay=fresh();relay.units[1].battery=0;advance(relay,Sim.STEP);relay.units[2].pos=Vector2(340,800);relay.command("select",{"unit":2})
 check(relay.command("salvage",{"item":"drone_sampler"}),"surviving fitted drone can explicitly recover another drone's module")
 advance(relay,4.1);relay.units[2].battery=0;var relay_pos=relay.units[2].pos;advance(relay,Sim.STEP);advance(relay,.2)
 check(relay.salvage_sites().size()==2 and relay.salvage_sites().all(func(site):return site.pos==relay_pos) and relay.module_recovery_status().cargo[2].is_empty(),"carrier loss drops its installed module and salvaged cargo once at its own position")
 # Replacement interrupts work and neither spends nor duplicates salvage.
 var cancel=fresh();cancel.units[1].battery=0;advance(cancel,Sim.STEP);cancel.units[0].pos=Vector2(350,800);cancel.command("salvage",{"item":"drone_sampler"});advance(cancel,1);cancel.command("route",{"point":Vector2(600,800)});advance(cancel,Sim.STEP)
 check(cancel.module_recovery_status().jobs[0].is_empty() and cancel.salvage_sites().size()==1 and cancel.units[0].hold=="","route replacement cancels retrieval without deleting its physical module")
 # Departure waits for meaningful hardware only, and deferral survives RUN.
 var depart=fresh();for o in depart.mission.objectives:o.captured=true
 depart.units[0].pos=depart.mission.extraction;depart.units[0].vel=Vector2.ZERO;advance(depart,Sim.STEP)
 var context=depart.departure_context()
 check(depart.outcome.is_empty() and context.available and context.pending and context.confirmation_required and context.left.size()==2 and not depart.paused,"unrecovered equipped drones require an explicit real departure decision without automatic pause")
 var read_before=depart.snapshot();depart.departure_context();depart.salvage_sites();depart.module_recovery_status()
 check(depart.snapshot()==read_before,"public recovery and departure projections never mutate state")
 check(depart.command("depart",{"confirm":false}) and not depart.departure_context().pending,"keep recovering explicitly defers the pending confirmation")
 advance(depart,.3);check(not depart.departure_context().pending and depart.outcome.is_empty(),"RUN with Quietus waiting in the mouth does not reopen the same confirmation every tick")
 var defer_copy=Sim.new();check(defer_copy.restore(depart.snapshot()) and not defer_copy.departure_context().pending,"deferred recovery choice survives save and restore")
 depart.units[0].pos+=Vector2(100,0);advance(depart,Sim.STEP)
 check(not depart.command("depart",{"confirm":true}),"departure confirmation cannot extract Quietus outside the actual mouth")
 depart.units[0].pos=depart.mission.extraction;depart.units[0].vel=Vector2.ZERO;advance(depart,Sim.STEP)
 check(depart.departure_context().pending and depart.command("depart",{"confirm":true}) and depart.outcome=="won","re-entering recovery asks again and explicit departure completes the ordinary objective")
 check(depart.module_recovery_status().result.lost==["drone_sampler","drone_deep_cells"],"departure records only actually launched modules left behind")
 var bare=fresh({"quietus":"","drone_a":"","drone_b":""});for o in bare.mission.objectives:o.captured=true
 advance(bare,Sim.STEP);check(bare.outcome=="won" and bare.module_recovery_status().result.lost.is_empty(),"unfitted drones remain expendable and never force whole-fleet shepherding")
 var all_home=fresh();for o in all_home.mission.objectives:o.captured=true
 all_home.units[1].pos=all_home.mission.extraction+Vector2(20,0);all_home.units[2].pos=all_home.mission.extraction+Vector2(-20,0);advance(all_home,Sim.STEP)
 check(all_home.outcome=="won" and all_home.module_recovery_status().result.recovered.size()==2,"ordinary extraction automatically keeps physically recovered fitted modules")
 # Campaign commit is deliberately separate from field observations and replay.
 var Fleet=load("res://src/campaign/fleet_inventory.gd");var earned=["drone_sampler","drone_deep_cells","quietus_baffles"]
 var inventory=Fleet.recover({},depart.mission,depart.outcome)
 check(Fleet.available(earned,inventory)==["quietus_baffles"] and Fleet.available(earned,{})==earned,"first successful departure removes lost physical modules while preserving historical entitlements")
 check(Fleet.recover(inventory,all_home.mission,"won")==inventory and Fleet.recover({},depart.mission,"lost").is_empty(),"repeat completion and failed retry cannot duplicate stock or rewrite committed loss")
 var replay=depart.mission.duplicate(true);replay.fleet_commit=false
 check(Fleet.recover({},replay,"won").is_empty(),"completed-operation replay cannot commit inventory changes")
 var fit={"quietus":"quietus_baffles","drone_a":"drone_sampler","drone_b":""}
 check(not Fleet.launch(fit,earned,inventory,1,[0]).ok and Fleet.launch(Fleet.reconcile_fitting(fit,Fleet.available(earned,inventory)),earned,inventory,0,[0]).launch.fleet_commit==false,"live launch rejects missing modules while bare replacements and noncommitting replay remain available")
 check(Fleet.valid(inventory,earned,[0]) and Sim.valid_snapshot(s.snapshot()),"committed inventory and salvage simulation remain valid current-format data")
 finish()
