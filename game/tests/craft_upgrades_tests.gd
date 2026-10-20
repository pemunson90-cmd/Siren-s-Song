extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/equipment/craft_upgrades.gd"
 if not ResourceLoader.exists(path):check(false,"persistent general craft upgrades exist")
 else:
  var Upgrades=load(path);var Catalog=load("res://src/equipment/equipment_catalog.gd")
  var base={"quietus":"","drone_a":"","drone_b":""}
  var tutorial=Upgrades.recovered([0,1,2,3,4,5],{})
  check("quietus_vector_drive" in tutorial and "drone_deep_cells" in tutorial,"tutorial5 grants general submarine and drone growth")
  check(Upgrades.recovered([0,1,2,3,4],{}).is_empty(),"unfinished tutorial grants no hardware")
  var progress={"completed":[6,7,8],"entitlements":["drone_sampler"]};var copy=progress.duplicate(true)
  var all=Upgrades.recovered([5],progress)
  check(all.size()==5 and "quietus_baffles" in all and "drone_survey_array" in all and "drone_sampler" in all,"both branches yield general capabilities and keep existing recovered equipment")
  check(progress==copy,"reward query does not mutate campaign")
  var fit=base.duplicate();fit.quietus="quietus_baffles"
  check(Catalog.choose(base,"quietus","quietus_baffles",all).ok and not Catalog.choose(base,"drone_a","quietus_baffles",all).ok,"existing fitting flow equips genuine compatible hardware")
  check(Upgrades.motion_radius(fit,0,78)<Upgrades.motion_radius(base,0,78) and Upgrades.motion_radius(fit,1,78)==Upgrades.motion_radius(base,1,78),"baffles reduce submarine actual sound rather than drone sound")
  check(Upgrades.motion_radius(fit,0,42)>0 and Upgrades.motion_radius(fit,0,0)==0,"residual movement stays audible and stationary drive adds none")
  fit.quietus="quietus_vector_drive"
  check(Upgrades.cruise_speed(fit)>Upgrades.cruise_speed(base),"vector drive adds general cruise speed")
  fit=base.duplicate();fit.drone_a="drone_survey_array"
  check(Upgrades.passive_range(fit,1)>Upgrades.passive_range(base,1) and Upgrades.passive_range(fit,0)==240 and Upgrades.passive_range(fit,2)==330,"survey array expands only fitted drone sensing")
  fit.drone_a="drone_deep_cells"
  check(Upgrades.battery_drain(fit,1,10)<Upgrades.battery_drain(base,1,10) and Upgrades.battery_drain(fit,2,10)==Upgrades.battery_drain(base,2,10),"deep cells lengthen actual fitted-drone endurance")
  check(Catalog.public_catalog(all).size()==5,"existing public fitting list exposes earned general upgrades")
 print("CRAFT UPGRADES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
