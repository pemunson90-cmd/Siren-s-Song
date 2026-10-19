extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 5:await process_frame
func tap(point):
 for down in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
 await settle()
func click(button):
 var point=button.get_global_rect().get_center()
 for down in [true,false]:
  var mouse=InputEventMouseButton.new();mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;mouse.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0;root.push_input(mouse,true);await process_frame
 await settle()
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="resolution-ui"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(13);g.ocean.fit_chart();g._layout();await settle()
  var h=g.mission_hud;var site=g.sim.observable_sites()[0];var before=g.sim.snapshot()
  var context=g.ocean.pick_context(g.ocean.screen_position(site.pos),g.ui_touch_height)
  check(context.get("subkind","")=="transmission","known sector has explicit context, not a physical installation")
  await tap(g.ocean.global_position+g.ocean.screen_position(site.pos))
  check(g.advanced_orders and h.page=="object" and g.sim.snapshot()==before,"sector badge tap is observational and owns release")
  check(g.order_buttons.camera.visible and g.order_buttons.camera.text=="TRANSMIT" and g.order_buttons.camera.disabled and not h.extra.route_here.visible,"sector context discloses disabled TRANSMIT outside region without routing to badge")
  h.dismiss();await settle()
  var water=Vector2(1900,1600);await tap(g.ocean.global_position+g.ocean.screen_position(water))
  check(not g.advanced_orders and not g.sim.route_goals().is_empty() and g.sim.route_goals()[0].pos.distance_to(water)<1.,"ordinary water inside the known sector still plots route")
  # Local own-actor geometry fixture, distinct from genuine captured play evidence.
  g.sim.command("hold");g.sim.units[0].pos=Vector2(1830,1080);g.sim.units[0].vel=Vector2.ZERO;g.ocean.focus_craft();g._layout();await settle()
  check(not load("res://src/presentation/expedition_view.gd").transmission_badge(g.ocean,site,g.ui_touch_height).has_area(),"offscreen info badge cannot leave a visible orphan label or invisible hit target")
  h.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});await settle()
  before=g.sim.snapshot();var routes_before=g.sim.route_goals().duplicate(true)
  check(g.order_buttons.camera.text=="TRANSMIT" and not g.order_buttons.camera.disabled,"settled own craft offers TRANSMIT at chosen actual position")
  await click(g.order_buttons.camera)
  check(g.sim.capture_feedback().unit==0 and not g.advanced_orders and g.sim.paused and g.sim.route_goals()==routes_before,"separate actual action tap starts paused own work without a fallthrough route")
  g.sim.advance(2.);check(g.sim.capture_feedback().elapsed==0 and g.sim.operation_context().get("transmission_origin",Vector2.INF)==Vector2.INF,"paused transmit grants neither elapsed work nor completed origin")
  g.sim.paused=false
  for tick in 120:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();await settle()
  check("2.0 / 6s" in h.intent.text and not g.sim.operation_context().has("transmission_origin"),"active status uses effective six-second clock without completed-send claim")
  before=g.sim.snapshot();h.open("craft");await settle();var point=h.center
  var press=InputEventScreenTouch.new();press.index=0;press.position=point;press.pressed=true;root.push_input(press,true);await process_frame
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=point+Vector2(70,0);drag.relative=Vector2(70,0);root.push_input(drag,true);await process_frame
  press=press.duplicate();press.position=drag.position;press.pressed=false;root.push_input(press,true);await settle()
  check(not g.advanced_orders and g.sim.snapshot()==before and not g.map_gesture.active(),"operation popup drag dismisses without ghost route or capture mutation")
  g.sim.paused=false
  for tick in 300:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();await settle()
  var completed=g.sim.operation_context().get("transmission_origin",Vector2.INF)
  check(completed==Vector2(1830,1080) and g.sim.operation_context().operations[0].completed,"ordinary completed work records actual chosen origin, not chart badge")
  h.open("craft");await settle();check(g.order_buttons.camera.text=="TRANSMIT" and g.order_buttons.camera.disabled==not g.sim.camera_context().ready,"completed broadcast remains available subject to actual current settling readiness")
  h.dismiss()
  check(load("res://src/presentation/receiver_scene.gd").applies(13,site),"own transmitter never renders a false Foundry optical scene")
  g._start_mission(12);g.ocean.fit_chart();g._layout();await settle();site=g.sim.observable_sites()[0]
  context=g.ocean.pick_context(g.ocean.screen_position(site.pos),g.ui_touch_height);h.open("object",context);await settle()
  check(g.order_buttons.camera.text=="ACTUATE" and g.order_buttons.camera.disabled and h.extra.route_here.visible,"physical actuator exposes local ACTUATE and ordinary approach route")
  h.open("inspect");await settle();check("optional" in h.instrument_info.text.to_lower() and "reception unknown" in h.instrument_info.text and h.instrument_info.text.begins_with("ACTUATE"),"actuator status discloses voluntary machinery cost without remote hearing knowledge")
  h.dismiss();g._start_mission(0);g._layout();await settle();check(not g.order_buttons.camera.disabled and g.order_buttons.camera.text=="CAMERA","tutorial camera remains unchanged after operation contexts")
  g.queue_free();await settle()
 print("RESOLUTION CONTROLS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
