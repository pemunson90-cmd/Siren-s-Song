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
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(host.store.path+suffix)
 print("SAVE2 FORKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
