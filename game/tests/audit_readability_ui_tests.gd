extends "res://tests/challenges_ui_tests.gd"
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Recovery=preload("res://src/presentation/module_recovery_view.gd")
const Copy=preload("res://src/presentation/public_copy.gd")
const Seed=preload("res://src/presentation/runs/seed_entry.gd")
var capture_dir=""
func capture(label):
 if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 get_root().get_texture().get_image().save_png(capture_dir+"/"+label+".png")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false);game._start_mission(0)
 var o=game.sim.mission.objectives[0];var u=game.sim.units[0]
 u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.;u.angle=u.pos.angle_to_point(o.pos);u.vel=Vector2.ZERO
 game._enter_water();await settle()
 if game.mission_hud.hints.panel.visible:await press(game,"hint_dismiss")
 var feed=game.ocean.optical_feed
 var Catalog=preload("res://src/equipment/equipment_catalog.gd")
 game.sim.mission.launch_equipment=Catalog.choose(Catalog.default_loadout(),"quietus","photo_flash",["photo_flash"]).fitted
 preload("res://src/simulation/photo_capture.gd").set_frame(game.sim,0,{"mode":"tight"})
 for scale in [1.,1.5]:
  Settings.current.text_scale=scale;feed.compact=false;game._layout();game._refresh();await settle()
  var stamp="%dx%d-%d"%[shape.x,shape.y,roundi(scale*100)]
  var intent=game.mission_hud.intent
  print("STATUS REFLOW ",stamp," rect=",intent.get_rect()," minimum=",intent.get_minimum_size()," lines=",intent.get_line_count()," font=",intent.get_theme_font_size("font_size"))
  check(intent.size.y>=intent.get_minimum_size().y and Rect2(game.global_position,game.size).encloses(intent.get_global_rect()),"complete resolved status fits its visible allocation "+stamp)
  check(intent.text.ends_with(game.sim.Depth.context(game.sim)),"full final depth-context suffix remains in visible status "+stamp)
  check(game.ocean.planning_size.y<=intent.position.y,"chart planning area ends above complete status "+stamp)
  check(feed._buttons.size()==3,"all fitted optical actions present "+stamp)
  check(feed.visible,"optical dock available "+stamp)
  check(not feed.get_global_rect().intersects(game.mission_hud.intent.get_global_rect()),"dock clears reflowed status "+stamp)
  check(game.ocean.planning_size.x<=feed.position.x,"planning area ends before optical dock "+stamp)
  check(Rect2(Vector2.ZERO,game.ocean.size).encloses(feed.get_rect()),"dock stays on screen "+stamp)
  var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
  check(feed.picture_rect.size.y>=120.,"optical image keeps useful height "+stamp)
  check(not feed.picture_rect.intersects(feed.footer_rect) and not feed.quality_rect.intersects(feed.picture_rect),"image meters and scrollable details have separate regions "+stamp)
  check(feed.footer_scroll.is_visible_in_tree() and "FILM" in feed.footer_label.text and "SHUTTER" in feed.footer_label.text,"complete pricing details are retained outside image "+stamp)
  for control in feed._buttons:
   check(Rect2(Vector2.ZERO,feed.size).encloses(control.rect),"optical action has full target "+stamp)
   check(control.rect.size.x*dp>=48. and control.rect.size.y*dp>=48.,"optical actions retain 48dp "+stamp)
  for b in game.mission_hud.fleet.buttons:
   if b.is_visible_in_tree():check(not b.get_global_rect().intersects(game.mission_hud.intent.get_global_rect()),"fleet handle clears current reflowed status "+stamp)
  if game.mission_hud.has_meta("hunt_meter_button"):
   var meter=game.mission_hud.get_meta("hunt_meter_button")
   meter.position=feed.position+Vector2(8,8)
   preload("res://src/presentation/hunt_meter.gd").fit(game.mission_hud);await settle()
   check(not meter.get_global_rect().intersects(feed.get_global_rect()),"Hunt meter clears optical dock after displacement "+stamp)
  await capture(stamp+"-optics")
  await optical_scroll_case(game,feed,stamp)
  await gesture_case(game,feed,stamp)
  if game.advanced_orders:game.mission_hud.dismiss();await settle()
  game.ocean.focus_craft();game.mission_hud.guard.reset();u.route.clear();feed.compact=false;game._refresh();await settle()
  var route=u.route.duplicate(true)
  await tap(feed.global_position+feed.toggle_rect.get_center())
  check(feed.compact and u.route==route,"fold touch belongs to optics "+stamp)
  await capture(stamp+"-compact")
  await tap(feed.global_position+feed.toggle_rect.get_center())
  check(not feed.compact,"optics reopen "+stamp)
  game.mission_hud.open("craft");await settle()
  var controls=game.mission_hud.ring_buttons+[game.mission_hud.close_button]
  for i in controls.size():
   if game.mission_hud.order_dock.visible and controls[i]!=game.mission_hud.close_button:
    game.mission_hud.order_dock_scroll.ensure_control_visible(controls[i]);await settle()
    check(game.mission_hud.order_dock_scroll.get_global_rect().encloses(controls[i].get_global_rect()),"scroll reveals complete command target "+stamp)
   check(Rect2(game.global_position,game.size).encloses(controls[i].get_global_rect()),"large text command remains on screen "+stamp)
   check(controls[i].size.x*dp>=48. and controls[i].size.y*dp>=48.,"command retains 48dp "+stamp)
   for j in range(i+1,controls.size()):check(not controls[i].get_global_rect().intersects(controls[j].get_global_rect()),"command targets have separate tap ownership "+stamp)
  check(not feed.visible,"radial orders own the screen without optical overlap "+stamp)
  if game.mission_hud.order_dock.visible:
   game.mission_hud.order_dock_scroll.scroll_vertical=0;await settle()
   var hidden=game.mission_hud.ring_buttons.filter(func(b):return not game.mission_hud.order_dock_scroll.get_global_rect().has_point(b.get_global_rect().get_center()))
   check(not hidden.is_empty() and not game.mission_hud.label_at(hidden.back().get_global_rect().get_center()),"clipped dock label cannot own an outside tap "+stamp)
   check(game.ocean.planning_size.x<=game.mission_hud.order_dock.position.x,"orders reserve a visible chart area "+stamp)
   if game.mission_hud.has_meta("hunt_meter_button"):
    var meter=game.mission_hud.get_meta("hunt_meter_button")
    meter.position=game.mission_hud.order_dock.position+Vector2(8,8)
    preload("res://src/presentation/hunt_meter.gd").fit(game.mission_hud);await settle()
    check(not meter.get_global_rect().intersects(game.mission_hud.order_dock.get_global_rect()),"Hunt meter clears command dock after deferred fitting "+stamp)
  await capture(stamp+"-orders")
  await command_scroll_case(game,stamp)
  game.mission_hud.dismiss();await settle()
 await departure_touch_case(game,str(shape.x))
 game.queue_free();await settle()
 Settings.current=preload("res://src/persistence/settings_store.gd").DEFAULTS.duplicate()
