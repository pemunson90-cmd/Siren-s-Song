extends "res://tests/challenges_ui_tests.gd"
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game._start_mission(0)
 var o=game.sim.mission.objectives[0];var u=game.sim.units[0]
 u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.;u.angle=u.pos.angle_to_point(o.pos);u.vel=Vector2.ZERO
 game._enter_water();game._refresh();await settle()
 if game.mission_hud.hints.panel.visible:await press(game,"hint_dismiss")
 var feed=game.ocean.optical_feed
 var scale=float(root.size.x)/root.get_visible_rect().size.x
 var dp=scale*160./420.
 var route=u.route.duplicate(true)
 check(feed.visible,"a real subject opens the live viewfinder")
 var controls=feed.get("_buttons")
 check(not controls.is_empty(),"the viewfinder exposes touch controls")
 for control in controls:
  check(control.rect.size.x*dp>=48 and control.rect.size.y*dp>=48,"camera control is at least48dp")
 for id in ["fleet_q","fleet_a","fleet_b","pause"]:
  var b=game.mission_hud.action_controls().get(id)
  if b!=null:
   var measured=b.get_global_rect().size*dp
   print("FIX2 TARGET ",shape," ",id," dp=",measured)
   check(measured.x>=48 and measured.y>=48,"fleet and pause touch target meets48dp")
 var previous=Photo.settings(game.sim,0).mode
 if not controls.is_empty():
  await tap(feed.global_position+controls[0].rect.get_center())
  check(Photo.settings(game.sim,0).mode!=previous and u.route==route,"real touch changes camera framing without plotting a route")
 var old_font=feed.receiver_font_size
 Settings.current.text_scale=1.25;game._layout();await settle()
 check(feed.receiver_font_size>old_font,"viewfinder follows text size setting")
 Settings.current.reduced_motion=true
 var clock=feed.time
 await settle()
 check(is_equal_approx(clock,feed.time),"reduced motion freezes decorative camera animation")
 var Catalog=preload("res://src/equipment/equipment_catalog.gd")
 game.sim.mission.launch_equipment=Catalog.choose(Catalog.default_loadout(),"quietus","photo_flash",["photo_flash"]).fitted
 Photo.set_frame(game.sim,0,{"mode":"tight"})
 Settings.current.text_scale=1.5;game._layout();await settle()
 check(feed.quality_rect.has_area() and not feed.quality_rect.intersects(feed.picture_rect),"quality meters stay outside the picture and its finite-film badge")
 check(feed._buttons.size()==3,"fitted flash and tight framing show all three camera controls")
 for control in feed._buttons:
  check(Rect2(Vector2.ZERO,feed.size).encloses(control.rect),"150 percent text keeps every full camera target inside the viewfinder")
 var focus=Photo.settings(game.sim,0).focus
 if feed._buttons.size()==3:
  await tap(feed.global_position+feed._buttons[2].rect.get_center())
  check(Photo.settings(game.sim,0).focus!=focus,"the large-text focus control responds to real touch")
 Settings.current=preload("res://src/persistence/settings_store.gd").DEFAULTS.duplicate()
 game._show_campaign();await settle()
 var menu_min=INF
 for b in game.panel_box.find_children("*","Button",true,false):
  menu_min=minf(menu_min,b.size.y*dp)
  check(b.size.y*dp>=48 and b.size.x*dp>=48,"menu button meets48dp")
 print("FIX2 MENU TARGET ",shape," minimum height dp=",menu_min)
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("FIX2 CAMERA UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
