extends SceneTree
var checks=0
var failures=0
var folder=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():for n in 6:await process_frame
func touch(p:Vector2,down:bool,id:int=0,canceled:bool=false):
 var e=InputEventScreenTouch.new();e.position=p;e.index=id;e.pressed=down;e.canceled=canceled;root.push_input(e,true);await process_frame
func mouse(p:Vector2,down:bool,device:int=InputEvent.DEVICE_ID_EMULATION):
 var e=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;e.device=device;root.push_input(e,true);await process_frame
func tap(p:Vector2):
 await touch(p,true);await mouse(p,true);await touch(p,false);await mouse(p,false);await settle()
func prepare(g):
 g._start_mission(9);var s=g.sim;s.sirens=[];s.units[1].pos=Vector2(1520,680);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1});s.paused=false
 for n in 60:s.advance(1./60.)
 s.paused=true;s.command("route",{"point":Vector2(1540,700)});s.command("queue")
 g.ocean.focus_craft();g._refresh();await settle()
 var subject=g.ocean.objective_context(g.ocean.screen_position(Vector2(1520,620)),g.ui_touch_height)
 g.mission_hud.open("object",subject);await settle()
 return g.mission_hud.extra.wake_playback
func capture(name:String):
 if not folder.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 check(ResourceLoader.exists("res://src/presentation/wake_crossing_view.gd"),"Wake has an earned local playback instrument")
 if failures:finish();return
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=shape;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="wake-crossing-ui"
  if shape.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false);g._start_mission(9);await settle()
  check(not g.sim.wake_context().known,"first launch never reveals the unmeasured empty branch or its controls")
  var b=await prepare(g);var h=g.mission_hud
  h.dismiss();await settle();var before_site=g.sim.snapshot()
  await tap(g.ocean.global_position+g.ocean.screen_position(Vector2(1520,620)))
  check(g.advanced_orders and h.subject.get("subkind","")=="wake_repeater" and g.sim.snapshot()==before_site,"ordinary touch on measured hardware opens its local orders without issuing a water route")
  check(h.subject.get("subkind","")=="wake_repeater" and b.visible and not b.disabled and not g.order_buttons.camera.visible,"actual measured repeater owns a distinct local playback rather than a capture hold")
  check(b.text.contains("ONCE") and b.text.contains("15s"),"one-use duration is visible before committing")
  await capture(str(shape.x)+"-local-orders")
  h.open("inspect");await settle()
  check(h.instrument_info.text.begins_with("OLD DEPARTURE LOOP") and h.instrument_info.text.contains("1100m") and h.instrument_info.text.contains("empty"),"first status text contains the real cost and keeper account without generic record-prefix flooding")
  check(not g.title_label.visible and not g.detail_label.visible,"local account owns its first screen instead of generic mission and raw source-ID detail")
  h.sheet_scroll.scroll_vertical=100;h.open("object",h.subject);h.open("inspect");await settle()
  check(h.sheet_scroll.scroll_vertical==0,"reopening local account starts with its decision and keeper voice")
  await capture(str(shape.x)+"-keeper-account")
  for kind in ["cancel","short drag","drag off","pinch"]:
   b=await prepare(g);var before=g.sim.snapshot();var queue=g.sim.queue_mode;var p=b.get_global_rect().get_center()
   await touch(p,true);await mouse(p,true)
   if kind=="cancel":await touch(p,false,0,true);await mouse(p,false)
   elif kind=="pinch":
    await touch(p+Vector2(100,0),true,1)
    var pinch=InputEventScreenDrag.new();pinch.index=1;pinch.position=p+Vector2(135,0);pinch.relative=Vector2(35,0);root.push_input(pinch,true);await process_frame
    await touch(p,false);await mouse(p,false);await touch(p+Vector2(135,0),false,1)
   else:
    var delta=Vector2(220,0) if kind=="drag off" else Vector2(20,0)
    var e=InputEventScreenDrag.new();e.index=0;e.position=p+delta;e.relative=delta;root.push_input(e,true);await process_frame
    await touch(p+delta,false);await mouse(p+delta,false)
   await settle();check(g.sim.snapshot()==before and g.sim.queue_mode==queue,kind+" with emulated release preserves one-use playback noise pause and queued route")
  for protocol in ["touch","mouse"]:
   b=await prepare(g);var before=g.sim.route_goals();var p=b.get_global_rect().get_center();var scale=Vector2(root.size)/root.get_visible_rect().size
   check(g.get_global_rect().encloses(b.get_global_rect()) and b.size.y*scale.y>=125.99,"local consequential control retains a full safe48dp target")
   if protocol=="touch":await tap(p)
   else:await mouse(p,true,0);await mouse(p,false,0);await settle()
   check(g.sim.wake_context().used and g.sim.noises.filter(func(n):return n.label=="OLD DEPARTURE LOOP").size()==1,"deliberate "+protocol+" spends exactly one actual local playback")
   check(g.sim.paused and g.sim.queue_mode and g.sim.route_goals()==before,"playback preserves pause and existing independent route intent")
  h.open("object",{"kind":"objective","subkind":"wake_repeater","name":"OLD DEPARTURE LOOP","pos":Vector2(1520,620)});await settle()
  check(h.extra.wake_playback.disabled,"spent hardware visibly refuses a second playback")
  await capture(str(shape.x)+"-spent-playback")
  g.queue_free();await settle()
 finish()
func finish():print("WAKE CROSSING UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
