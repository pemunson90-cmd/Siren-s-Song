extends SceneTree
# Source-known route-panel fixture, real touch editing and Android Back on both Fold shapes.
const Measure=preload("res://tests/nav_clearance_measure.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func touch(point,down):
 var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point):
 for down in [true,false]:
  await touch(point,down)
  var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
 await settle()
func run():
 var bands=load("res://src/presentation/route_clearance/hull_band.gd") if ResourceLoader.exists("res://src/presentation/route_clearance/hull_band.gd") else null
 check(bands!=null,"accepted courses have a hull-width clearance preview")
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=shape;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
  game.set_meta("dev_profile",true) # 127: the touch-compiled pathfinder course is the dev/test route path (Pat 2026-10-30).
  if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(3)
  var s=game.sim;s.units[0].pos=Vector2(889.6,800);s.units[0].vel=Vector2.ZERO
  s.command("route",{"point":Vector2(1420,900)})
  game._order("program");await settle()
  var p=game.route_editor.preview;var wanted=s.mission.extraction
  await tap(p.global_position+p.screen_position(wanted))
  check(s.route_goals().size()==1 and s.route_goals()[0].pos.distance_to(wanted)<.1,"real touch edits only the selected destination "+str(shape))
  check(Measure.route_clearance(s,s.units[0].pos,s.units[0].route)>=12.,"touch-compiled course retains independently measured hull clearance")
  var before=s.snapshot()
  if bands!=null:
   var segments=bands.segments(s,0)
   check(segments.size()==s.units[0].route.size() and not segments.is_empty(),"clearance band follows the actual accepted corners")
   check(segments.all(func(leg):return leg.radius==12.),"preview depicts the physical hull radius in world metres")
   check(s.snapshot()==before,"render geometry reads no hidden terrain and changes no simulation state")
   var scale=p.chart_camera.scale
   await tap(p.navigation_buttons[1].get_global_rect().get_center())
   check(p.chart_camera.scale>scale and bands.segments(s,0)==segments and s.snapshot()==before,"touch zoom scales the band without changing route clearance or orders")
  # Android Back must cancel a pending chart tap and close this panel like Escape.
  var point=p.global_position+p.size/2
  await touch(point,true)
  root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
  await touch(point,false);await settle()
  check(game.screen=="mission" and not game.route_editor.visible and s.paused,"Android Back closes the route panel into paused play")
  check(s.snapshot()==before,"Back cancels the pending touch without a late waypoint edit")
  game.queue_free();await settle()
 print("NAV CLEARANCE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
