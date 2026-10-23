extends "res://tests/fix2_menu_ui_tests.gd"
const Sim=preload("res://src/simulation/simulation.gd")
func shape_case(shape):
 root.size=shape;await settle()
 var path="user://fix2-feedback-%d.save"%shape.x
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test";game.store.path=path
 root.add_child(game);await settle();game.set_process(false);game._start_mission(0)
 var s=game.sim;var u=s.units[0];var enemy=s.sirens[0]
 enemy.pos=u.pos+Vector2(60,0);enemy.band=1;enemy.transition={};enemy.lock=0.2;enemy.target=0;enemy.mode="LOCKING";s._observe()
 game._enter_water();game.mission_hud.hints.dismiss();game.mission_hud.open("tools",{"kind":"craft","unit":0,"pos":u.pos});await settle()
 if await press(game,"emp"):
  var text="\n".join(game.ocean.contact_entries().map(func(entry):return entry.text))
  check("STUNNED" in text and not "BEAM" in text,"Disrupt immediately replaces beam with the observed stun countdown")
  check(not game.lock_warning.visible,"a stunned contact has no lock countdown")
  var before=s.snapshot();game._refresh();await settle()
  check(s.snapshot()==before,"feedback reads the result without changing rules or simulation")
 game.capture_scenario="";game.mission_hud.hints.show_hint("priced_film");game._save_archive()
 check("priced_film" in game.store.load_game().get("hints_seen",[]),"a shown hint persists in the optional validated field")
 game.queue_free();await settle()
 var restored=load("res://scenes/main.tscn").instantiate();restored.store.path=path;root.add_child(restored);await settle();restored.set_process(false)
 check("priced_film" in restored.hints_seen,"fresh launch retains seen hints")
 restored.queue_free();await settle()
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("FIX2 FEEDBACK UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
