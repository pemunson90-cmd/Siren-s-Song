extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(2184,1968);await process_frame;await process_frame
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="fresh-header-fit";root.add_child(game);await process_frame;await process_frame
 game._start_mission(0);await process_frame;await process_frame;game.set_process(false)
 var samples=[]
 for mission_id in 6:
  var m=load("res://src/campaign/missions.gd").make(mission_id)
  for o in m.objectives:
   for field in ["requirement","unit_requirement"]:
    if o.has(field):samples.append(o[field])
 samples.append("Quietus must operate the archive uplink. Bring the submarine to this anchor.")
 samples.append("Uplink needs both relay records. Photograph WEST and EAST first.")
 for text in samples:
  game.detail_label.text="DRONE A · ADD TO ROUTE · "+text
  await process_frame;await process_frame
  print("FRESH_HEADER lines=",game.detail_label.get_line_count()," label=",game.detail_label.get_global_rect()," chart_y=",game.ocean.global_position.y," text=",game.detail_label.text)
 game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
