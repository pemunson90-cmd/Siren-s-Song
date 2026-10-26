extends "res://tests/challenges_ui_tests.gd"
# Source-known HUD wording and actual Fold7 touch. Revert with status_table.enabled.
const Sim=preload("res://src/simulation/simulation.gd")
const Status=preload("res://src/presentation/status_text/status_text.gd")
const Table=preload("res://src/presentation/status_text/status_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const EXPECTED={
 0:"UNKNOWN SIGNAL SOURCE · search the marked area · the camera reaches 240m",
 6:"SOURCE SEARCH · listen elsewhere or spend local RECON",
 7:"Locate the rendezvous hull or use local Survey",
 9:"RETURN RECEIVER · listen elsewhere or spend local RECON",
 11:"CONFLUENCE SIGNALS · listen elsewhere or spend local RECON",
 22:"FREIGHT SLED · use CHOIR WORK at the berth and lane gates",
 24:"BALLAST · CHOIR WORK offers BYPASS or ISOLATE",
 27:"COUNTERWEIGHT · CHOIR WORK tracks its tow, lock and cradle",
 28:"OCCUPIED BELL · CHOIR WORK handles tow, locks and landing",
 29:"SECURITY FEED · CHOIR WORK offers LOCK C / RECONNECT or DISMANTLE"
}
const TOUCH_IDS=[6,11,24,29]
var capture_dir=""
func picture(name:String):
 if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))==OK,"native screenshot "+name)
func display_line(sim)->String:
 return "QUIETUS · REPLACE ROUTE · "+EXPECTED[int(sim.mission.id)]
func make_game(id:int,shape:Vector2i):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate()
 game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="status-text-ui"
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 var settings=Store.DEFAULTS.duplicate(true);settings.text_scale=1.5
 Settings.apply(settings,game);await settle()
 game._start_mission(id);game._layout();await settle()
 return game
func ring_geometry(game,label:String):
 var hud=game.mission_hud
 var visible=Rect2(game.global_position,game.size)
 var dp_scale=160.0/420.0*float(root.size.x)/root.get_visible_rect().size.x
 var controls=hud.ring_buttons+[hud.close_button]
 for button in hud.action_controls().values():
  if button.is_visible_in_tree() and button not in controls:controls.append(button)
 for button in controls:
  var rect=button.get_global_rect()
  check(button.is_visible_in_tree() and visible.encloses(rect),label+" visible "+str(button.get_meta("action","back"))+" fits the safe viewport")
  check(rect.size.x*dp_scale>=48.0 and rect.size.y*dp_scale>=48.0,label+" "+str(button.get_meta("action","back"))+" retains 48dp touch")
 for i in controls.size():
  for j in range(i+1,controls.size()):
   var overlap=controls[i].get_global_rect().intersection(controls[j].get_global_rect()).get_area()
   check(overlap<1.0,label+" command targets do not overlap "+str(i)+"/"+str(j)+" area="+str(overlap))
func sheet_geometry(game,label:String):
 var hud=game.mission_hud
 var visible=Rect2(game.global_position,game.size)
 var back=hud.close_button.get_global_rect()
 var dp_scale=160.0/420.0*float(root.size.x)/root.get_visible_rect().size.x
 check(hud.sheet.is_visible_in_tree() and visible.encloses(hud.sheet.get_global_rect()),label+" sheet fits the safe viewport")
 check(hud.close_button.is_visible_in_tree() and visible.encloses(back),label+" Back fits the safe viewport")
 check(back.size.x*dp_scale>=48.0 and back.size.y*dp_scale>=48.0,label+" Back retains 48dp touch")
 check(not back.intersects(hud.sheet.get_global_rect()),label+" Back stays clear of the sheet")
func source_contract():
 Table.enabled=true
 for id in EXPECTED:
  var sim=Sim.new();sim.start(id,"endurance")
  var before=sim.snapshot();var context=sim.camera_context().get("text","");var message=sim.message
  check(Status.present(sim,context)==EXPECTED[id],"op%d maps only its public source status"%id)
  check(Status.present(sim,"Other current guidance")=="Other current guidance","op%d leaves unrelated guidance intact"%id)
  Table.enabled=false
  check(Status.present(sim,context)==context,"op%d off switch restores the original context"%id)
  Table.enabled=true
  check(sim.snapshot()==before and sim.camera_context().get("text","")==context and sim.message==message and Sim.valid_snapshot(sim.snapshot()),"op%d presentation leaves simulation bytes and save validation unchanged"%id)
func table_ui():
 for id in EXPECTED:
  var game=await make_game(id,Vector2i(2184,1968))
  var before=game.sim.snapshot();var raw=game.sim.camera_context().get("text","");var message=game.sim.message
  await tap(game.mission_hud.fleet.buttons[0].get_global_rect().get_center())
  await tap(game.mission_hud.extra.inspect.get_global_rect().get_center())
  check(game.mission_hud.page=="inspect" and game.detail_label.is_visible_in_tree() and game.detail_label.text==display_line(game.sim),"op%d real touch displays its exact operation status"%id)
  Table.enabled=false;game._refresh();await settle()
  check(game.detail_label.text=="QUIETUS · REPLACE ROUTE · "+raw,"op%d off switch restores the old displayed wording"%id)
  check(game.mission_hud.extra.arrivals.text=="ARRIVALS\n0","off switch restores the old ARRIVALS label")
  Table.enabled=true;game._refresh();await settle()
  check(game.detail_label.text==display_line(game.sim) and game.sim.snapshot()==before and game.sim.message==message and game.sim.camera_context().get("text","")==raw,"op%d display refresh preserves source state"%id)
  game.queue_free();await settle()
