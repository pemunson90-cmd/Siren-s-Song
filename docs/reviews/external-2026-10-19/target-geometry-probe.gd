extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var game=load("res://scenes/main.tscn").instantiate(); game.capture_scenario="audit-targets"; root.add_child(game)
 await process_frame; await process_frame
 game._start_mission(0)
 for dimensions in [Vector2i(1680,720),Vector2i(1280,1153)]:
  root.size=dimensions; game.size=dimensions; game._layout(); await process_frame; await process_frame
  print("TARGET_AUDIT ",JSON.stringify({"viewport":str(dimensions),"pause":str(game.pause_button.get_global_rect()),"droneA":str(game.unit_buttons[1].get_global_rect()),"zoom_in":str(game.zoom_buttons[1].get_global_rect()),"camera":str(game.order_buttons.camera.get_global_rect()),"pause_min":str(game.pause_button.get_combined_minimum_size()),"drone_min":str(game.unit_buttons[1].get_combined_minimum_size())}))
 game.queue_free(); await process_frame
 quit()
