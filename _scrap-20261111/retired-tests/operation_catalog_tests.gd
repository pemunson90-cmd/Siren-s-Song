extends SceneTree
const Missions=preload("res://src/campaign/missions.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 preload("res://tests/operation_catalog_scenarios.gd").run(self)
 print("OPERATION CATALOG CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
