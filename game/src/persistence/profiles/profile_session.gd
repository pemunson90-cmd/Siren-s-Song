extends Node
# Runs outside the retired host. Pending retries are cancelled before any mutation;
# a suspended Store also rejects already-queued save callbacks after detachment.
static func handover(front, operation: Callable) -> void:
 var runner = load("res://src/persistence/profiles/profile_session.gd").new()
 front.get_tree().root.add_child(runner)
 runner.call_deferred("_replace",front,operation)
func _replace(front, operation: Callable) -> void:
 var old = front.host
 var parent = old.get_parent()
 var script = old.get_script()
 var was_current = get_tree().current_scene == old
 var model = front.profile_picker.model
 old.store.suspended = true
 old.save_retry_pending = false
 old.set_process(false);old.set_physics_process(false);old.process_mode = Node.PROCESS_MODE_DISABLED
 if old.sound != null:old.sound.suspend()
 parent.remove_child(old)
 # Immediate free discards every deferred callback and cached challenge record.
 old.free()
 var ok = operation.call()
 var fresh = load("res://scenes/main.tscn").instantiate()
 fresh.set_script(script)
 parent.add_child(fresh)
 if was_current:get_tree().current_scene = fresh
 var overlay = fresh.get_node_or_null("Frontend")
 if overlay != null:
  overlay.profile_picker.model = model
  overlay.profile_picker.notice = "Profile ready." if ok else model.warning
  overlay.profile_picker.show_picker()
 queue_free()
