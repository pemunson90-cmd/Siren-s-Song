extends RefCounted
# 107: physical Ironman losses. Missing bays stay empty until paid manufacturing.
# Optional economy block migrates lazily; no retrospective losses. Numbers are in economy_table.
# Revert: enabled=false ignores the block without damaging an existing profile.
static var enabled=true
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
static func fresh()->Dictionary:return {"drones":[],"modules":[],"counts":{},"last":[]}
static func active(e:Dictionary)->bool:return enabled and e.get("ironman",false)
static func state(e:Dictionary)->Dictionary:return e.get("permanent_losses",fresh())
static func missing(e:Dictionary,id:int)->bool:return active(e) and id in state(e).drones
static func available(e:Dictionary,items:Array)->Array:
 return items.filter(func(item):return item not in state(e).modules) if active(e) else items
static func fitting(e:Dictionary,fit:Dictionary)->Dictionary:
 if not active(e):return fit
 var result=fit.duplicate(true)
 for id in 3:
  for mount in Catalog.MOUNT_KEYS[Catalog.SLOTS[id]]:
   if missing(e,id) or result.get(mount,"") in state(e).modules:result[mount]=""
 return result
static func racks(e:Dictionary,stock:Dictionary)->Dictionary:
 var result=stock.duplicate(true)
 for id in [1,2]:
  if missing(e,id):result["drone_a" if id==1 else "drone_b"]={}
 return result
static func migrated(e:Dictionary)->Dictionary:
 var result=e.duplicate(true)
 if not result.has("permanent_losses"):result.permanent_losses=fresh()
 return result
static func apply(e:Dictionary,sim)->void:
 for id in [1,2]:
  if missing(e,id):sim.units[id].alive=false;sim.units[id].battery=0.
static func name(id:String)->String:
 if id in ["drone_a","drone_b"]:return id.replace("_"," ").to_upper()
 return Catalog.ITEMS.get(id,{}).get("name",id)
static func line(id:String,count:int=1)->String:
 return "PERMANENT LOSS: %s%s."%[name(id)," x%d"%count if count>1 else ""]
static func lines(e:Dictionary,last:bool=false)->Array:
 var result=[]
 if not active(e):return result
 var s=state(e)
 for id in (s.last if last else s.counts.keys()):result.append(line(id,1 if last else s.counts[id]))
 return result
# Called behind Economy.settle's once-per-launch guard. Only existing recovery receipts
# can save modules/carriers; a failed dive has no physical recovery receipt.
static func settle(e:Dictionary,facts:Dictionary)->void:
 if not active(e):return
 var s=state(e).duplicate(true);s.last=[]
 var mission=facts.get("mission",{})
 var receipt=mission.get("module_recovery",{}).get("result",{}) if facts.outcome=="won" else {}
 var fit=mission.get("launch_equipment",e.last_fit)
 for id in [1,2]:
  if id in s.drones:continue
  var home=id in receipt.get("recovered_drones",[]) if facts.outcome=="won" else false
  # Legacy terminal saves without a physical receipt use survival only.
  if facts.outcome=="won" and receipt.is_empty():home=facts.alive[id-1]
  if not home:
   s.drones.append(id);s.last.append("drone_a" if id==1 else "drone_b")
 for id in [1,2]:
  for item in Catalog.items_for(fit,id):
   if item in s.modules:continue
   var lost=item in receipt.get("lost",[]) if facts.outcome=="won" else true
   if lost:
    s.last.append(item)
    if e.spares.get(item,0)>0:e.spares.erase(item)
    else:s.modules.append(item)
 for item in s.last:s.counts[item]=s.counts.get(item,0)+1
 e.permanent_losses=s
static func valid(value)->bool:
 if not value is Dictionary or value.size()!=4 or not value.has_all(["drones","modules","counts","last"]):return false
 if not value.drones is Array or not value.modules is Array or not value.counts is Dictionary or not value.last is Array:return false
 if value.drones.size()>2 or value.modules.size()>Catalog.ITEMS.size() or value.counts.size()>Catalog.ITEMS.size()+2 or value.last.size()>Catalog.ITEMS.size()+2:return false
 for id in value.drones:
  if not id is int or id not in [1,2] or value.drones.count(id)!=1:return false
 for item in value.modules+value.last+value.counts.keys():
  if not item is String or (item not in ["drone_a","drone_b"] and (not Catalog.ITEMS.has(item) or not Catalog.ITEMS[item].compatible_slots.any(func(slot):return slot in ["drone_a","drone_b"]))):return false
 for item in value.modules:
  if item in ["drone_a","drone_b"] or value.modules.count(item)!=1:return false
 for item in value.last:
  if value.last.count(item)!=1 or not value.counts.has(item):return false
 for item in value.counts:
  if not value.counts[item] is int or value.counts[item]<1:return false
 return true
