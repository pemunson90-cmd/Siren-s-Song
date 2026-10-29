extends RefCounted
# 098 editable racks, extended by100 lockers. Only overflow consumes general cargo.
# Cargo uses exact hundredths, rounded only when a whole winch place is requested.
# Seams: Main archive/launch, rack view, field tool stock and ModuleRecovery.capacity_data.
# Revert: enabled=false bypasses cargo/editing and restores template seed; retain optional save validation.
# Torpedoes and hull patches remain Quietus-only. All numbers are AI-DESIGNED, provisional.
const enabled=true
const Tools=preload("res://src/equipment/field_tools.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Economy=preload("res://src/campaign/economy.gd")
const UNITS=["quietus","drone_a","drone_b"]
const QUIETUS_ONLY=["knock","hull_patch"]
const MAX_COUNT=9
const CHARGE_PRICE={"scrap":1,"cells":1}
static func empty()->Dictionary:return {"quietus":{},"drone_a":{},"drone_b":{}}
const ARCHIVE_VERSION=100
# Original role allocation: Quietus keeps legacy tools and patch; A listens; B carries field support.
# The largest original bundle is SURVEY: .95 Quietus, .15 A, .50 B.
# All hulls/chassis, including zero-cargo scout, keep these separate tool lockers.
static func template(choice:String)->Dictionary:
 var racks=empty()
 for id in Tools.ids():
  if id in Tools.field_ids() and not Tools.is_enabled(id):continue
  var unit=0 if id in ["emp","decoy","recon","knock","hull_patch"] else (1 if id=="sonobuoy" else 2)
  var n=Tools.loadout_count(id,choice)
  if n>0:racks[UNITS[unit]][id]=n
 return racks
static func migrated(data:Dictionary)->Dictionary:
 # 098 did not record edits: its automatic template and EMPTY ALL are identical.
 # Refill that exact unversioned shape once; any edited keys, even zero, survive.
 if not data.has("tool_racks") or (not data.has("tool_racks_version") and data.tool_racks==empty()):
  return template(data.get("upgrade","endurance"))
 return data.tool_racks.duplicate(true)
static func write_archive(data:Dictionary,racks:Dictionary)->void:
 data["tool_racks"]=racks.duplicate(true)
 data["tool_racks_version"]=ARCHIVE_VERSION
static func valid(value)->bool:
 if not value is Dictionary or value.size()!=3 or not value.has_all(UNITS):return false
 for slot in UNITS:
  if not value[slot] is Dictionary:return false
  for id in value[slot]:
   if id not in Tools.ids() or not value[slot][id] is int:return false
   var n=value[slot][id]
   if n<0 or n>MAX_COUNT or (id=="hull_patch" and n>1) or (slot!="quietus" and id in QUIETUS_ONLY and n>0):return false
 for id in Tools.ids():
  if total(value,id)> (1 if id=="hull_patch" else (2 if id=="knock" else MAX_COUNT)):return false
 return true
static func label(id:String)->String:
 return {"decoy":"DECOYS","knock":"TORPEDOES"}.get(id,Tools.spec(id).name.to_upper())
static func total(racks:Dictionary,id:String)->int:
 var n=0
 for slot in UNITS:n+=int(racks.get(slot,{}).get(id,0))
 return n
static func weight_ticks(racks:Dictionary,unit:int)->int:
 var n=0
 for id in racks.get(UNITS[unit],{}):n+=int(racks[UNITS[unit]][id])*int(Tools.CARGO_WEIGHTS.get(id,0))
 return n
static func locker_ticks(unit:int)->int:return int(Tools.LOCKER_TICKS[UNITS[unit]])
static func locker_used_ticks(racks:Dictionary,unit:int)->int:return mini(weight_ticks(racks,unit),locker_ticks(unit))
static func cargo_ticks(racks:Dictionary,unit:int)->int:
 return maxi(0,weight_ticks(racks,unit)-locker_ticks(unit)) if enabled else 0
static func cargo(racks:Dictionary,unit:int)->float:return cargo_ticks(racks,unit)/100.0
static func room_ticks(fit:Dictionary,racks:Dictionary,unit:int)->int:
 var b=Catalog.budget(fit,unit)
 return int(b.cargo_cap-b.cargo)*100-cargo_ticks(racks,unit)
static func reason(fit:Dictionary,racks)->String:
 if not valid(racks):return "Malformed tool racks"
 if not enabled:return ""
 for unit in 3:
  if room_ticks(fit,racks,unit)<0:return "%s cargo full: unload tools or modules"%Catalog.NAMES[UNITS[unit]]
 return ""
static func cost(racks:Dictionary,choice:String,economy:Dictionary)->Dictionary:
 if not enabled or not preload("res://src/campaign/economy_table.gd").enabled:return {}
 var extras=0
 for id in Tools.ids():extras+=maxi(0,total(racks,id)-Tools.loadout_count(id,choice))
 return Economy.scaled({"scrap":extras*CHARGE_PRICE.scrap,"cells":extras*CHARGE_PRICE.cells},economy)
static func launch(sim,racks:Dictionary)->void:
 if not enabled:return
 var launched=racks.duplicate(true)
 # The 055 master switch removes field state entirely, while legacy tools still seed.
 # Keep supplied legacy racks and omit disabled field charges from the launched copy.
 for slot in UNITS:
  for id in Tools.field_ids():
   if not Tools.is_enabled(id):launched[slot].erase(id)
 sim.mission["tool_racks"]=launched
 for id in sim.tools:sim.tools[id]=total(launched,id)
 if sim.mission.has("field_tools"):
  for id in Tools.field_ids():sim.mission.field_tools.counts[id]=total(launched,id)
static func sync_legacy(sim)->void:
 if not sim.mission.has("tool_racks"):return
 for id in sim.tools:
  var spent=total(sim.mission.tool_racks,id)-int(sim.tools[id])
  if spent>0:
   var rack=sim.mission.tool_racks[UNITS[sim.selected]]
   rack[id]=maxi(0,int(rack.get(id,0))-spent)
static func count(sim,id:String)->int:
 if sim.mission.has("tool_racks"):
  return int(sim.mission.tool_racks[UNITS[sim.selected]].get(id,0))
 if id in sim.tools:return int(sim.tools[id])
 return int(sim.mission.get("field_tools",{}).get("counts",{}).get(id,0))
static func spend(sim,id:String)->void:
 if sim.mission.has("tool_racks"):
  var rack=sim.mission.tool_racks[UNITS[sim.selected]]
  rack[id]=int(rack.get(id,0))-1
static func winch_capacity(mission:Dictionary,unit:int)->int:
 var racks=mission.get("tool_racks",empty())
 # Capacity is queried by earlier save validators too; malformed stock must fail closed.
 if not valid(racks):return 0
 return maxi(0,floori(room_ticks(mission.get("launch_equipment",{}),racks,unit)/100.0))
# Explain only a refusal that unloading tools would actually resolve.
static func full_reason(mission:Dictionary,unit:int,carried:int,fallback:String)->String:
 var fit=mission.get("launch_equipment",{})
 var b=Catalog.budget(fit,unit)
 if carried>=winch_capacity(mission,unit) and carried<maxi(0,b.cargo_cap-b.cargo):
  return "Hold full of tools: unload at the fittings screen"
 return fallback
static func valid_archive(data:Dictionary)->bool:
 if data.has("tool_racks_version"):
  if not data.tool_racks_version is int or data.tool_racks_version!=ARCHIVE_VERSION or not data.has("tool_racks"):return false
 return not data.has("tool_racks") or valid(data.tool_racks)
static func valid_snapshot(data:Dictionary)->bool:
 var mission=data.mission
 if not mission.has("tool_racks"):return true
 if not valid(mission.tool_racks) or not reason(mission.get("launch_equipment",{}),mission.tool_racks).is_empty():return false
 for id in Tools.ids():
  var aggregate=data.tools.get(id,0) if id in data.tools else mission.get("field_tools",{}).get("counts",{}).get(id,0)
  if total(mission.tool_racks,id)!=aggregate:return false
 return true
