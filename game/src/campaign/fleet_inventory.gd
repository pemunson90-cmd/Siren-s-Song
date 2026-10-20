extends RefCounted
# Entitlements describe discoveries; this ledger records physical modules left
# on a first successful recovery. Failure, retry and replay never spend stock.
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
static func available(earned:Array,fleet:Dictionary={})->Array:
 var lost=[]
 for result in fleet.get("outcomes",{}).values():lost.append_array(result.lost)
 return earned.filter(func(item):return item not in lost)
static func reconcile_fitting(fitted:Dictionary,available_items:Array)->Dictionary:
 var result=fitted.duplicate(true)
 for slot in result:
  if result[slot] not in available_items:result[slot]=""
 return result
static func launch(fitted:Dictionary,earned:Array,fleet:Dictionary,mission_id:int,completed:Array)->Dictionary:
 var missing=[];var stock=available(earned,fleet)
 if not Catalog.valid_fitting(fitted):return {"ok":false,"missing":missing,"launch":{}}
 for item in fitted.values():
  if not item.is_empty() and item not in stock:missing.append(item)
 return {"ok":missing.is_empty(),"missing":missing,"launch":{"fitted":fitted.duplicate(true),"fleet_commit":mission_id not in completed}}
static func recover(previous:Dictionary,mission:Dictionary,outcome:String)->Dictionary:
 var result=previous.duplicate(true)
 if outcome!="won" or not mission.get("fleet_commit",false) or result.get("outcomes",{}).has(mission.id):return result
 var recovery=mission.get("module_recovery",{}).get("result",{})
 if recovery.is_empty():return result
 var launched=[]
 for slot in ["drone_a","drone_b"]:
  var item=mission.get("launch_equipment",{}).get(slot,"")
  if not item.is_empty():launched.append(item)
 if not _partition(recovery.get("recovered"),recovery.get("lost"),launched):return result
 if not result.has("outcomes"):result.outcomes={}
 result.outcomes[mission.id]={"recovered":recovery.recovered.duplicate(),"lost":recovery.lost.duplicate()}
 return result
static func _partition(recovered,lost,expected:Array)->bool:
 if not recovered is Array or not lost is Array:return false
 var seen=[]
 for item in recovered+lost:
  if item not in expected or item in seen:return false
  seen.append(item)
 return seen.size()==expected.size()
static func valid(value,earned:Array,completed:Array)->bool:
 if not value is Dictionary:return false
 if value.is_empty():return true
 if value.size()!=1 or not value.get("outcomes") is Dictionary or value.outcomes.size()>preload("res://src/campaign/operation_catalog.gd").registered_ids().size():return false
 var lost=[]
 for id in value.outcomes:
  if not id is int or id not in preload("res://src/campaign/operation_catalog.gd").registered_ids() or id not in completed:return false
  var result=value.outcomes[id]
  if not result is Dictionary or result.size()!=2 or not result.get("recovered") is Array or not result.get("lost") is Array:return false
  var seen=[]
  for item in result.recovered+result.lost:
   if (item not in Catalog.ITEMS or not Catalog.ITEMS[item].compatible_slots.any(func(slot):return slot in ["drone_a","drone_b"])) or item not in earned or item in seen or item in lost:return false
   seen.append(item)
  lost.append_array(result.lost)
 return true
