extends "res://tests/depth_policy_ui_tests.gd"
# Source-known complete opening1–5 journeys. Commands enter through viewport
# touch plus emulated releases; only simulation time is accelerated.
func mode(g,wanted):
 await craft(g,g.sim.selected);await click(g.order_buttons.program)
 var panel=g.route_editor
 for n in 3:
  if g.sim.route_goals()[0].mode==wanted:break
  await click(panel.mode_button)
 check(g.sim.route_goals()[0].mode==wanted,"physical planner touch selects incoming drive")
 for b in panel.find_children("*","Button",true,false):
  if b.get_meta("action","")=="close":await click(b);break
 await settle()
func go(g,id,point,drive=""):
 if not await plot(g,id,point):return
 if not drive.is_empty():await mode(g,drive)
 if g.sim.paused:await click(g.pause_button)
 for n in 12000:
  g.sim.advance(1./60)
  if n%120==0:
   g._refresh();await process_frame;await acknowledge_warning(g)
  if not g.sim.outcome.is_empty() or not g.sim.units[id].alive or (g.sim.units[id].pos.distance_to(point)<18 and g.sim.units[id].vel.length()<2):break
 if not g.sim.paused:await click(g.pause_button)
 g._refresh();await settle()
 check(g.sim.units[id].alive and (g.sim.units[id].pos.distance_to(point)<18 or g.sim.outcome=="won"),"physical route arrives in actual authored band")
const Patient=preload("res://tests/patient_play.gd")
func lull(g,id,up,target,then=Vector2.INF,at=Vector2.INF):
 for n in 40:
  if Patient.rehearsal_survives(g.sim,id,up,target,then,at):return
  await run_seconds(g,2.)
func band(g,id,wanted):await shift(g,id,g.sim.units[id].band<wanted)
func take(g,id,target):
 await craft(g,id);await click(g.order_buttons.camera);g.mission_hud.dismiss();await run_seconds(g,g.sim.mission.objectives[target].get("duration",4.)+.3)

 check(g.sim.mission.objectives[target].captured,"actual local input retains required record")
func append_goals(g,id,points):
 await plot(g,id,points[0]);await craft(g,id);await click(g.order_buttons.program)
 var panel=g.route_editor
 for point in points.slice(1):
  for button in panel.find_children("*","Button",true,false):
   if button.get_meta("action","")=="insert":await click(button);break
  await preview_point(g,point)
 check(g.sim.route_goals(id).size()==points.size(),"physical planner retains all deliberate crossing/return waypoints")
 await close_program(g)
func start_shift(g,id,down):
 await acoustics(g,id);await click(g.mission_hud.extra.depth_down if down else g.mission_hud.extra.depth_up);g.mission_hud.dismiss();await settle()
func arc_split(g):
 await plot(g,1,Vector2(420,580));await plot(g,2,Vector2(1550,940));await band(g,0,2)
 await append_goals(g,0,[Vector2(660,2100),Vector2(900,1730)])
 var returned={1:false,2:false};var returning=false;var home=false
 await click(g.pause_button)
 for n in 1300:
  g.sim.advance(.1)
  for id in [1,2]:
   var u=g.sim.units[id];var o=g.sim.mission.objectives[id-1]
   if not u.alive:continue
   if not o.captured and g.sim.captures[id].is_empty() and u.pos.distance_to(o.pos)<230:
    await craft(g,id);await click(g.order_buttons.camera);g.mission_hud.dismiss()
   if o.captured and not returned[id]:
    if id==1:await append_goals(g,id,[Vector2(680,580),Vector2(680,1700),Vector2(620,2020),g.sim.mission.extraction])
    else:await plot(g,id,g.sim.mission.extraction)
    returned[id]=true
  var q=g.sim.units[0]
  if not returning and q.pos.distance_to(Vector2(900,1730))<20 and q.vel.length()<2 and q.transition.is_empty():
   if q.band==2:await start_shift(g,0,false)
   elif g.sim.captures[0].is_empty() and g.sim.mission.objectives[0].captured and g.sim.mission.objectives[1].captured:
    await craft(g,0);await click(g.order_buttons.camera);g.mission_hud.dismiss()
  if g.sim.all_records() and not returning:
   await start_shift(g,0,true);await append_goals(g,0,[Vector2(660,2100),g.sim.mission.extraction]);returning=true
  if returning and not home and q.pos.distance_to(g.sim.mission.extraction)<25 and q.vel.length()<2 and q.transition.is_empty():await start_shift(g,0,false);home=true
  await acknowledge_warning(g)
  if g.sim.paused and g.sim.outcome.is_empty():await click(g.pause_button)
  if n%10==0:
   g._refresh();await process_frame;await acknowledge_warning(g)
  if not g.sim.outcome.is_empty():break
 if not g.sim.paused:await click(g.pause_button)
 g._refresh();await settle()
 check(returning and home,"real simultaneous fleet input completes relay/link and depth recovery")
