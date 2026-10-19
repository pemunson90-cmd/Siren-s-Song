extends SceneTree
var folder=""
func _initialize():call_deferred("run")
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--folder="):folder=arg.trim_prefix("--folder=")
 DirAccess.make_dir_recursive_absolute(folder)
 for profile in [{"name":"cover","size":Vector2i(2520,1080),"dpi":420.,"inset":136},{"name":"inner","size":Vector2i(2184,1968),"dpi":420.,"inset":0},{"name":"desktop","size":Vector2i(1280,720),"dpi":95.,"inset":0}]:
  root.size=profile.size;await process_frame;await process_frame
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(preload("res://tests/fit_label_main.gd"));g.fixture_dpi=profile.dpi;g.capture_scenario="contact-instrument-clearance"
  if profile.inset:g.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(g);g._start_mission(4);await process_frame;await process_frame
  g.sim.units[0].pos=g.sim.mission.objectives[2].pos+Vector2(0,100);g.sim.elapsed=3
  assert(g.sim.command("camera"));assert(g.sim.command("ping"))
  for id in 3:g.sim.contacts[id]={"pos":g.sim.units[0].pos+Vector2(30+id*40,-20),"time":3. if id==2 else 0.,"mode":"LOCKING" if id==2 else "PATROL","lock":2. if id==2 else 0.,"angle":0.,"target":0 if id==2 else -1,"type":["patroller","hunter","sentinel"][id]}
  g._refresh();g._layout()
  for n in 4:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder.path_join(profile.name+".png"))
  var widest=0.
  for line in g.ocean.acoustic_rows():widest=maxf(widest,ThemeDB.fallback_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,g.ocean.feedback_font_size).x+20)
  print("CLEARANCE_VIEW ",profile.name," chart=",g.ocean.size," font=",g.ocean.feedback_font_size," instrument_width=",widest," lines=",g.ocean.acoustic_rows()," contacts=",g.ocean.contact_readout_rects()," optical=",g.ocean.optical_feed.get_rect()," visible=",g.ocean.optical_feed.visible)
  g.queue_free();await process_frame;await create_timer(.5).timeout
 quit()