func departure_touch_case(game,label):
 var fitting=preload("res://src/equipment/equipment_catalog.gd").default_loadout();fitting.drone_a="drone_deep_cells"
 game.sim.start(0,"endurance",{"fitted":fitting,"fleet_commit":false})
 var sim=game.sim
 for o in sim.mission.objectives:o.captured=true
 sim.units[0].pos=sim.mission.extraction;sim.units[0].vel=Vector2.ZERO
 sim.units[1].pos=sim.mission.extraction;sim.units[1].vel=Vector2.ZERO;sim.units[1].band=0
 sim.paused=true
 check(sim.departure_context().available and sim.departure_context().confirmation_required,"staged fitted carrier triggers real departure decision")
 Recovery.confirm_departure(game);await settle()
 var copy=""
 for l in game.panel_box.find_children("*","Label",true,false):copy+=l.text+"\n"
 check("CHANGE TO MIDDLE" in copy and "DISTANCE" in copy and "SPEED" in copy and "TERRAIN" in copy,"actual departure panel shows complete per-carrier reason")
 await capture(label+"-recovery-band")
 var before=sim.units.map(func(body):return [body.pos,body.vel,body.get("hull",0.),body.get("battery",0.)])
 var hull=sim.hull;var oxygen=sim.oxygen;var elapsed=sim.elapsed
 await press(game,"recovery_band_1")
 check(sim.selected==1 and sim.units[1].transition.get("to",-1)==1,"real touch issues Middle change to named carrier")
 check(sim.units[0].transition.is_empty() and sim.units[2].transition.is_empty(),"other craft keep their band orders")
 check(sim.outcome.is_empty() and game.screen=="mission","band command continues recovery without departure")
 check(before==sim.units.map(func(body):return [body.pos,body.vel,body.get("hull",0.),body.get("battery",0.)]) and sim.hull==hull and sim.oxygen==oxygen and sim.elapsed==elapsed,"presentation touch preserves physical fields until normal advance")
 sim.units[1].transition={};sim.mission["structures"]=sim.mission.get("structures",[]);sim.mission.structures.append(Rect2(sim.units[1].pos-Vector2.ONE*30,Vector2.ONE*60))
 Recovery.confirm_departure(game);await settle();await press(game,"recovery_band_1")
 check(sim.units[1].transition.is_empty() and "Depth unavailable" in sim.message,"blocked direct band command retains authoritative clearance refusal")
