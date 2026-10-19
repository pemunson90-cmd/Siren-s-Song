extends SceneTree
var checks=0
var failures=0
func check(value,message):
 checks+=1
 if not value: failures+=1; printerr("FAIL: ",message)
func _initialize():
 preload("res://tests/patrol_scenarios.gd").run(self)
 print("CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
