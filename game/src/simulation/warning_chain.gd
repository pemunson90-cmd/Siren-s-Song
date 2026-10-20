extends RefCounted
const OperationsCatalog=preload("res://src/campaign/operation_catalog.gd")
# A local own body supplies a remote machine. Its physical dependency is not a
# captured flag; only the final plant result remains latched after disconnection.
const Plant=preload("res://src/campaign/onward_missions.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const RANGE=60.0
static func layout(m:Dictionary)->Dictionary:
 var config=OperationsCatalog.definition(m.get("id",-1)).get("config",{})
 return config.get("plant",{"inlet":Plant.CHAIN_INLET,"panel":Plant.CHAIN_PANEL,"mast":Plant.CHAIN_MAST,"shutter":Plant.CHAIN_SHUTTER,"recovery":Plant.CHAIN_RECOVERY})
static func applies(m:Dictionary)->bool:return OperationsCatalog.supports(m.get("id",-1),"warning_plant") and m.has("warning_chain")
static func complete(sim)->bool:return not applies(sim.mission) or not sim.mission.warning_chain.result.is_empty()
static func connected(sim,id:int)->bool:return applies(sim.mission) and sim.mission.warning_chain.power=="umbilical" and sim.mission.warning_chain.unit==id
static func _work(sim,id:int)->bool:return not sim.captures[id].is_empty() or not sim.module_recovery_status().jobs[id].is_empty()
static func _local(sim,id:int,pos:Vector2)->String:
 var u=sim.units[id]
 if not u.alive:return "Craft lost"
 if u.band!=1 or not u.transition.is_empty():return "MIDDLE band and settled depth required"
 if u.pos.distance_to(pos)>RANGE:return "Move within60m of this plant station"
 if not sim.Depth.clear(sim,u.pos,pos,u.band):return "Terrain blocks the local plant connection"
 if u.vel.length()>=2:return "Settle below2m/s"
 if _work(sim,id):return "Finish this craft's active work first"
 return ""
static func _action(sim,action:String,id:int)->Dictionary:
 var s=sim.mission.warning_chain;var a={"id":action,"unit":id,"ready":false,"reason":""}
 if not sim.outcome.is_empty():a.reason="Dive ended"
 elif action=="disconnect":
  if not connected(sim,id):a.reason="This craft has no plant umbilical"
 elif not s.result.is_empty():a.reason="Plant already commissioned · choose recovery"
 elif action in ["connect","backup"]:
  if s.power=="backup":a.reason="Backup already running"
  elif action=="connect" and s.power=="umbilical":a.reason="A craft already supplies the plant"
  else:
   a.reason=_local(sim,id,layout(sim.mission).inlet)
   if a.reason.is_empty() and sim.units[id].hold not in ["","HOLD"]:a.reason="Release this craft's conditional hold first"
 else:
  if id!=0 and Catalog.item_for(sim.mission.launch_equipment,id)!="drone_sampler":a.reason="Quietus or a fitted field sampler must operate this panel"
  elif s.power=="off":a.reason="Plant unpowered · CONNECT a craft or START BACKUP at WEST"
  else:
   a.reason=_local(sim,id,layout(sim.mission).panel)
   if a.reason.is_empty():
    if action=="send":
     if s.output.is_empty():a.reason="Select SERVICE or NORTH MAST first"
     elif s.output in s.sends:a.reason="This output has already activated · select the other branch"
    elif s.output==action:a.reason="Output already selected"
 a.ready=a.reason.is_empty()
 if a.ready:a.reason={"connect":"CONNECT · quiet own-body shore supply","disconnect":"DISCONNECT · release retained course","backup":"START BACKUP · audible900m/6s, once","service":"SERVICE · open water/sound crosslink","mast":"NORTH MAST · preserve a closed crosslink","send":"SEND WARNING · finite physical output"}[action]
 return a
static func context(sim,id:int)->Dictionary:
 if not applies(sim.mission) or id not in [0,1,2]:return {}
 var s=sim.mission.warning_chain;var text="Plant unpowered · CONNECT at WEST or START BACKUP"
 if s.power!="off":text="Powered %s · configure and send at EAST"%("by "+sim.units[s.unit].name if s.power=="umbilical" else "by backup")
 if not s.result.is_empty():text=("Western service branch received the warning" if s.result.proof=="local_receipt" else "North mast transmitted · external reception unknown")+" · recover Quietus"
 var actions=[]
 for action in ["connect","disconnect","backup","service","mast","send"]:actions.append(_action(sim,action,id))
 return {"power":{"source":s.power,"unit":s.unit},"stations":[{"id":"inlet","site_id":"chain_west","name":"WEST SERVICE INLET","pos":layout(sim.mission).inlet},{"id":"panel","site_id":"chain_east","name":"EAST ROUTING PANEL","pos":layout(sim.mission).panel}],"output":s.output,"crosslink_open":s.opened,"crosslink":{"rect":layout(sim.mission).shutter,"opened":s.opened},"commissioned":not s.result.is_empty(),"result":s.result.duplicate(true),"actions":actions,"sends_used":s.sends.duplicate(),"outputs":[{"id":"service","origin":layout(sim.mission).panel,"radius":1400.0,"duration":6.0,"proof":"local_receipt"},{"id":"mast","origin":layout(sim.mission).mast,"radius":1100.0,"duration":6.0,"proof":"mast_transmission"}],"text":text}
static func _record(sim,index:int,id:int)->void:
 var site=sim.mission.objectives[index]
 if site.captured:return
 site.captured=true;sim.mission.expedition_facts[site.site_id]=site.evidence;sim._record_secured(site,id)
static func _release(sim)->void:
 var s=sim.mission.warning_chain;var id:int=s.unit
 if id>=0 and sim.units[id].hold=="HOLD":sim.units[id].hold=""
 s.power="off";s.unit=-1
static func command(sim,action:String)->bool:
 if not applies(sim.mission) or action not in ["connect","disconnect","backup","service","mast","send"]:return false
 var id:int=sim.selected;var a=_action(sim,action,id)
 if not a.ready:sim.message=a.reason;return false
 var s=sim.mission.warning_chain
 match action:
  "connect":s.power="umbilical";s.unit=id;sim.units[id].hold="HOLD";_record(sim,0,id)
  "disconnect":_release(sim)
  "backup":
   if s.power=="umbilical":_release(sim)
   s.power="backup";s.unit=-1;sim._noise(layout(sim.mission).inlet,900,"BACKUP GENERATOR START",6);_record(sim,0,id)
  "service","mast":
   s.output=action
   if action=="service" and not s.opened:
    s.opened=true;sim.mission.structures.erase(layout(sim.mission).shutter);sim.opened_terrain(layout(sim.mission).shutter);sim._build_navigation();sim._noise(layout(sim.mission).shutter.get_center(),350,"SERVICE SHUTTER",2)
   _record(sim,1,id)
  "send":
   var service=s.output=="service";var origin=layout(sim.mission).panel if service else layout(sim.mission).mast
   s.sends.append(s.output);sim._noise(origin,1400 if service else 1100,"SERVICE WARNING" if service else "NORTH MAST WARNING",6)
   # The service station's actual acoustic reception returns through the known
   # plant diagnostic bus. Mast telemetry certifies only its own transmission.
   if service and sim.acoustic_paths.arrivals(layout(sim.mission).inlet,origin,1400).is_empty():
    sim.message="No service receipt · the powered NORTH MAST remains available";return true
   s.result={"output":s.output,"proof":"local_receipt" if service else "mast_transmission","time":sim.elapsed,"origin":origin};_record(sim,2,id)
   sim.mission.record="SERVICE RECEIPT / The western branch received this warning through the opened crosslink. One local acknowledgement is proved; the wider population remains unobserved." if service else "MAST TRANSMISSION / Powered northern hardware sent the warning; external reception unknown. Quietus recovered a transmission record, not proof that an inhabited shore answered."
 sim.events.append({"type":"plant_control","action":action,"unit":id,"pos":sim.units[id].pos});sim.message=context(sim,id).text;return true
static func cancel_released(sim,order:String)->void:
 if not applies(sim.mission) or sim.mission.warning_chain.power!="umbilical":return
 var id:int=sim.mission.warning_chain.unit
 if sim.units[id].hold!="HOLD" or (sim.selected==id and order in ["route","emergency","route_edit","route_insert","route_delete","route_undo"]):_release(sim)
static func tick(sim)->void:
 if not applies(sim.mission) or sim.mission.warning_chain.power!="umbilical":return
 var id:int=sim.mission.warning_chain.unit
 if sim.units[id].hold!="HOLD" or not _local(sim,id,layout(sim.mission).inlet).is_empty():
  _release(sim);sim.message="Shore supply disconnected · reconnect a craft or START BACKUP at WEST"
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if not OperationsCatalog.supports(m.get("id",-1),"warning_plant"):return not m.has("warning_chain")
 var s=m.get("warning_chain")
 if not s is Dictionary or s.size()!=6 or s.get("power") not in ["off","umbilical","backup"] or not s.get("unit") is int or s.get("output") not in ["","service","mast"] or not s.get("opened") is bool or not s.get("sends") is Array or s.sends.size()>2 or not s.get("result") is Dictionary:return false
 if not m.get("structures") is Array or m.structures!=([] if s.opened else [layout(m).shutter]):return false
 if not m.get("objectives") is Array or m.objectives.size()!=3:return false
 if m.objectives[0].pos!=layout(m).inlet or m.objectives[1].pos!=layout(m).panel or m.objectives[2].pos!=layout(m).panel:return false
 if s.output=="service" and not s.opened:return false
 if m.objectives[1].captured!=(not s.output.is_empty()) or m.objectives[2].captured!=(not s.result.is_empty()):return false
 if s.power=="umbilical":
  if s.unit not in [0,1,2] or not data.units is Array or data.units.size()!=3:return false
  var u=data.units[s.unit]
  if not u is Dictionary or u.get("alive")!=true or u.get("hold")!="HOLD" or not u.get("pos") is Vector2 or not u.get("vel") is Vector2 or not u.vel.is_finite() or u.pos.distance_to(layout(m).inlet)>RANGE or u.vel.length()>=2:return false
 elif s.unit!=-1:return false
 if s.power!="off" and not m.objectives[0].captured:return false
 var seen=[]
 for output in s.sends:
  if output not in ["service","mast"] or output in seen:return false
  seen.append(output)
 if not s.result.is_empty():
  var r=s.result
  if r.size()!=4 or r.get("output")!=s.output or r.output not in s.sends or r.get("proof")!=("local_receipt" if r.output=="service" else "mast_transmission") or r.get("origin")!=(layout(m).panel if r.output=="service" else layout(m).mast):return false
  if not (r.get("time") is float or r.get("time") is int) or not is_finite(r.time) or r.time<0 or r.time>data.get("elapsed",0):return false
 elif "mast" in s.sends:return false
 return data.get("outcome","")!="won" or not s.result.is_empty()
