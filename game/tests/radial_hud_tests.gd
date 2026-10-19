extends SceneTree
var checks=0
var failures=0
var captures=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
func touch(point:Vector2,down:bool):
 var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point:Vector2):await touch(point,true);await touch(point,false);await settle()
func click(button):
 var point=button.get_global_rect().get_center()
 for down in [true,false]:
  await touch(point,down)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func capture(name:String):
 if not captures.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="radial-hud"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle()
  var name="cover" if dimensions.x==2520 else "inner";var h=g.mission_hud
  await capture(name+"-water")
  var before=g.sim.snapshot();var ship=g.ocean.global_position+g.ocean.screen_position(g.sim.units[0].pos)
  await tap(ship)
  check(g.advanced_orders and g.sim.snapshot()==before,"tap craft opens contextual projection without route or spend")
  if not g.advanced_orders:g.queue_free();await settle();continue
  check(h.page=="craft" and h.ring_buttons.size()==8,"craft menu presents eight stable labelled choices")
  var scale=Vector2(dimensions)/root.get_visible_rect().size
  for b in h.ring_buttons:
   check(g.get_global_rect().encloses(b.get_global_rect()) and b.size.x*scale.x>=125.99 and b.size.y*scale.y>=125.99,"clamped edge menu retains full48dp labels")
  await capture(name+"-commands")
  await click(h.extra.tools_menu);check(h.page=="tools" and g.sim.snapshot()==before,"tools projection changes no tactical state")
  await click(g.order_buttons.decoy);check(g.decoy_armed and not g.advanced_orders,"chosen tool leaves menu into explicit aim")
  before=g.sim.snapshot();await click(h.close_button)
  check(not g.decoy_armed and not g.advanced_orders and g.sim.snapshot()==before,"CANCEL returns directly to water without charge or order")
  await tap(ship);await click(h.extra.route_menu);await click(g.order_buttons.queue)
  check(g.sim.queue_mode and not g.advanced_orders and "QUEUE" in h.intent.text,"explicit QUEUE returns to water with visible persistent intent")
  before=g.sim.snapshot();await tap(ship);await tap(g.global_position+Vector2(g.size.x-20,g.size.y-20))
  check(not g.advanced_orders and g.sim.snapshot()==before,"outside dismissal consumes its release without route")
  g.sim.units[1].pos=g.sim.units[0].pos;g.sim.units[2].pos=g.sim.units[0].pos;g._refresh();await settle();before=g.sim.snapshot()
  await tap(ship);check(h.page=="fleet" and g.sim.snapshot()==before,"overlapping own craft open explicit identity choices")
  g.ocean.pan_chart(Vector2(-60,0));var camera=g.ocean.chart_camera.snapshot();await click(g.unit_buttons[1])
  check(g.sim.selected==1 and g.ocean.chart_camera.mode=="free" and g.ocean.chart_camera.snapshot()==camera,"choosing a craft preserves FREE camera intent")
  h.dismiss();g.ocean.fit_chart();await settle();before=g.sim.snapshot()
  var site=g.sim.mission.objectives[0];await tap(g.ocean.global_position+g.ocean.screen_position(site.pos))
  check(g.advanced_orders and h.page=="object" and g.sim.snapshot()==before,"briefed-object tap opens observational context without remote action")
  await capture(name+"-site")
  h.dismiss();g.ocean.focus_craft();await settle();ship=g.ocean.global_position+g.ocean.screen_position(g.sim.units[g.sim.selected].pos)
  before=g.sim.snapshot();await tap(ship)
  var origin=h.center
  await touch(origin,true)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=origin+Vector2(70,0);root.push_input(drag,true);await process_frame
  await touch(drag.position,false);await settle()
  check(not g.advanced_orders and not g.map_gesture.active() and g.sim.snapshot()==before,"popup pan cancels and release cannot route or spend")
  await tap(ship);await touch(h.center,true)
  var second=InputEventScreenTouch.new();second.index=1;second.position=h.center+Vector2(100,0);second.pressed=true;root.push_input(second,true);await process_frame
  second.pressed=false;root.push_input(second,true);await touch(h.center,false);await settle()
  check(not g.advanced_orders and not g.map_gesture.active() and g.sim.snapshot()==before,"popup pinch cancels both pointers without a world order")
  var water=g.global_position+Vector2(g.size.x*.7,g.size.y*.5)
  await touch(water,true);h.open("craft");h.dismiss();await touch(water,false);await settle()
  check(not g.map_gesture.active() and g.sim.snapshot()==before,"opening and dismissing context cancels an already active chart press")
  g.sim.contacts={0:{"pos":g.sim.units[g.sim.selected].pos+Vector2(150,0),"time":g.sim.elapsed,"mode":"LOCKING","lock":1.0,"angle":0.0,"target":g.sim.selected,"type":"sentinel","report_remaining":1.0}}
  g._refresh();h.open("craft");await settle()
  check(h.alarm.visible and "REPORT" in h.alarm.text and h.alarm.get_index()>h.blocker.get_index(),"earned imminent report warning stays above contextual projection")
  await click(h.instrument_button)
  check(h.sheet.visible and "RECORDS" in h.instrument_info.text and "reception unknown" in h.instrument_info.text,"STATUS exposes objective accounting and acoustic uncertainty")
  h.dismiss();g.sim.tools.emp=0;g.sim.tools.recon=0;g._refresh();h.open("tools");await settle()
  check(g.order_buttons.emp.visible and g.order_buttons.emp.disabled and g.order_buttons.recon.visible and g.order_buttons.recon.disabled,"depleted tools keep stable visible disabled slots and counts")
  h.dismiss();g.queue_free();await settle()
 print("RADIAL HUD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
