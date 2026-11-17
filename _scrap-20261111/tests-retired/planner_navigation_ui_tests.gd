extends SceneTree
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for i in 5:await process_frame
func touch(index:int,p:Vector2,down:bool,canceled:bool=false):
 var e=InputEventScreenTouch.new();e.index=index;e.position=p;e.pressed=down;e.canceled=canceled;root.push_input(e,true);await process_frame
func drag(index:int,p:Vector2):
 var e=InputEventScreenDrag.new();e.index=index;e.position=p;root.push_input(e,true);await process_frame
func click(b):
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=b.get_global_rect().get_center();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(preload("res://tests/density_main.gd"));g.capture_scenario="planner-navigation-tests"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(0)
  g.sim.command("route",{"point":Vector2(260,800)});g.sim.command("queue");g.sim.command("route",{"point":Vector2(380,800)});g.sim.command("route",{"point":Vector2(540,800)})
  g._order("program");await settle();g.route_editor.selected_goal=1;g.route_editor.refresh();await settle()
  var p=g.route_editor.preview
  check(p.has_method("zoom_at") and p.has_method("pan_chart"),"paused planner preview supports actual chart navigation")
  if not p.has_method("zoom_at"):g.queue_free();await settle();finish();return
  var baseline=g.sim.snapshot();var original_size=p.size
  var scale=Vector2(dimensions)/g.get_viewport_rect().size
  for b in p.navigation_buttons:
   check(p.get_global_rect().encloses(b.get_global_rect()) and b.size.x*scale.x>=125.99 and b.size.y*scale.y>=125.99,"preview zoom/FIT controls stay inside and at least48dp")
  await click(p.navigation_buttons[1]);check(p.chart_camera.zoom>1,"actual plus button enlarges planner chart")
  await click(p.navigation_buttons[0]);check(p.chart_camera.zoom==1,"actual minus returns toward overview")
  var center=p.size/2;var world=p.map_position(center);var origin=p.global_position+center
  await touch(0,origin-Vector2(30,0),true);await touch(1,origin+Vector2(30,0),true)
  await drag(0,origin-Vector2(60,0));await drag(1,origin+Vector2(60,0));await touch(0,origin-Vector2(60,0),false);await touch(1,origin+Vector2(60,0),false);await settle()
  check(p.chart_camera.zoom>1.9 and p.map_position(center).distance_to(world)<.1,"actual two-finger pinch magnifies around inspected center")
  var old_center=p.chart_camera.center
  await touch(0,origin,true);await drag(0,origin+Vector2(45,0));await touch(0,origin+Vector2(45,0),false);await settle()
  check(p.chart_camera.center!=old_center,"actual finger drag pans zoomed preview")
  check(g.sim.snapshot()==baseline and g.route_editor.selected_goal==1 and p.size==original_size,"navigation changes no goal, selected intent, resource, or chart area")
  p.fit_chart();p.zoom_at(100.,p.screen_position(Vector2(380,800)));check(p.chart_camera.zoom==4.,"planner zoom has bounded4x precision")
  var goals=g.sim.route_goals().duplicate(true);var wanted=Vector2(400,780);var tap=p.global_position+p.screen_position(wanted)
  await touch(0,tap,true);await touch(0,tap,false);await settle()
  check(g.sim.route_goals()[1].pos.distance_to(wanted)<.1 and g.sim.route_goals()[0]==goals[0] and g.sim.route_goals()[2]==goals[2],"zoomed/panned touch edits only selected goal at intended world point")
  if not capture_dir.is_empty():
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir+"/challenger-"+("cover" if dimensions.x==2520 else "inner")+".png")
  var saved=g.sim.snapshot()
  for down in [true,false]:
   var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=tap;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
  check(g.sim.snapshot()==saved,"emulated mouse cannot duplicate waypoint edit/undo history")
  await touch(0,origin,true);await click(p.navigation_buttons[2]);await touch(0,origin,false);await settle()
  check(p.chart_camera.zoom==1 and g.sim.snapshot()==saved,"FIT during pending finger cancels edit and restores overview")
  await touch(0,origin,true);await touch(0,origin,false,true);await settle();check(g.sim.snapshot()==saved,"OS-canceled preview touch cannot edit")
  await touch(0,origin,true)
  var wheel=InputEventMouseButton.new();wheel.button_index=MOUSE_BUTTON_WHEEL_DOWN;wheel.pressed=true;wheel.position=g.route_editor.row_scroll.get_global_rect().get_center();root.push_input(wheel,true);await process_frame
  await touch(0,origin,false);await settle();check(g.sim.snapshot()==saved,"scrolling list cancels pending chart tap without edit")
  await touch(0,origin,true);await drag(0,p.global_position-Vector2(50,50));await touch(0,p.global_position-Vector2(50,50),false);await settle();check(g.sim.snapshot()==saved,"release outside preview cannot edit")
  await touch(0,origin,true);g.route_editor.close();await touch(0,origin,false);await settle()
  check(g.sim.snapshot()==saved and g.sim.paused,"leaving panel cancels pending preview edit without world order")
  g.queue_free();await settle();await create_timer(.5).timeout
 finish()
func finish():print("PLANNER NAVIGATION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
