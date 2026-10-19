extends SceneTree
var checks:=0
var failures:=0
var game
func check(ok:bool,text:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",text)
func _initialize():call_deferred("run")
func click(point:Vector2):
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func run():
 root.size=Vector2i(1280,720);await process_frame;await process_frame
 game=load("res://scenes/main.tscn").instantiate();root.add_child(game);await process_frame;await process_frame
 await preload("res://tests/touch_navigation_scenarios.gd").run(self,game)
 print("TOUCH NAVIGATION CHECKS ",checks," FAILURES ",failures)
 game.queue_free();await process_frame;await create_timer(.5).timeout;quit(1 if failures else 0)
