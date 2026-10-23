extends RefCounted
# Only unique hardware actually launched on own drones enters this authority.
# Salvage positions come from own craft, never a hostile or terrain query.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Inventory=preload("res://src/campaign/fleet_inventory.gd")
const Upgrades=preload("res://src/equipment/craft_upgrades.gd")
const DURATION=4.0
const RANGE=60.0
const NOISE=520.0
static func initial(fitted:Dictionary,units:Array)->Dictionary:
 var modules={}
 for id in [1,2]:
  for item in Catalog.items_for(fitted,id):modules[item]={"state":"fitted","unit":id,"pos":units[id].pos}
 return {"modules":modules,"jobs":[{},{},{}],"result":{},"deferred":""}
static func _state(sim)->Dictionary:
 return sim.mission.get("module_recovery",{"modules":{},"jobs":[{},{},{}],"result":{},"deferred":""})
static func _name(item:String)->String:return Catalog.ITEMS.get(item,{}).get("name",item)
# Winch carriage is the craft's free cargo budget; the standard frames hold two.
static func capacity(sim,unit_id:int)->int:return Upgrades.cargo_free(sim.mission.get("launch_equipment",{}),unit_id)
static func carried(sim,unit_id:int)->int:
 var state=_state(sim);var count=0
 for item in state.modules:
  if state.modules[item].state=="cargo" and state.modules[item].unit==unit_id:count+=1
 return count
static func status(sim)->Dictionary:
 var state=_state(sim);var result={"modules":[],"cargo":[[],[],[]],"jobs":[{},{},{}],"result":state.result.duplicate(true)}
 for item in state.modules:
  var module=state.modules[item];var pos=module.pos
  if module.unit>=0:pos=sim.units[module.unit].pos
  result.modules.append({"item":item,"name":_name(item),"state":module.state,"unit":module.unit,"pos":pos})
  if module.state=="cargo":result.cargo[module.unit].append(item)
 for id in 3:
  if not state.jobs[id].is_empty():result.jobs[id]={"item":state.jobs[id].item,"elapsed":state.jobs[id].elapsed,"duration":DURATION}
 return result
static func sites(sim)->Array:
 return status(sim).modules.filter(func(module):return module.state=="salvage").map(func(module):return {"item":module.item,"name":module.name,"pos":module.pos})
static func context(sim,item:String,unit_id:int)->Dictionary:
 var state=_state(sim);var result={"item":item,"unit":unit_id,"ready":false,"reason":"Module unavailable","active":false,"claimed_by":-1,"elapsed":0.0,"duration":DURATION,"distance":0.0,"range":RANGE,"noise_radius":NOISE,"cargo":0,"cargo_cap":0}
 if unit_id<0 or unit_id>=sim.units.size() or not state.modules.has(item):return result
 var module=state.modules[item];var unit=sim.units[unit_id]
 for id in 3:
  if not state.jobs[id].is_empty() and state.jobs[id].item==item:
   result.claimed_by=id;result.active=id==unit_id;result.elapsed=state.jobs[id].elapsed
 if module.state!="salvage":return result
 result.distance=unit.pos.distance_to(module.pos);result.cargo=carried(sim,unit_id);result.cargo_cap=capacity(sim,unit_id)
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif not unit.alive:result.reason="Craft lost"
 elif result.claimed_by>=0:result.reason="Recovery in progress"
 elif not state.jobs[unit_id].is_empty() or not sim.captures[unit_id].is_empty() or sim._blackwater_recovery_busy(unit_id) or sim._warning_chain_busy(unit_id) or sim._witness_recovery_busy(unit_id) or sim.Glass.busy(sim,unit_id) or sim.Choir.busy(sim,unit_id):result.reason="Finish this craft's active work first"
 elif result.cargo>=result.cargo_cap:result.reason="No free cargo place · %d / %d carried"%[result.cargo,result.cargo_cap]
 elif result.distance>RANGE:result.reason="Move within 60m"
 elif unit.band!=sim.Depth.cargo_band(sim,item) or not unit.transition.is_empty():result.reason="Salvage requires its recorded depth band"
 elif not sim.Depth.clear(sim,unit.pos,module.pos,unit.band):result.reason="Terrain blocks recovery"
 elif unit.vel.length()>=2.0:result.reason="Settle below 2m/s"
 else:result.ready=true;result.reason="Recover module · audible winch 4s"
 return result
static func begin(sim,item:String)->bool:
 var c=context(sim,item,sim.selected)
 if not c.ready:sim.message=c.reason;return false
 var state=_state(sim);state.jobs[sim.selected]={"item":item,"elapsed":0.0};sim.units[sim.selected].hold="HOLD"
 sim._noise(sim.units[sim.selected].pos,NOISE,"RECOVERY WINCH",DURATION,sim.units[sim.selected].band)
 sim.events.append({"type":"salvage","pos":sim.units[sim.selected].pos,"item":item});sim.message="%s · recover %s · audible winch 4s"%[sim.units[sim.selected].name,_name(item)]
 return true
# JobRelease calls this only after the shared HOLD guard.
static func release_if_unheld(sim,unit_id:int)->void:
 if sim.mission.has("module_recovery"):sim.mission.module_recovery.jobs[unit_id]={}
