extends RefCounted
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Acoustics=preload("res://src/simulation/acoustic_paths.gd")
# Conventional hardware enters the existing recovery/fitting path in pairs.
# Alien hardware remains owned by research; these milestones grant none of it.
const RECOVERY_GRANTS={
 9:["quietus_ducted_shroud","drone_ballast_pack"],
 11:["quietus_scrubber_bed","drone_mast_array"],
 16:["quietus_long_hydrophone","drone_whisper_props"],
 22:["quietus_reserve_cell","quietus_camera_cowl"]
}
# Recovery queries award general craft hardware; field notes do not award it.
static func recovered(tutorial_completed:Array,expedition:Dictionary,intel:Dictionary={})->Array:
 var result:Array=expedition.get("entitlements",[]).duplicate()
 var earned=[]
 if 5 in tutorial_completed:earned.append_array(["quietus_vector_drive","drone_deep_cells"])
 if 7 in expedition.get("completed",[]):earned.append("quietus_baffles")
 if 8 in expedition.get("completed",[]):earned.append("drone_survey_array")
 earned.append_array(preload("res://src/campaign/photo_intel.gd").projects(intel))
 var completed=tutorial_completed+expedition.get("completed",[])
 for milestone in RECOVERY_GRANTS:
  if milestone in completed:earned.append_array(RECOVERY_GRANTS[milestone])
 for item in earned:
  if item not in result:result.append(item)
 return result
# Budgets of the launched frame. A standard frame returns exactly 1 everywhere.
static func noise_factor(fitted:Dictionary,unit_id:int)->float:
 return maxf(0.1,Catalog.budget(fitted,unit_id).noise)
static func endurance_factor(fitted:Dictionary,unit_id:int)->float:
 return maxf(0.1,Catalog.budget(fitted,unit_id).endurance)
static func motion_radius(fitted:Dictionary,unit_id:int,speed:float)->float:
 return Acoustics.motion_radius(speed)*(0.55 if unit_id==0 and Catalog.has(fitted,0,"quietus_baffles") else 1.0)*noise_factor(fitted,unit_id)
static func cruise_speed(fitted:Dictionary)->float:
 var base=112.0 if Catalog.has(fitted,0,"quietus_vector_drive") else 78.0
 return base*Catalog.frame(fitted,0).speed*(1.0+Catalog.stat(fitted,0,"speed"))
# Hull drive multiplier for any other Quietus speed (silent running, routes).
static func frame_speed(fitted:Dictionary,unit_id:int,speed:float)->float:
 return speed*Catalog.frame(fitted,0).speed if unit_id==0 else speed
static func passive_range(fitted:Dictionary,unit_id:int)->float:
 if unit_id==0:return 240.0*(1.0+Catalog.stat(fitted,0,"reach"))
 var base=460.0 if Catalog.has(fitted,unit_id,"drone_survey_array") else 330.0
 return base*Catalog.frame(fitted,unit_id).get("reach",1.0)*(1.0+Catalog.stat(fitted,unit_id,"reach"))
static func battery_drain(fitted:Dictionary,unit_id:int,dt:float)->float:
 return dt/(28.0 if Catalog.has(fitted,unit_id,"drone_deep_cells") else 14.0)/endurance_factor(fitted,unit_id)
# Quietus life support lasts longer or shorter with the hull endurance budget.
static func life_support(fitted:Dictionary)->float:
 return 1.0/endurance_factor(fitted,0)
# SONAR reserve cost. A bus drawn to its full capacity leaves no headroom and
# each pulse costs half again as much; a spare point keeps the frame rate.
static func pulse_cost(fitted:Dictionary,unit_id:int)->float:
 var b=Catalog.budget(fitted,unit_id)
 return Catalog.frame(fitted,unit_id).get("pulse",1.0)*(1.5 if b.power>0 and b.power>=b.power_cap else 1.0)
# Winch places left for recovered modules after fitted items take theirs.
static func cargo_free(fitted:Dictionary,unit_id:int)->int:
 var b=Catalog.budget(fitted,unit_id)
 return maxi(0,b.cargo_cap-b.cargo)
