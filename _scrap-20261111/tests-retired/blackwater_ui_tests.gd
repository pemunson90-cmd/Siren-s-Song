extends SceneTree
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720);await process_frame;await process_frame
	var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="blackwater-ui";root.add_child(game);await process_frame;await process_frame
	game.set_process(false)
	await preload("res://tests/blackwater_ui_scenarios.gd").run(self,game)
	game.queue_free();await process_frame;await create_timer(0.5).timeout
	print("BLACKWATER UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
