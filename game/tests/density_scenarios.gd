extends SceneTree
var checks=0
var failures=0
func check(ok: bool,message: String):
 checks+=1
 if not ok: failures+=1; printerr("FAIL: ",message)
func _initialize():call_deferred("run")
func click(point: Vector2) -> void:
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true);await process_frame
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
 await process_frame
func route_intent(ui) -> void:
 # This route uses Survey from Drone A; equip its own charge before launching.
 ui.tool_racks=preload("res://src/equipment/tool_racks.gd").empty();ui.tool_racks.drone_a.recon=1
 ui._start_mission(0);await process_frame;await process_frame;await process_frame
 ui.mission_hud.open("fleet");await process_frame;await click(ui.unit_buttons[1].get_global_rect().get_center())
 ui.mission_hud.dismiss();ui.ocean.fit_chart();await process_frame
 await click(ui.ocean.global_position+ui.ocean.screen_position(Vector2(600,800)))
 ui.mission_hud.open("route");await process_frame;await click(ui.order_buttons.queue.get_global_rect().get_center())
 ui.mission_hud.open("tools");await process_frame;await click(ui.order_buttons.recon.get_global_rect().get_center())
 check(ui.sim.queue_mode and not ui.order_buttons.queue.is_visible_in_tree(),"survey preserves explicit queued state after contextual menu closes")
 check(ui.mission_hud.intent.is_visible_in_tree() and "DRONE A · MIDDLE · QUEUE" in ui.mission_hud.intent.text,"selected craft and sticky append intent remain visible on water")
 var second=Vector2.INF
 for candidate in [Vector2(900,600),Vector2(1100,800),Vector2(600,700)]:
  var point=ui.ocean.global_position+ui.ocean.screen_position(candidate)
  if not ui.mission_hud.blocks(point) and not ui.sim.blocked(candidate,24) and ui.ocean.pick_context(point-ui.ocean.global_position,ui.ui_touch_height).is_empty():second=candidate;break
 check(second.is_finite(),"queue fixture exposes legal water clear of the floating undo control")
 await click(ui.ocean.global_position+ui.ocean.screen_position(second))
 check(ui.sim.route_goals(1).size()==2,"ordinary chart tap still appends to the actual queued plan")
 # 127 (Pat 2026-10-30): EXTRACT autopilot is a dev/test shortcut; release play hides it.
 ui.set_meta("dev_profile",true)
 ui.mission_hud.open("route");await process_frame;await click(ui.order_buttons.home.get_global_rect().get_center())
 # 133: a craft outside recovery asks first; CONFIRM carries on as the press did before.
 if ui.screen=="recovery_manifest":
  for b in ui.menu.find_children("*","Button",true,false):
   if b.get_meta("action","")=="manifest_confirm":await click(b.get_global_rect().get_center())
 ui.set_meta("dev_profile",false)
 check(ui.sim.queue_mode and ui.sim.selected==1 and ui.sim.route_goals(1)[-1].pos==ui.sim.mission.extraction and "DRONE A · MIDDLE · QUEUE" in ui.mission_hud.intent.text,"ordinary recovery routing honors the explicit queued intent")
func run():
 root.size=Vector2i(2520,1080); await process_frame; await process_frame
 var ui=load("res://scenes/main.tscn").instantiate(); ui.set_script(preload("res://tests/density_main.gd")); ui.capture_scenario="density-test"; root.add_child(ui)
 for profile in [{"size":Vector2i(2520,1080),"inset":0},{"size":Vector2i(2184,1968),"inset":0},{"size":Vector2i(2520,1080),"inset":136}]:
  var dimensions=profile.size
  ui.fixture_safe_area=Rect2(profile.inset,0,dimensions.x-profile.inset,dimensions.y) if profile.inset>0 else Rect2()
  print("DENSITY_PROFILE window=",dimensions," recorded_inset_x=",profile.inset)
  root.size=dimensions; await process_frame; await process_frame
  ui._start_mission(0); ui._layout(); await process_frame; await process_frame
  var scale=Vector2(dimensions)/ui.get_viewport_rect().size
  var before=ui.sim.snapshot()
  for page in ["water","craft","tools","route","guard","fleet","inspect"]:
   if page=="water":ui.mission_hud.dismiss()
   else:ui.mission_hud.open(page)
   await process_frame;await process_frame
   var buttons=ui.mission_hud.action_controls().values()
   for button in buttons:
    if not button.is_visible_in_tree():continue
    var dp=button.get_global_rect().size*scale/(420.0/160.0)
    var font_size=maxi(14,roundi(ui.ui_touch_height*.26)) if button in ui.mission_hud.fleet.buttons else button.get_theme_font_size("font_size")
    check(font_size*scale.y/(420.0/160.0)>=13.99,"%s %s readable text retains at least14 fixture dp"%[dimensions,button.text])
    check(dp.x>=47.99 and dp.y>=47.99,"%s %s actual target meets48dp; measured%s"%[dimensions,button.text,dp])
   check(ui.sim.snapshot()==before,"opening secondary orders does not mutate paused tactical state")
   check(ui.pause_button.is_visible_in_tree(),"pause stays immediately accessible on every contextual page")
   var metrics=ui._ui_metrics()
   var safe=preload("res://src/presentation/layout_metrics.gd").content_rect(ui.get_viewport_rect().size,Vector2(dimensions),Rect2(profile.inset,0,dimensions.x-profile.inset,dimensions.y))
   for i in metrics.controls.size():
    var c=metrics.controls[i];var r=Rect2(c.hit_rect[0],c.hit_rect[1],c.hit_rect[2],c.hit_rect[3])
    check(not c.clipped and safe.encloses(r),"visible mission action %s fully exposed"%c.action)
    for j in range(i):
     var other=metrics.controls[j].hit_rect;var intersection=r.intersection(Rect2(other[0],other[1],other[2],other[3]))
     check(not intersection.has_area(),"actual hit rectangles %s/%s do not overlap"%[c.action,metrics.controls[j].action])
  var area=ui.ocean.size.x*ui.ocean.size.y/(ui.get_viewport_rect().size.x*ui.get_viewport_rect().size.y)
  check(area>=0.50,"enlarged physical targets retain at least half the surface for the chart")
  await route_intent(ui)
  ui._briefing(5);await process_frame;await process_frame
  var begin
  for button in ui.find_children("*","Button",true,false):
   if button.get_meta("action","")=="begin":begin=button
  check(begin!=null and ui.menu.get_global_rect().encloses(begin.get_global_rect()) and ui.get_viewport_rect().encloses(begin.get_global_rect()),"long finale briefing keeps ENTER WATER fully exposed at physical target size")
  var content_safe=preload("res://src/presentation/layout_metrics.gd").content_rect(ui.get_viewport_rect().size,Vector2(dimensions),Rect2(profile.inset,0,dimensions.x-profile.inset,dimensions.y))
  for button in ui.menu_footer.get_children():
   check(content_safe.encloses(button.get_global_rect()),"sticky briefing action %s remains inside recorded physical safe region"%button.get_meta("action",""))
  ui._settings_menu();await process_frame;await process_frame;await process_frame
  for button in ui.menu_footer.get_children():
   check(content_safe.encloses(button.get_global_rect()),"sticky Settings BACK remains inside recorded physical safe region")
 check(ui.has_method("_ui_metrics"),"actual hit geometry and density provenance are available for independent native measurement")
 ui.queue_free();await process_frame;await create_timer(0.5).timeout
 print("DENSITY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
