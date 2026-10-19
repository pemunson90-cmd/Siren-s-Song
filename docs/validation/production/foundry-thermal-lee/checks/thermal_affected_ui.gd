extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="thermal-affected-ui";root.add_child(game)
 for n in 4:await process_frame
 await preload("res://tests/observed_contact_ui_scenarios.gd").run(self,game)
 preload("res://tests/observed_contact_scenarios.gd").run(self)
 game.queue_free();await process_frame
 print("THERMAL AFFECTED CONTACT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