static func tick(sim,dt:float)->void:
 if not sim.mission.has("module_recovery"):return
 var state=sim.mission.module_recovery
 for item in state.modules:
  var module=state.modules[item]
  if module.unit>=0 and not sim.units[module.unit].alive:
   module.pos=sim.units[module.unit].pos;module.unit=-1;module.state="salvage"
   sim.message="%s lost · module salvage at last craft position"%_name(item)
 for id in 3:
  var job=state.jobs[id]
  if job.is_empty():continue
  var unit=sim.units[id];var module=state.modules[job.item]
  if not unit.alive or unit.hold!="HOLD" or module.state!="salvage" or unit.pos.distance_to(module.pos)>RANGE or unit.band!=sim.Depth.cargo_band(sim,job.item) or not unit.transition.is_empty() or not sim.Depth.clear(sim,unit.pos,module.pos,unit.band):
   state.jobs[id]={}
   if unit.hold=="HOLD":unit.hold=""
   sim.message="%s · module recovery interrupted"%unit.name
  elif unit.vel.length()>=2.0:job.elapsed=0.0
  else:
   job.elapsed+=dt
   if job.elapsed+0.0000001>=DURATION:
    if not sim._collect_shared_wreck(id,module.pos) and carried(sim,id)<capacity(sim,id):module.state="cargo";module.unit=id
    state.jobs[id]={};unit.hold=""
    sim.message="%s carries %s · bring carrier to recovery"%[unit.name,_name(job.item)]
 if not sim.departure_context().available:state.deferred=""
static func departure(sim,corridor:Dictionary)->Dictionary:
 var state=_state(sim);var result={"available":true,"pending":false,"confirmation_required":false,"corridor":corridor.duplicate(true),"recovered":[],"left":[],"recovered_drones":[],"text":"Fleet recovery ready"}
 var home=[0]
 for id in [1,2]:
  var unit=sim.units[id]
  if unit.alive and unit.band==1 and unit.transition.is_empty() and unit.pos.distance_to(corridor.pos)<65 and unit.vel.length()<12 and sim.Depth.clear(sim,unit.pos,corridor.pos,unit.band):home.append(id);result.recovered_drones.append(id)
 for module in status(sim).modules:
  if module.unit in home:result.recovered.append(module.item)
  else:
   var copy=module.duplicate(true);copy.reason="Module awaits salvage" if module.state=="salvage" else "Carrier outside this recovery mouth";result.left.append(copy)
 result.confirmation_required=not result.left.is_empty();result.pending=result.confirmation_required and state.deferred!=_token(result)
 if result.confirmation_required:result.text="Recover remaining modules, or explicitly depart without them"
 return result
static func _token(context:Dictionary)->String:
 var states=[]
 for module in context.left:states.append([module.item,module.state,module.unit])
 return str([context.corridor.pos,context.corridor.get("route",""),context.recovered,states])
static func defer(sim,context:Dictionary)->void:
 if sim.mission.has("module_recovery"):sim.mission.module_recovery.deferred=_token(context)
static func record(sim,context:Dictionary)->void:
 if not sim.mission.has("module_recovery"):return
 sim.mission.module_recovery.result={"recovered":context.recovered.duplicate(),"lost":context.left.map(func(module):return module.item),"recovered_drones":context.recovered_drones.duplicate()}
static func valid(data:Dictionary)->bool:
 var mission=data.mission
 if mission.has("fleet_commit") and not mission.fleet_commit is bool:return false
 if not mission.has("module_recovery"):return true
 var state=mission.module_recovery
 if not state is Dictionary or state.size()!=4 or not state.get("modules") is Dictionary or not state.get("jobs") is Array or state.jobs.size()!=3 or not state.get("result") is Dictionary or not state.get("deferred") is String:return false
 if not mission.get("launch_equipment",{}) is Dictionary:return false
 var launched=[]
 for id in [1,2]:
  launched.append_array(Catalog.items_for(mission.get("launch_equipment",{}),id))
 if state.modules.size()!=launched.size():return false
 var dimensions=mission.get("world_size",preload("res://src/simulation/world_region.gd").LEGACY_SIZE)
 if not dimensions is Vector2 or not dimensions.is_finite():return false
 for item in state.modules:
  var module=state.modules[item]
  if item not in launched or not module is Dictionary or module.size()!=3 or not module.get("state") in ["fitted","salvage","cargo"] or not module.get("unit") is int or not module.get("pos") is Vector2 or not module.pos.is_finite() or not Rect2(Vector2.ZERO,dimensions).has_point(module.pos):return false
  if module.state=="salvage":
   if module.unit!=-1:return false
  elif module.unit not in [0,1,2]:return false
  elif module.state=="fitted" and (module.unit==0 or not Catalog.has(mission.launch_equipment,module.unit,item)):return false
 var claimed=[]
 for job in state.jobs:
  if not job is Dictionary:return false
  if job.is_empty():continue
  if job.size()!=2 or not job.get("item") in state.modules or job.item in claimed or state.modules[job.item].state!="salvage" or not (job.get("elapsed") is float or job.get("elapsed") is int) or not is_finite(job.elapsed) or job.elapsed<0 or job.elapsed>DURATION:return false
  claimed.append(job.item)
 if not state.result.is_empty():
  if data.get("outcome","")!="won" or state.result.size()!=3 or not Inventory._partition(state.result.get("recovered"),state.result.get("lost"),launched) or not state.result.get("recovered_drones") is Array:return false
  var seen=[]
  for id in state.result.recovered_drones:
   if id not in [1,2] or id in seen:return false
   seen.append(id)
 return true

static func collect_at(sim,unit_id:int,pos:Vector2)->void:
 if not sim.mission.has("module_recovery"):return
 for item in sim.mission.module_recovery.modules:
  var module=sim.mission.module_recovery.modules[item]
  if module.state=="salvage" and module.pos.distance_to(pos)<=1 and sim.Depth.cargo_band(sim,item)==sim.units[unit_id].band and carried(sim,unit_id)<capacity(sim,unit_id):module.state="cargo";module.unit=unit_id
