extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for frame in 6:await process_frame
func click(button):
 var point=button.get_global_rect().get_center()
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="view-controls-menu"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
  var hud=game.mission_hud;var before=game.sim.snapshot()
  var water_actions=hud.action_controls().keys()
  check(water_actions.size()==6 and ["pause","more_orders","fleet_q","fleet_a","fleet_b","hunt_meter"].all(func(key):return key in water_actions),"water keeps camera sizing controls inside menu beside own craft instruments")
  await click(game.advanced_button)
  var view=hud.extra.get("view_menu")
  check(view!=null and view.is_visible_in_tree(),"FLEET exposes VIEW from actual water touch")
  if view==null:game.queue_free();await settle();continue
  await click(view)
  check(hud.page=="view" and ["focus","fit","zoom_in","zoom_out"].all(func(key):return hud.action_controls().has(key)),"VIEW exposes existing focus fit and both zoom actions")
  for button in hud.ring_buttons:
   check(game.get_global_rect().encloses(button.get_global_rect()) and button.size.y>=game.ui_touch_height,"VIEW retains full-size bounded touch targets")
  await click(game.zoom_buttons[2]);check(game.ocean.chart_camera.mode=="overview" and game.ocean.chart_camera.zoom==1.,"menu FIT enters actual overview")
  await click(hud.focus_button);check(game.ocean.chart_camera.mode=="follow","menu FOCUS restores craft follow")
  var zoom=game.ocean.chart_camera.zoom;await click(game.zoom_buttons[1]);check(game.ocean.chart_camera.zoom>zoom,"menu plus zooms actual chart")
  await click(game.zoom_buttons[0]);check(is_equal_approx(game.ocean.chart_camera.zoom,zoom),"menu minus reverses zoom")
  await click(hud.close_button);check(hud.page=="fleet","VIEW BACK returns to containing FLEET menu")
  await click(hud.close_button);check(not game.advanced_orders and not hud.focus_button.is_visible_in_tree() and game.zoom_buttons.all(func(b):return not b.is_visible_in_tree()),"dismissing menu leaves water free of camera buttons")
  check(game.sim.snapshot()==before,"view navigation changes no orders resources clock or pause")
  var origin=game.global_position+Vector2(game.size.x*.7,game.size.y*.5)
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=origin;touch.pressed=true;root.push_input(touch,true);await process_frame
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=origin+Vector2(60,0);drag.relative=Vector2(60,0);root.push_input(drag,true);await process_frame
  touch.position=drag.position;touch.pressed=false;root.push_input(touch,true);await settle()
  check(game.ocean.chart_camera.mode=="free" and game.sim.snapshot()==before,"direct water drag retains FREE navigation without ghost order")
  var old_zoom=game.ocean.chart_camera.zoom
  for id in 2:
   var press=InputEventScreenTouch.new();press.index=id;press.position=origin+Vector2(id*100,0);press.pressed=true;root.push_input(press,true);await process_frame
  drag=InputEventScreenDrag.new();drag.index=1;drag.position=origin+Vector2(160,0);drag.relative=Vector2(60,0);root.push_input(drag,true);await process_frame
  for id in 2:
   var release=InputEventScreenTouch.new();release.index=id;release.position=origin+Vector2(id*160,0);release.pressed=false;root.push_input(release,true);await process_frame
  await settle();check(game.ocean.chart_camera.zoom>old_zoom and game.sim.snapshot()==before,"direct water pinch retains zoom without route or spend")
  game.queue_free();await settle()
 print("VIEW CONTROLS MENU CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
