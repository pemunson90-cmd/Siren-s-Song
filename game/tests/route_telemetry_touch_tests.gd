extends SceneTree
# Source-known local input fixtures, not a blind campaign journey.
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func touch(point:Vector2,down:bool,id:int=0):
 var event=InputEventScreenTouch.new();event.index=id;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func move(point:Vector2,delta:Vector2,id:int=0):
 var event=InputEventScreenDrag.new();event.index=id;event.position=point;event.relative=delta;root.push_input(event,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  await touch(point,down)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="route-telemetry-touch-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(0);await settle()
  var sim=game.sim;var h=game.mission_hud;var fleet=h.fleet;var name="cover" if dimensions.x==2520 else "inner"
  check(fleet.get("telemetry") is Array,"fleet telemetry is a separate read-only display beside explicit station handles")
  if not fleet.get("telemetry") is Array:game.queue_free();await settle();continue
  # Clear known geometry solely to isolate gesture ownership from path rejection.
  sim.sirens=[];sim.mission.rocks=[];sim.mission.structures=[];sim.mission.objectives=[];sim._build_navigation()
  sim.units[0].pos=Vector2(450,620);sim.units[1].pos=Vector2(900,720);sim.units[2].pos=Vector2(1460,160)
  game.ocean.fit_chart();game._refresh();await settle()
  var text=fleet.telemetry[0];var handle=fleet.buttons[0];var point=text.get_global_rect().get_center()
  var world=game.ocean.map_position(point-game.ocean.global_position)
  check(text.mouse_filter==Control.MOUSE_FILTER_IGNORE and not game.mission_hud.blocks(point) and game.ocean.pick_context(point-game.ocean.global_position,game.ui_touch_height).is_empty(),"read-only reserve text leaves its underlying permitted water available to chart input")
  check(handle.size.x>=game.ui_touch_height and handle.size.y>=game.ui_touch_height and not handle.get_global_rect().intersects(text.get_global_rect()),"identity is a full-size separately bounded touch handle, not a hidden sliver of telemetry")
  check(fleet.readouts.all(func(r):return r.has("handle_rect") and r.has("text_rect") and r.rect.encloses(r.handle_rect) and (not r.text_rect.has_area() or r.rect.encloses(r.text_rect))),"visual bounds reserve actual rings and currently visible informational text")
  await capture(name+"-readout-handles")
  await tap(point)
  check(sim.selected==0 and not game.advanced_orders and sim.route_goals().size()==1 and sim.route_goals()[0].pos.distance_to(world)<1.,"tap on telemetry issues exactly one selected-craft route to underlying water")
  var first=sim.route_goals()[0].pos
  sim.command("queue");game._refresh();await settle();point=fleet.telemetry[0].get_global_rect().get_center();world=game.ocean.map_position(point-game.ocean.global_position)
  await tap(point)
  check(sim.queue_mode and sim.selected==0 and not game.advanced_orders and sim.route_goals().size()==2 and sim.route_goals()[0].pos==first and sim.route_goals()[1].pos.distance_to(world)<1.,"telemetry route respects explicit QUEUE and retains the preceding destination")
  game.mission_hud.guard.reset();game._refresh();await settle()  # the order-undo chip is not part of these gesture fixtures
  var before=sim.snapshot();var camera=game.ocean.chart_camera.snapshot();point=fleet.telemetry[0].get_global_rect().get_center()
  await touch(point,true);await move(point+Vector2(90,35),Vector2(90,35));await touch(point+Vector2(90,35),false);await settle()
  check(sim.snapshot()==before and game.ocean.chart_camera.snapshot()!=camera and game.ocean.chart_camera.mode=="free","drag begun on telemetry pans without changing routes selection or pause")
  point=fleet.telemetry[0].get_global_rect().get_center();var start_below=point+Vector2(0,fleet.telemetry[0].size.y+20);before=sim.snapshot();camera=game.ocean.chart_camera.snapshot()
  await touch(start_below,true);await move(point,point-start_below);await touch(point,false);await settle()
  check(sim.snapshot()==before and game.ocean.chart_camera.snapshot()!=camera,"water drag crossing into telemetry stays chart navigation rather than transferring to a station")
  point=fleet.telemetry[0].get_global_rect().get_center();before=sim.snapshot();camera=game.ocean.chart_camera.snapshot()
  await touch(point,true);await touch(point+Vector2(160,0),true,1);await move(point+Vector2(200,20),Vector2(40,20),1);await touch(point,false);await touch(point+Vector2(200,20),false,1);await settle()
  check(sim.snapshot()==before and game.ocean.chart_camera.snapshot()!=camera and not game.advanced_orders,"pinch starting over telemetry navigates without route or craft action")
  # A genuine cancellation cannot be reinterpreted as a tap on release.
  point=fleet.telemetry[0].get_global_rect().get_center();before=sim.snapshot();await touch(point,true)
  var cancel=InputEventScreenTouch.new();cancel.index=0;cancel.position=point;cancel.pressed=false;cancel.canceled=true;root.push_input(cancel,true);await process_frame
  await touch(point,false);await settle();check(sim.snapshot()==before and not game.map_gesture.active(),"canceled telemetry touch has no late route or lingering pointer")
  game.ocean.focus_craft();game._refresh();await settle();before=sim.snapshot()
  check(fleet.readouts.any(func(r):return r.unit==2 and r.offscreen),"separated station keeps an offscreen identity handle")
  await tap(fleet.buttons[2].get_global_rect().get_center())
  check(sim.selected==2 and game.ocean.chart_camera.mode=="follow" and not game.advanced_orders,"offscreen identity tap selects and focuses that craft without routing")
  await tap(fleet.buttons[2].get_global_rect().get_center())
  check(game.advanced_orders and h.page=="craft","second followed identity tap retains intentional craft radial access")
  h.dismiss();await settle();point=fleet.telemetry[2].get_global_rect().get_center();before=sim.snapshot()
  h.open("craft");await settle();await tap(point)
  check(sim.snapshot()==before,"a modal craft popup owns telemetry-area tap and cannot leak a world route")
  h.dismiss();await settle();before=sim.snapshot();var start=fleet.buttons[1].get_global_rect().get_center();var water=fleet.telemetry[2].get_global_rect().get_center()
  await touch(start,true);await touch(water,true,1);await touch(start,false);await touch(water,false,1);await settle()
  check(sim.snapshot()==before and not game.advanced_orders,"handle-first mixed gesture cannot select or leak a telemetry-water route")
  start=fleet.buttons[1].get_global_rect().get_center();water=fleet.telemetry[2].get_global_rect().get_center();before=sim.snapshot()
  await touch(water,true);await touch(start,true,1);await touch(water,false);await touch(start,false,1);await settle()
  check(sim.snapshot()==before and not game.advanced_orders,"water-first mixed handle gesture preserves cancellation history")
  # Navigation through read-only text also remains available after selecting.
  game.ocean.pan_chart(Vector2(-140,30));game._refresh();await settle();await tap(fleet.buttons[2].get_global_rect().get_center())
  check(game.advanced_orders and h.page=="craft" and game.ocean.chart_camera.mode=="free","visible craft opens its own context in place without resetting manual view")
  h.dismiss();await settle()
  before=sim.snapshot();await tap(game.ocean.global_position+game.ocean.screen_position(sim.units[2].pos))
  check(game.advanced_orders and h.page=="craft" and sim.snapshot()==before,"physical craft-body tap still opens the intentional radial")
  await capture(name+"-handle-context");h.dismiss();await settle()
  await tap(game.pause_button.get_global_rect().get_center());check(not sim.paused,"direct pause control remains reachable beside route-first telemetry")
  await tap(game.pause_button.get_global_rect().get_center());check(sim.paused,"pause returns to unlimited planning")
  # Returning Warning Chain play lost a relay tap to B's projected handle
  # (1792474021079711943). These own positions isolate that real failure;
  # mission machinery, context picking and injected input remain actual.
  # Plant replaces the old north upload: retain the same B-to-control offset
  # at its publicly observable EAST panel, without an internal third marker.
  game._start_mission(10);await settle()
  sim=game.sim;h=game.mission_hud;fleet=h.fleet
  var station=sim.observable_sites()[1]
  sim.units[0].pos=Vector2(480,1000);sim.units[1].pos=Vector2(1000,1880);sim.units[2].pos=station.pos+Vector2(285,205)
  game.ocean.fit_chart();game._refresh();await settle()
  var relay=game.ocean.global_position+game.ocean.screen_position(station.pos)
  var relay_touch=Rect2(relay-Vector2.ONE*game.ui_touch_height*.5,Vector2.ONE*game.ui_touch_height)
  check(not fleet.buttons.any(func(b):return b.get_global_rect().intersects(relay_touch)),"projected fleet handles leave the visible warning relay touch target accessible")
  await capture(name+"-relay-clear")
  before=sim.snapshot();await tap(relay)
  check(game.advanced_orders and h.page=="plant" and h.subject.get("station","")=="panel" and sim.selected==0 and sim.snapshot()==before,"public station-center touch opens its actual plant operation without changing craft or routing")
  h.dismiss();await settle();await tap(fleet.buttons[2].get_global_rect().get_center())
  check(sim.selected==2 and game.advanced_orders and h.page=="craft","visible craft beside the panel opens its own context directly")
  await capture(name+"-relay-access")
  game.queue_free();await settle()
 print("ROUTE TELEMETRY TOUCH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
