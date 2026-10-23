extends "res://tests/depth_sonar_ui_tests.gd"
# Source-known, accelerated opening journeys. Every consequential order enters
# through real viewport input; simulation travel is stepped faster than wall time.
func craft(g,id):
 await acknowledge_warning(g)
 g.mission_hud.dismiss();await settle();await click(g.advanced_button);await click(g.unit_buttons[id])
 check(g.sim.selected==id and g.mission_hud.page=="craft","physical fleet input chooses craft")
func acoustics(g,id):
 await craft(g,id);await click(g.mission_hud.extra.depth_menu)
# Opening warnings now pause for any craft. A player acknowledges and resumes
# through real controls; accelerated travel must do the same before counting time.
func acknowledge_warning(g):
 for attempt in 2:
  var hints=g.mission_hud.hints
  if not g.sim.outcome.is_empty() or not g.sim.paused or not hints.panel.visible or hints.current not in ["warning","sweep"]:return
  await click(hints.dismiss_button);await settle()
  check(not hints.panel.visible and g.sim.paused,"real touch acknowledges warning without resuming")
  await click(g.pause_button);await settle()
func run_seconds(g,seconds):
 if g.sim.paused:await click(g.pause_button)
 for n in roundi(seconds*60):
  g.sim.advance(1./60)
  if n%120==0:
   g._refresh();await process_frame;await acknowledge_warning(g)
 if not g.sim.paused:await click(g.pause_button)
 g._refresh();await settle()
func shift(g,id,down):
 await acoustics(g,id);await click(g.mission_hud.extra.depth_down if down else g.mission_hud.extra.depth_up)
 check(not g.sim.units[id].transition.is_empty(),"real depth input starts deliberate transit")
 g.mission_hud.dismiss();await run_seconds(g,4.1)
func fit(g):
 g.mission_hud.dismiss();await settle();await click(g.advanced_button);await click(g.mission_hud.extra.view_menu);await click(g.zoom_buttons[2]);g.mission_hud.dismiss();await settle()
func close_program(g):
 for b in g.route_editor.find_children("*","Button",true,false):
  if b.get_meta("action","")=="close":await click(b);break
 await settle()
func preview_point(g,point):
 var preview=g.route_editor.preview
 for attempt in 8:
  var p=preview.global_position+preview.screen_position(point)
  if preview.get_global_rect().grow(-3).has_point(p) and not preview.navigation_buttons.any(func(button):return button.get_global_rect().has_point(p)):
   await touch(p,true);await mouse(p,true);await touch(p,false);await mouse(p,false);await settle();return
  if attempt==0:
   await click(preview.navigation_buttons[1]);await click(preview.navigation_buttons[1])
  else:
   var start=preview.get_global_rect().get_center()
   var focus=preview.global_position+preview.size*Vector2(.4,.6)
   var delta=(focus-p).clamp(-preview.size*.3,preview.size*.3)
   await touch(start,true)
   var drag=InputEventScreenDrag.new();drag.index=0;drag.position=start+delta;drag.relative=delta;root.push_input(drag,true);await process_frame
   await touch(start+delta,false);await settle()
 check(false,"physical planner view can expose intended water away from navigation controls")
func plot(g,id,point):
 # FIT can overlap intended water with a craft's touch handle. The existing
 # paused planner exposes that same public route geometry through ordinary input.
 await craft(g,id);await click(g.order_buttons.program)
 await preview_point(g,point)
 var goals=g.sim.route_goals(id)
 check(not goals.is_empty() and goals[0].pos.distance_to(point)<2,"physical planner input retains public operator destination")
 await close_program(g)
 return not goals.is_empty() and goals[0].pos.distance_to(point)<2
func travel(g,id,point):
 if not await plot(g,id,point):return
 if g.sim.paused:await click(g.pause_button)
 for n in 9000:
  g.sim.advance(1./60)
  if n%120==0:
   g._refresh();await process_frame;await acknowledge_warning(g)
  if not g.sim.outcome.is_empty() or (g.sim.units[id].pos.distance_to(point)<15 and g.sim.units[id].vel.length()<2):break
 if not g.sim.paused:await click(g.pause_button)
 g._refresh();await settle()
 check(g.sim.units[id].pos.distance_to(point)<16 or g.sim.outcome=="won","real route arrives through actual band geometry")
func emp(g):
 await craft(g,0);await click(g.mission_hud.extra.tools_menu);await click(g.order_buttons.emp)
func journey(g,active,shape):
 if active:
  await shift(g,1,true);await plot(g,1,Vector2(1000,500));await craft(g,0);g.mission_hud.dismiss()
 else:await shift(g,0,true)
 for point in ([Vector2(360,650),Vector2(560,480),Vector2(760,620),Vector2(1190,490)] if not active else [Vector2(760,620),Vector2(940,570),Vector2(1190,490)]):
  await travel(g,0,point)
  if not active and point.x==560:await capture(str(shape.x)+"-quiet-under-shelf")
  if active and point.x==940:
   await emp(g);await acoustics(g,1)
   await click(g.mission_hud.extra.sonar_power);await click(g.mission_hud.extra.sonar_emit);g.mission_hud.dismiss();await run_seconds(g,3)
   await acoustics(g,1);await click(g.mission_hud.extra.sonar_history);await capture(str(shape.x)+"-received-scout-history");g.mission_hud.dismiss()
 if not active:await shift(g,0,false)
 await craft(g,0);await click(g.order_buttons.camera);await run_seconds(g,4.2)
 check(g.sim.all_records(),"physical input earns the spire record")
 await emp(g)
 if not active:await shift(g,0,true)
 for point in [Vector2(760,650),Vector2(360,750),Vector2(140,800)]:await travel(g,0,point)
 if not active:await shift(g,0,false)
 await run_seconds(g,.2)
 check(g.sim.outcome=="won","actual input completes opening policy")
 print("TOUCH POLICY active=",active," shape=",shape," outcome=",g.sim.outcome," time=",g.sim.elapsed," hull=",g.sim.hull," emp=",g.sim.tools.emp)
 g.mission_hud.dismiss();await capture(str(shape.x)+("-active-recovery" if active else "-quiet-recovery"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=shape;await settle()
  for active in [false,true]:
   var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://depth-policy-touch-%d-%s.save"%[shape.x,str(active)]
   if shape.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
   root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle()
   await journey(g,active,shape)
   g.queue_free();await settle()
 print("DEPTH POLICY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
