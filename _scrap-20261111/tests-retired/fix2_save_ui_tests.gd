extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 5:await process_frame
func clear_owned(path:String):
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
 DirAccess.remove_absolute(path.get_base_dir())
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720)
 var g=load("res://scenes/main.tscn").instantiate();g.store.path="user://fix2-save-ui-initial.save"
 root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle()
 var transient="user://fix2-transient/quietus.save";clear_owned(transient)
 g.store.path=transient;g.sim.message="Orders remain available";g._save_archive()
 check(g.save_error.is_empty() and not g.archive_status.visible and g.sim.message=="Orders remain available","a first write failure does not scare the player before retry")
 DirAccess.make_dir_recursive_absolute(transient.get_base_dir())
 await settle()
 check(FileAccess.file_exists(transient) and g.save_error.is_empty() and not g.archive_status.visible,"the deferred retry writes when storage is available again")
 var persistent="user://fix2-persistent/quietus.save";clear_owned(persistent)
 g.store.path=persistent;g._save_archive()
 check(g.save_error.is_empty(),"a new failure waits for confirmation before showing an error")
 await settle()
 check(not g.save_error.is_empty() and g.archive_status.visible and g.save_retry_button.visible,"a repeated real write failure remains visible and retryable")
 g.queue_free();await settle()
 clear_owned(transient);clear_owned(persistent)
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://fix2-save-ui-initial.save"+suffix)
 print("FIX2 SAVE UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
