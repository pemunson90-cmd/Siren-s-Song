extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 load("res://tests/core_scenarios.gd").run(self)
 load("res://tests/split_channel_scenarios.gd").run(self)
 print("ACOUSTIC COMPOSITION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
