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
 ui._start_mission(0);await process_frame;await process_frame;await process_frame
 await click(ui.unit_buttons[1].get_global_rect().get_center())
 await click(ui.ocean.global_position+ui.ocean.world_offset+Vector2(600,800)*ui.ocean.world_scale)
 await click(ui.order_buttons.queue.get_global_rect().get_center())
 await click(ui.advanced_button.get_global_rect().get_center())
 await click(ui.order_buttons.recon.get_global_rect().get_center())
 check(ui.sim.queue_mode and not ui.order_buttons.queue.is_visible_in_tree(),"secondary survey preserves explicit queued state without hidden mutation")
 check(ui.detail_label.is_visible_in_tree() and ui.detail_label.text.begins_with("DRONE A · ADD TO ROUTE"),"selected craft and sticky append intent remain visible after secondary survey replaces log")
 await click(ui.ocean.global_position+ui.ocean.world_offset+Vector2(900,800)*ui.ocean.world_scale)
 check(ui.sim.units[1].route.size()==2,"ordinary chart tap still appends to the actual queued plan")
 await click(ui.order_buttons.home.get_global_rect().get_center())
 check(not ui.sim.queue_mode and ui.sim.selected==1 and ui.detail_label.text.begins_with("DRONE A · REPLACE ROUTE"),"emergency replacement visibly clears stale append state on secondary page")
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
  for secondary in [false,true]:
   if secondary:ui._toggle_advanced();await process_frame;await process_frame
   var buttons=ui.unit_buttons.duplicate();buttons.append(ui.pause_button);buttons.append(ui.advanced_button);buttons.append_array(ui.zoom_buttons);buttons.append_array(ui.order_buttons.values())
   for button in buttons:
    if not button.is_visible_in_tree():continue
    var dp=button.get_global_rect().size*scale/(420.0/160.0)
    check(button.get_theme_font_size("font_size")*scale.y/(420.0/160.0)>=13.99,"%s %s readable text retains at least14 fixture dp"%[dimensions,button.text])
    check(dp.x>=47.99 and dp.y>=47.99,"%s %s actual target meets48dp; measured%s"%[dimensions,button.text,dp])
   check(ui.sim.snapshot()==before,"opening secondary orders does not mutate paused tactical state")
   check((ui.order_buttons.knock.is_visible_in_tree() if secondary else ui.order_buttons.camera.is_visible_in_tree()) and ui.order_buttons.home.is_visible_in_tree(),"primary camera or secondary knock and emergency remain accessible")
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
  var header_font=ui.detail_label.get_theme_font("font")
  var header_size=ui.detail_label.get_theme_font_size("font_size")
  for mission_id in 6:
   for objective in ui.Simulation.Missions.make(mission_id).objectives:
    for field in ["requirement","unit_requirement"]:
     if not objective.has(field):continue
     var text="DRONE A · REPLACE ROUTE · "+objective[field]
     check(header_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,header_size).x<=ui.detail_label.size.x,"long authored camera prerequisite fits with persistent route intent: %s"%objective[field])
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
