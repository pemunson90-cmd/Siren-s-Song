extends "res://tests/challenges_ui_tests.gd"
func button(node,id):
 for b in node.find_children("*","Button",true,false):
  if b.get_meta("ui_action",b.get_meta("action",""))==id and b.is_visible_in_tree():return b
 return null
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game.economy.unlocks=["hull:quiet","hull:fast","chassis:scout","chassis:heavy","chassis:endurance"];game.completed=[0];game.unlocked=5
 game.active_started=false;game._show_campaign();await settle()
 var row=button(game,"mission1");var position=row.position.y if row!=null else -1.
 game.active_started=true;game._show_campaign();await settle();row=button(game,"mission1")
 check(row!=null and is_equal_approx(row.position.y,position),"a resume row never shifts mission rows")
 check(button(game,"fittings")!=null,"operations has a separate Fittings entry")
 if await press(game,"fittings"):
  for id in Catalog.frames(0):
   var b=button(game,"frame_quietus_"+id)
   check(b!=null,"all Quietus hull options are listed: "+id)
  if await press(game,"frame_quietus_quiet"):
   check(game.fitted_equipment.hull=="quiet" and game.screen=="fittings","touch selects a named hull without cycling")
  await android_back()
  check(game.screen=="menu","Android Back leaves Fittings for operations")
 for id in [3,4,5]:
  game._briefing(id);await settle()
  var text=""
  for label in game.panel_box.find_children("*","Label",true,false):text+=label.text+"\n"
  check("GOAL:" in text and "DANGER:" in text and not "ORDERS\n" in text,"op%d gives goal/danger with orders behind the manual"%(id+1))
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("FIX2 MENU UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
