extends SceneTree
# Source-known unlocked-equipment fixture. Uses the engine's touchscreen GUI
# mouse-emulation path for genuine ScrollContainer drags and fitting taps.
var game
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func mouse(point:Vector2,down:bool):
 var event=InputEventMouseButton.new();event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;event.device=InputEvent.DEVICE_ID_EMULATION;root.push_input(event,true)
func tap(point:Vector2):
 var move=InputEventMouseMotion.new();move.position=point;move.global_position=point;move.device=InputEvent.DEVICE_ID_EMULATION;root.push_input(move,true)
 mouse(point,true);await process_frame;mouse(point,false);await settle()
func drag(start:Vector2,finish:Vector2):
 var move=InputEventMouseMotion.new();move.position=start;move.global_position=start;move.device=InputEvent.DEVICE_ID_EMULATION;root.push_input(move,true)
 mouse(start,true);await process_frame
 var previous=start
 for n in 24:
  var point=start.lerp(finish,(n+1)/24.0)
  move=InputEventMouseMotion.new();move.position=point;move.global_position=point;move.relative=point-previous;move.button_mask=MOUSE_BUTTON_MASK_LEFT;move.device=InputEvent.DEVICE_ID_EMULATION;root.push_input(move,true);previous=point;await process_frame
 mouse(finish,false)
 # Let the actual drag coast stop before a separate tap.
 var deadline=Time.get_ticks_msec()+2000;var offset=game.scroll.scroll_vertical;var still_since=Time.get_ticks_msec()
 while Time.get_ticks_msec()<deadline:
  await process_frame
  if game.scroll.scroll_vertical!=offset:offset=game.scroll.scroll_vertical;still_since=Time.get_ticks_msec()
  elif Time.get_ticks_msec()-still_since>250:break
 await settle()
func fitting(slot:String):
 for control in game.panel_box.get_children():
  if control is Button and control.get_meta("action","")=="fit_"+slot and "Drone deep cells" in control.text:return control
 return null
func action(id:String):
 for control in game.panel_box.get_children()+game.menu_footer.get_children():
  if control is Button and control.get_meta("action","")==id:return control
 return null
func expose_fittings():
 for n in 20:
  if game.scroll.get_global_rect().encloses(fitting("drone_b").get_global_rect()):break
  var area=game.scroll.get_global_rect();var start=Vector2(area.get_center().x,area.end.y-20)
  await drag(start,Vector2(start.x,area.position.y+30))
func change_loadout(label:String):
 game._show_campaign();await settle()
 for n in 8:
  if game.scroll.get_global_rect().encloses(action("loadout").get_global_rect()):break
  var area=game.scroll.get_global_rect();var start=Vector2(area.get_center().x,area.end.y-20)
  await drag(start,Vector2(start.x,area.position.y+30))
 var before=game.scroll.scroll_vertical;var active=game.sim.snapshot();var previous=game.upgrade
 check(before>0 and game.scroll.get_global_rect().encloses(action("loadout").get_global_rect()),label+" loadout control reached by ordinary operations scrolling")
 await capture(label+"-loadout-before")
 await tap(action("loadout").get_global_rect().get_center())
 check(game.upgrade!=previous,label+" loadout tap changes next-dive supplies")
 check(game.scroll.scroll_vertical>0 and absf(game.scroll.scroll_vertical-before)<=game.ui_touch_height,label+" cycling loadout retains operations reading location")
 check(game.scroll.get_global_rect().encloses(action("loadout").get_global_rect()),label+" loadout remains fully visible for another comparison")
 check(game.screen=="menu" and game.sim.snapshot()==active,label+" loadout change preserves the active dive")
 await capture(label+"-loadout-after")
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func change_fit(slot:String,item:String,label:String):
 await expose_fittings()
 var control=fitting(slot);var before=game.scroll.scroll_vertical;var before_rect=control.get_global_rect();var active=game.sim.snapshot()
 check(before>game.scroll.size.y and game.scroll.get_global_rect().encloses(before_rect),"long briefing is actually scrolled to a fully visible fitting before "+label)
 await capture(label+"-before")
 await tap(before_rect.get_center())
 control=fitting(slot)
 print("FIT_SCROLL ",label," before=",before," after=",game.scroll.scroll_vertical," row_before=",before_rect," row_after=",control.get_global_rect())
 check(game.fitted_equipment[slot]==item and (("→ BARE" in control.text)==not item.is_empty()),"separate fitting tap updates the selected next-launch equipment for "+label)
 check(game.scroll.scroll_vertical>0 and absf(game.scroll.scroll_vertical-before)<=game.ui_touch_height,"fitting retains the current briefing reading location for "+label)
 check(game.scroll.get_global_rect().encloses(control.get_global_rect()),"changed fitting remains fully readable and immediately tappable for "+label)
 check(game.screen=="briefing" and game.sim.snapshot()==active,"fitting preserves the paused active dive and keeps the briefing for "+label)
 await capture(label+"-after")
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 var previous_emulation=Input.is_emulating_touch_from_mouse();Input.set_emulate_touch_from_mouse(true)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="briefing-scroll-fitting-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false)
  game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition={"version":1,"route":"deep","routes":["deep","shelf"],"facts":{"deep":"known","shelf":"known"},"completed":[6,7,8]};game._start_mission(6);game._briefing(6);await settle()
  var label="cover" if dimensions.x==2520 else "inner"
  check(game.scroll.scroll_vertical==0 and DisplayServer.is_touchscreen_available(),"fresh "+label+" briefing begins at the top on the touchscreen GUI path")
  # 029 folds preparation initially. Enter it through its real control before
  # the existing drag/selection/persistence checks; all those checks stay intact.
  var fold=action("fit_fold")
  if fold!=null and "SHOW" in fold.text:
   await tap(fold.get_global_rect().get_center())
   check("HIDE" in action("fit_fold").text,"real touch expands preparation before scrolling "+label)
  await change_fit("drone_b","drone_deep_cells",label+"-fit")
  check(fitting("drone_a").disabled,"rebuilt fitting keeps the single kit reserved on drone B")
  await change_fit("drone_b","",label+"-clear")
  check(not fitting("drone_a").disabled,"clearing a fitting makes the other carrier available without stale stock")
  await change_fit("drone_a","drone_deep_cells",label+"-other-carrier")
  await tap(action("begin").get_global_rect().get_center())
  check(game.screen=="mission" and game.sim.equipment_feedback().fitted.drone_a=="drone_deep_cells" and game.sim.equipment_feedback().fitted.drone_b=="","ENTER WATER freezes the chosen fitting after scrolling and several changes")
  game._briefing(0);await settle();check(game.scroll.scroll_vertical==0,"opening a different fresh briefing still resets to its beginning")
  await change_loadout(label)
  game.queue_free();await settle()
 Input.set_emulate_touch_from_mouse(previous_emulation)
 print("BRIEFING SCROLL FITTING UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
