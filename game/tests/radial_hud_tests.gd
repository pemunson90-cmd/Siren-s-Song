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
func disc_holds(h,r:Rect2)->bool:
 var radii=(h.ring_radius-h.touch_height*.7)*(h.get_meta("status_radial_axes")/h.ring_radius if h.has_meta("status_radial_axes") else Vector2.ONE)
 return preload("res://src/presentation/radial_layout/center_layout.gd").inside(r,h.center,radii)
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="radial-hud"
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false)
  # The aim/cancel path needs one equipped charge; cancellation must not spend it.
  g.tool_racks=preload("res://src/equipment/tool_racks.gd").empty();g.tool_racks.quietus.decoy=1
  g._start_mission(0);await settle()
  var name="cover" if dimensions.x==2520 else "inner";var h=g.mission_hud
  # Frame the chart before probing a world label or tapping a distant site.
  g.ocean.fit_chart();g._view_changed();await settle()
  # WP-36: the pause and FLEET controls are plates (MAIN while paused, NORMAL running) in the rectangles they had as flat text.
  var was=g.sim.paused
  var old_pause=Rect2(12,12,151.9,98) if dimensions.x==2520 else Rect2(12,12,134.85,87)
  var old_fleet=Rect2(1425.433,12,151.9,98) if dimensions.x==2520 else Rect2(1133.15,12,134.85,87)
  for paused in [true,false]:
   g.sim.paused=paused;g._refresh();await settle()
   var label=name+(" paused" if paused else " running")
   check(g.pause_button.get_meta("ui_role","")==("MAIN" if paused else "QUIET"),"the pause control has the "+("MAIN" if paused else "QUIET")+" role "+label)
   check(g.advanced_button.get_meta("ui_role","")=="NORMAL","FLEET has the NORMAL role "+label)
   check(g.pause_button.text.begins_with("PAUSED\n") if paused else g.pause_button.text.begins_with("RUNNING\n"),"the pause control names the state first "+label+": "+g.pause_button.text)
   check("O₂" in g.pause_button.text,"the pause control keeps the life support reading "+label+": "+g.pause_button.text)
   check(g.pause_button.get_rect().position.is_equal_approx(old_pause.position) and g.pause_button.get_rect().size.is_equal_approx(old_pause.size),"the pause rectangle is unchanged "+label+" "+str(g.pause_button.get_rect()))
   check(g.advanced_button.get_rect().position.is_equal_approx(old_fleet.position) and g.advanced_button.get_rect().size.is_equal_approx(old_fleet.size),"the FLEET rectangle is unchanged "+label+" "+str(g.advanced_button.get_rect()))
   var plate:StyleBoxFlat=g.pause_button.get_theme_stylebox("normal")
   check((plate.bg_color.a>0.9 if paused else plate.bg_color.a==0.) and plate.border_width_left>0 and plate.corner_radius_top_left>0,"the pause control is a filled plate while paused and a quiet bordered outline while running "+label)
   check((g.advanced_button.get_theme_stylebox("normal") as StyleBoxFlat).bg_color.a>0.9,"FLEET is a filled plate "+label)
  g.sim.paused=was;g._refresh();await settle()
  var extraction=g.sim.mission.extraction;var label_origin=extraction+Vector2(-120,-66)
  check(g.ocean.world_label_position(label_origin,"EXTRACTION",18).is_finite(),"crowded recovery keeps its world label with safe relocated placement")
  await capture(name+"-water")
  g._focus_craft();await settle()
  var before=g.sim.snapshot();var ship=g.ocean.global_position+g.ocean.screen_position(g.sim.units[0].pos)
  await tap(ship)
  check(g.advanced_orders and g.sim.snapshot()==before,"tap craft opens contextual projection without route or spend")
  if not g.advanced_orders:g.queue_free();await settle();continue
  check(h.page=="craft" and h.ring_buttons.size()==8 and h.ring_buttons[3]==h.extra.deploy and not (g.order_buttons.program in h.ring_buttons),"craft menu presents eight stable labelled choices, DEPLOY in PLAN ROUTE's place while a drone is aboard and PLAN ROUTE on the ROUTE page (WP-35, WP-52)")
  var scale=Vector2(dimensions)/root.get_visible_rect().size
  for b in h.ring_buttons:
   check(g.get_global_rect().encloses(b.get_global_rect()) and b.size.x*scale.x>=125.99 and b.size.y*scale.y>=125.99,"clamped edge menu retains full48dp labels")
  # WP-31: centre lines are whole (no ellipsis), no ring word is split, the wheel stays on screen.
  check(h.caption_texts.all(func(t):return not str(t).ends_with("…")),"wheel centre text wraps instead of truncating")
  check(h.caption_rects.all(func(r):return Rect2(Vector2.ZERO,h.size).encloses(r)),"wheel centre lines stay inside the safe area")
  check(not h.caption_rects.is_empty() and h.caption_rects.all(func(r):return disc_holds(h,r)),"no wheel centre line crosses the disc")
  var wheel=Rect2(h.center-Vector2.ONE*h.ring_radius,Vector2.ONE*h.ring_radius*2)
  check(Rect2(Vector2.ZERO,h.size).encloses(wheel),"whole wheel sits inside the safe area")
  var zoomed=g.ocean.world_scale;g.ocean.world_scale=4.
  check(g.ocean.label_font(18)*4.<=18.+4. and g.ocean.label_font(18)*4.>=12.,"zoomed-in chart label keeps a constant readable on-screen size")
  g.ocean.world_scale=zoomed
  await capture(name+"-commands")
  await click(h.extra.tools_menu);check(h.page=="tools" and g.sim.snapshot()==before,"tools projection changes no tactical state")
  var sector=h.global_position+h.center+Vector2.from_angle(-PI/3)*h.ring_radius
  check(not g.order_buttons.decoy.get_global_rect().has_point(sector),"sector probe lies in actual visible wedge outside native label rectangle")
  await tap(sector);check(g.decoy_armed and not g.advanced_orders,"full visible wedge tap selects chosen tool into explicit aim")
  before=g.sim.snapshot();await click(h.close_button)
  check(not g.decoy_armed and not g.advanced_orders and g.sim.snapshot()==before,"CANCEL returns directly to water without charge or order")
  await tap(ship);await click(h.extra.route_menu);await click(g.order_buttons.queue)
  check(g.sim.queue_mode and not g.advanced_orders and "QUEUE" in h.intent.text,"explicit QUEUE returns to water with visible persistent intent")
  before=g.sim.snapshot();await tap(ship);await tap(g.global_position+Vector2(g.size.x-20,g.size.y-20))
  check(not g.advanced_orders and g.sim.snapshot()==before,"outside dismissal consumes its release without route")
  preload("res://tests/fixtures/player_dive.gd").launch_drones(g.sim);g.sim.units[1].pos=g.sim.units[0].pos;g.sim.units[2].pos=g.sim.units[0].pos;g._refresh();await settle();before=g.sim.snapshot()
  await tap(ship);check(h.page=="fleet" and g.sim.snapshot()==before,"overlapping own craft open explicit identity choices")
  g.ocean.pan_chart(Vector2(-60,0));var camera=g.ocean.chart_camera.snapshot();await click(g.unit_buttons[1])
  check(g.sim.selected==1 and g.ocean.chart_camera.mode=="free" and g.ocean.chart_camera.snapshot()==camera,"choosing a craft preserves FREE camera intent")
  h.dismiss();g.ocean.fit_chart();await settle();before=g.sim.snapshot()
  var site=g.ocean.observable_sites()[0];await tap(g.ocean.global_position+g.ocean.screen_position(site.pos))
  check(g.advanced_orders and h.page=="object" and g.sim.snapshot()==before,"briefed-object tap opens observational context without remote action")
  await capture(name+"-site")
  h.dismiss();g._focus_craft();await settle();ship=g.ocean.global_position+g.ocean.screen_position(g.sim.units[g.sim.selected].pos)
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
  # The new any-craft tutorial warning owns its own acknowledgement before
  # another button beneath that card can be tapped.
  if h.hints.panel.visible and h.hints.current in ["warning","sweep"]:await click(h.hints.dismiss_button)
  await click(h.instrument_button)
  check(h.sheet.visible and "RECORDS" in h.instrument_info.text and "reception unknown" in h.instrument_info.text,"STATUS exposes objective accounting and acoustic uncertainty")
  h.dismiss();g.sim.tools.emp=0;g.sim.tools.recon=0;g._refresh();h.open("tools");await settle()
  check(g.order_buttons.emp.visible and g.order_buttons.emp.disabled and g.order_buttons.recon.visible and g.order_buttons.recon.disabled,"depleted tools keep stable visible disabled slots and counts")
  before=g.sim.snapshot();sector=h.global_position+h.center+Vector2.from_angle(PI/6)*h.ring_radius
  await tap(sector)
  check(g.advanced_orders and h.page=="tools" and g.sim.snapshot()==before,"disabled wedge stays visible and consumes a separate tap without spend or route")
  for edge_page in ["craft","object"]:
   h.open(edge_page,{"kind":"craft" if edge_page=="craft" else "objective","unit":g.sim.selected,"index":0,"name":"SITE","pos":g.ocean.map_position(Vector2.ZERO)});await settle()
   var radius=h.ring_radius+h.touch_height*.6;var annulus=Rect2(h.global_position+h.center-Vector2.ONE*radius,Vector2.ONE*radius*2)
   check(h.ring_buttons.all(func(b):return not b.get_global_rect().intersects(g.pause_button.get_global_rect())) and not annulus.intersects(g.pause_button.get_global_rect()),"top-edge craft/object projection keeps labels and full annulus clear of PAUSE")
  # WP-36: a long single line wraps to the chord at its own height instead of being cut at the disc edge.
  h.open("object",{"kind":"objective","unit":g.sim.selected,"index":0,"name":"UNKNOWN SIGNAL SOURCE AREA BEYOND THE SOUTHERN SHELF","pos":g.ocean.map_position(h.size*.5)});await settle()
  check(not h.caption_rects.is_empty() and h.caption_rects.all(func(r):return disc_holds(h,r)),"a long site name stays inside the wheel centre disc")
  check(h.caption_texts.any(func(t):return "SOURCE" in str(t)) and h.caption_texts.all(func(t):return not str(t).ends_with("…")),"a long site name keeps its whole words")
  # WP-36: the outermost labels keep the safe-area margin at the left, right, top and bottom edges.
  var margin=h.edge_margin(h.touch_height)
  for spot in [Vector2(0,.5),Vector2(1,.5),Vector2(.5,0),Vector2(.5,1),Vector2(0,0),Vector2(1,1)]:
   h.open("craft",{"kind":"craft","unit":g.sim.selected,"pos":g.ocean.map_position(h.size*spot)});await settle()
   var safe=Rect2(Vector2.ZERO,h.size).grow(-margin+.5)
   check(h.ring_buttons.all(func(b):return safe.encloses(b.get_rect())),"outer labels keep the edge margin with the craft at "+str(spot)+" "+name)
  h.dismiss();g.queue_free();await settle()
 print("RADIAL HUD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
