extends Node
# Retire queued writes before exact replacement; free the old host only after
# the validated disk transaction succeeds. Revert through Table.enabled=false.
const Controller=preload("res://src/persistence/save_states/save2_controller.gd")
static func restore(host,kind:String,index:int,token:String)->bool:
 if host.store.suspended:return false
 var storage=Controller.manager(host)
 if host.store.uses_profiles():
  var profiles=load("res://src/persistence/profiles/profile_store.gd").new()
  if not profiles.open() or profiles.slot_path(profiles.state.active)!=host.store.path:
   host.set_meta("save2_session_error","Profile selection changed. No saved campaign was replaced.");return false
 var process=host.is_processing();var physics=host.is_physics_processing();var mode=host.process_mode
 host.store.suspended=true;host.save_retry_pending=false;host.set_process(false);host.set_physics_process(false);host.process_mode=Node.PROCESS_MODE_DISABLED
 if not storage.load_entry(kind,index,host.store,true,token):
  host.store.suspended=false;host.process_mode=mode;host.set_process(process);host.set_physics_process(physics)
  host.set_meta("save2_session_error",storage.warning);Controller.notice(host,storage.warning);return false
 if host.sound!=null:host.sound.suspend()
 var runner=load("res://src/persistence/save_states/save2_session.gd").new()
 host.get_tree().root.add_child(runner);runner.call_deferred("_replace",host)
 return true
func _replace(old)->void:
 if not is_instance_valid(old):queue_free();return
 var parent=old.get_parent();var script=old.get_script();var was_current=get_tree().current_scene==old
 var location=old.store.path;var managed=old.store.uses_profiles();var settings=old.settings_path
 var safe=null
 if old.get_property_list().any(func(p):return p.name=="fixture_safe_area"):safe=old.get("fixture_safe_area")
 parent.remove_child(old);old.free()
 var fresh=load("res://scenes/main.tscn").instantiate();fresh.set_script(script)
 fresh.store.pin_path(location,managed);fresh.settings_path=settings;fresh.capture_scenario=""
 if safe!=null:fresh.set("fixture_safe_area",safe)
 fresh.set_meta("save2_replaced",true);parent.add_child(fresh)
 if was_current:get_tree().current_scene=fresh
 var front=fresh.get_node_or_null("Frontend")
 if front!=null:front._continue()
 fresh._show_campaign();Controller.notice(fresh,"Saved state loaded exactly. Later film and fittings were replaced.")
 queue_free()
