extends RefCounted
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Acoustics=preload("res://src/simulation/acoustic_paths.gd")
# Recovery queries award general craft hardware; field notes do not award it.
static func recovered(tutorial_completed:Array,expedition:Dictionary)->Array:
 var result:Array=expedition.get("entitlements",[]).duplicate()
 var earned=[]
 if 5 in tutorial_completed:earned.append_array(["quietus_vector_drive","drone_deep_cells"])
 if 7 in expedition.get("completed",[]):earned.append("quietus_baffles")
 if 8 in expedition.get("completed",[]):earned.append("drone_survey_array")
 for item in earned:
  if item not in result:result.append(item)
 return result
static func motion_radius(fitted:Dictionary,unit_id:int,speed:float)->float:
 return Acoustics.motion_radius(speed)*(0.55 if unit_id==0 and Catalog.item_for(fitted,unit_id)=="quietus_baffles" else 1.0)
static func cruise_speed(fitted:Dictionary)->float:
 return 112.0 if Catalog.item_for(fitted,0)=="quietus_vector_drive" else 78.0
static func passive_range(fitted:Dictionary,unit_id:int)->float:
 if unit_id==0:return 240.0
 return 460.0 if Catalog.item_for(fitted,unit_id)=="drone_survey_array" else 330.0
static func battery_drain(fitted:Dictionary,unit_id:int,dt:float)->float:
 return dt/(28.0 if Catalog.item_for(fitted,unit_id)=="drone_deep_cells" else 14.0)
