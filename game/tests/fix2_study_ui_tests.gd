extends "res://tests/fix2_menu_ui_tests.gd"
const Photo=preload("res://src/simulation/photo_capture.gd")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 for id in [7,27]:
  game._start_mission(id);var s=game.sim;var u=s.units[0]
  for angle in [0.,PI/2.,PI,3.*PI/2.]:
   var point=u.pos+Vector2.from_angle(angle)*60.
   if s.Depth.clear(s,u.pos,point,1):s.sirens[0].pos=point;u.angle=angle;break
  s.sirens[0].band=1;s.sirens[0].transition={};s._observe()
  game._enter_water();game.mission_hud.hints.dismiss();game.mission_hud.open("craft",{"kind":"craft","unit":0,"pos":u.pos});await settle()
  check(s.camera_context().get("target",-1)==-2,"a legitimate Siren is available in op%d"%id)
  if await press(game,"camera"):
   check(s.captures[0].get("target",-1)>=Photo.STUDY,"real PHOTO touch starts the late Siren study")
   game._refresh();await settle()
   check("PHOTO" in game.unit_buttons[0].text and "PHOTO" in game.mission_hud.fleet.task(0),"fleet instruments display a study without indexing charted objectives")
   check(game.ocean.optical_feed.subject_view().get("index",-1)>=Photo.STUDY,"the viewfinder retains the active study")
   check(s.valid_snapshot(s.snapshot()),"a touch-started study saves mid-exposure")
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("FIX2 STUDY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
