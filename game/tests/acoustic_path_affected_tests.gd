extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	preload("res://tests/acoustic_scenarios.gd").run(self)
	preload("res://tests/siren_role_scenarios.gd").run(self)
	preload("res://tests/observed_contact_scenarios.gd").run(self)
	print("AFFECTED ACOUSTIC CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
