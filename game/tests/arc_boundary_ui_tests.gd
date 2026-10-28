extends "res://tests/fix2_menu_ui_tests.gd"
# Source-known UI/save boundary fixtures, not campaign play or human evaluation.
const Arcs=preload("res://src/campaign/arcs/arc_table.gd")
const Card=preload("res://src/presentation/arcs/arc_card.gd")
const Recap=preload("res://src/campaign/arcs/arc_recap.gd")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path="user://arc080-%d.save"%shape.x
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 var settings=preload("res://src/presentation/frontend/frontend_settings.gd")
 var prior_scale=settings.text_scale();settings.current["text_scale"]=1.5;game._layout()
 game.active_started=false;game.completed=[0,1,2,3,4,5];game.unlocked=5
 game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed","glass_choice":"service","choir_choice":"bypass","choir_people":"landed","choir_plant":"reconnect"},"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25,30,31,32,33,34],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
 Card.clear(game)
 var legacy=game._archive()
 check(Arcs.valid(legacy) and game.store.valid(legacy),"old archive without arc markers remains valid")
 Card.restore(game,legacy)
 for arc in Arcs.ARCS:
  check(not game.get_meta(Card.META).get(arc.seen),"absent marker is unseen for arc %d"%arc.number)
  game._briefing(arc.first);await settle()
  var card=game.get_node_or_null("ArcCard")
  check(card!=null and not game.menu.visible,"first open presents modal arc %d"%arc.number)
  if card==null:continue
  var next=button(card,"arc_continue")
  check(next!=null and next.size.x>=48 and next.size.y>=game.ui_touch_height,"arc has a touch-sized Continue")
  if next!=null:
   var rect=next.get_global_rect()
   check(game.get_global_rect().encloses(rect),"arc Continue stays inside safe content at large text")
  check(button(game,"begin")==null,"hidden briefing cannot receive touch behind card")
  var seen=game._archive()
  check(seen.get(arc.seen)==true and game.store.valid(seen),"opening immediately persists optional seen boolean")
  var wrong=seen.duplicate(true);wrong[arc.seen]=1
  check(not game.store.valid(wrong),"nonboolean arc marker is rejected")
  check(game.store.save(seen) and game.store.load_game()==seen,"seen marker survives checksummed disk roundtrip")
  if arc.number%2==0:await press(card,"arc_continue")
  else:await android_back()
  check(game.get_node_or_null("ArcCard")==null and game.screen=="briefing" and game.menu.visible,"Continue or Android Back reveals original briefing")
  game._briefing(arc.first);await settle()
  check(game.get_node_or_null("ArcCard")==null,"replay never repeats arc intro")
  Card.restore(game,seen);game._briefing(arc.first);await settle()
  check(game.get_node_or_null("ArcCard")==null,"restored seen marker never repeats intro")
 var recap="\n".join(Recap.lines(game.expedition))
 for fact in ["deep","concealed","service","bypass","landed","reconnect"]:check(recap.contains(fact),"recap carries saved fact "+fact)
 check(Recap.lines({}).size()==2 and not "\n".join(Recap.lines({})).contains("deep"),"missing facts produce no invented choices")
 # Departure decorates the already-built result and restores it without settling twice.
 game._show_campaign();game.screen="debrief";game.sim.start(19);game.mission_index=19;game.sim.mission.recovered=true;game.sim.outcome="won"
 var before=game.expedition.duplicate(true)
 Card.recovered(game,true);await settle()
 check(game.get_node_or_null("ArcCard")!=null,"first last-core recovery shows departure")
 await android_back()
 check(game.screen=="debrief" and game.menu.visible and game.expedition==before,"Back restores result without repeating campaign recovery")
 Card.recovered(game,false);await settle()
 check(game.get_node_or_null("ArcCard")==null,"replayed last core never shows departure")
 game.sim.outcome="lost";Card.recovered(game,true);await settle()
 check(game.get_node_or_null("ArcCard")==null,"failure never shows departure")
 game.sim.start(10);game.mission_index=10;game.sim.mission.recovered=true;game.sim.outcome="won"
 Card.recovered(game,true);await settle()
 check(game.get_node_or_null("ArcCard")==null,"alternative thread recovery does not repeat arc departure")
 game._show_campaign();await settle()
 var groups=game.panel_box.find_children("*","VBoxContainer",true,false).filter(func(node):return node.has_meta("arc_group"))
 check(groups.size()>=6,"Operations and recovered fold group existing rows under six arcs")
 game.queue_free();await settle();settings.current["text_scale"]=prior_scale
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://arc080-%d.save"%shape.x+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("ARC BOUNDARY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
