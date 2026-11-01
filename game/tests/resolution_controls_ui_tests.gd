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
func find_site(sim,id:String)->Dictionary:
 for objective in sim.mission.objectives:
  if objective.get("site_id","")==id:return objective
 return {}
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="resolution-ui"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(13);g.ocean.fit_chart();g._layout();await settle()
  var h=g.mission_hud;var site=find_site(g.sim,"warning_transmission");var before=g.sim.snapshot()
  var context=g.ocean.pick_context(g.ocean.screen_position(site.pos),g.ui_touch_height)
  check(context.get("subkind","")=="transmission","known sector has explicit context, not a physical installation")
  await tap(g.ocean.global_position+g.ocean.screen_position(site.pos))
  check(g.advanced_orders and h.page=="object" and g.sim.snapshot()==before,"sector badge tap is observational and owns release")
  check(g.order_buttons.camera.visible and g.order_buttons.camera.text.get_slice("\n",0)=="TRANSMIT" and "charted transmission sector" in g.order_buttons.camera.tooltip_text and g.order_buttons.camera.disabled and not h.extra.route_here.visible,"sector context discloses disabled TRANSMIT outside region without routing to badge")
  h.dismiss();await settle()
  var water=Vector2(1900,1600);await tap(g.ocean.global_position+g.ocean.screen_position(water))
  check(not g.advanced_orders and not g.sim.route_goals().is_empty() and g.sim.route_goals()[0].pos.distance_to(water)<1.,"ordinary water inside the known sector still plots route")
  # Complete the newly required local account by ordinary travel and reception.
  # Keep the sole positioned geometry fixture below at its original origin.
  var pickup=find_site(g.sim,"warning_uplink")
  var approach=pickup.pos+Vector2(160,-80)
  check(g.sim.command("depth",{"band":0}),"pickup approach uses a public adjacent depth order")
  g.sim.paused=false
  for tick in 300:g.sim.advance(1./60)
  g.sim.paused=true
  var course=[Vector2(850,1950),Vector2(900,700),Vector2(2350,700),approach]
  check(not pickup.is_empty() and not pickup.captured and g.sim.command("route",{"point":course[0]}),"required pickup service starts unresolved and accepts a physical approach")
  g.sim.paused=false
  var leg=0
  for tick in 7200:
   g.sim.advance(1./60)
   if g.sim.units[0].pos.distance_to(course[leg])<40:
    if leg==course.size()-1:break
    leg+=1;g.sim.command("route",{"point":course[leg]})
  g.sim.paused=true;g.sim.command("hold");g._refresh();await settle()
  check(not g.sim.command("camera") and not pickup.captured,"local receiver cannot be decoded from SHALLOW")
  check(g.sim.command("depth",{"band":1}) and not g.sim.command("camera") and not pickup.captured,"local receiver cannot be decoded during the physical return to MIDDLE")
  g.sim.paused=false
  for tick in 300:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();await settle()
  print("PICKUP APPROACH ",dimensions," pos=",g.sim.units[0].pos," camera=",g.sim.camera_context()," outcome=",g.sim.outcome)
  check(g.sim.units[0].pos.distance_to(approach)<40 and g.sim.line_clear(g.sim.units[0].pos,pickup.pos) and g.sim.outcome.is_empty(),"Quietus physically reaches local pickup service with live patrols")
  h.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});await settle()
  check(g.order_buttons.camera.text=="LISTEN" and g.sim.camera_context().get("target",-1)==g.sim.mission.objectives.find(pickup) and g.sim.camera_context().ready,"pickup service is the actual ready local LISTEN target")
  await tap(g.order_buttons.camera.get_global_rect().get_center())
  g.sim.advance(2.)
  check(g.sim.capture_feedback().elapsed==0 and not pickup.captured,"paused local pickup reception grants no elapsed work or record")
  g.sim.paused=false
  for tick in 300:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();await settle()
  check(pickup.captured and not find_site(g.sim,"warning_transmission").captured and g.sim.outcome.is_empty(),"real local pickup work completes without sending the warning or resolving the ending")
  h.dismiss();await settle()
  # Local own-actor geometry fixture, distinct from genuine captured play evidence.
  g.sim.command("hold");g.sim.units[0].pos=Vector2(1830,1080);g.sim.units[0].vel=Vector2.ZERO;g.ocean.focus_craft();g._layout();await settle()
  check(not load("res://src/presentation/expedition_view.gd").transmission_badge(g.ocean,site,g.ui_touch_height).has_area(),"offscreen info badge cannot leave a visible orphan label or invisible hit target")
  h.open("craft",{"kind":"craft","unit":0,"pos":g.sim.units[0].pos});await settle()
  before=g.sim.snapshot();var routes_before=g.sim.route_goals().duplicate(true)
  # Staged own-craft depth fixtures: the selected sector must explain its own
  # gate, preserving the model instead of borrowing a nearby receiver's refusal.
  for band in [0,2]:
   g.sim.units[0].band=band;var gate_before=g.sim.snapshot().duplicate(true)
   h.open("object",context);await settle()
   check(g.order_buttons.camera.disabled and g.order_buttons.camera.text.get_slice("\n",0)=="TRANSMIT" and g.order_buttons.camera.tooltip_text=="Needs MIDDLE" and g.sim.snapshot()==gate_before,"selected transmission sector names required MIDDLE without changing state from band %d"%band)
  g.sim.units[0].band=1
  check(g.sim.command("depth",{"band":0}),"transmission fixture starts an ordinary depth change")
  var changing_before=g.sim.snapshot().duplicate(true)
  h.open("object",context);await settle()
  check(g.order_buttons.camera.disabled and g.order_buttons.camera.text.get_slice("\n",0)=="TRANSMIT" and g.order_buttons.camera.tooltip_text=="Finish changing depth" and g.sim.snapshot()==changing_before,"selected transmission sector names active depth change without changing state")
  g.sim.units[0].transition={};h.open("craft");await settle()
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
  check(completed==Vector2(1830,1080) and g.sim.operation_context().operations.any(func(op):return op.site_id=="warning_transmission" and op.completed),"ordinary completed work records actual chosen origin, not chart badge")
  var transmitter=find_site(g.sim,"warning_transmission")
  var tx_index=g.sim.mission.objectives.find(transmitter)
  check(g.sim.units[0].vel.length()>=12 and not g.sim.Operations.ready(g.sim,transmitter,0) and not g.sim.command("camera") and g.sim.capture_feedback().unit<0,"completed transmission cannot restart while its retained course is unsettled")
  # Completed work releases HOLD; explicitly stop the retained course before
  # checking the transmitter again, rather than assuming the craft stayed still.
  check(g.sim.command("hold"),"completed send accepts an ordinary station hold")
  g.sim.paused=false
  for tick in 120:g.sim.advance(1./60)
  g.sim.paused=true;g._refresh();await settle()
  print("REBROADCAST ",dimensions," camera=",g.sim.camera_context()," vel=",g.sim.units[0].vel)
  h.open("craft");await settle();check(g.order_buttons.camera.text=="TRANSMIT" and g.order_buttons.camera.disabled==not g.sim.camera_context().ready,"completed broadcast remains available subject to actual current settling readiness")
  check(g.sim.command("select",{"unit":1}) and not g.sim.Operations.ready(g.sim,transmitter,1) and not g.sim.command("camera") and g.sim.capture_feedback().unit<0,"bare drone cannot rebroadcast Quietus warning")
  g.sim.command("select",{"unit":0})
  g._refresh();h.open("craft");await settle()
  check(g.sim.camera_context().get("target",-1)==tx_index and g.sim.camera_context().ready and g.order_buttons.camera.text=="TRANSMIT" and not g.order_buttons.camera.disabled,"completed warning remains independently ready after the wrong-craft negative")
  var prior_send=transmitter.completed_emission.duplicate(true)
  await tap(g.order_buttons.camera.get_global_rect().get_center())
  check(g.sim.capture_feedback().unit==0 and g.sim.capture_feedback().target==tx_index and g.sim.capture_feedback().elapsed==0 and transmitter.completed_emission==prior_send,"real rebroadcast tap begins a fresh paused transmission without inventing another completion")
  check(pickup.captured and transmitter.captured and g.sim.outcome.is_empty() and not g.sim.mission.recovered and not g.sim.mission.warning_recipient.receipt,"required local work and an actual rebroadcast attempt cannot bypass recipient arrival or the ending")
  print("RESOLUTION FIXTURE ",dimensions," pickup=",pickup.captured," transmission=",transmitter.captured," repeat_target=",g.sim.capture_feedback().target," repeat_elapsed=",g.sim.capture_feedback().elapsed," recovered=",g.sim.mission.recovered," receipt=",g.sim.mission.warning_recipient.receipt," outcome=",g.sim.outcome)
  h.dismiss()
  check(load("res://src/presentation/receiver_scene.gd").applies(13,site),"own transmitter never renders a false Foundry optical scene")
  g._start_mission(12);g.ocean.fit_chart();g._layout();await settle();site=g.sim.observable_sites()[0]
  context=g.ocean.pick_context(g.ocean.screen_position(site.pos),g.ui_touch_height);h.open("object",context);await settle()
  check(g.order_buttons.camera.text.get_slice("\n",0)=="ACTUATE" and not g.order_buttons.camera.tooltip_text.is_empty() and g.order_buttons.camera.disabled and not h.extra.route_here.visible,"physical actuator exposes local ACTUATE without a release approach shortcut")
  # 127 (Pat 2026-10-30): the approach route is a dev/test shortcut; release play hides it.
  g.set_meta("dev_profile",true);h.open("object",context);await settle()
  check(h.extra.route_here.visible,"dev state keeps the ordinary approach route on the actuator page")
  g.set_meta("dev_profile",false);h.open("object",context);await settle()
  h.open("inspect");await settle();check("optional" in h.instrument_info.text.to_lower() and "reception unknown" in h.instrument_info.text and "ACTUATE" in h.instrument_info.text,"actuator status discloses voluntary machinery cost without remote hearing knowledge")
  h.dismiss();g._start_mission(0);g._layout();await settle();check(not g.order_buttons.camera.disabled and g.order_buttons.camera.text=="PHOTO","tutorial photo action is restored after operation contexts")
  g.queue_free();await settle()
 print("RESOLUTION CONTROLS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
