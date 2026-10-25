extends RefCounted
# Optional presentation history belongs to the active archive, never Simulation.
# Revert: remove these archive calls/validation; absent history is always valid.
const FIELD="first_siren_seen"
const TYPES="first_siren_types"
const Table=preload("res://src/presentation/first_siren_cue/cue_table.gd")
static func valid_types(data:Dictionary)->bool:
 if not data.has(TYPES):return true
 var kinds=data[TYPES]
 if not kinds is Array or kinds.size()>Table.NOTE_LIMIT:return false
 var seen=[]
 for kind in kinds:
  if not kind is String or kind.is_empty() or kind.length()>32 or kind in seen:return false
  seen.append(kind)
 return true
static func valid(data:Dictionary)->bool:
 if not valid_types(data):return false
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
 var kinds=cue.tracker.saved_types()
 if not kinds.is_empty():data[TYPES]=kinds
static func restore(host,data:Dictionary)->void:
 var cue=host.hud.get_node_or_null("FirstSirenCue")
 if cue==null:return
 cue.tracker.restore_seen(data.get(FIELD,[]));cue.voice.stop()
# Types seen are campaign wide, so they restore even when no dive is active.
static func restore_types(host,data:Dictionary)->void:
 var cue=host.hud.get_node_or_null("FirstSirenCue")
 if cue==null:return
 cue.tracker.restore_types(data.get(TYPES,[]) if data.get(TYPES,[]) is Array else [])
