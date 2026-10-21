extends RefCounted
const OperationsCatalog=preload("res://src/campaign/operation_catalog.gd")
# One occupied sealed pod travels on real fleet bodies. It is not a fourth
# combat actor: ordinary carrier sight, beams, loss and salvage remain physical.
const ITEM="witness_capsule"
const BERTH=Vector2(1840,760)
const HARBOUR=Vector2(2260,2700)
const RANGE=60.0
const DURATION=4.0
static func initial()->Dictionary:
 return {"state":"at_berth","pos":BERTH,"carrier":-1,"job":{},"rescues":0,"losses":[],"landed_by":-1}
static func applies(mission:Dictionary)->bool:return OperationsCatalog.supports(mission.get("id",-1),"witness") and mission.has("witness_evacuation")
static func known(sim)->bool:
 return applies(sim.mission) and (sim.mission.witness_evacuation.state!="at_berth" or sim.mission.signal_sources.any(func(s):return s.id=="witness_packet" and s.located))
static func available(sim)->bool:return known(sim) and sim.mission.witness_evacuation.state in ["at_berth","salvage"]
static func complete(sim)->bool:return not applies(sim.mission) or sim.mission.witness_evacuation.state=="landed"
static func busy(sim,unit:int)->bool:
 return applies(sim.mission) and not sim.mission.witness_evacuation.job.is_empty() and sim.mission.witness_evacuation.job.unit==unit
static func handles(sim,item:String)->bool:
 if not applies(sim.mission):return false
 if item==ITEM:return true
 var module=sim.mission.get("module_recovery",{}).get("modules",{}).get(item,{})
 return available(sim) and module.get("state","")=="salvage" and module.pos.distance_to(sim.mission.witness_evacuation.pos)<=1
static func _shared_work(sim)->Dictionary:
 var result={}
 if not available(sim):return result
 var modules=sim.mission.get("module_recovery",{});var jobs=modules.get("jobs",[{},{},{}])
 for id in 3:
  if not jobs[id].is_empty() and modules.modules[jobs[id].item].pos.distance_to(sim.mission.witness_evacuation.pos)<=1:
   result={"unit":id,"item":jobs[id].item,"elapsed":jobs[id].elapsed,"duration":DURATION};break
 return result