func native_swipe(a,b):
 var mouse=InputEventMouseMotion.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=a;root.push_input(mouse,true)
 await touch_event(a,true)
 var click=InputEventMouseButton.new();click.device=InputEvent.DEVICE_ID_EMULATION;click.position=a;click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;root.push_input(click,true)
 var previous=a
 for n in 12:
  var point=a.lerp(b,float(n+1)/12.)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=point;drag.relative=point-previous;root.push_input(drag,true)
  mouse=InputEventMouseMotion.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.relative=point-previous;mouse.button_mask=MOUSE_BUTTON_MASK_LEFT;root.push_input(mouse,true)
  previous=point;await process_frame
 await touch_event(b,false)
 click=InputEventMouseButton.new();click.device=InputEvent.DEVICE_ID_EMULATION;click.position=b;click.button_index=MOUSE_BUTTON_LEFT;click.pressed=false;root.push_input(click,true)
 await create_timer(.5).timeout;await settle()
func optical_scroll_case(game,feed,stamp):
 var scroll=feed.footer_scroll
 var before=scroll.scroll_vertical;var routes=game.sim.units.map(func(u):return u.route.duplicate(true))
 var rect=scroll.get_global_rect();var start=Vector2(rect.get_center().x,rect.end.y-16.)
 await native_swipe(start,Vector2(start.x,rect.position.y+16.))
 check(scroll.scroll_vertical>before if feed.footer_label.size.y>scroll.size.y else scroll.get_global_rect().encloses(feed.footer_label.get_global_rect()),"real optical swipe scrolls overflow or retains fully visible details "+stamp)
 await capture(stamp+"-optics-details")
 check(game.sim.units.map(func(u):return u.route)==routes and not game.map_gesture.active() and feed.owned_pointers.is_empty() and feed.details_touch.pointer==999,"optical swipe leaves chart routes and pointer ownership clear "+stamp)
