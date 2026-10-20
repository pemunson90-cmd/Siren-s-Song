extends "res://tests/recovery_route_ui_tests.gd"
func mouse(point:Vector2,down:bool,canceled:bool=false):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down
 if e.get_property_list().any(func(p):return p.name=="canceled"):e.set("canceled",canceled)
 root.push_input(e,true);await process_frame
func screen_cancel(point:Vector2):
 var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=false;e.canceled=true;root.push_input(e,true);await process_frame
func parse_touch(point:Vector2,down:bool,canceled:bool=false):
 var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;e.canceled=canceled;Input.parse_input_event(e);await process_frame
func parse_drag(point:Vector2,delta:Vector2):
 var e=InputEventScreenDrag.new();e.index=0;e.position=point+delta;e.relative=delta;Input.parse_input_event(e);await process_frame
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="recovery-pointer-review"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false)
  for variant in ["short-drag-emulated","canceled-emulated"]:
   await begin(g,10);await home(g)
   var button=choices(g)[0];var point=button.get_global_rect().get_center();var before=g.sim.snapshot()
   if variant.ends_with("engine") or variant=="normal-engine-tap":await parse_touch(point,true)
   else:await touch(point,true);await mouse(point,true)
   if variant.begins_with("short-drag"):
    if variant.ends_with("engine"):await parse_drag(point,Vector2(20,0));await parse_touch(point+Vector2(20,0),false)
    else:await drag(point,Vector2(20,0));await touch(point+Vector2(20,0),false);await mouse(point+Vector2(20,0),false)
   elif variant.begins_with("canceled"):
    if variant.ends_with("engine"):await parse_touch(point,false,true)
    else:await screen_cancel(point);await mouse(point,false,true)
   else:await parse_touch(point,false)
   await settle()
   print("POINTER ",dimensions," ",variant," unchanged=",g.sim.snapshot()==before," popup=",g.advanced_orders," goals=",g.sim.route_goals())
   check(g.sim.snapshot()!=before if variant=="normal-engine-tap" else g.sim.snapshot()==before,"bounded recovery pointer "+variant+" "+str(dimensions))
   g.mission_hud.dismiss();await settle()
  g.queue_free();await settle()
 print("REVIEW RECOVERY POINTER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
