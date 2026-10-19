extends SceneTree
func _initialize():call_deferred("run")
func run():
 var output="";var density=false
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
  if arg=="--density":density=true
 var game=load("res://scenes/main.tscn").instantiate()
 if density:game.set_script(preload("res://tests/density_main.gd"))
 game.capture_scenario="thermal-static";root.add_child(game);game.set_process(false);game._start_mission(3)
 var f=FileAccess.open("/workspace/Siren-s-Song-environment-investigation/work/furnace-qualified.snapshot",FileAccess.READ);var data=f.get_var();f.close();assert(game.sim.restore(data));game.ocean.sim=game.sim;game.sim.message="PAUSED · charted cold front · passive information trades against staging"
 game._refresh();game._layout()
 for n in 5:await process_frame
 for zoom in [1.0,2.0,4.0]:
  game.ocean.fit_chart();game.ocean.zoom_at(zoom,game.ocean.size/2)
  if zoom>1:game.ocean.pan_chart(game.ocean.size/2-game.ocean.screen_position(Vector2(1100,830)))
  game.ocean.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(output+"-%dx.png"%zoom)
 print("STATIC_COMPLETE ",output," chart=",game.ocean.size," dpi=",game.ui_density_dpi());quit()