func arc_blackwater(g):
 await band(g,0,2);await go(g,0,Vector2(300,800))
 await go(g,1,Vector2(760,400),"silent");await take(g,1,0)
 await go(g,1,Vector2(300,800),"cruise")
 await craft(g,1);check(g.mission_hud.extra.blackwater_handoff.disabled,"physical carrier menu explains unavailable cross-band transfer")
 await band(g,1,2);await craft(g,1);await click(g.mission_hud.extra.blackwater_handoff)
 check(0 in g.sim.mission.blackwater_delivery.aboard,"actual transfer touch delivers physical raw buffer")
 await go(g,0,Vector2(720,540));await lull(g,0,1,1);await band(g,0,1);await go(g,0,Vector2(1360,340));await take(g,0,1)
 for p in [Vector2(1120,720),Vector2(760,720),g.sim.mission.extraction]:await go(g,0,p)
func arc_foundry(g):
 await band(g,0,2);await go(g,0,Vector2(960,500))
 await go(g,1,Vector2(1090,580),"silent");await take(g,1,0);await plot(g,1,Vector2(1080,820));await mode(g,"cruise")
 await go(g,0,Vector2(1060,580));await go(g,0,Vector2(1060,820));await band(g,0,1);await go(g,0,Vector2(1110,820));await take(g,0,1);await go(g,0,g.sim.mission.extraction)
func arc_well(g):
 await band(g,0,0);await go(g,0,Vector2(360,590));await go(g,0,Vector2(800,390));await band(g,0,1);await take(g,0,0)
 await band(g,0,2);await go(g,0,Vector2(1170,400));await lull(g,0,1,1,Vector2(1000,650));await band(g,0,1);await take(g,0,1)
 await band(g,0,2);await go(g,0,Vector2(1000,650));await go(g,0,Vector2(560,850));await go(g,0,Vector2(620,835));await lull(g,0,1,2);await band(g,0,1);await take(g,0,2);await band(g,0,2);await go(g,0,g.sim.mission.extraction);await band(g,0,1)
 check(g.sim.mission.well_reference.is_empty() and g.sim.mission.well_observation.is_empty(),"physical quiet route retains honest unverified Well archive")
func arc_song(g):
 await band(g,0,2)
 for p in [Vector2(360,650),Vector2(950,400),Vector2(1180,40)]:await go(g,0,p)
 await band(g,0,1);await take(g,0,0);await band(g,0,0)
 for p in [Vector2(1180,400),Vector2(1180,760),Vector2(1250,870)]:await go(g,0,p)
 await band(g,0,1);await take(g,0,1);await go(g,0,Vector2(690,780));await take(g,0,2);await band(g,0,2);await go(g,0,g.sim.mission.extraction);await band(g,0,1)
func run():
 var only=-1
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
  if arg.begins_with("--operation="):only=int(arg.trim_prefix("--operation="))
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=shape;await settle()
  for id in range(1,6):
   if only>=0 and id!=only:continue
   var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://opening-policy-%d-%d.save"%[shape.x,id]
   if shape.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
   root.add_child(g);await settle();g.set_process(false);g._start_mission(id);await settle()
   match id:
    1:await arc_split(g)
    2:await arc_blackwater(g)
    3:await arc_foundry(g)
    4:await arc_well(g)
    5:await arc_song(g)
   check(g.sim.outcome=="won","actual touch completes opening "+str(id)+" on "+str(shape))
   check(g.sim.tools.emp==2 and g.sim.tools.decoy==3 and g.sim.tools.recon==2 and g.sim.tools.knock==2,"actual input policy requires no finite tool")
   check(g.sim.valid_snapshot(g.sim.snapshot()),"input-earned opening result remains current-save valid")
   print("OPENING TOUCH op=",id," shape=",shape," outcome=",g.sim.outcome," time=",g.sim.elapsed," hull=",g.sim.hull," oxygen=",g.sim.oxygen," alive=",g.sim.units.map(func(u):return u.alive))
   g.mission_hud.dismiss();g._refresh();await capture("%d-op%d-earned-return"%[shape.x,id]);g.queue_free();await settle()
 print("OPENING POLICY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
