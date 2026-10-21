extends RefCounted
const Budgets=preload("res://src/campaign/endurance_budgets.gd")
const CraftUpgrades=preload("res://src/equipment/craft_upgrades.gd")
static func profile(id:int)->Dictionary:
 return Budgets.for_mission(id)
static func oxygen_drain(mission:Dictionary,dt:float)->float:
 var budget=mission.get("endurance",profile(mission.id))
 return dt*100.0/budget.oxygen_seconds*CraftUpgrades.life_support(mission.get("launch_equipment",{}))
static func battery_drain(mission:Dictionary,unit_id:int,propulsion_speed:float,dt:float)->float:
 var budget=mission.get("endurance",profile(mission.id))
 # Electronics remain active at HOLD. Through-water effort includes real
 # counterthrust against current, rather than rewarding motionless engines.
 var effort=clampf(propulsion_speed/96.0,0,1)
 var work=.35+.65*effort*effort
 var hardware=CraftUpgrades.battery_drain(mission.get("launch_equipment",{}),unit_id,1.0)*14.0
 return dt*100.0/budget.drone_seconds*work*hardware
