extends SceneTree
var checks:=0
var failures:=0
var capture_dir:=""
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",message)
func _initialize() -> void:call_deferred("run")
func settle() -> void:
 for i in 4:await process_frame
func click(point: Vector2) -> void:
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true);await process_frame
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.position=point;event.global_position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
 await settle()
func layout_issues(ui,profile) -> Array:
 var issues=[];var buttons=[ui.pause_button,ui.advanced_button];buttons.append_array(ui.unit_buttons);buttons.append_array(ui.order_buttons.values());buttons.append_array(ui.zoom_buttons)
 var visible=[];var scale=Vector2(profile.size)/ui.get_viewport_rect().size
 for b in buttons:
  if not b.is_visible_in_tree():continue
  var r=b.get_global_rect();var minimum=48.0*profile.dpi/160.0 if profile.dpi==420.0 else 48.0
  if not ui.get_global_rect().encloses(r):issues.append("unsafe "+b.text.replace("\n","/"))
  var touch_size=r.size*scale if profile.dpi==420.0 else r.size
  if touch_size.x<minimum-0.01 or touch_size.y<minimum-0.01:issues.append("small "+b.text.replace("\n","/"))
  for other in visible:
   if r.intersects(other.get_global_rect()):issues.append("overlap %s / %s"%[b.text.replace("\n","/"),other.text.replace("\n","/")])
  visible.append(b)
 return issues
func begin_drag(ui) -> Vector2:
 var point=ui.ocean.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true)
 var down=InputEventMouseButton.new();down.position=point;down.global_position=point;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;root.push_input(down,true);await process_frame
 point+=Vector2(32,20);motion.position=point;motion.global_position=point;motion.relative=Vector2(32,20);root.push_input(motion,true);await process_frame
 return point
func end_drag(point: Vector2) -> void:
 var up=InputEventMouseButton.new();up.position=point;up.global_position=point;up.button_index=MOUSE_BUTTON_LEFT;root.push_input(up,true);await settle()
