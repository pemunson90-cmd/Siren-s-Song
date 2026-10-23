extends RefCounted
# Optional presentation history belongs to the active archive, never Simulation.
# Revert: remove these archive calls/validation; absent history is always valid.
const FIELD="first_siren_seen"
static func valid(data:Dictionary)->bool:
 if not data.has(FIELD):return true
 var ids=data[FIELD];var active=data.get("active",{})
 if not ids is Array or not active is Dictionary or not active.get("sirens") is Array:return false
 var seen=[]
 for id in ids:
  if not id is int or id<0 or id>=active.sirens.size() or id in seen:return false
  seen.append(id)
 return true
static func write(host,data:Dictionary)->void:
 var cue=host.hud.get_node_or_null("FirstSirenCue")
 if cue==null:return
 var ids=cue.tracker.saved_seen()
 if not ids.is_empty():data[FIELD]=ids
static func restore(host,data:Dictionary)->void:
 var cue=host.hud.get_node_or_null("FirstSirenCue")
 if cue==null:return
 cue.tracker.restore_seen(data.get(FIELD,[]));cue.voice.stop()
