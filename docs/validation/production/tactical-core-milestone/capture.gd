extends SceneTree
var folder="/workspace/Siren-s-Song-gauntlet/work/core-integration/tactical-ui"
func _initialize():
 root.size=Vector2i(1280,720);call_deferred("run")
func settle():
 for n in 6:await process_frame
func run():
 DirAccess.make_dir_recursive_absolute(folder)
 for profile in [{"name":"cover","size":Vector2i(2520,1080),"inset":136},{"name":"inner","size":Vector2i(2184,1968),"inset":0}]:
  root.size=profile.size;await settle()
  var ui=load("res://scenes/main.tscn").instantiate();ui.set_script(preload("res://tests/fit_label_main.gd"));ui.fixture_dpi=420.;ui.capture_scenario="tactical-composition-capture"
  if profile.inset:ui.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(ui);await settle();ui.set_process(false);ui._start_mission(4)
  ui.sim.command("route",{"point":Vector2(350,800)});ui.sim.command("route_edit",{"index":0,"mode":"silent"});ui._toggle_advanced();ui._layout();await settle();await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder+"/"+profile.name+"-secondary.png")
  ui._order("program");await settle();await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder+"/"+profile.name+"-planner.png")
  ui.queue_free();await settle()
 quit()
