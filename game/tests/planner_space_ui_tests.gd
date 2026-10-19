extends SceneTree
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 10:await process_frame
func touch(p:Vector2,down:bool):
 var event=InputEventScreenTouch.new();event.index=0;event.position=p;event.pressed=down;root.push_input(event,true);await process_frame
func fitted_area(preview) -> float:
 var fitted=preview.chart_rect().size/preview.chart_camera.zoom
 return fitted.x*fitted.y
func capture(game,name:String):
 var p=game.route_editor.preview;var scale=Vector2(root.size)/root.get_visible_rect().size
 print("PLANNER_SPACE ",name," panel=",game.route_editor.size," preview=",p.size," fitted_physical=",p.chart_rect().size*scale," area_physical=",fitted_area(p)*scale.x*scale.y)
 if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func pan_during_reflow(game,dimensions:Vector2i,gesture:bool):
 var panel=game.route_editor;var p=panel.preview
 p.fit_chart();p.zoom_at(4.,p.size/2);p.pan_chart(Vector2(-100,-50));await settle()
 var saved=game.sim.snapshot();var selected=panel.selected_goal
 root.size=Vector2i(2184,1968) if dimensions.x==2520 else Vector2i(2520,1080)
 await process_frame
 var before=p.chart_camera.center
 if gesture:
  var origin=p.global_position+p.size/2
  var press=InputEventScreenTouch.new();press.index=0;press.position=origin;press.pressed=true;root.push_input(press,true)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=origin+Vector2(-30,0);root.push_input(drag,true)
  var release=InputEventScreenTouch.new();release.index=0;release.position=drag.position;release.pressed=false;root.push_input(release,true)
 else:p.pan_chart(Vector2(-30,0))
 var intended=p.chart_camera.center;var label="completed gesture" if gesture else "public pan"
 check(intended.distance_to(before)>1 and not p.map_gesture.active(),label+" completes a meaningful pan before resize restore")
 await settle()
 check(p.chart_camera.center.distance_to(intended)<.1,label+" during reflow takes precedence over saved center")
 check(game.sim.snapshot()==saved and panel.selected_goal==selected,label+" during reflow preserves paused route intent")
 root.size=dimensions;await settle()
func action(panel,key:String):
 for b in panel.find_children("*","Button",true,false):
  if b.get_meta("action","")==key:return b
 return null
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="planner-space"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(0);game._order("program");await settle()
  var panel=game.route_editor;var p=panel.preview;var name="cover" if dimensions.x==2520 else "inner"
  await capture(game,name+"-empty")
  # This measures the world drawn at FIT, rather than a large letterboxed Control.
  check(fitted_area(p)>panel.size.x*panel.size.y*(.22 if name=="cover" else .40),name+" fitted world uses substantial planner area")
  if name=="inner":check(p.size.x>panel.size.x*.9,"inner chart spans the panel above editing controls")
  else:check(p.size.x>panel.size.x*.5,"cover chart receives the larger content share")
  for n in 10:game.sim.command("route_insert",{"index":n,"point":Vector2(180+n*30,800)})
  panel.selected_goal=9;panel.refresh();await settle();await capture(game,name+"-populated")
  check(panel.row_scroll.get_global_rect().encloses(panel.selected_row.get_global_rect()),name+" selected last waypoint scrolls into view")
  var physical_scale=Vector2(root.size)/root.get_visible_rect().size
  for key in ["close","craft0","craft1","craft2","propulsion","arrival","insert","delete","undo","planner_zoom_out","planner_zoom_in","planner_fit"]:
   var b=action(panel,key)
   check(b!=null and panel.get_global_rect().encloses(b.get_global_rect()) and b.size.y*physical_scale.y>=125.99 and b.size.x*physical_scale.x>=125.99,name+" visible48dp control "+key)
  var saved=game.sim.snapshot();var selected=panel.selected_goal;var preview_id=p.get_instance_id()
  p.zoom_at(2.,p.size/2);p.pan_chart(Vector2(-20,-10));await settle()
  var zoom=p.chart_camera.zoom;var center=p.chart_camera.center
  var origin=p.global_position+p.size/2;await touch(origin,true)
  game.fixture_safe_area=Rect2()
  root.size=Vector2i(2184,1968) if dimensions.x==2520 else Vector2i(2520,1080)
  await settle()
  await touch(p.global_position+p.size/2,false);await settle()
  check(p.get_instance_id()==preview_id and p.chart_camera.zoom==zoom,"resize keeps the same preview and zoom")
  var expected_camera=load("res://src/presentation/chart_camera.gd").new();expected_camera.zoom=zoom;expected_camera.center=center;expected_camera.configure(p.size)
  check(p.chart_camera.center.distance_to(expected_camera.center)<.1,"resize preserves inspected center subject to chart bounds: "+str(center)+" -> "+str(p.chart_camera.center)+" expected "+str(expected_camera.center))
  check(game.sim.snapshot()==saved and panel.selected_goal==selected and game.sim.paused,"resize cancels pending touch and preserves paused route intent")
  check(panel.row_scroll.get_global_rect().encloses(panel.selected_row.get_global_rect()),"resize keeps selected last row visible")
  p.fit_chart();await settle();check(p.chart_camera.zoom==1 and p.chart_camera.center==Vector2(800,480),"FIT restores world overview after reflow")
  p.zoom_at(2.,p.size/2)
  root.size=dimensions;game.fixture_safe_area=Rect2(136,0,2384,1080) if dimensions.x==2520 else Rect2()
  await process_frame;p.fit_chart();await settle()
  check(p.chart_camera.zoom==1 and p.chart_camera.center==Vector2(800,480) and game.sim.snapshot()==saved,"FIT during reflow takes precedence and preserves model")
  await pan_during_reflow(game,dimensions,false);await pan_during_reflow(game,dimensions,true)
  game.queue_free();await settle()
 print("PLANNER SPACE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