func run() -> void:
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for profile in [{"name":"desktop","size":Vector2i(1280,720),"dpi":95.0,"inset":0},{"name":"cover","size":Vector2i(2520,1080),"dpi":420.0,"inset":136},{"name":"inner","size":Vector2i(2184,1968),"dpi":420.0,"inset":0},{"name":"four-three","size":Vector2i(1024,768),"dpi":95.0,"inset":0},{"name":"wide-small","size":Vector2i(1440,900),"dpi":95.0,"inset":0}]:
  if not capture_dir.is_empty() and profile.name not in ["desktop","cover","inner"]:continue
  root.size=profile.size;await settle()
  var ui=load("res://scenes/main.tscn").instantiate();ui.set_script(preload("res://tests/order_row_main.gd"));ui.capture_scenario="order-row-test";ui.fixture_dpi=profile.dpi
  if profile.inset:ui.fixture_safe_area=Rect2(profile.inset,0,profile.size.x-profile.inset,profile.size.y)
  root.add_child(ui);await settle()
  for state in [{"mission":0,"task":"READY","stock":3},{"mission":1,"task":"ROUTE","stock":2},{"mission":5,"task":"EXPOSING","stock":1,"target":2,"label":"LISTEN"},{"mission":0,"task":"OPTICAL","stock":2,"target":0,"label":"PHOTO"},{"mission":1,"task":"UPLINK","stock":1,"target":2,"label":"LINK"},{"mission":2,"task":"LISTEN","stock":0,"target":0,"label":"DECODE"},{"mission":0,"task":"CONTACT","stock":0},{"mission":0,"task":"DRONE","stock":1},{"mission":0,"task":"LOST","stock":2}]:
   if not capture_dir.is_empty() and not (state.task=="READY" or (state.task=="EXPOSING" and profile.name=="cover")):continue
   # Seed the actual carrying rack for each finite-stock layout state.
   ui.tool_racks=preload("res://src/equipment/tool_racks.gd").empty()
   ui.tool_racks.quietus={"emp":state.stock,"recon":state.stock,"decoy":state.stock}
   ui._start_mission(state.mission);await settle()
   if state.task=="ROUTE":ui.sim.command("route",{"point":Vector2(320,800)})
   elif state.has("target"):ui.sim.captures[0]={"target":state.target,"elapsed":0.0}
   elif state.task=="LOST":ui.sim.units[1].alive=false
   elif state.task in ["CONTACT","DRONE"]:ui.sim.units[0].hold=state.task
   ui.sim.queue_mode=state.stock==0;ui.sim.pass_through=state.stock!=1;ui.sim.units[0].silent=state.stock!=2;ui._refresh();await settle()
   if state.has("label"):
    check(ui.unit_buttons[0].text.get_slice("\n",1)==state.label,"%s active %s uses short honest %s task"%[profile.name,state.task,state.label])
    var b=ui.unit_buttons[0];var required=b.get_theme_font("font").get_string_size(state.label,HORIZONTAL_ALIGNMENT_LEFT,-1,b.get_theme_font_size("font_size")).x+b.get_theme_stylebox("normal").get_minimum_size().x
    check(required<=b.size.x,"%s active %s task remains one whole word at unchanged font"%[profile.name,state.task])
   for advanced in [false,true]:
    if ui.advanced_orders!=advanced:ui._toggle_advanced();await settle()
    var issues=layout_issues(ui,profile)
    check(issues.is_empty(),"%s %s %s safe disjoint targets: %s"%[profile.name,state.task,"advanced" if advanced else "primary",str(issues)])
    check(ui.unit_buttons[0].get_theme_font_size("font_size")==maxi(14,roundi(ui.ui_touch_height*0.26)) and ui.advanced_button.get_theme_font_size("font_size")==maxi(14,roundi(ui.ui_touch_height*0.26)) and ui.order_buttons.emp.get_theme_font_size("font_size")==maxi(14,roundi(ui.ui_touch_height*0.26)),"%s fonts preserved"%profile.name)
   if not capture_dir.is_empty() and state.task in ["READY","EXPOSING"] and profile.name in ["desktop","cover","inner"]:
    ui._toggle_advanced();await settle();await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(capture_dir+"/"+profile.name+("-exposing" if state.task=="EXPOSING" else "")+".png")
  ui._start_mission(0);await settle();var before=ui.sim.snapshot()
  var point=await begin_drag(ui);await settle();var reports=ui.target_reports
  for i in 10:await process_frame
  check(ui.map_gesture.active() and ui.target_reports==reports,"%s stable refresh preserves chart drag without repeated relayout reports"%profile.name)
  await end_drag(point)
  check(ui.sim.snapshot()==before,"%s chart drag/release creates no accidental order"%profile.name)
  point=await begin_drag(ui);var previous_chart=ui.ocean.get_global_rect();ui.sim.captures[0]={"target":0,"elapsed":0.0};ui._refresh();await settle()
  check(ui.map_gesture.active()==(ui.ocean.get_global_rect()==previous_chart),"%s dynamic task reflow cancels drag only if chart bounds change"%profile.name)
  await end_drag(point);ui._start_mission(0);await settle();before=ui.sim.snapshot()
  await click(ui.advanced_button.get_global_rect().get_center())
  check(ui.advanced_orders and ui.sim.snapshot()==before,"%s real MORE click changes only order page"%profile.name)
  await click(ui.unit_buttons[2].get_global_rect().get_center())
  var expected=ui.Simulation.new();expected.restore(before);expected.command("select",{"unit":2})
  check(ui.sim.selected==2 and ui.sim.snapshot()==expected.snapshot(),"%s real DRONE B click selects without spurious route/tool order"%profile.name)
  await click(ui.advanced_button.get_global_rect().get_center())
  check(not ui.advanced_orders,"%s real BACK ORDERS click restores primary page"%profile.name)
  print("ORDER_ROW_PROFILE ",profile.name," toggle=",ui.advanced_button.get_global_rect()," droneB=",ui.unit_buttons[2].get_global_rect()," emp=",ui.order_buttons.emp.get_global_rect())
  ui.queue_free();await process_frame;await create_timer(0.5).timeout
 print("ORDER ROW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
