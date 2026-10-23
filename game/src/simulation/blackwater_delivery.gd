extends RefCounted
const OperationsCatalog=preload("res://src/campaign/operation_catalog.gd")
# Raw exchange records remain with their own receiver until a local handoff.
# Field evidence is retained immediately; mission delivery has separate custody.
const RANGE=60.0
static func initial()->Dictionary:return {"aboard":[],"carriers":[[],[],[]],"wrecks":{},"jobs":[{},{},{}]}
static func applies(mission:Dictionary)->bool:return OperationsCatalog.supports(mission.get("id",-1),"packet_delivery") and mission.has("blackwater_delivery")
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
 var jobs=state.jobs.duplicate(true)
 for job in jobs:
  if not job.is_empty():job["duration"]=4.0
 var text="Exchange aboard Quietus · return to recovery" if complete(sim) else "SAMPLE REQUEST and REPLY · raw exchange must return to Quietus"
 if not complete(sim) and packets.any(func(packet):return packet.recorded):text="Field notes %d/2 · Quietus buffers %d/2 · local TRANSFER or recover/resample missing data"%[packets.filter(func(packet):return packet.recorded).size(),state.aboard.size()]
 return {"packets":packets,"cargo":cargo,"jobs":jobs,"complete":complete(sim),"text":text}
static func handoff_context(sim,carrier:int)->Dictionary:
 var result={"carrier":carrier,"ready":false,"reason":"No exchange buffer available","packets":[],"distance":0.0,"range":RANGE}
 if not applies(sim.mission) or carrier not in [1,2]:return result
 var state=sim.mission.blackwater_delivery;var unit=sim.units[carrier];var quietus=sim.units[0]
 result.packets=state.carriers[carrier].filter(func(p):return p not in state.aboard);result.distance=unit.pos.distance_to(quietus.pos)
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif not unit.alive or not quietus.alive:result.reason="Both transfer craft must be alive"
 elif unit.band!=quietus.band or not unit.transition.is_empty() or not quietus.transition.is_empty():result.reason="Meet at the same settled depth"
 elif result.packets.is_empty():pass
 elif result.distance>RANGE:result.reason="Meet Quietus within60m for local TRANSFER"
 elif not sim.Depth.clear(sim,unit.pos,quietus.pos,unit.band):result.reason="Terrain blocks the local data connection"
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
 state.aboard.sort();_cancel_redundant_samples(sim);sim.message="Raw exchange transferred locally · "+status(sim).text
 sim.events.append({"type":"data_handoff","pos":sim.units[0].pos,"carrier":carrier});return true
static func sampled(sim,packet:int,unit:int)->void:
 if not applies(sim.mission):return
 var state=sim.mission.blackwater_delivery;var cargo=state.aboard if unit==0 else state.carriers[unit]
 if packet not in cargo:cargo.append(packet);cargo.sort()
 _cancel_redundant_samples(sim)
 sim.message=("REQUEST" if packet==0 else "REPLY")+" field record retained · raw buffer "+("aboard Quietus" if unit==0 else "carried by "+sim.units[unit].name+" · local TRANSFER to Quietus within60m")
 sim.message+=" · "+("REPLY" if packet==0 else "REQUEST")+": quiet SAMPLE or settled SONAR replay within240m with a clear line"
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
 if not OperationsCatalog.supports(mission.get("id",-1),"packet_delivery"):return not mission.has("blackwater_delivery")
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
 for packet in 2:
  if mission.objectives[packet].captured and packet not in state.aboard and not state.carriers.any(func(cargo):return packet in cargo) and not state.wrecks.values().any(func(wreck):return packet in wreck.packets):return false
 for id in 3:
  var work=data.captures[id]
  if not state.jobs[id].is_empty() and (not work.is_empty() or not mission.get("module_recovery",{}).get("jobs",[{},{},{}])[id].is_empty()):return false
  if not work.is_empty() and (work.target in state.aboard or work.target in state.carriers[id]):return false
 return data.get("outcome","")!="won" or (0 in state.aboard and 1 in state.aboard)
static func needs_sample(sim,packet:int,unit:int)->bool:
 return applies(sim.mission) and packet not in sim.mission.blackwater_delivery.aboard and packet not in sim.mission.blackwater_delivery.carriers[unit]
static func _cancel_redundant_samples(sim)->void:
 # Delivery can finish while another receiver resamples the same field record.
 # Settle that work in this transition, including paused handoff commands.
 for id in sim.captures.size():
  if sim.captures[id].is_empty() or needs_sample(sim,sim.captures[id].target,id):continue
  sim.captures[id]={}
  if sim.units[id].hold=="HOLD":sim.units[id].hold=""
static func busy(sim,unit:int)->bool:return applies(sim.mission) and not sim.mission.blackwater_delivery.jobs[unit].is_empty()
static func losses(sim)->void:
 if not applies(sim.mission):return
 var state=sim.mission.blackwater_delivery
 for id in [1,2]:
  if sim.units[id].alive or state.carriers[id].is_empty():continue
  state.wrecks["blackwater_buffer_%d"%id]={"pos":sim.units[id].pos,"packets":state.carriers[id].duplicate()};state.carriers[id].clear()
  sim.message="Raw exchange buffer at lost craft position · recover the wreck or SAMPLE the fixed relay again"
