extends SceneTree
# Source-known fixtures exercise real touch + emulated-mouse dispatch.
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for frame in 6:await process_frame
func touch(point:Vector2,down:bool,id:int=0,canceled:bool=false):
 var e=InputEventScreenTouch.new();e.index=id;e.position=point;e.pressed=down;e.canceled=canceled;root.push_input(e,true);await process_frame
func mouse_button(point:Vector2,down:bool,device:int=InputEvent.DEVICE_ID_EMULATION):
 var e=InputEventMouseButton.new();e.device=device;e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  await touch(point,down)
  await mouse_button(point,down)
 await settle()
func click(button):await tap(button.get_global_rect().get_center())
func drag(point:Vector2,delta:Vector2,id:int=0):
 var e=InputEventScreenDrag.new();e.index=id;e.position=point+delta;e.relative=delta;root.push_input(e,true);await process_frame
func action(panel,key:String):
 for b in panel.find_children("*","Button",true,false):
  if b.get_meta("action","")==key:return b
 return null
func choices(game)->Array:
 return game.mission_hud.action_controls().values().filter(func(b):return str(b.get_meta("action","")).begins_with("recovery_"))
func named(game,label:String):
 for b in choices(game):
  if label in b.text:return b
 return null
func begin(game,index:int,unit:int=0):
 game._start_mission(index)
 var s=game.sim
 # Separate own craft so opening the selected craft never selects another one.
 s.units[1].pos=s.units[0].pos+Vector2(260,0);s.units[2].pos=s.units[0].pos+Vector2(0,-260)
 s.command("select",{"unit":unit});game.ocean.focus_craft();game._refresh();await settle()
func route_menu(game):
 await tap(game.ocean.global_position+game.ocean.screen_position(game.sim.units[game.sim.selected].pos))
 if game.mission_hud.page=="fleet":await click(game.unit_buttons[game.sim.selected])
 await click(game.mission_hud.extra.route_menu)
func home(game):
 await route_menu(game);await click(game.order_buttons.home)
