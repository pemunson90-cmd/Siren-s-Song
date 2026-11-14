extends SceneTree
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",message)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 root.size=Vector2i(1280,720);await process_frame;await process_frame
 var ui=load("res://scenes/main.tscn").instantiate();ui.set_script(preload("res://tests/fit_label_main.gd"));ui.capture_scenario="task-label-ui-test";root.add_child(ui);await process_frame
 await preload("res://tests/blackwater_ui_scenarios.gd").run(self,ui)
 # The finale plan flies authored water the player rules leave uncharted; this check is about the warning evidence, not discovery, so it uses the developer known-charts switch.
 var charts_before=PlayerDive.known_water(true)
 await preload("res://tests/finale_ui_scenarios.gd").run(self,ui)
 PlayerDive.known_water(charts_before)
 ui.queue_free();await process_frame;await create_timer(0.5).timeout
 print("TASK UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
