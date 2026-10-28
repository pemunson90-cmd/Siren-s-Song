extends "res://tests/challenges_ui_tests.gd"
# Source-known desktop Compatibility scene with Fold density/inset fixtures.
# UI buttons use the existing touch + emulated-mouse harness; map gestures are touch only.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const Table=preload("res://src/presentation/quality/quality_table.gd")
func touch(index:int,point:Vector2,down:bool):
 var e=InputEventScreenTouch.new();e.index=index;e.position=point;e.pressed=down;root.push_input(e,true)
func shape_quality(shape):
 root.size=shape;await settle()
 var path="user://quality-ui-%d.json"%shape.x
 var store=Store.new();store.path=path;check(store.save_settings({}),"legacy-style settings fixture saved")
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";game.settings_path=path
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game._show_campaign();await settle()
 var front=Front.new();front.settings_store.path=path;game.add_child(front);front.setup(game);await settle()
 await press(front,"frontend_settings");await press(front,"settings_page_display")
 var low=button(front,"quality_low_effects")
 var dp=float(root.size.x)/root.get_visible_rect().size.x*160.0/420.0
 check(low!=null and low.size.x*dp>=48 and low.size.y*dp>=48,"quality choice is 48dp at recorded Fold density")
 await press(front,"quality_low_effects");await create_timer(.4).timeout
 check(Settings.current.quality==Table.LOW_EFFECTS and store.load_settings().quality==Table.LOW_EFFECTS,"touch quality choice applies and persists")
 check(game.ocean.quality_tier==Table.LOW_EFFECTS,"live ocean consumes LOW EFFECTS")
 await android_back();front._dismiss();await settle()
 game._start_mission(0);game._enter_water();game.sim.paused=true;game._refresh();await settle()
 if shape.x==2520 and DisplayServer.get_name()!="headless":
  root.grab_focus();await settle()
  Settings.apply({"quality":Table.STANDARD},game)
  Engine.max_fps=20 # Test stimulus only: actual wall frames above the 30fps budget.
  game.sim.paused=false
  await create_timer(14.0).timeout
  print("QUALITY UI live sample average=",game.quality_runtime.governor.average_frame_seconds()," pending=",not game.quality_runtime.governor.suggestion().is_empty()," focused=",DisplayServer.window_is_focused()," elapsed=",game.sim.elapsed)
  check(not game.quality_runtime.governor.suggestion().is_empty(),"actual rendered slow frames create suggestion")
  check(Settings.current.quality==Table.STANDARD and Engine.max_fps==20,"live governor changes neither quality nor FPS cap")
  await press(game,"quality_dismiss")
  check(game.quality_runtime.governor.suggestion().is_empty(),"actual live suggestion dismisses through touch")
  game.sim.paused=true;Settings.apply({"quality":Table.LOW_EFFECTS},game)
 var before=game.ocean.quality_draw_count;var refresh_before=game.quality_runtime.refresh_count
 var tick=Time.get_ticks_usec();await create_timer(3.0).timeout
 var seconds=float(Time.get_ticks_usec()-tick)/1000000.0
 var draws=game.ocean.quality_draw_count-before;var refreshes=game.quality_runtime.refresh_count-refresh_before
 print("QUALITY UI actual paused shape=",shape," seconds=",seconds," draws=",draws," hz=",draws/seconds," main_refreshes=",refreshes," backend=",DisplayServer.get_name())
 if DisplayServer.get_name()!="headless":
  check(draws>0 and draws/seconds<15.0,"actual paused ocean redraws below 15Hz")
  check(refreshes>0 and refreshes/seconds<15.0,"actual paused Main refreshes below 15Hz")
 else:check(draws>0,"headless preserves redraw requests")
 # Drag in clear chart water: real injected touch, no direct pan callback.
 var point=game.ocean.global_position+Vector2(game.ocean.size.x*.45,game.ocean.size.y*.55)
 var offset=game.ocean.world_offset;touch(0,point,true);await process_frame
 before=game.ocean.quality_draw_count
 var drag=InputEventScreenDrag.new();drag.index=0;drag.position=point+Vector2(90,30);drag.relative=Vector2(90,30);root.push_input(drag,true)
 await process_frame;await process_frame
 check(game.map_gesture.active() and game.ocean.world_offset!=offset,"paused real-touch drag pans immediately")
 check(game.ocean.quality_draw_count>before,"paused gesture redraws on the next frame")
 touch(0,drag.position,false);await settle()
 var scale=game.ocean.world_scale
 touch(0,point,true);touch(1,point+Vector2(120,0),true);await process_frame
 drag=InputEventScreenDrag.new();drag.index=1;drag.position=point+Vector2(210,0);drag.relative=Vector2(90,0);root.push_input(drag,true)
 await process_frame;await process_frame
 check(game.ocean.world_scale>scale,"paused touch pinch zoom remains live")
 touch(0,point,false);touch(1,drag.position,false);await settle()
 # Explicit resume retains full per-frame ocean drawing immediately.
 before=game.ocean.quality_draw_count;game.sim.paused=false
 await process_frame;await process_frame
 check(game.ocean.quality_draw_count>before,"resume redraws on next rendered frame")
 game.sim.paused=true
 # Supply synthetic governor samples to test consent UI, separately from actual frame timing.
 var governor=load("res://src/presentation/quality/quality_governor.gd").new(false)
 game.quality_runtime.governor=governor
 Settings.apply({"quality":Table.STANDARD},game)
 for n in 300:governor.observe_frame(.05)
 await settle()
 check(button(game,"quality_dismiss")!=null,"synthetically triggered suggestion is dismissible")
 var dismiss=button(game,"quality_dismiss")
 check(root.get_visible_rect().has_point(dismiss.get_global_rect().get_center()),"suggestion actions stay inside the viewport")
 await press(game,"quality_dismiss");check(governor.suggestion().is_empty(),"dismiss keeps current tier")
 check(Settings.current.quality==Table.STANDARD,"dismiss never silently downgrades")
 # Fresh session can explicitly accept the same suggestion.
 game.quality_runtime.notice.queue_free();await settle()
 game.quality_runtime.governor=load("res://src/presentation/quality/quality_governor.gd").new(false)
 for n in 300:game.quality_runtime.governor.observe_frame(.05)
 await settle();await press(game,"quality_accept")
 check(Settings.current.quality==Table.LOW_EFFECTS and store.load_settings().quality==Table.LOW_EFFECTS,"explicit suggestion acceptance persists LOW EFFECTS")
 game.queue_free();await settle();Settings.apply(Store.DEFAULTS);DirAccess.remove_absolute(path)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_quality(shape)
 print("QUALITY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
