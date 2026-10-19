extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var game
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func action(key):
 for b in game.route_editor.find_children("*","Button",true,false):
  if b.is_visible_in_tree() and b.get_meta("action","")==key:return b
 return null
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func progress():
 return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Fixture recovered carrier","confluence_route":"concealed","resolution":"concealed_recovery"},"completed":[6,7,9,11,12],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func run():
 # Recovered-context and blocked-state fixtures isolate presentation. Actual
 # journey screenshots are produced separately from an earned saved profile.
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="earned-chart-ui"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game.expedition=progress();game._start_mission(14);await settle()
  var sim=game.sim;var chart=sim.public_chart();var state=sim.snapshot()
  for operation in [func():game.ocean.fit_chart(),func():game.ocean.pan_chart(Vector2(-50,30)),func():game.ocean.focus_craft()]:
   operation.call();await settle()
  check(sim.snapshot()==state and sim.public_chart()==chart,"FOLLOW FREE FIT in pause preserve actual earned chart and tactical state")
  game.mission_hud.open("inspect");await settle()
  check("HANDOFF" in game.mission_hud.instrument_info.text and not "0/0" in game.mission_hud.instrument_info.text,"STATUS names physical handoff objective instead of empty record accounting")
  check(game.order_buttons.camera.disabled and game.order_buttons.camera.text=="NAVIGATE","empty local CAMERA does not suggest fictional receiver work")
  check(game.mission_hud.sheet.get_global_rect().end.y<game.size.y and game.mission_hud.close_button.get_global_rect().end.y<game.size.y,"navigation STATUS and BACK fit both device shapes")
  game.mission_hud.dismiss();game.sim.command("route",{"point":Vector2(500,2700)});game.sim.command("queue");game.sim.command("route",{"point":Vector2(300,2700)});game._order("program");await settle()
  var editor=game.route_editor;var tail=sim.route_goals()[1].duplicate(true)
  editor.preview.fit_chart();await settle()
  var target=Vector2(1000,2300);var point=editor.preview.global_position+editor.preview.screen_position(target)
  check(editor.preview.get_global_rect().has_point(point),"hidden-rock goal lies in actual visible planner water")
  await tap(point)
  check(sim.route_goals()[0].pos.distance_to(target)<1. and sim.route_goals()[1]==tail,"ordinary preview tap accepts unknown rock endpoint and retains queued return")
  check(sim.paused and sim.public_chart()==chart and sim.capture_unit<0,"plotting unknown intent adds no chart or capture and remains paused")
  for blocked in [false,true]:
   if blocked:sim.units[0]["chart_stop"]="New terrain — replot"
   editor.refresh();await settle()
   check(editor.point_info.text.contains("REPLOT" if blocked else "TENTATIVE"),"planner explains active course uncertainty or replot latch")
   check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(editor.get_global_rect()),"uncertainty and blocked guidance retain bounded planner height")
   for id in ["propulsion","arrival","insert","delete","undo"]:
    var b=action(id)
    check(b!=null and Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(b.get_global_rect()) and b.size.y>=game.ui_touch_height,"full-size visible replot editing target "+id)
  var before=sim.snapshot();editor.preview.pan_chart(Vector2(40,-30));editor.preview.zoom_at(1.5,editor.preview.size*.5);await settle()
  check(sim.snapshot()==before,"planner camera gestures retain full intent and chart in pause")
  game.queue_free();await settle()
 print("EARNED CHART UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
