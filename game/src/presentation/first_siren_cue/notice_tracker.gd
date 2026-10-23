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
func bind(source)->void:
 unbind();sim=source;mission_ref=sim.mission;clock=sim.elapsed
 sim.siren_notice.connect(_notice)
func unbind()->void:
 if sim!=null and sim.siren_notice.is_connected(_notice):sim.siren_notice.disconnect(_notice)
 sim=null;seen.clear();records.clear();mission_ref={};clock=-1.
func _observe_clock()->void:
 if not is_same(mission_ref,sim.mission) or sim.elapsed<clock:
  seen.clear();records.clear();mission_ref=sim.mission
 clock=sim.elapsed
func _notice(id:int,source:Vector2)->void:
 _observe_clock()
 if not Table.enabled or sim.mission.get("id",-1) not in Table.OPERATIONS or seen.has(id):return
 if not source.is_finite() or sim.units.is_empty():return
 var direction=(source-sim.units[sim.selected].pos).normalized()
 seen[id]=true
 var row={"id":id,"time":sim.elapsed,"direction":direction,"bearing":fposmod(rad_to_deg(atan2(direction.x,-direction.y)),360.)}
 records.append(row);noticed.emit(row)
func frames()->Array:
 if sim==null:return []
 _observe_clock()
 if not Table.enabled or sim.mission.get("id",-1) not in Table.OPERATIONS:return []
 return records.filter(func(row):return sim.elapsed>=row.time and sim.elapsed-row.time<Table.DURATION)