func command_scroll_case(game,stamp):
 var hud=game.mission_hud
 if not hud.order_dock.visible:return
 var scroll=hud.order_dock_scroll;var before=scroll.scroll_vertical
 var target=hud.extra.inspect
 for n in 10:
  var rect=scroll.get_global_rect()
  if n>0 and rect.encloses(target.get_global_rect()):break
  var start=Vector2(rect.get_center().x,rect.end.y-16.)
  await native_swipe(start,Vector2(start.x,rect.position.y+16.))
 await capture(stamp+"-orders-scrolled")
 check(scroll.scroll_vertical>before and scroll.get_global_rect().encloses(target.get_global_rect()),"real swipes reveal complete Status command "+stamp)
 check(game.advanced_orders and hud.order_dock.visible and not game.map_gesture.active(),"command swipes retain dock without chart gesture "+stamp)
 var presses=[0]
 target.pressed.connect(func():presses[0]+=1)
 if scroll.get_global_rect().encloses(target.get_global_rect()):await tap(target.get_global_rect().get_center())
 check(presses[0]==1 and hud.page=="inspect","revealed Status command fires once through real touch "+stamp)
func water_point(game)->Vector2:
 for y in [0.25,0.4,0.6]:
  for x in [0.2,0.4,0.7]:
   var local=Vector2(game.ocean.planning_size.x*x,game.ocean.size.y*y)
   if not game.mission_hud.blocks(game.ocean.global_position+local) and game.ocean.pick_context(local,game.ui_touch_height).is_empty():return game.ocean.global_position+local
 return game.ocean.global_position+Vector2(30,200)
func touch_event(point,down):
 var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func drag_event(point):
 var event=InputEventScreenDrag.new();event.index=0;event.position=point;root.push_input(event,true);await process_frame
func gesture_case(game,feed,stamp):
 var water=water_point(game);var dock=feed.global_position+feed.toggle_rect.get_center()
 await touch_event(water,true);await drag_event(dock);await touch_event(dock,false);await settle()
 check(not game.map_gesture.active(),"chart drag ending over optics releases gesture "+stamp)
 water=water_point(game)
 await touch_event(water,true)
 check(game.map_gesture.active(),"next chart press starts normally "+stamp)
 await touch_event(water,false);await settle()
 if game.advanced_orders:game.mission_hud.dismiss();await settle()
 dock=feed.global_position+feed.toggle_rect.get_center()
 await touch_event(dock,true);await drag_event(water);await touch_event(water,false);await settle()
 check(feed.owned_pointers.is_empty() and not game.map_gesture.active(),"optics drag ending over chart drains only optical owner "+stamp)
 if feed.compact:await tap(feed.global_position+feed.toggle_rect.get_center())
func recovery_case():
 var sim=preload("res://src/simulation/simulation.gd").new();sim.start(0)
 var mouth={"pos":Vector2(300,800),"name":"Recovery"}
 var u=sim.units[1];u.pos=mouth.pos;u.vel=Vector2.ZERO;u.band=0;u.transition={}
 var row=Recovery.carrier_check(sim,1,mouth)
 check(row.unmet==["CHANGE TO MIDDLE"],"carrier at mouth explains only unmet band")
 check("SHALLOW" in row.text and "0.0m" in row.text and "TERRAIN CLEAR" in row.text,"carrier shows actual band distance speed clearance")
 u.band=1;u.pos=mouth.pos+Vector2(65,0);u.vel=Vector2(12,0);u.transition={"to":2,"remaining":1.}
 row=Recovery.carrier_check(sim,1,mouth)
 check("MOVE INSIDE 65m" in row.unmet and "SLOW BELOW 12m/s" in row.unmet and "FINISH DEPTH CHANGE" in row.unmet,"strict boundary and transition conditions remain visible")
 u.pos=mouth.pos;u.vel=Vector2.ZERO;u.transition={}
 check(Recovery.carrier_check(sim,1,mouth).unmet.is_empty(),"eligible middle carrier is ready")
 sim=null
func run():
 Input.set_emulate_touch_from_mouse(true)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(capture_dir)
 recovery_case()
 check("Counterweight Grave observation" in Copy.present("Observed choir_27"),"observations name recovered operation")
 check(not "AI-DESIGNED" in Copy.present("AI-DESIGNED optional CAMERA work"),"manual copy removes author label")
 check("EXPEDITION HUNT 2" in Seed.setup_context(preload("res://src/campaign/runs/run_state.gd").new_run(166421881)),"seed context distinguishes expedition Hunt modifier")
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("AUDIT READABILITY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
