extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Table=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize()->void:
 for id in Catalog.registered_ids():
  check(id>=0 and id<Table.CAPS.size(),"explicit Hunt cap for catalog operation %d"%id)
 var sorley={"id":41,"reconnaissance":{"hunt":95.}}
 Hunt.initialize(sorley)
 check(is_equal_approx(Hunt.view_mission(sorley).cap,1.3),"Sorley uses neighbouring optional range cap 1.30")
 check(is_equal_approx(Hunt.sight(sorley,{"type":"hunter"},1.),1.3),"Sorley Hunt sharpens eligible sight at high pressure")
 sorley.reconnaissance.hunt=0.
 check(Hunt.sight(sorley,{"type":"hunter"},1.)==1.,"Sorley low Hunt retains base sight")
 print("HUNT CAP COVERAGE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