func capture(name:String):
 if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(capture_dir)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="recovery-route-ui"
  g.store.path="user://recovery-route-ui-%d.save"%dimensions.x
  if dimensions.x==2520:g.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(g);await settle();g.set_process(false)
  # 127 (Pat 2026-10-30): EXTRACT / recovery chooser autopilot is a dev/test shortcut.
  g.set_meta("dev_profile",true)
  var label="cover" if dimensions.x==2520 else "inner"
  # A single mouth is an ordinary destination, never a hidden propulsion order.
  for quiet in [true,false]:
   await begin(g,0);var s=g.sim;s.units[0].silent=quiet;g._refresh();await settle()
   var before=s.snapshot();await home(g)
   check(s.units[0].silent==quiet,"single-mouth EXTRACT preserves Quietus SILENT/CRUISE "+str(quiet)+" "+label)
   check(s.route_goals().size()==1 and s.route_goals()[0].pos==s.mission.extraction and s.route_goals()[0].mode=="inherit","single-mouth touch routes selected Quietus directly with inherited drive "+label)
   check(not g.advanced_orders and s.selected==0 and s.tools==before.tools and s.units[0].vel==before.units[0].vel,"single-mouth route changes no tools, selected identity or instantaneous velocity "+label)
  for drive in ["quiet","transit"]:
   for low in [true,false]:
    await begin(g,0,1);var s=g.sim;s.units[1].silent=low;s.command("drone_drive",{"mode":drive});g._refresh();await settle()
    var other=s.route_goals(0);var tools=s.tools.duplicate(true);await home(g)
    check(s.units[1].silent==low and s.units[1].drone_drive==drive,"EXTRACT preserves independent drone "+drive+" drive and "+str(low)+" profile "+label)
    check(s.selected==1 and s.route_goals(1).size()==1 and s.route_goals(1)[0].pos==s.mission.extraction and s.route_goals(0)==other and s.tools==tools,"EXTRACT routes only the selected drone without spending tools "+label)
  # Ordinary queue and planner undo retain the previously programmed intent.
  await begin(g,0,1);var s=g.sim
  s.units[1].silent=false;s.command("drone_drive",{"mode":"quiet"});s.pass_through=false
  s.command("route",{"point":s.units[1].pos+Vector2(0,-60)});s.command("queue");s.command("route",{"point":s.units[1].pos+Vector2(60,-100)})
  var prior=s.route_goals();var history=s.units[1].get("route_undo",[]).duplicate(true);g._refresh();await settle();await home(g)
  var queued=s.route_goals()
  check(s.queue_mode and queued.size()==prior.size()+1 and queued.slice(0,prior.size())==prior and queued.back().pos==s.mission.extraction,"EXTRACT obeys QUEUE and retains preceding stops and incoming modes "+label)
  check(s.units[1].get("route_undo",[]).size()==history.size()+1 and s.units[1].get("drone_drive","")=="quiet" and not s.units[1].silent,"ordinary recovery append retains undo history and quiet/open craft state "+label)
  await route_menu(g);await click(g.order_buttons.program);await click(action(g.route_editor,"undo"))
  check(s.route_goals()==prior and s.units[1].get("route_undo",[])==history,"actual planner UNDO restores pre-recovery route and history "+label)
  await click(action(g.route_editor,"close"))
  # Two Warning Chain mouths: opening cannot silently choose the primary one.
  await begin(g,10);s=g.sim;var before=s.snapshot();await home(g)
  check(g.advanced_orders and g.mission_hud.page=="recovery" and s.snapshot()==before,"multiple-mouth EXTRACT asks before ordering or changing noise "+label)
  check(named(g,"NORTH WATER RECOVERY")!=null and named(g,"WEST SERVICE RECOVERY")!=null,"both physical Warning Chain mouths have explicit names "+label)
  var west=named(g,"WEST SERVICE RECOVERY")
  if west!=null:
   check(not west.disabled and "APPROACH" in west.text,"known but not-ready mouth remains available for approach planning "+label)
   var scale=Vector2(dimensions)/root.get_visible_rect().size
   check(choices(g).all(func(b):return g.get_global_rect().encloses(b.get_global_rect()) and b.size.y*scale.y>=125.99),"named choice buttons fit full cover/inner48dp targets "+label)
   await capture(label+"-warning-recovery-choice");await click(west)
   check(s.route_goals().size()==1 and s.route_goals()[0].pos==Vector2(180,1000) and s.units[0].silent and not g.advanced_orders,"touch deliberately chooses nonprimary WEST without forcing Cruise "+label)
  # Cancel, modal drag and pinch never leak a choice or a chart order.
  for gesture in ["cancel","drag","pinch"]:
   await begin(g,10);s=g.sim;before=s.snapshot();await home(g)
   if g.mission_hud.page!="recovery":continue
   if gesture=="cancel":await click(g.mission_hud.close_button)
   else:
    var point=choices(g)[0].get_global_rect().get_center();await touch(point,true)
    if gesture=="drag":await drag(point,Vector2(95,50));await touch(point+Vector2(95,50),false)
    else:
     await touch(point+Vector2(100,0),true,1);await touch(point,false);await touch(point+Vector2(100,0),false,1)
    await settle()
   check(not g.advanced_orders and not g.map_gesture.active() and s.snapshot()==before,"recovery choice "+gesture+" preserves all orders, resources and pause "+label)
  # A native GUI press must not bypass the touch gesture's drag/cancel verdict.
  # Keep the emulated release inside the button: the previous long raw-only drag missed this protocol.
  for gesture in ["short drag","canceled touch"]:
   await begin(g,10);s=g.sim;before=s.snapshot();await home(g)
   var point=choices(g)[0].get_global_rect().get_center()
   await touch(point,true);await mouse_button(point,true)
   if gesture=="short drag":
    await drag(point,Vector2(20,0));await touch(point+Vector2(20,0),false);await mouse_button(point+Vector2(20,0),false)
   else:
    await touch(point,false,0,true);await mouse_button(point,false)
   await settle()
   check(s.snapshot()==before,"recovery choice "+gesture+" followed by inside emulated release issues no order "+label)
   g.mission_hud.dismiss();await settle()
  # Native mouse clicks remain a deliberate choice through the same tap owner.
  await begin(g,10);s=g.sim;await home(g)
  var mouse_point=named(g,"WEST SERVICE RECOVERY").get_global_rect().get_center()
  await mouse_button(mouse_point,true,0);await mouse_button(mouse_point,false,0);await settle()
  check(s.route_goals().size()==1 and s.route_goals()[0].pos==Vector2(180,1000) and s.units[0].silent and not g.advanced_orders,"native mouse deliberately chooses nonprimary WEST without forcing Cruise "+label)
  # Narrative forks retain their author-provided names, never PRIMARY/NEAREST.
  await begin(g,11);s=g.sim;before=s.snapshot();await home(g)
  check(named(g,"CONCEALED ASCENT")!=null and named(g,"OPEN WARNING PASSAGE")!=null and s.snapshot()==before,"Confluence offers both named narrative forks without committing one "+label)
  var overt=named(g,"OPEN WARNING PASSAGE")
  if overt!=null:
   await capture(label+"-confluence-recovery-choice");await click(overt)
   check(s.route_goals().size()==1 and s.route_goals()[0].pos==Vector2(3160,4200) and s.mission.chosen_route.is_empty(),"nonprimary fork touch only plots an approach; physical arrival still owns branch commitment "+label)
  await begin(g,6);s=g.sim;before=s.snapshot();await home(g)
  check(named(g,"DEEP DESCENT")!=null and named(g,"SHELF PASSAGE")!=null and named(g,"INCOMPLETE WITHDRAWAL")!=null and s.snapshot()==before,"Divergence distinguishes both onward routes and incomplete withdrawal "+label)
  var withdrawal=named(g,"INCOMPLETE WITHDRAWAL")
  if withdrawal!=null:
   await capture(label+"-divergence-recovery-choice");await click(withdrawal)
   check(s.route_goals().size()==1 and s.route_goals()[0].pos==s.mission.extraction and s.units[0].silent,"explicit incomplete withdrawal plots the existing southern basin quietly "+label)
  # Free chart gestures still work after leaving the new choice page.
  await begin(g,10);before=g.sim.snapshot();var water=g.global_position+Vector2(g.size.x*.75,g.size.y*.65)
  await touch(water,true);await drag(water,Vector2(70,20));await touch(water+Vector2(70,20),false);await settle()
  check(g.ocean.chart_camera.mode=="free" and g.sim.snapshot()==before,"water drag remains navigation with no route or tools "+label)
  var zoom=g.ocean.chart_camera.zoom
  await touch(water,true);await touch(water+Vector2(100,0),true,1);await drag(water+Vector2(100,0),Vector2(65,0),1);await touch(water,false);await touch(water+Vector2(165,0),false,1);await settle()
  check(g.ocean.chart_camera.zoom>zoom and g.sim.snapshot()==before,"water pinch retains zoom without recovery or chart orders "+label)
  g.queue_free();await settle()
 print("RECOVERY ROUTE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
