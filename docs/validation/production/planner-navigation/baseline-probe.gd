extends SceneTree
func _initialize():call_deferred("run")
func run():
 var destination="";var density=false;var drone=false
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--out="):destination=arg.trim_prefix("--out=")
  if arg=="--density":density=true
  if arg=="--drone":drone=true
 var game=load("res://scenes/main.tscn").instantiate()
 if density:
  game.set_script(load("res://tests/density_main.gd"))
  if root.size.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 game.capture_scenario="waypoint-editor-actual";root.add_child(game)
 for n in 6:await process_frame
 game.set_process(false);game._start_mission(0)
 game.sim.command("route",{"point":Vector2(260,800)});game.sim.command("queue");game.sim.command("route",{"point":Vector2(380,800)});game.sim.command("route",{"point":Vector2(540,800)})
 for args in [{"index":0,"mode":"cruise"},{"index":1,"mode":"silent","stop":true},{"index":2,"mode":"cruise"}]:game.sim.command("route_edit",args)
 if drone:game.sim.command("select",{"unit":1});game.sim.command("route",{"point":Vector2(300,700)})
 game._order("program")
 for n in 8:await process_frame
 var chosen=game.route_editor.rows.get_child(0 if drone else 1)
 game.route_editor.row_scroll.ensure_control_visible(chosen)
 for n in 3:await process_frame
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.position=chosen.get_global_rect().get_center();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
 for n in 10:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(destination)
 var preview=game.route_editor.preview;var before=preview.chart_rect();var sim_before=game.sim.snapshot();var p=preview.global_position+preview.size/2
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=p if down else p+Vector2(60,0);e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true)
  if down:
   var move=InputEventMouseMotion.new();move.position=p+Vector2(60,0);move.relative=Vector2(60,0);root.push_input(move,true)
  await process_frame
 print("PLANNER_BASELINE viewport=",root.get_visible_rect()," preview=",preview.size," chart_before=",before," chart_after_drag=",preview.chart_rect()," one_physical_pixel_world_m=",1600./before.size.x/(root.size.x/root.get_visible_rect().size.x)," snapshot_unchanged=",sim_before==game.sim.snapshot())
 game.queue_free();await process_frame;await create_timer(0.2).timeout;quit()
