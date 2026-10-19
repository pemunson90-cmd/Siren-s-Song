extends SceneTree
func _initialize():call_deferred("run")
func click(p):
 var m=InputEventMouseMotion.new();m.position=p;m.global_position=p;root.push_input(m,true);await process_frame
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=p;e.global_position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func run():
 for profile in [{"name":"cover","size":Vector2i(2520,1080),"inset":136},{"name":"inner","size":Vector2i(2184,1968),"inset":0}]:
  root.size=profile.size;await process_frame;await process_frame
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(preload("res://tests/fit_label_main.gd"));g.fixture_dpi=420.
  if profile.inset:g.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(g);await process_frame;await process_frame
  g._start_mission(4);g.sim.units[0].pos=Vector2(600,750)
  for i in 2:g.sim.sirens[i].pos=Vector2(710+2*i,750);g.sim.sirens[i].vel=Vector2.ZERO
  g.sim.paused=false
  for i in 24:g.sim.advance(1./60)
  g.sim.paused=true;g.sim._observe();g._toggle_advanced();g._order("knock");g._refresh()
  for i in 3:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/workspace/Siren-s-Song-contact-clearance/docs/validation/production/torpedo-aim/baseline-"+profile.name+".png")
  var text_size=ThemeDB.fallback_font.get_string_size("S1",HORIZONTAL_ALIGNMENT_LEFT,-1,g.ocean.feedback_font_size)
  var intended=g.ocean.screen_position(g.sim.contacts[0].pos)+g.ocean.global_position+Vector2(12,-18)+Vector2(text_size.x/2,-g.ocean.feedback_font_size/2.)
  await click(intended)
  print("BASELINE_AIM ",profile.name," intended_S1_glyph_tap=",intended," observed=",g.sim.knockdown_targets()," actual_projectiles=",g.sim.projectiles," remaining=",g.sim.tools.knock)
  g.queue_free();await process_frame;await create_timer(.5).timeout
 quit()
