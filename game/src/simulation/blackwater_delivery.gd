extends RefCounted
# Raw exchange records remain with their own receiver until a local handoff.
# Field evidence is retained immediately; mission delivery has separate custody.
const RANGE=60.0
static func initial()->Dictionary:return {"aboard":[],"carriers":[[],[],[]],"wrecks":{},"jobs":[{},{},{}]}
static func applies(mission:Dictionary)->bool:return mission.id==2 and mission.has("blackwater_delivery")
static func complete(sim)->bool:return not applies(sim.mission) or (0 in sim.mission.blackwater_delivery.aboard and 1 in sim.mission.blackwater_delivery.aboard)
static func status(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.blackwater_delivery;var packets=[];var cargo=state.carriers.duplicate(true);cargo[0]=state.aboard.duplicate()
 for packet in 2:
  var carriers=[];var salvage=[]
  for id in [1,2]:
   if sim.units[id].alive and packet in state.carriers[id]:carriers.append(id)
  for item in state.wrecks:
   if packet in state.wrecks[item].packets:salvage.append(item)
  packets.append({"id":packet,"name":["REQUEST","REPLY"][packet],"recorded":sim.mission.objectives[packet].captured,"aboard":packet in state.aboard,"carriers":carriers,"salvage":salvage})
 return {"packets":packets,"cargo":cargo,"jobs":state.jobs.duplicate(true),"complete":complete(sim),"text":"Exchange aboard Quietus · return to recovery" if complete(sim) else "Field records are retained · bring raw exchange buffers to Quietus for local TRANSFER"}
static func handoff_context(sim,carrier:int)->Dictionary:
 var result={"carrier":carrier,"ready":false,"reason":"No exchange buffer available","packets":[],"distance":0.0,"range":RANGE}
 if not applies(sim.mission) or carrier not in [1,2]:return result
 var state=sim.mission.blackwater_delivery;var unit=sim.units[carrier];var quietus=sim.units[0]
 result.packets=state.carriers[carrier].filter(func(p):return p not in state.aboard);result.distance=unit.pos.distance_to(quietus.pos)
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif not unit.alive or not quietus.alive:result.reason="Both transfer craft must be alive"
 elif result.packets.is_empty():pass
 elif result.distance>RANGE:result.reason="Meet Quietus within60m for local TRANSFER"
 elif not sim.line_clear(unit.pos,quietus.pos):result.reason="Terrain blocks the local data connection"
 elif unit.vel.length()>=2 or quietus.vel.length()>=2:result.reason="Settle both craft below2m/s"
 elif not sim.captures[carrier].is_empty() or not sim.captures[0].is_empty() or not sim.module_recovery_status().jobs[carrier].is_empty() or not sim.module_recovery_status().jobs[0].is_empty() or not state.jobs[carrier].is_empty() or not state.jobs[0].is_empty():result.reason="Finish active work before local TRANSFER"
 else:result.ready=true;result.reason="TRANSFER · raw exchange buffers to Quietus"
 return result
static func handoff(sim,carrier:int)->bool:
 var context=handoff_context(sim,carrier)
 if not context.ready:sim.message=context.reason;return false
 if sim.selected not in [0,carrier]:sim.message="Select Quietus or this data carrier";return false
 var state=sim.mission.blackwater_delivery
 for packet in context.packets:state.aboard.append(packet);state.carriers[carrier].erase(packet)
 state.aboard.sort();sim.message="Raw exchange transferred locally · "+status(sim).text
 sim.events.append({"type":"data_handoff","pos":sim.units[0].pos,"carrier":carrier});return true
static func sampled(sim,packet:int,unit:int)->void:
 if not applies(sim.mission):return
 var state=sim.mission.blackwater_delivery;var cargo=state.aboard if unit==0 else state.carriers[unit]
 if packet not in cargo:cargo.append(packet);cargo.sort()
 sim.message=("REQUEST" if packet==0 else "REPLY")+" field record retained · raw buffer "+("aboard Quietus" if unit==0 else "carried by "+sim.units[unit].name+" · local TRANSFER to Quietus within60m")
 if packet==0 and sim.mission.courier_launch>=0:sim.message+=" · southern REPLY CARRIER announced; fixed relay remains available"
static func _packets(value,objectives:Array)->bool:
 if not value is Array or value.size()>2:return false
 var seen=[]
 for packet in value:
  if not packet is int or packet not in [0,1] or packet in seen or not objectives[packet].captured:return false
  seen.append(packet)
 return true
static func valid(data:Dictionary)->bool:
 var mission=data.mission
 if mission.get("id")!=2:return not mission.has("blackwater_delivery")
 if not mission.get("blackwater_delivery") is Dictionary or not mission.get("objectives") is Array or mission.objectives.size()!=2:return false
 for objective in mission.objectives:
  if not objective is Dictionary or not objective.get("captured") is bool:return false
 var state=mission.blackwater_delivery
 if state.size()!=4 or not state.get("carriers") is Array or state.carriers.size()!=3 or not state.get("wrecks") is Dictionary or state.wrecks.size()>2 or not state.get("jobs") is Array or state.jobs.size()!=3 or not _packets(state.get("aboard"),mission.objectives):return false
 for cargo in state.carriers:
  if not _packets(cargo,mission.objectives):return false
 if not state.carriers[0].is_empty():return false
 for item in state.wrecks:
  var wreck=state.wrecks[item]
  if item not in ["blackwater_buffer_1","blackwater_buffer_2"] or not wreck is Dictionary or wreck.size()!=2 or not wreck.get("pos") is Vector2 or not wreck.pos.is_finite() or not Rect2(0,0,1600,960).has_point(wreck.pos) or not _packets(wreck.get("packets"),mission.objectives) or wreck.packets.is_empty():return false
 var claimed=[]
 for job in state.jobs:
  if not job is Dictionary:return false
  if job.is_empty():continue
  if job.size()!=2 or not job.get("item") in state.wrecks or job.item in claimed or not (job.get("elapsed") is int or job.get("elapsed") is float) or not is_finite(job.elapsed) or job.elapsed<0 or job.elapsed>4:return false
  claimed.append(job.item)
 return data.get("outcome","")!="won" or (0 in state.aboard and 1 in state.aboard)
