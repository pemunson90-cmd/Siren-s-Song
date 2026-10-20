extends SceneTree
var checks=0
var failures=0
var folder=""
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize()->void:call_deferred("run")
func settle()->void:
 for n in 6:await process_frame
func touch(point:Vector2,down:bool,canceled:bool=false,id:int=0)->void:
 var event=InputEventScreenTouch.new();event.index=id;event.position=point;event.pressed=down;event.canceled=canceled;root.push_input(event,true);await process_frame
func mouse(point:Vector2,down:bool,device:int=InputEvent.DEVICE_ID_EMULATION)->void:
 var event=InputEventMouseButton.new();event.device=device;event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
func drag(point:Vector2,delta:Vector2)->void:
 var event=InputEventScreenDrag.new();event.index=0;event.position=point+delta;event.relative=delta;root.push_input(event,true);await process_frame
func tap(point:Vector2)->void:
 for down in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down;root.push_input(event,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func prepare_pointer(game,site:String):
 # Own-position fixtures make both finite actions ready. Keep a real queued
 # route so an accidental action or water order cannot hide behind an empty plan.
 game._start_mission(8);var sim=game.sim;sim.sirens=[]
 var target=Vector2(1120,1480) if site=="alarm" else Vector2(1700,1200)
 sim.units[0].pos=target+Vector2(0,40);sim.units[0].vel=Vector2.ZERO;sim.paused=false
 for n in 15:sim.advance(1./60.)
 sim.paused=true;sim.command("route",{"point":sim.units[0].pos+Vector2(0,30)});sim.command("queue")
 game.ocean.focus_craft();game._refresh();game.mission_hud.open("habitat",{"kind":"habitat","site":site,"name":site.to_upper(),"pos":target});await settle()
 return game.mission_hud.extra.shelf_alarm if site=="alarm" else game.mission_hud.extra.shelf_warn
func pointer_safety(game)->void:
 for site in ["east","alarm"]:
  for gesture in ["cancel","short drag","drag off","pinch"]:
   var button=await prepare_pointer(game,site);check(not button.disabled,site+" pointer rejection fixture has a ready real action")
   var sim=game.sim;var before=sim.snapshot();var queued=sim.queue_mode;var point=button.get_global_rect().get_center()
   await touch(point,true);await mouse(point,true)
   if gesture=="cancel":await touch(point,false,true);await mouse(point,false)
   elif gesture in ["short drag","drag off"]:
    var delta=Vector2(220,0) if gesture=="drag off" else Vector2(20,0)
    await drag(point,delta);await touch(point+delta,false);await mouse(point+delta,false)
   else:
    await touch(point+Vector2(100,0),true,false,1);await touch(point,false);await mouse(point,false);await touch(point+Vector2(100,0),false,false,1)
   await settle()
   check(sim.snapshot()==before and sim.queue_mode==queued,site+" "+gesture+" plus emulated release preserves finite action noise pause and queued route")
  for protocol in ["touch","mouse"]:
   var button=await prepare_pointer(game,site);var sim=game.sim;var route=sim.route_goals();var quiet=sim.units[0].silent
   var scale=Vector2(root.size)/root.get_visible_rect().size
   check(game.get_global_rect().encloses(button.get_global_rect()) and button.size.y*scale.y>=125.99,site+" action keeps its full safe48dp target")
   if protocol=="touch":await tap(button.get_global_rect().get_center())
   else:
    await mouse(button.get_global_rect().get_center(),true,0);await mouse(button.get_global_rect().get_center(),false,0);await settle()
   var accepted=sim.mission.shelf_habitat.alarm_used if site=="alarm" else sim.mission.shelf_habitat.warned_at.has("east")
   var label="COMMON SHELTER ALARM" if site=="alarm" else "LOCAL SHELTER WARNING"
   check(accepted and sim.noises.filter(func(noise):return noise.label==label).size()==1,site+" deliberate "+protocol+" sends exactly one real warning")
   check(sim.paused and sim.queue_mode and sim.route_goals()==route and sim.units[0].silent==quiet,site+" deliberate "+protocol+" preserves pause profile and queued route intent")
func run()->void:
 print("SHELF UI DISPLAY ",DisplayServer.get_name()," RENDERER ",RenderingServer.get_current_rendering_method())
 check(ResourceLoader.exists("res://src/presentation/shelf_habitat_view.gd"),"inhabited Shelf has a dedicated earned world and action projection")
 if failures:finish();return
 var Habitat=load("res://src/simulation/shelf_habitat.gd")
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 for size in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=size;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="shelf-habitat-ui"
  if size.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(8);await settle()
  var sim=game.sim;sim.sirens=[];var view=load("res://src/presentation/shelf_habitat_view.gd")
  check(view.context(sim).galleries.is_empty(),"unseen galleries do not reveal occupied activity or resident response")
  sim.units[0].pos=Vector2(1700,1255);sim.units[0].vel=Vector2.ZERO;sim.paused=false
  for n in 15:sim.advance(1./60.)
  sim.paused=true;game.ocean.focus_craft();game._refresh();await settle()
  var site=view.context(sim).galleries.filter(func(row):return row.id=="east")[0]
  if not folder.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(str(size.x)+"-occupied-before.png"))
  var before=sim.snapshot()
  var marker=view.markers(game.ocean,sim,game.ui_touch_height).filter(func(row):return row.subject.site=="east")[0]
  await tap(game.ocean.global_position+marker.rect.get_center())
  var hud=game.mission_hud
  check(hud.page=="habitat" and hud.subject.get("site","")=="east" and sim.snapshot()==before,"actual occupied-mouth tap opens its local action without changing course or time")
  check(hud.extra.shelf_warn.visible and not hud.extra.shelf_warn.disabled and not game.order_buttons.camera.visible,"local method is an explicit warning action rather than another camera hold")
  hud.open("inspect");await settle()
  check("100m" in hud.instrument_info.text and "berths" in hud.instrument_info.text.to_lower(),"object status explains real local prerequisite and occupied place")
  if not folder.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(str(size.x)+"-local-status.png"))
  hud.open("habitat",hud.subject);await settle();await tap(hud.extra.shelf_warn.get_global_rect().get_center())
  check(sim.mission.shelf_habitat.warned_at.has("east") and sim.paused and not game.advanced_orders,"actual warning touch sends once while preserving tactical pause")
  sim.paused=false
  for n in 180:sim.advance(1./60.)
  sim.paused=true;game._refresh();await settle()
  check(view.context(sim).galleries[0].closing>=.99 and "east" in sim.mission.shelf_habitat.receipts,"delivered warning causes measured shutter closure and an actually received shelter reply")
  if not folder.is_empty() and DisplayServer.get_name()!="headless":
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(str(size.x)+"-occupied-response.png"))
  await pointer_safety(game)
  game.queue_free();await settle()
 finish()
func finish()->void:
 print("SHELF HABITAT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
