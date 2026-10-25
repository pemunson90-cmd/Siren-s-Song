extends SceneTree
const Path="res://src/persistence/save_states/save2_controller.gd"
const Store=preload("res://src/persistence/save_store.gd")
const Table=preload("res://src/persistence/save_states/save2_table.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
class Host extends RefCounted:
 var completed=[0,1,2,3,4,5]
 var expedition={}
 var active_started=false
 var sim={"outcome":"","mission":{"id":0}}
 var archive_warning=""
 var capture_scenario=""
 var store=load("res://src/persistence/save_store.gd").new()
 func _campaign_completed():return completed+expedition.get("completed",[])
 func _archive():
  var data={"version":2,"unlocked":5,"completed":completed.duplicate(),"settings":{},"upgrade":"endurance","expedition":expedition.duplicate(true)}
  load("res://src/persistence/save_states/save2_controller.gd").write(self,data)
  return data
func _initialize():call_deferred("run")
func run():
 if not ResourceLoader.exists(Path):
  check(false,"fork controller exists");print("SAVE2 FORKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1);return
 var C=load(Path)
 var fields=[["route",{"route":"deep"}],["thread",{"selected_thread":"deep"}],["confluence",{"facts":{"confluence_route":"concealed"}}],["glass",{"facts":{"glass_choice":"salvage"}}],["choir_choice",{"facts":{"choir_choice":"bypass"}}],["choir_people",{"facts":{"choir_people":"landed"}}],["choir_plant",{"facts":{"choir_plant":"reconnect"}}]]
 for row in fields:
  var before={};var after:Dictionary=row[1].duplicate(true);var saved=after.duplicate(true)
  check(row[0] in C.events(before,after),"first committed "+row[0]+" is a fork")
  check(C.events(after,after).is_empty() and after==saved,"replaying "+row[0]+" neither duplicates nor mutates progress")
 var ending={"selected_thread":"deep","route":"deep","facts":{"confluence_route":"concealed"},"completed":[12]}
 check("first_ending" in C.events({},ending),"first old ending has its own pre-choice state")
 check(C.events(ending,ending).is_empty(),"already resolved ending is not a new fork")
 seed(814);var expected=randf();seed(814)
 var initial=C.initial_state({"completed":[0,1],"expedition":{"completed":[6]}})
 check(randf()==expected,"snapshot identity generation leaves gameplay RNG untouched")
 check(initial.recoveries==3 and initial.legacy_minimum,"legacy recovery count is an honestly labeled known minimum")
 var host=Host.new();host.store.path="user://save2-fork-live.save"
 var manager=C.manager(host)
 manager.delete_all(true)
 var prior=host._archive();var prior_copy=prior.duplicate(true)
 check(Store.new().valid(prior),"prelaunch source is a valid ordinary campaign archive")
 host.capture_scenario="challenge-session";C.before_launch(host,6)
 check(manager.inspect("pending",0).status=="empty","isolated challenge/capture sessions do not create campaign fork files")
 host.capture_scenario=""
 C.before_launch(host,6)
 var pending=manager.inspect("pending",0)
 check(pending.status=="ready" and pending.data==prior_copy,"pending checkpoint is the full state before launch mutation")
 host.active_started=true;host.sim={"outcome":"lost","mission":{"id":6}}
 C.terminal(host);C.recovered(host,{})
 check(manager.list_entries("fork").all(func(e):return e.status=="empty"),"failed dive never publishes a fork state")
 host.active_started=false;C.before_launch(host,6)
 var snapshot=manager.inspect("pending",0).data.duplicate(true)
 host.sim={"outcome":"won","mission":{"id":6}};host.active_started=true
 host.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Observed carrier"},"completed":[6],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":""}
 C.terminal(host);var counted=C.ensure_state(host).recoveries;C.terminal(host)
 check(C.ensure_state(host).recoveries==counted,"repeated debrief credits one successful launch only")
 C.recovered(host,{})
 var forks=manager.list_entries("fork").filter(func(e):return e.status=="ready")
 check(forks.size()==1 and forks[0].record.event=="route","successful first route publishes one labeled fork")
 if not forks.is_empty():check(forks[0].data==snapshot and forks[0].data.get("expedition",{}).is_empty(),"published route state predates committed route and keeps the exact full archive")
 C.recovered(host,host.expedition)
 check(manager.list_entries("fork").filter(func(e):return e.status=="ready").size()==1,"ordinary repeat debrief does not duplicate the checkpoint")
 var archived=host._archive();var other=Host.new();other.completed=host.completed.duplicate();other.expedition=host.expedition.duplicate(true);other.active_started=true
 C.restore(other,archived)
 check(not other.active_started and C.ensure_state(other)==archived[Table.STATE],"between-dive saved metadata restores without inventing a Resume dive")
 var before_off=C.ensure_state(host).duplicate(true);Table.enabled=false;C.terminal(host)
 check(C.ensure_state(host)==before_off and not C.manual_allowed(host),"off switch preserves stored state and hides new save behavior")
 Table.enabled=true;C.reset(host)
 check(C.ensure_state(host).recoveries==0 and C.ensure_state(host).run_id!=before_off.run_id,"new campaign resets tracking without deleting saved states")
 check(manager.list_entries("fork").filter(func(e):return e.status=="ready").size()==1,"reset preserves existing fork sidecars")
 manager.delete_all(true)
 # A committed checkpoint that failed to publish must survive the next launch.
 var Txn=load("res://src/persistence/save_states/save2_transaction.gd")
 host.expedition={};host.active_started=false;host.sim={"outcome":"","mission":{"id":0}};C.reset(host)
 C.before_launch(host,6)
 host.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Observed carrier"},"completed":[6],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":""}
 host.active_started=true;host.sim={"outcome":"won","mission":{"id":6}};C.terminal(host)
 Txn.test_failures=["stage"];C.recovered(host,{})
 var pending_token=manager.inspect("pending",0).token
 var held_state=C.ensure_state(host).duplicate(true)
 check(manager.inspect("pending",0).status=="ready" and manager.list_entries("fork").all(func(e):return e.status=="empty"),"failed fork publication preserves the complete pending checkpoint")
 Txn.test_failures=["stage"]
 check(C.before_launch(host,9)==false,"another failed publication defers launch instead of discarding the committed checkpoint")
 check(C.ensure_state(host)==held_state and manager.inspect("pending",0).token==pending_token,"deferred launch preserves candidate bytes and run/launch identity")
 Txn.test_failures=[]
 for index in 4:
  var file=FileAccess.open(manager.entry_path("fork",index),FileAccess.WRITE);file.store_buffer(PackedByteArray([1,2,3]));file.close()
 check(C.before_launch(host,9)==false and C.ensure_state(host)==held_state,"all unreadable fork slots defer launch without discarding the committed checkpoint")
 var damaged=manager.inspect("fork",0)
 check(manager.delete_entry("fork",0,true,damaged.token),"explicit confirmed deletion frees a fork slot for recovery")
 check(C.before_launch(host,9)==true,"next launch retries the committed checkpoint after storage recovers")
 check(not host.has_meta("save2_banner") and not host.has_meta("save2_notice"),"successful retry clears the stale launch-paused notice")
 check(manager.list_entries("fork").any(func(e):return e.status=="ready" and e.record.event=="route"),"retry publishes the first committed route before preparing the next choice")
 manager.delete_all(true)
 # Cold restore is the other retry boundary. Reject unrelated run/launch IDs.
 host.expedition={};host.active_started=false;host.sim={"outcome":"","mission":{"id":0}};C.reset(host);C.before_launch(host,6)
 host.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Observed carrier"},"completed":[6],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":""}
 host.active_started=true;host.sim={"outcome":"won","mission":{"id":6}};C.terminal(host)
 var recovered_archive=host._archive().duplicate(true)
 var cold=Host.new();cold.store.path=host.store.path;cold.expedition=host.expedition.duplicate(true)
 var wrong=recovered_archive.duplicate(true);wrong[Table.STATE].run_id=Table.identity();C.restore(cold,wrong)
 check(manager.list_entries("fork").all(func(e):return e.status=="empty"),"cold restore refuses a pending checkpoint from a different campaign run")
 wrong=recovered_archive.duplicate(true);wrong[Table.STATE].launch_id=Table.identity();C.restore(cold,wrong)
 check(manager.list_entries("fork").all(func(e):return e.status=="empty"),"cold restore refuses a pending checkpoint from a different launch")
 C.restore(cold,recovered_archive)
 check(manager.list_entries("fork").any(func(e):return e.status=="ready" and e.record.event=="route") and manager.inspect("pending",0).status=="empty","cold restore publishes a matching committed checkpoint and clears pending only after success")
 manager.delete_all(true)
 host.expedition={};host.active_started=false;host.sim={"outcome":"","mission":{"id":0}};C.reset(host);C.before_launch(host,6)
 host.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Observed carrier"},"completed":[6],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":""}
 host.active_started=true;host.sim={"outcome":"won","mission":{"id":6}};C.terminal(host)
 held_state=C.ensure_state(host).duplicate(true)
 Txn.test_failures=["commit_1","rollback","rollback","rollback","rollback"]
 C.recovered(host,{})
 check(FileAccess.file_exists(manager.directory+"/transaction"),"failed publication rollback retains its recovery journal")
 check(C.before_launch(host,9)==false and C.ensure_state(host)==held_state,"unavailable transaction recovery blocks launch without orphaning the checkpoint")
 Txn.test_failures=[]
 check(C.before_launch(host,9)==true and manager.list_entries("fork").any(func(e):return e.status=="ready" and e.record.event=="route"),"launch recovers the journal and publishes the checkpoint after filesystem repair")
 manager.delete_all(true)
 var count_before_replay=C.ensure_state(host).recoveries
 C.before_launch(host,6);host.sim={"outcome":"won","mission":{"id":6}};C.terminal(host);C.recovered(host,host.expedition.duplicate(true))
 check(C.ensure_state(host).recoveries==count_before_replay+1 and C.ensure_state(host).last_recovered==6,"successful replay counts as another recovered operation and records its actual ID")
 check(manager.list_entries("fork").all(func(e):return e.status=="empty"),"successful replay never invents another first-choice checkpoint")
 C.before_launch(host,6);host.sim={"outcome":"lost","mission":{"id":6}};C.terminal(host)
 check(C.ensure_state(host).recoveries==count_before_replay+1,"lost replay never increments recovered-operation play count")
 host.archive_warning="Existing unrelated archive warning"
 var long_notice="A checkpoint needs storage recovery. ".repeat(30)
 C.notice(host,long_notice);C.notice(host,long_notice+"Retry remains available.")
 check(host.archive_warning.split("\n").size()==2 and host.archive_warning.begins_with("Existing unrelated archive warning\n"),"repeated SAVE2 notices retain other warnings and one short fixed banner only")
 check(host.get_meta("save2_notice")==long_notice+"Retry remains available." and not long_notice in host.archive_warning,"complete recovery details remain available without expanding the fixed archive banner")
 C.notice(host,"Hard save written.",false)
 check(host.archive_warning=="Existing unrelated archive warning" and host.get_meta("save2_notice")=="Hard save written.","successful saved-state actions clear their own banner while preserving unrelated archive warnings")
 var off=Host.new();off.store.path="user://save2-off-live.save";off.active_started=false
 var tracked=off._archive()[Table.STATE].duplicate(true)
 tracked.legacy_minimum=false;tracked.last_recovered=5;tracked.credited_launch=tracked.launch_id;off.set_meta(Table.STATE,tracked.duplicate(true))
 off.active_started=true;Table.enabled=false
 var disabled_archive=off._archive()
 check(not disabled_archive[Table.STATE].between,"disabled writes keep the existing between-dive marker aligned with the actual unfinished dive")
 check(disabled_archive[Table.STATE].legacy_minimum and disabled_archive[Table.STATE].last_recovered==-1 and disabled_archive[Table.STATE].recoveries==tracked.recoveries,"disabled tracking marks its recovery count as a retained minimum and last recovery as unknown")
 check(disabled_archive[Table.STATE].launch_id!=tracked.launch_id and disabled_archive[Table.STATE].credited_launch=="" and disabled_archive[Table.STATE].run_id==tracked.run_id,"disabled writes invalidate the old pending launch binding without remapping the campaign")
 Table.enabled=true
 var resumed=Host.new();resumed.active_started=true;C.restore(resumed,disabled_archive)
 check(resumed.active_started,"re-enabling SAVE2 preserves an unfinished dive instead of hiding Resume")
 check(C.manager(off).list_entries("fork").all(func(e):return e.status=="empty") and C.manager(off).inspect("pending",0).status=="empty","disabled bookkeeping creates no fork or pending files")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(host.store.path+suffix)
 print("SAVE2 FORKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
