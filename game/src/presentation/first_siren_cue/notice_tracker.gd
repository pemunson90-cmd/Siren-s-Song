extends RefCounted
signal noticed(row:Dictionary)
# D1 observer only: never writes simulation, contacts, saves or detection state.
# Revert with cue_table.enabled=false; the unconsumed notice signal has no effect.
const Table=preload("res://src/presentation/first_siren_cue/cue_table.gd")
var sim
var mission_ref:Dictionary={}
var clock=-1.
var seen:Dictionary={}
var records:Array=[]
var note_records:Array=[]
var types_seen:Array=[]
func bind(source)->void:
 unbind();sim=source;mission_ref=sim.mission;clock=sim.elapsed
 sim.siren_notice.connect(_notice)
func unbind()->void:
 if sim!=null and sim.siren_notice.is_connected(_notice):sim.siren_notice.disconnect(_notice)
 sim=null;seen.clear();records.clear();note_records.clear();mission_ref={};clock=-1.
func _observe_clock()->void:
 if not is_same(mission_ref,sim.mission) or sim.elapsed<clock:
  seen.clear();records.clear();note_records.clear();mission_ref=sim.mission
 clock=sim.elapsed
func _notice(id:int,source:Vector2)->void:
 _observe_clock()
 if not Table.enabled or not source.is_finite() or sim.units.is_empty():return
 var listed=sim.mission.get("id",-1) in Table.OPERATIONS
 if listed and seen.has(id):return
 _note_type(id)
 if not listed:return
 var direction=(source-sim.units[sim.selected].pos).normalized()
 seen[id]=true
 var row={"id":id,"unit":sim.selected,"time":sim.elapsed,"direction":direction,"bearing":fposmod(rad_to_deg(atan2(direction.x,-direction.y)),360.)}
 records.append(row);noticed.emit(row)
# One-time kind note: reads only the public sirens[id].type, adds no sim field.
func _note_type(id:int)->void:
 if id<0 or id>=sim.sirens.size():return
 var kind=str(sim.sirens[id].get("type","patroller"))
 if not Table.TYPE_NAMES.has(kind) or kind in types_seen:return
 types_seen.append(kind)
 note_records.append({"id":id,"time":sim.elapsed,"type":kind,"text":Table.NOTE_PREFIX+Table.TYPE_NAMES[kind]})
func notes()->Array:
 if sim==null:return []
 _observe_clock()
 if not Table.enabled:return []
 return note_records.filter(func(row):return sim.elapsed>=row.time and sim.elapsed-row.time<Table.NOTE_DURATION)
func saved_types()->Array:
 return types_seen.duplicate()
func restore_types(kinds:Array)->void:
 types_seen.clear()
 for kind in kinds:
  if kind is String and Table.TYPE_NAMES.has(kind) and kind not in types_seen:types_seen.append(kind)
func saved_seen()->Array:
 _observe_clock()
 return seen.keys()
func restore_seen(ids:Array)->void:
 _observe_clock();seen.clear();records.clear()
 for id in ids:seen[id]=true
func frames()->Array:
 if sim==null:return []
 _observe_clock()
 if not Table.enabled or sim.mission.get("id",-1) not in Table.OPERATIONS:return []
 return records.filter(func(row):return sim.elapsed>=row.time and sim.elapsed-row.time<Table.DURATION)
