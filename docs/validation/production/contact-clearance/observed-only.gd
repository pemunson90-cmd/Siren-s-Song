extends SceneTree
var checks:=0
var failures:=0
var game
func check(ok:bool,text:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",text)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720);await process_frame;await process_frame
 game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame;await process_frame
 await preload("res://tests/observed_contact_ui_scenarios.gd").run(self,game)
 await preload("res://tests/acoustic_ui_scenarios.gd").run(self,game)
 print("CONTACT CLEARANCE CHECKS ",checks," FAILURES ",failures)
 game.queue_free();await process_frame;await create_timer(.5).timeout;quit(1 if failures else 0)
