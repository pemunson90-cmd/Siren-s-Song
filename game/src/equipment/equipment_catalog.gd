extends RefCounted
# Persistent hardware is optional. Campaign recovery owns entitlements; this
# catalog cannot award them or change equipment on an already launched mission.
# A fit names one hull, one chassis per drone and items held in typed mounts.
# Absent keys mean the standard frame or an empty mount, so the original three
# key fit {"quietus","drone_a","drone_b"} still reads as the standard loadout.
const Hulls=preload("res://src/equipment/hulls.gd")
const Chassis=preload("res://src/equipment/chassis.gd")
const SLOTS=["quietus","drone_a","drone_b"]
const NAMES={"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}
const FRAME_KEYS={"quietus":"hull","drone_a":"chassis_a","drone_b":"chassis_b"}
const MOUNT_KEYS={"quietus":["quietus","quietus_2","quietus_3","quietus_4","quietus_5","quietus_6"],"drone_a":["drone_a","drone_a_2","drone_a_3","drone_a_4","drone_a_5"],"drone_b":["drone_b","drone_b_2","drone_b_3","drone_b_4","drone_b_5"]}
# power: draw on the craft bus; cargo: winch places the item occupies; noise and
# endurance: additive changes to the frame multipliers.
const ITEMS={
 "quietus_pressure_sleeve":{"id":"quietus_pressure_sleeve","name":"Choir pressure sleeve","compatible_slots":["quietus"],"mount":"HARDWARE","power":2,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Adjacent depth transition takes2.5s instead of4s, still exposed in both bands.","cost":"Each change spends0.75 reserve and emits a250m pump pulse."},
 "drone_traction_yoke":{"id":"drone_traction_yoke","name":"Choir traction yoke","compatible_slots":["drone_a","drone_b"],"mount":"CARGO","power":1,"cargo":1,"noise":0.0,"endurance":0.0,"benefit":"This drone can tow industrial loads through narrow service water.","cost":"Tow speed capped22m/s with extra propulsion noise. Bare Quietus tows wider water at28m/s."},
 "quietus_prism":{"id":"quietus_prism","name":"Reach directional prism","compatible_slots":["quietus"],"mount":"SENSOR","power":2,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Forward SONAR reaches40% farther.","cost":"Forward pulses cost double reserve and emit25% farther. All-around sonar unchanged."},
 "quietus_decoder":{"id":"quietus_decoder","name":"Range service decoder","compatible_slots":["quietus"],"mount":"UTILITY","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Open nearby Reach service gates quietly in2s within120m, after measuring their local position.","cost":"Bare manual work takes8 audible seconds within60m; outside routes remain available."},
 "quietus_baffles":{"id":"quietus_baffles","name":"Quietus acoustic baffles","compatible_slots":["quietus"],"mount":"PROPULSION","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Reduce propulsion sound by45% at the same actual speed.","cost":"Occupies the propulsion mount."},
 "quietus_vector_drive":{"id":"quietus_vector_drive","name":"Quietus vector drive","compatible_slots":["quietus"],"mount":"PROPULSION","power":2,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Cruise at112m/s instead of78m/s; silent speed remains42m/s.","cost":"Fast cruise makes more motion noise. Occupies the propulsion mount."},
 "drone_survey_array":{"id":"drone_survey_array","name":"Drone survey array","compatible_slots":["drone_a","drone_b"],"mount":"SENSOR","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Extend this drone's ordinary passive and chart reach from330m to460m.","cost":"Occupies the drone sensor mount."},
 "drone_deep_cells":{"id":"drone_deep_cells","name":"Drone deep cells","compatible_slots":["drone_a","drone_b"],"mount":"HARDWARE","power":0,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Double this drone's operating endurance.","cost":"Occupies the drone hardware mount."},
 "quietus_correlator":{"id":"quietus_correlator","name":"Cadence correlator","compatible_slots":["quietus"],"mount":"SENSOR","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Compare fresh received cadence with a recovered reference before close source acquisition.","cost":"Settle below 12m/s for 6 seconds. Matching cadence does not prove identity, range or safety."},
 "quietus_tele_lens":{"id":"quietus_tele_lens","name":"Tele lens","compatible_slots":["quietus"],"mount":"OPTICS","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Photograph from 50% farther with a narrower frame and a longer sweet spot.","cost":"Narrow field: close or wide subjects crop, and hull motion blurs the frame sooner."},
 "photo_flash":{"id":"photo_flash","name":"Flash unit","compatible_slots":["quietus","drone_a","drone_b"],"mount":"OPTICS","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Lights a subject within about 200m for a sharp frame in the dark. Four charges on Quietus, two on a drone.","cost":"Each flash exposure is a louder audible camera event and spends a charge."},
 "thermal_imager":{"id":"thermal_imager","name":"Thermal imager","compatible_slots":["quietus","drone_a","drone_b"],"mount":"OPTICS","power":1,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"Resolves heat features at range and through thermal shimmer, with no light needed.","cost":"15% lower resolution on every other feature."},
 "low_light_back":{"id":"low_light_back","name":"Low-light film back","compatible_slots":["quietus","drone_a","drone_b"],"mount":"OPTICS","power":0,"cargo":0,"noise":0.0,"endurance":0.0,"benefit":"A still exposure gathers light over eight seconds: dark subjects sharpen without a flash.","cost":"Gain is lost if the craft drifts or turns; short exposures see no benefit."},
 "drone_sampler":{"id":"drone_sampler","name":"Field sampler pod","compatible_slots":["drone_a","drone_b"],"mount":"UTILITY","power":1,"cargo":1,"noise":0.0,"endurance":0.0,"benefit":"Prepare compatible field receivers and operate the powered Warning Chain panel while Quietus takes another task.","cost":"One pod on one drone. Receiver exposure takes8 audible seconds; Quietus takes4. Plant switches require a settled local connection."},
 # C2 equipment: 8 conventional rows, then 2 alien rows that research grants (campaign/glass_research.gd).
 # Optional keys: reach and speed are fractions added to passive reach and Quietus cruise (craft_upgrades.gd).
 "quietus_ducted_shroud":{"id":"quietus_ducted_shroud","name":"Ducted prop shroud","compatible_slots":["quietus"],
  "mount":"PROPULSION","power":1,"cargo":0,"noise":-0.15,"endurance":0.0,"speed":-0.08,
  "benefit":"Motion sound 15% lower at the same speed.","cost":"Cruise 8% slower. Occupies the propulsion mount."},
 "quietus_scrubber_bed":{"id":"quietus_scrubber_bed","name":"Regen scrubber bed","compatible_slots":["quietus"],
  "mount":"UTILITY","power":1,"cargo":0,"noise":0.1,"endurance":0.25,
  "benefit":"Life support lasts 25% longer.","cost":"Fan hum raises motion sound 10%."},
 "quietus_long_hydrophone":{"id":"quietus_long_hydrophone","name":"Long hydrophone","compatible_slots":["quietus"],
  "mount":"SENSOR","power":2,"cargo":0,"noise":0.05,"endurance":0.0,"reach":0.2,
  "benefit":"Quietus passive reach 20% longer.","cost":"Draws 2 power and towing drag adds 5% motion sound."},
 "quietus_reserve_cell":{"id":"quietus_reserve_cell","name":"Reserve air cell","compatible_slots":["quietus"],
  "mount":"HARDWARE","power":1,"cargo":1,"noise":0.0,"endurance":0.2,
  "benefit":"Life support lasts 20% longer.","cost":"Takes one winch place and one power."},
 "quietus_camera_cowl":{"id":"quietus_camera_cowl","name":"Streamlined camera cowl","compatible_slots":["quietus"],
  "mount":"OPTICS","power":1,"cargo":0,"noise":-0.1,"endurance":0.0,
  "benefit":"Motion sound 10% lower.","cost":"Fills the camera mount, so no optics module rides with it."},
 "drone_ballast_pack":{"id":"drone_ballast_pack","name":"Drone ballast pack","compatible_slots":["drone_a","drone_b"],
  "mount":"CARGO","power":0,"cargo":1,"noise":0.0,"endurance":0.3,
  "benefit":"This drone's battery lasts 30% longer.","cost":"Takes one winch place."},
 "drone_mast_array":{"id":"drone_mast_array","name":"Drone mast array","compatible_slots":["drone_a","drone_b"],
  "mount":"SENSOR","power":0,"cargo":0,"noise":0.0,"endurance":-0.15,"reach":0.12,
  "benefit":"This drone's passive reach is 12% longer.","cost":"Mast drain shortens battery 15%."},
 "drone_whisper_props":{"id":"drone_whisper_props","name":"Drone whisper props","compatible_slots":["drone_a","drone_b"],
  "mount":"UTILITY","power":1,"cargo":0,"noise":-0.2,"endurance":-0.15,
  "benefit":"This drone's motion sound is 20% lower.","cost":"Slow props shorten battery 15%."},
 "quietus_wellhead_seal":{"id":"quietus_wellhead_seal","name":"Trench wellhead seal","compatible_slots":["quietus"],
  "mount":"HARDWARE","power":2,"cargo":1,"noise":0.15,"endurance":0.4,
  "origin":"alien","gate":"research","artifact":"trench_seal_core",
  "benefit":"Life support lasts 40% longer. AI-DESIGNED: marked optional pump/lift work takes6s instead of12s, with half the sound radius and audible time.","cost":"Pump hum raises motion sound 15%. Two power, one winch place."},
 "drone_choir_tuner":{"id":"drone_choir_tuner","name":"Choir reed tuner","compatible_slots":["drone_a","drone_b"],
  "mount":"SENSOR","power":1,"cargo":0,"noise":0.15,"endurance":0.0,"reach":0.3,
  "origin":"alien","gate":"research","artifact":"choir_reed",
  "benefit":"This drone's passive reach is 30% longer. AI-DESIGNED: this drone works marked optional reed/service machinery silently from its own position; bare work stays audible.","cost":"The reed tone raises its motion sound 15%."}
}
static func default_loadout()->Dictionary:
 var result={"hull":Hulls.DEFAULT,"chassis_a":Chassis.DEFAULT,"chassis_b":Chassis.DEFAULT}
 for slot in SLOTS:
  for key in MOUNT_KEYS[slot]:result[key]=""
 return result
static func canonical(fit:Dictionary)->Dictionary:
 var result=default_loadout()
 for key in fit:result[key]=fit[key]
 return result
static func _unit_of(key:String)->String:
 for slot in SLOTS:
  if key in MOUNT_KEYS[slot] or key==FRAME_KEYS[slot]:return slot
 return ""
static func frame_id(fit:Dictionary,unit_id:int)->String:
 if unit_id<0 or unit_id>=SLOTS.size():return ""
 return fit.get(FRAME_KEYS[SLOTS[unit_id]],Hulls.DEFAULT if unit_id==0 else Chassis.DEFAULT)
static func frames(unit_id:int)->Dictionary:
 return Hulls.HULLS if unit_id==0 else Chassis.CHASSIS
# Frame of a validated fit; an invalid fit reads as the standard frame.
static func frame(fit:Dictionary,unit_id:int)->Dictionary:
 if unit_id<0 or unit_id>=SLOTS.size():return {}
 var table=frames(unit_id)
 if not valid_fitting(fit):return table["standard"]
 return table.get(frame_id(fit,unit_id),table["standard"])
static func items_for(fit:Dictionary,unit_id:int)->Array:
 if unit_id<0 or unit_id>=SLOTS.size() or not valid_fitting(fit):return []
 var result=[]
 for key in MOUNT_KEYS[SLOTS[unit_id]]:
  var item=fit.get(key,"")
  if not item.is_empty():result.append(item)
 return result
# Sum of an optional fractional item key (reach, speed) across a unit's fitted items.
static func stat(fit:Dictionary,unit_id:int,key:String)->float:
 var total=0.0
 for item in items_for(fit,unit_id):total+=float(ITEMS[item].get(key,0.0))
 return total
static func has(fit:Dictionary,unit_id:int,item:String)->bool:
 return item in items_for(fit,unit_id)
static func all_items(fit)->Array:
 var result=[]
 if not fit is Dictionary:return result
 for key in fit:
  if _unit_of(key)!="" and key not in FRAME_KEYS.values() and fit[key] is String and not fit[key].is_empty():result.append(fit[key])
 return result
static func key_of(fit:Dictionary,item:String)->String:
 for slot in SLOTS:
  for key in MOUNT_KEYS[slot]:
   if fit.get(key,"")==item:return key
 return ""
# Unit budget summary. Mount rows place items into matching typed mounts in order.
static func budget(fit:Dictionary,unit_id:int)->Dictionary:
 var f=frame(fit,unit_id);var items=items_for(fit,unit_id)
 var result={"frame":f.id,"name":f.name,"power":0,"power_cap":f.power,"cargo":0,"cargo_cap":f.cargo,"noise":f.noise,"endurance":f.endurance,"mounts":[]}
 for item in items:
  var spec=ITEMS[item];result.power+=spec.power;result.cargo+=spec.cargo;result.noise+=spec.noise;result.endurance+=spec.endurance
 var placed=[]
 for type in f.mounts:
  var held=""
  for item in items:
   if item not in placed and ITEMS[item].mount==type:held=item;placed.append(item);break
  result.mounts.append({"type":type,"item":held})
 return result
static func _unit_reason(fit:Dictionary,slot:String)->String:
 var unit_id=SLOTS.find(slot);var table=frames(unit_id)
 var id=fit.get(FRAME_KEYS[slot],"standard")
 if not id is String or not table.has(id):return "Unknown %s frame"%NAMES[slot]
 var f=table[id];var power=0;var cargo=0;var used={}
 for key in MOUNT_KEYS[slot]:
  var item=fit.get(key,"")
  if item.is_empty():continue
  var spec=ITEMS[item]
  if slot not in spec.compatible_slots:return "%s does not fit %s"%[spec.name,NAMES[slot]]
  used[spec.mount]=used.get(spec.mount,0)+1
  if used[spec.mount]>f.mounts.count(spec.mount):return "%s needs a free %s mount on the %s"%[spec.name,spec.mount,f.name.to_lower()]
  power+=spec.power;cargo+=spec.cargo
 if power>f.power:return "%s over power budget %d / %d"%[NAMES[slot],power,f.power]
 if cargo>f.cargo:return "%s over cargo budget %d / %d"%[NAMES[slot],cargo,f.cargo]
 return ""
# Empty reason means a legal fit.
static func reason(value)->String:
 if not value is Dictionary:return "Malformed fit"
 var used=[]
 for key in value:
  var slot=_unit_of(key) if key is String else ""
  if slot.is_empty() or not value[key] is String:return "Malformed fit"
  if key in FRAME_KEYS.values():continue
  var item=value[key]
  if item.is_empty():continue
  if not ITEMS.has(item):return "Unknown fitting"
  if item in used:return "%s is already fitted"%ITEMS[item].name
  used.append(item)
 for slot in SLOTS:
  var why=_unit_reason(value,slot)
  if not why.is_empty():return why
 return ""
# Hot simulation paths ask per tick, so legality is memoised by loadout content.
static var _legal:Dictionary={}
static func valid_fitting(value)->bool:
 if not value is Dictionary:return false
 var key=value.hash()
 if _legal.has(key):return _legal[key]
 var ok=reason(value).is_empty()
 if _legal.size()>512:_legal.clear()
 _legal[key]=ok
 return ok
# key is a unit or mount key for an item (empty item clears that mount), or a
# frame key with a hull/chassis id. Choosing an item for a unit uses a free
# mount, else swaps the unit's item of the same mount type.
static func choose(previous:Dictionary,key:String,item:String,entitlements:Array)->Dictionary:
 if not valid_fitting(previous):return {"ok":false,"reason":"Malformed fit"}
 var slot=_unit_of(key)
 if slot.is_empty():return {"ok":false,"reason":"Unknown mount"}
 var fitted=previous.duplicate(true)
 if key==FRAME_KEYS[slot]:
  if not frames(SLOTS.find(slot)).has(item):return {"ok":false,"reason":"Unknown frame"}
  fitted[key]=item
  var why=reason(fitted)
  return {"ok":why.is_empty(),"fitted":fitted,"reason":why}
 if item.is_empty():
  fitted[key]="";return {"ok":true,"fitted":fitted,"reason":""}
 if not ITEMS.has(item) or item not in entitlements:return {"ok":false,"reason":"Not recovered"}
 if slot not in ITEMS[item].compatible_slots:return {"ok":false,"reason":"%s does not fit %s"%[ITEMS[item].name,NAMES[slot]]}
 var holder=key_of(previous,item)
 if not holder.is_empty():return {"ok":false,"reason":"%s is already fitted on %s"%[ITEMS[item].name,NAMES[_unit_of(holder)]]}
 var target=key
 if key==slot and not fitted.get(key,"").is_empty():
  target=""
  for candidate in MOUNT_KEYS[slot]:
   if fitted.get(candidate,"").is_empty():target=candidate;break
 var attempt=fitted.duplicate(true)
 if not target.is_empty():attempt[target]=item
 var why=reason(attempt) if not target.is_empty() else "No free mount"
 if why.is_empty():return {"ok":true,"fitted":attempt,"reason":""}
 for candidate in MOUNT_KEYS[slot]:
  var current=fitted.get(candidate,"")
  if current.is_empty() or ITEMS[current].mount!=ITEMS[item].mount:continue
  var swap=fitted.duplicate(true);swap[candidate]=item
  if reason(swap).is_empty():return {"ok":true,"fitted":swap,"reason":""}
 return {"ok":false,"reason":why}
static func public_catalog(entitlements:Array)->Array:
 var result=[]
 for id in ITEMS:
  if id in entitlements:result.append(ITEMS[id].duplicate(true))
 return result
