extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 preload("res://tests/sweeper_scenarios.gd").run(self)
 print("SWEEPER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
