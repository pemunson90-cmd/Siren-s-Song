extends SceneTree
var game
var checks=0
var failures=0
var output_dir=""
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="):output_dir=arg.trim_prefix("--output=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions
  game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="planner-metrics-test"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);game.set_process(false);game.ocean.hide();await settle();game._start_mission(0);await settle()
  game.sim.command("route",{"point":Vector2(260,800)})
  game._order("program");await settle()
  var state=game.sim.snapshot();var layout=game._ui_metrics()
  check(layout.screen=="program" and layout.has("planner"),"actual program metric payload present")
  if not layout.has("planner"):game.queue_free();await settle();continue
  var planner=layout.planner;var actions=[]
  for control in layout.controls:actions.append(control.action)
  for key in ["close","craft0","craft1","craft2","planner_zoom_out","planner_zoom_in","planner_fit"]:check(actions.has(key),"visible planner control "+key)
  check(not actions.has("pause") and not actions.has("mission0"),"hidden HUD/menu excluded")
  var preview=game.route_editor.preview;var physical=preview.get_global_rect();var scale=Vector2(root.size)/root.get_visible_rect().size
  check(planner.preview_physical==game._rect_values(Rect2(physical.position*scale,physical.size*scale)),"preview physical pixels follow actual control")
  check(planner.zoom==preview.chart_camera.zoom and planner.center==[preview.chart_camera.center.x,preview.chart_camera.center.y],"actual camera values")
  check(planner.intent.paused and planner.intent.selected==game.sim.selected and planner.intent.tools==game.sim.tools,"paused selection and finite supplies")
  check(planner.intent.units[0].goals[0].pos==[260.0,800.0],"own goal identity uses world coordinates")
  check(not planner.intent.has("sirens") and not planner.intent.has("contacts") and not planner.intent.has("mission_data"),"diagnostic identity excludes enemy/sensor data")
  var original=planner.intent
  preview.zoom_at(1.5,preview.size/2);await settle();var zoomed=game._ui_metrics().planner
  check(zoomed.zoom>planner.zoom and zoomed.intent==original,"zoom changes view only")
  preview.pan_chart(Vector2(-80,0));await settle();var panned=game._ui_metrics().planner
  check(panned.center!=zoomed.center and panned.intent==original,"pan changes center only")
  preview.fit_chart();await settle();var fitted=game._ui_metrics().planner
  check(fitted.zoom==1 and fitted.center==[800.0,480.0] and fitted.intent==original,"FIT preserves own intent")
  check(game.sim.snapshot()==state,"diagnostics and navigation do not mutate model")
  if not output_dir.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(output_dir.path_join("planner-"+str(dimensions.x)+".png"))
  game.route_editor.close();await settle();check(not game._ui_metrics().has("planner"),"closed planner not reported")
  game.queue_free();await settle()
 print("PLANNER METRICS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
