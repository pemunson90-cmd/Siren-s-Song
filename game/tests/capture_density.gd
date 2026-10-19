extends SceneTree
func _initialize():call_deferred("run")
func run():
 var view="primary";var evidence_path=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--density-view="):view=arg.get_slice("=",1)
  if arg.begins_with("--metrics-path="):evidence_path=arg.trim_prefix("--metrics-path=")
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(preload("res://tests/density_main.gd"));game.capture_scenario="density-review";root.add_child(game)
 var screenshot_path=game.capture_path; game.capture_path=""
 await process_frame;await process_frame
 if view=="settings":game._settings_menu()
 elif view=="briefing":game._briefing(5)
 elif view=="operations":game.active_started=false;game._show_campaign()
 else:
  game._start_mission(0);game.sim.command("select",{"unit":1});game.sim.command("route",{"point":Vector2(1300,510)});game.sim.paused=false
  for n in 500:
   game.sim.advance(0.1)
   if game.sim.units[1].route.is_empty() and game.sim.units[1].vel.length()<2:break
  game.sim.paused=true;game.ocean.zoom_at(1.8,game.ocean.size/2)
  if view=="secondary":game._toggle_advanced()
 game._refresh();game._layout();await process_frame;await process_frame;await process_frame
 await RenderingServer.frame_post_draw
 if not screenshot_path.is_empty():
  var image=root.get_texture().get_image(); var result=image.save_png(screenshot_path)
  print("DENSITY_SETTLED_CAPTURE size=",image.get_size()," result=",result)
 if not evidence_path.is_empty():
  var f=FileAccess.open(evidence_path,FileAccess.WRITE);f.store_string(JSON.stringify(game._ui_metrics(),"  "));f.close()
 print("DENSITY_TRANSFORMS screen=",root.get_screen_transform()," final=",root.get_final_transform()," canvas=",game.get_global_transform_with_canvas()," rect=",game.get_viewport_rect())
 print("DENSITY_MENU_DEBUG h=",game.ui_touch_height," menu=",game.menu.get_global_rect()," stackmin=",game.menu.get_child(0).get_combined_minimum_size()," footer=",game.menu_footer.get_global_rect()," scrollmin=",game.scroll.get_combined_minimum_size())
 print("DENSITY_CAPTURE fixture_dpi=420 view=",view," chart=",game.ocean.get_global_rect()," fraction=",game.ocean.size.x*game.ocean.size.y/(game.size.x*game.size.y)," state=",game.sim.elapsed)

 if view=="briefing":
  var actions=game._ui_metrics().controls.filter(func(c):return not c.clipped).map(func(c):return c.action)
  if not ("begin" in actions and "back" in actions):
   printerr("DENSITY_CAPTURE_FAIL sticky briefing actions not fully exposed"); quit(1)
