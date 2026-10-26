extends RefCounted
# Global sight floor only; no guard stamps or hidden knowledge are written.
# Revert Table.enabled=false. Old saves without the optional field stay inactive.
# Keep optional-state validation enabled after any display/rule revert.
const Table=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
static func initialize(m:Dictionary)->void:
 if Table.enabled:m["hunt_pressure"]={"revision":Table.REVISION,"stage":0,"seen":false,"cause":"LAUNCH","cue_at":-Table.CUE_INTERVAL,"pending":false,"stage_cause":"LAUNCH"}
static func active(m:Dictionary)->bool:
 return Table.enabled and m.get("hunt_pressure") is Dictionary and m.hunt_pressure.get("revision")==Table.REVISION
static func stage(m:Dictionary)->int:
 var hunt:float=m.get("reconnaissance",{}).get("hunt",0.)
 var index=0
 for threshold in Table.THRESHOLDS:
  if hunt>=threshold:index+=1
 return index
static func view_mission(m:Dictionary)->Dictionary:
 var index=stage(m);var id=int(m.get("id",-1))
 var cap:float=Table.CAPS[id] if id>=0 and id<Table.CAPS.size() else 1.
 var on=active(m);var p:Dictionary=m.get("reconnaissance",{})
 var cause:String=m.get("hunt_pressure",{}).get("cause","ACTIVITY")
 return {"active":on,"hunt":float(p.get("hunt",0.)),"floor":float(p.get("floor",0.)),"index":index,"stage":Table.STAGES[index],"cap":cap,"scale":minf(Table.SCALES[index],cap) if on else 1.,"cause":Table.CAUSES.get(cause,"own activity"),"change_cause":Table.CAUSES.get(m.get("hunt_pressure",{}).get("stage_cause",cause),"own activity")}
static func view(sim)->Dictionary:return view_mission(sim.mission)
static func sight(m:Dictionary,guard:Dictionary,local:float)->float:
 if not active(m) or guard.get("type","") not in Table.ROLES:return local
 return maxf(local,view_mission(m).scale)
static func action_amount(m:Dictionary,label:String,legacy:float)->float:
 return float(Table.ACTIONS.get(label,legacy)) if active(m) else legacy
static func note(m:Dictionary,cause:String)->void:
 if active(m):
  m.hunt_pressure.cause=cause if Table.CAUSES.has(cause) else "ACTIVITY"
  m.hunt_pressure.pending=true
static func _seeing(sim)->bool:
 for guard in sim.sirens:
  var target=int(guard.get("target",-1))
  if target<0 or target>=sim.units.size() or guard.get("recipient_target",false):continue
  if guard.get("stun",0.)>0 or not sim.units[target].alive:continue
  if guard.get("lock",0.)>0 and guard.get("mode","") in ["LOCKING","BEAM"]:return true
 return false
static func observe(sim,_dt:float)->void:
 if not active(sim.mission):return
 var p:Dictionary=sim.mission.hunt_pressure
 var seen=_seeing(sim)
 # Observe the previous completed threat step, never run a second sensing pass.
 if seen and not p.seen:sim.Recon.action(sim.mission,Table.SIGHT_EDGE,"NEW SIGHT")
 p.seen=seen
 var next=stage(sim.mission)
 if next!=p.stage:p.stage_cause="COOLING" if next<p.stage else (p.get("cause","ACTIVITY") if p.get("pending",false) else "TIME")
 p.pending=false
 if next>p.stage and sim.elapsed-float(p.get("cue_at",-Table.CUE_INTERVAL))>=Table.CUE_INTERVAL:
  sim.events.append({"type":"hunt_stage","stage":next,"cause":p.get("stage_cause","ACTIVITY")})
  p.cue_at=sim.elapsed
 p.stage=next
static func ambience_offset(m:Dictionary)->float:
 if not active(m):return 0.
 var value:float=Table.AMBIENCE_DB[stage(m)]
 return minf(value,Table.EARLY_AMBIENCE_CAP) if int(m.get("id",-1)) in range(6) else value
static func _number(value:Variant,low:float,high:float)->bool:
 return (value is float or value is int) and is_finite(value) and value>=low and value<=high
static func valid(m:Dictionary,elapsed:float=INF)->bool:
 if not m.has("hunt_pressure"):return true
 var p=m.hunt_pressure
 if not p is Dictionary:return false
 if not p.get("revision") is int or p.revision!=Table.REVISION:return false
 if not p.get("stage") is int or p.stage<0 or p.stage>=Table.STAGES.size():return false
 if not p.get("seen") is bool:return false
 if p.has("cause") and (not p.cause is String or not Table.CAUSES.has(p.cause)):return false
 if p.has("pending") and not p.pending is bool:return false
 if p.has("stage_cause") and (not p.stage_cause is String or not Table.CAUSES.has(p.stage_cause)):return false
 if p.has("cue_at") and not _number(p.cue_at,-Table.CUE_INTERVAL,elapsed):return false
 var pressure=m.get("reconnaissance",{"hunt":0.,"floor":0.,"delay":0.,"secured":[]})
 if not pressure is Dictionary:return false
 if not _number(pressure.get("hunt"),0.,100.) or not _number(pressure.get("floor"),0.,100.):return false
 if pressure.hunt<pressure.floor or not _number(pressure.get("delay"),0.,6.):return false
 var secured=pressure.get("secured")
 if not secured is Array:return false
 var indices=[]
 for index in secured:
  if not index is int or index<0 or index in indices:return false
  indices.append(index)
 return true
