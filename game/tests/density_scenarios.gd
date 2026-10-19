extends SceneTree
var checks=0
var failures=0
func check(ok: bool,message: String):
 checks+=1
 if not ok: failures+=1; printerr("FAIL: ",message)
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(2520,1080); await process_frame; await process_frame
 var ui=load("res://scenes/main.tscn").instantiate(); ui.set_script(preload("res://tests/density_main.gd")); ui.capture_scenario="density-test"; root.add_child(ui)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
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
   check(ui.order_buttons.camera.is_visible_in_tree() and ui.order_buttons.home.is_visible_in_tree(),"camera and emergency remain accessible on both order pages")
   var metrics=ui._ui_metrics()
   var safe=Rect2(Vector2.ZERO,ui.get_viewport_rect().size)
   for i in metrics.controls.size():
    var c=metrics.controls[i];var r=Rect2(c.hit_rect[0],c.hit_rect[1],c.hit_rect[2],c.hit_rect[3])
    check(not c.clipped and safe.encloses(r),"visible mission action %s fully exposed"%c.action)
    for j in range(i):
     var other=metrics.controls[j].hit_rect;var intersection=r.intersection(Rect2(other[0],other[1],other[2],other[3]))
     check(not intersection.has_area(),"actual hit rectangles %s/%s do not overlap"%[c.action,metrics.controls[j].action])
  var area=ui.ocean.size.x*ui.ocean.size.y/(ui.size.x*ui.size.y)
  check(area>=0.50,"enlarged physical targets retain at least half the surface for the chart")
  ui._briefing(5);await process_frame;await process_frame
  var begin
  for button in ui.find_children("*","Button",true,false):
   if button.get_meta("action","")=="begin":begin=button
  check(begin!=null and ui.menu.get_global_rect().encloses(begin.get_global_rect()) and ui.get_viewport_rect().encloses(begin.get_global_rect()),"long finale briefing keeps ENTER WATER fully exposed at physical target size")
 check(ui.has_method("_ui_metrics"),"actual hit geometry and density provenance are available for independent native measurement")
 ui.queue_free();await process_frame;await create_timer(0.5).timeout
 print("DENSITY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
