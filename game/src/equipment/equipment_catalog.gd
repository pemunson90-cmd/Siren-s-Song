extends RefCounted
# Persistent hardware is optional. Campaign recovery owns entitlements; this
# catalog cannot award them or change equipment on an already launched mission.
const SLOTS=["quietus","drone_a","drone_b"]
const ITEMS={
 "quietus_baffles":{"id":"quietus_baffles","name":"Quietus acoustic baffles","compatible_slots":["quietus"],"benefit":"Reduce propulsion sound by45% at the same actual speed.","cost":"Uses Quietus hardware slot."},
 "quietus_vector_drive":{"id":"quietus_vector_drive","name":"Quietus vector drive","compatible_slots":["quietus"],"benefit":"Cruise at112m/s instead of78m/s; silent speed remains42m/s.","cost":"Fast cruise makes more motion noise. Uses Quietus hardware slot."},
 "drone_survey_array":{"id":"drone_survey_array","name":"Drone survey array","compatible_slots":["drone_a","drone_b"],"benefit":"Extend this drone's ordinary passive and chart reach from330m to460m.","cost":"Uses one drone hardware slot."},
 "drone_deep_cells":{"id":"drone_deep_cells","name":"Drone deep cells","compatible_slots":["drone_a","drone_b"],"benefit":"Double this drone's operating endurance.","cost":"Uses one drone hardware slot."},
 "quietus_correlator":{"id":"quietus_correlator","name":"Cadence correlator","compatible_slots":["quietus"],"benefit":"Compare fresh received cadence with a recovered reference before close source acquisition.","cost":"Settle below 12m/s for 6 seconds. Matching cadence does not prove identity, range or safety."},
 "drone_sampler":{"id":"drone_sampler","name":"Field sampler pod","compatible_slots":["drone_a","drone_b"],"benefit":"Prepare compatible field receivers remotely while Quietus takes another task.","cost":"One pod on one drone. An 8-second local exposure emits camera noise; Quietus can prepare the same receiver in 4 seconds."}
}
static func valid_fitting(value)->bool:
 if not value is Dictionary:return false
 var used=[]
 for slot in value:
  if slot not in SLOTS or not value[slot] is String:return false
  var item=value[slot]
  if item.is_empty():continue
  if not ITEMS.has(item) or slot not in ITEMS[item].compatible_slots or item in used:return false
  used.append(item)
 return true
static func choose(previous:Dictionary,slot:String,item:String,entitlements:Array)->Dictionary:
 if not valid_fitting(previous) or slot not in SLOTS:return {"ok":false}
 if not item.is_empty() and (item not in entitlements or not ITEMS.has(item)):return {"ok":false}
 var fitted=previous.duplicate(true);fitted[slot]=item
 if not valid_fitting(fitted):return {"ok":false}
 return {"ok":true,"fitted":fitted}
static func public_catalog(entitlements:Array)->Array:
 var result=[]
 for id in ITEMS:
  if id in entitlements:result.append(ITEMS[id].duplicate(true))
 return result
static func item_for(fitted:Dictionary,unit_id:int)->String:
 if unit_id<0 or unit_id>=SLOTS.size() or not valid_fitting(fitted):return ""
 return fitted.get(SLOTS[unit_id],"")