static func status(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.witness_evacuation;var located=known(sim);var capsule={};var cargo=[[],[],[]];var jobs=[{},{},{}]
 if located:
  capsule={"id":ITEM,"name":"OCCUPIED WITNESS CAPSULE","state":state.state,"pos":sim.units[state.carrier].pos if state.state=="carried" else state.pos,"carrier":state.carrier,"occupied":true,"landed_by":state.landed_by,"rescues":state.rescues,"losses":state.losses.duplicate()}
 if state.state=="carried":cargo[state.carrier].append(ITEM)
 if not state.job.is_empty():jobs[state.job.unit]={"unit":state.job.unit,"item":state.job.item,"elapsed":state.job.elapsed,"duration":DURATION}
 else:
  var shared=_shared_work(sim)
  if not shared.is_empty():jobs[shared.unit]=shared
 var text={"at_berth":"Living witness awaits local WINCH · bring the occupied capsule to southeast lift point","carried":"Living witness aboard transport · explicitly LAND at southeast lift point","salvage":"Occupied pressure pod ejected at own lost-craft position · recover locally","landed":"Living witness landed · local station account and Quietus recovery required"}[state.state] if located else "Locate the witness berth by local observation or Survey"
 return {"known":located,"capsule":capsule,"cargo":cargo,"jobs":jobs,"landed":state.state=="landed","harbour":{"id":"witness_harbour","name":"CONCEALED RECOVERY BASIN","pos":HARBOUR,"range":RANGE},"text":text}
static func sites(sim,modules:Array)->Array:
 if not available(sim):return modules
 var result=modules.duplicate(true);var pos=sim.mission.witness_evacuation.pos
 var same=result.filter(func(site):return site.pos.distance_to(pos)<=1)
 if same.is_empty():result.append({"item":ITEM,"name":"Occupied witness capsule","pos":pos,"witness":true})
 else:
  for extra in same.slice(1):same[0].name+=" + "+extra.name;result.erase(extra)
  same[0]["witness"]=true;same[0].name+=" + occupied witness capsule"
 return result
static func context(sim,unit:int,item:String=ITEM)->Dictionary:
 if not applies(sim.mission) or unit not in [0,1,2]:return {}
 var state=sim.mission.witness_evacuation;var body=sim.units[unit]
 var winch={"item":item,"unit":unit,"ready":false,"reason":"Locate the occupied capsule first","active":false,"claimed_by":-1,"elapsed":0.0,"duration":DURATION,"distance":0.0,"range":RANGE,"noise_radius":520.0}
 if known(sim):
  winch.distance=body.pos.distance_to(state.pos)
  var job=state.job if not state.job.is_empty() else _shared_work(sim)
  if not job.is_empty():winch.claimed_by=job.unit;winch.active=job.unit==unit;winch.elapsed=job.elapsed
  if not sim.outcome.is_empty():winch.reason="Dive ended"
  elif not body.alive:winch.reason="Craft lost"
  elif not available(sim):winch.reason="Capsule already carried or landed"
  elif not handles(sim,item):winch.reason="This item is not the occupied pod site"
  elif winch.claimed_by>=0:winch.reason="Occupied capsule recovery in progress"
  elif not sim.captures[unit].is_empty() or not sim.module_recovery_status().jobs[unit].is_empty() or sim._blackwater_recovery_busy(unit) or sim._warning_chain_busy(unit):winch.reason="Finish this craft's active work first"
  elif winch.distance>RANGE:winch.reason="Move within 60m of the occupied pod"
  elif body.band!=sim.Depth.cargo_band(sim,ITEM) or not body.transition.is_empty():winch.reason="Salvage requires its recorded depth band"
  elif not sim.Depth.clear(sim,body.pos,state.pos,body.band):winch.reason="Terrain blocks the winch"
  elif body.vel.length()>=2:winch.reason="Settle below 2m/s"
  else:winch.ready=true;winch.reason="WINCH occupied capsule · 4s audible · 520m open-water reach"
 var land={"ready":false,"reason":"This craft does not carry the witness","distance":body.pos.distance_to(HARBOUR),"range":RANGE}
 if not sim.outcome.is_empty():land.reason="Dive ended"
 elif body.alive and state.state=="carried" and state.carrier==unit:
  if body.band!=1 or not body.transition.is_empty():land.reason="Ascend to MIDDLE and settle for lift-point landing"
  elif land.distance>RANGE:land.reason="Bring the occupied capsule within 60m of southeast lift point"
  elif not sim.Depth.clear(sim,body.pos,HARBOUR,body.band):land.reason="Terrain blocks lift-point landing"
  elif body.vel.length()>=2:land.reason="Settle below 2m/s to land the witness"
  elif not sim.captures[unit].is_empty() or not sim.module_recovery_status().jobs[unit].is_empty() or sim._blackwater_recovery_busy(unit) or busy(sim,unit):land.reason="Finish this craft's active work first"
  else:land.ready=true;land.reason="LAND living witness · lift point"
 return {"unit":unit,"winch":winch,"land":land}
static func begin(sim,item:String)->bool:
 var c=context(sim,sim.selected,item).get("winch",{})
 if not c.get("ready",false):sim.message=c.get("reason","Witness unavailable");return false
 sim.mission.witness_evacuation.job={"unit":sim.selected,"item":item,"elapsed":0.0};sim.units[sim.selected].hold="HOLD"
 sim._noise(sim.units[sim.selected].pos,520.0,"RECOVERY WINCH",DURATION,sim.units[sim.selected].band);sim.events.append({"type":"salvage","pos":sim.units[sim.selected].pos,"item":item})
 sim.message="Occupied pressure pod · living witness aboard · audible winch4s";return true
static func land(sim)->bool:
 var c=context(sim,sim.selected).get("land",{})
 if not c.get("ready",false):sim.message=c.get("reason","Witness unavailable");return false
 var state=sim.mission.witness_evacuation;state.landed_by=sim.selected;state.carrier=-1;state.pos=HARBOUR;state.state="landed"
 sim.mission.record="The living witness was physically landed in the concealed southeast lift point by "+sim.units[sim.selected].name+". The account is preserved without broadcasting the passage."
 sim.events.append({"type":"witness_landed","pos":HARBOUR});sim.message="Living witness landed safely · "+("return Quietus to recovery" if preload("res://src/simulation/concealed_harbour.gd").complete(sim) else "complete the witness-guided local work and receive its station reply");return true
static func losses(sim)->void:
 if not applies(sim.mission):return
 var state=sim.mission.witness_evacuation
 if state.state=="carried" and not sim.units[state.carrier].alive:
  var id=state.carrier;state.pos=sim.units[id].pos;state.state="salvage";state.carrier=-1;state.losses.append(id)
  sim.events.append({"type":"witness_ejected","pos":state.pos});sim.message="Transport lost · occupied sealed pressure pod ejected at its last own position · recover locally"
static func collect_at(sim,unit:int,pos:Vector2)->void:
 if not available(sim) or sim.mission.witness_evacuation.pos.distance_to(pos)>1 or sim.units[unit].band!=sim.Depth.cargo_band(sim,ITEM):return
 var state=sim.mission.witness_evacuation
 if state.state=="salvage":state.rescues+=1
 else:
  for site in sim.mission.objectives:
   if site.get("site_id","")=="witness_packet":site.captured=true;sim._record_secured(site,unit);break
 state.state="carried";state.carrier=unit;state.job={}
 sim.events.append({"type":"witness_boarded","pos":sim.units[unit].pos});sim.message=sim.units[unit].name+" carries the occupied witness capsule · LAND at southeast lift point"
static func cancel_released(sim,unit:int)->void:
 if busy(sim,unit) and sim.units[unit].hold!="HOLD":sim.mission.witness_evacuation.job={}
static func tick(sim,dt:float)->void:
 if not applies(sim.mission):return
 losses(sim);var state=sim.mission.witness_evacuation
 if state.job.is_empty():return
 var job=state.job;var body=sim.units[job.unit]
 if not body.alive or body.hold!="HOLD" or not available(sim) or body.pos.distance_to(state.pos)>RANGE or body.band!=sim.Depth.cargo_band(sim,ITEM) or not body.transition.is_empty() or not sim.Depth.clear(sim,body.pos,state.pos,body.band):
  state.job={}
  if body.hold=="HOLD":body.hold=""
  sim.message="Occupied pod winch interrupted"
 elif body.vel.length()>=2:job.elapsed=0.0
 else:
  job.elapsed+=dt
  if job.elapsed+0.0000001>=DURATION:sim._collect_shared_wreck(job.unit,state.pos);state.job={};body.hold=""
static func recovered_facts(mission:Dictionary)->Dictionary:
 if not applies(mission) or mission.witness_evacuation.state!="landed":return {}
 var state=mission.witness_evacuation;var names=["QUIETUS","DRONE A","DRONE B"]
 var account="No transport lost."
 if not state.losses.is_empty():account=", ".join(state.losses.map(func(id):return names[id]))+" lost while carrying the occupied pod; %d rescue(s) brought the same living witness home."%state.rescues
 var kit=mission.get("module_recovery",{}).get("result",{}).get("lost",[])
 if not kit.is_empty():account+=" Launched equipment left behind: "+", ".join(kit)+"."
 return {"witness_arrival":["quietus","drone_a","drone_b"][state.landed_by],"witness_recovery":account}
static func valid(data:Dictionary)->bool:
 var mission=data.mission
 if not OperationsCatalog.supports(mission.get("id",-1),"witness"):return not mission.has("witness_evacuation")
 var state=mission.get("witness_evacuation")
 if not state is Dictionary or state.size()!=7 or state.get("state") not in ["at_berth","carried","salvage","landed"] or not state.get("pos") is Vector2 or not state.pos.is_finite() or not Rect2(Vector2.ZERO,mission.world_size).has_point(state.pos):return false
 if not state.get("carrier") is int or not state.get("landed_by") is int or not state.get("rescues") is int or state.rescues<0 or state.rescues>2 or not state.get("losses") is Array or state.losses.size()>2 or not state.get("job") is Dictionary:return false
 if data.units.size()!=3 or data.units.any(func(u):return not u is Dictionary or not u.get("alive") is bool):return false
 var ids=[]
 for id in state.losses:
  if not id is int or id not in [1,2] or id in ids or data.units[id].alive:return false
  ids.append(id)
 if state.state=="salvage":
  if state.losses.is_empty() or state.rescues!=state.losses.size()-1:return false
 elif state.rescues!=state.losses.size():return false
 if state.state!="landed" and state.pos!=(BERTH if state.losses.is_empty() else data.units[state.losses.back()].pos):return false
 if state.state=="carried":
  if state.carrier not in [0,1,2] or not data.units[state.carrier].alive:return false
 elif state.carrier!=-1:return false
 if state.state=="at_berth" and (state.pos!=BERTH or not state.losses.is_empty() or state.rescues!=0):return false
 if state.state=="landed":
  if state.pos!=HARBOUR or state.landed_by not in [0,1,2] or state.landed_by in state.losses:return false
 elif state.landed_by!=-1:return false
 if not state.job.is_empty():
  var job=state.job
  if job.size()!=3 or not job.get("unit") is int or job.unit not in [0,1,2] or not job.get("item") is String or state.state not in ["at_berth","salvage"] or not (job.get("elapsed") is float or job.get("elapsed") is int) or not is_finite(job.elapsed) or job.elapsed<0 or job.elapsed>DURATION:return false
  if not data.units[job.unit].alive or data.units[job.unit].get("hold","")!="HOLD" or not data.captures[job.unit].is_empty() or not mission.get("module_recovery",{}).get("jobs",[{},{},{}])[job.unit].is_empty():return false
 if state.state in ["carried","landed"] and not mission.objectives.any(func(o):return o.get("site_id","")=="witness_packet" and o.captured):return false
 return data.get("outcome","")!="won" or state.state=="landed"
