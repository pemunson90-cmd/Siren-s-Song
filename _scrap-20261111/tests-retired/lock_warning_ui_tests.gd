extends SceneTree
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for frame in 6:await process_frame
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
  var s=game.sim;var w=game.lock_warning
  s.elapsed=10.;s.contacts={0:{"pos":s.units[0].pos+Vector2(80,0),"time":10.,"mode":"LOCKING","lock":2.,"target":0,"type":"patroller","source":"optical","angle":0.,"band":1}}
  var before=s.snapshot();game._refresh();await settle()
  check(w.visible and w.locks.size()==1 and w.show_hint,"observed Quietus lock shows live warning and hint")
  check(Rect2(Vector2.ZERO,game.size).encloses(w.banner),"countdown stays in safe content on both screen shapes")
  check(not w.banner.intersects(game.pause_button.get_global_rect()),"warning preserves pause access")
  check(w.mouse_filter==Control.MOUSE_FILTER_IGNORE,"warning never owns chart gestures")
  check(w.marker(Vector2(-10000,-10000)).x>=0 and w.marker(Vector2(10000,10000)).y<=w.size.y,"offscreen lock markers stay on screen")
  check(s.snapshot()==before,"warning refresh does not change simulation")
  if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join("lock-%d.png"%dimensions.x))
  s.contacts[0].lock=4.;s.contacts[0].mode="BEAM";game._refresh();await settle()
  check(not w.visible,"firing removes the buildup panel")
  game.queue_free();await settle()
 print("LOCK WARNING UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
