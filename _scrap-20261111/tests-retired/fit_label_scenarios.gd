extends SceneTree
var checks:=0
var failures:=0
var capture_dir:=""
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures+=1;printerr("FAIL: ",message)
func _initialize() -> void: call_deferred("run")
func click(point: Vector2) -> void:
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true);await process_frame
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.position=point;event.global_position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
 await process_frame
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="): capture_dir=arg.trim_prefix("--capture-dir=")
 root.size=Vector2i(1280,720);await process_frame;await process_frame
 for profile in [{"name":"desktop","size":Vector2i(1280,720),"dpi":95.0,"inset":0},{"name":"cover","size":Vector2i(2520,1080),"dpi":420.0,"inset":136},{"name":"inner","size":Vector2i(2184,1968),"dpi":420.0,"inset":0}]:
  root.size=profile.size;await process_frame;await process_frame
  var ui=load("res://scenes/main.tscn").instantiate();ui.set_script(preload("res://tests/fit_label_main.gd"));ui.capture_scenario="fit-label-test"
  ui.fixture_dpi=profile.dpi;ui.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y) if profile.inset else Rect2();root.add_child(ui)
  ui._start_mission(0);ui._layout();await process_frame;await process_frame;await process_frame
  ui.mission_hud.open("view");await process_frame;await process_frame
  var scale=Vector2(profile.size)/ui.get_viewport_rect().size
  var safe=ui.get_global_rect();var last=Rect2()
  var geometry=[]
  for b in ui.zoom_buttons:
   var font_size=b.get_theme_font_size("font_size");var font=b.get_theme_font("font")
   var required=font.get_string_size(b.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x+b.get_theme_stylebox("normal").get_minimum_size().x
   check(b.size.x+0.01>=required,"%s %s fits on one line with unchanged text and theme padding (%s >= %s)"%[profile.name,b.text,b.size.x,required])
   check(is_equal_approx(b.size.y,ui.ui_touch_height),"%s %s retains intended single-row height"%[profile.name,b.text])
   check(font_size*scale.y/(profile.dpi/160.0 if profile.dpi==420.0 else 1.0)>=13.99,"%s %s retains readable font size"%[profile.name,b.text])
   var physical=b.size*scale;var minimum=48.0*(profile.dpi/160.0) if profile.dpi==420.0 else 48.0
   check(physical.x>=minimum-0.01 and physical.y>=minimum-0.01,"%s %s retains touch minimum"%[profile.name,b.text])
   var rect=b.get_global_rect()
   check(safe.encloses(rect) and ui.ocean.get_global_rect().encloses(rect),"%s %s remains in chart and safe area"%[profile.name,b.text])
   check(not last.has_area() or not rect.intersects(last),"%s zoom buttons do not overlap"%profile.name)
   last=rect;geometry.append({"label":b.text,"rect":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"required_width":required,"font":font_size})
  print("FIT_GEOMETRY ",JSON.stringify({"profile":profile.name,"window":[profile.size.x,profile.size.y],"geometry":geometry}))
  if not capture_dir.is_empty():
   await process_frame;await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(capture_dir+"/"+profile.name+".png")
  var before=ui.sim.snapshot()
  ui.ocean.zoom_at(2.0,ui.ocean.size*0.5);ui.ocean.pan_chart(Vector2(24,12))
  ui._refresh();ui._layout();await process_frame;await process_frame;await process_frame
  await click(ui.zoom_buttons[2].get_global_rect().get_center())
  check(is_equal_approx(ui.ocean.chart_camera.zoom,1.0),"%s actual FIT click returns zoom to overview"%profile.name)
  check(ui.sim.snapshot()==before,"%s FIT changes no simulation or orders"%profile.name)
  ui.queue_free();await process_frame;await create_timer(0.5).timeout
 print("FIT LABEL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