func touch_case(shape:Vector2i,id:int):
 var game=await make_game(id,shape)
 var label="op%d %s"%[id,str(shape)]
 var before=game.sim.snapshot();var context=game.sim.camera_context().get("text","");var message=game.sim.message
 await tap(game.mission_hud.fleet.buttons[0].get_global_rect().get_center())
 check(game.advanced_orders and game.mission_hud.page=="craft",label+" actual Quietus touch opens its command ring")
 ring_geometry(game,label+" craft")
 await picture("status-%d-%d-craft"%[shape.x,id])
 await tap(game.mission_hud.extra.inspect.get_global_rect().get_center())
 check(game.mission_hud.page=="inspect" and game.detail_label.is_visible_in_tree() and game.detail_label.text==display_line(game.sim),label+" actual STATUS touch shows the operation guidance")
 sheet_geometry(game,label+" STATUS")
 await picture("status-%d-%d-inspect"%[shape.x,id])
 await android_back()
 check(game.mission_hud.page=="craft",label+" Android Back leaves STATUS for craft")
 await tap(game.mission_hud.close_button.get_global_rect().get_center())
 check(not game.advanced_orders and game.screen=="mission",label+" visible craft Back returns to water")
 await tap(game.advanced_button.get_global_rect().get_center())
 var arrivals=game.mission_hud.extra.arrivals
 check(game.mission_hud.page=="fleet" and arrivals.is_visible_in_tree() and arrivals.disabled,label+" disabled ARRIVALS remains visible in Fleet")
 check(arrivals.text==Status.arrivals_label(0),label+" zero ARRIVALS label names signals")
 check(game.mission_hud.get_meta("status_arrivals_hint","")==Status.arrivals_hint(0),label+" Fleet caption carries the actual no-signal explanation")
 ring_geometry(game,label+" fleet")
 await picture("status-%d-%d-fleet"%[shape.x,id])
 if DisplayServer.get_name()!="headless":
  check(game.mission_hud.caption_rects.size()>=3,label+" Fleet explanation is drawn in the native radial caption")
  for caption in game.mission_hud.caption_rects:
   var rect=Rect2(caption.position+game.mission_hud.global_position,caption.size)
   check(Rect2(game.global_position,game.size).encloses(rect),label+" visible Fleet caption fits the safe viewport")
   for button in game.mission_hud.ring_buttons:
    check(not rect.intersects(button.get_global_rect()),label+" Fleet caption stays clear of its touch targets")
 await tap(game.mission_hud.close_button.get_global_rect().get_center())
 check(not game.advanced_orders and game.screen=="mission",label+" visible Fleet Back returns to water")
 check(game.sim.snapshot()==before and game.sim.message==message and game.sim.camera_context().get("text","")==context,label+" touch and HUD text do not mutate the dive")
 game.queue_free();await settle()
func received_arrivals(shape:Vector2i):
 var game=await make_game(9,shape)
 var sim=game.sim
 sim.paused=false;sim.advance(Sim.STEP);sim.paused=true
 var count=sim.signal_readings().size()
 check(count>0 and Sim.valid_snapshot(sim.snapshot()),"actual op9 signal update earns received arrivals")
 var before=sim.snapshot();game._refresh();await settle()
 await tap(game.advanced_button.get_global_rect().get_center())
 var arrivals=game.mission_hud.extra.arrivals
 check(arrivals.is_visible_in_tree() and not arrivals.disabled and arrivals.text==Status.arrivals_label(count),"earned signals enable the labeled ARRIVALS control")
 ring_geometry(game,"op9 received fleet "+str(shape))
 await picture("status-%d-9-received"%shape.x)
 await tap(arrivals.get_global_rect().get_center())
 check(game.mission_hud.page=="signals" and "RECEIVED ARRIVALS" in game.mission_hud.instrument_info.text and Status.arrivals_hint(count) in game.mission_hud.instrument_info.text,"real touch opens the explained earned-signal list")
 sheet_geometry(game,"op9 received signals "+str(shape))
 await picture("status-%d-9-signals"%shape.x)
 await android_back()
 check(game.mission_hud.page=="fleet" and sim.snapshot()==before,"Back restores Fleet without changing received signals")
 game.queue_free();await settle()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 if not capture_dir.is_empty():DirAccess.make_dir_recursive_absolute(capture_dir)
 source_contract()
 await table_ui()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for id in TOUCH_IDS:await touch_case(shape,id)
  await received_arrivals(shape)
 Table.enabled=true;Settings.apply(Store.DEFAULTS)
 print("STATUS TEXT UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