static func packets_at(sim,pos:Vector2)->Array:
 var result=[]
 if not applies(sim.mission):return result
 var state=sim.mission.blackwater_delivery
 for wreck in state.wrecks.values():
  if wreck.pos.distance_to(pos)>1:continue
  for packet in wreck.packets:
   if packet not in state.aboard and packet not in result:result.append(packet)
 result.sort();return result
static func sites(sim,modules:Array)->Array:
 if not applies(sim.mission):return modules
 var result=[]
 for module in modules:
  var same=result.filter(func(site):return site.pos.distance_to(module.pos)<=1)
  if same.is_empty():result.append(module.duplicate(true))
  else:same[0].name+=" + "+module.name
 for site in result:
  site["packets"]=packets_at(sim,site.pos)
  if not site.packets.is_empty():site.name+=" + raw "+"/".join(site.packets.map(func(p):return ["REQUEST","REPLY"][p]))
 var state=sim.mission.blackwater_delivery
 for item in state.wrecks:
  var wreck=state.wrecks[item];var packets=packets_at(sim,wreck.pos)
  if packets.is_empty() or result.any(func(site):return site.pos.distance_to(wreck.pos)<=1):continue
  result.append({"item":item,"name":"Raw "+"/".join(packets.map(func(p):return ["REQUEST","REPLY"][p]))+" buffer","pos":wreck.pos,"packets":packets})
 return result
static func context(sim,item:String,unit:int)->Dictionary:
 var result={"item":item,"unit":unit,"ready":false,"reason":"Buffer unavailable","active":false,"claimed_by":-1,"elapsed":0.0,"duration":4.0,"distance":0.0,"range":RANGE,"noise_radius":520.0,"packets":[]}
 if not applies(sim.mission) or unit not in [0,1,2]:return result
 var state=sim.mission.blackwater_delivery
 if not state.wrecks.has(item):return result
 var pos=state.wrecks[item].pos;result.packets=packets_at(sim,pos);result.distance=sim.units[unit].pos.distance_to(pos)
 for id in 3:
  if not state.jobs[id].is_empty() and state.jobs[id].item==item:result.claimed_by=id;result.active=id==unit;result.elapsed=state.jobs[id].elapsed
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif not sim.units[unit].alive:result.reason="Craft lost"
 elif result.packets.is_empty():result.reason="This data is already aboard Quietus"
 elif result.claimed_by>=0:result.reason="Recovery in progress"
 elif busy(sim,unit) or not sim.module_recovery_status().jobs[unit].is_empty() or not sim.captures[unit].is_empty():result.reason="Finish this craft's active work first"
 elif result.distance>RANGE:result.reason="Move within60m"
 elif sim.units[unit].band!=sim.Depth.cargo_band(sim,item) or not sim.units[unit].transition.is_empty():result.reason="Salvage requires its recorded depth band"
 elif not sim.Depth.clear(sim,sim.units[unit].pos,pos,sim.units[unit].band):result.reason="Terrain blocks recovery"
 elif sim.units[unit].vel.length()>=2:result.reason="Settle below2m/s"
 else:result.ready=true;result.reason="Recover raw buffer · audible winch4s"
 return result
static func begin(sim,item:String)->bool:
 var c=context(sim,item,sim.selected)
 if not c.ready:sim.message=c.reason;return false
 sim.mission.blackwater_delivery.jobs[sim.selected]={"item":item,"elapsed":0.0};sim.units[sim.selected].hold="HOLD"
 sim._noise(sim.units[sim.selected].pos,520,"RECOVERY WINCH",4,sim.units[sim.selected].band);sim.events.append({"type":"salvage","pos":sim.units[sim.selected].pos,"item":item});sim.message=c.reason;return true
static func collect_at(sim,unit:int,pos:Vector2)->void:
 if not applies(sim.mission):return
 var state=sim.mission.blackwater_delivery;var cargo=state.aboard if unit==0 else state.carriers[unit]
 for item in state.wrecks.keys():
  if state.wrecks[item].pos.distance_to(pos)>1 or sim.Depth.cargo_band(sim,item)!=sim.units[unit].band:continue
  for packet in state.wrecks[item].packets:
   if packet not in cargo:cargo.append(packet)
  state.wrecks.erase(item)
 cargo.sort();_cancel_redundant_samples(sim)
# JobRelease calls this only after the shared HOLD guard.
static func release_if_unheld(sim,unit:int)->void:
 if applies(sim.mission):sim.mission.blackwater_delivery.jobs[unit]={}
static func tick(sim,dt:float)->void:
 if not applies(sim.mission):return
 losses(sim);var state=sim.mission.blackwater_delivery
 for id in 3:
  var job=state.jobs[id]
  if job.is_empty():continue
  var unit=sim.units[id]
  if not unit.alive or unit.hold!="HOLD" or not state.wrecks.has(job.item) or unit.pos.distance_to(state.wrecks[job.item].pos)>RANGE or unit.band!=sim.Depth.cargo_band(sim,job.item) or not unit.transition.is_empty() or not sim.Depth.clear(sim,unit.pos,state.wrecks[job.item].pos,unit.band):
   state.jobs[id]={}
   if unit.hold=="HOLD":unit.hold=""
   sim.message="Buffer recovery interrupted"
  elif unit.vel.length()>=2:job.elapsed=0.0
  else:
   job.elapsed+=dt
   if job.elapsed+0.0000001>=4:
    sim._collect_shared_wreck(id,state.wrecks[job.item].pos);state.jobs[id]={};unit.hold=""
    sim.message="Raw buffer recovered · "+("aboard Quietus" if id==0 else "local TRANSFER to Quietus still required")
