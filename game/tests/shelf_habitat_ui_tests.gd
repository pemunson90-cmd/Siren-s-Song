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
func tap(point:Vector2)->void:
 for down in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down;root.push_input(event,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func run()->void:
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
  game.queue_free();await settle()
 finish()
func finish()->void:
 print("SHELF HABITAT UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
