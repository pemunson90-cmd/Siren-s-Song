extends "res://tests/depth_policy_ui_tests.gd"
# WP-181: the chart-stop card never loops. A kept course that runs into rock offers no CONTINUE COURSE; an answered
# stop (REPLAN, or a CONTINUE that cannot be flown) closes the card until the craft holds at a new stop.
func goal_where(g,want_ok:bool):
 var u=g.sim.units[0]
 for y in range(40,int(g.sim.world_size().y)-40,20):
  for x in range(40,int(g.sim.world_size().x)-40,20):
   var plan=[{"pos":Vector2(x,y),"stop":true,"mode":"inherit"}]
   # A rock goal is a point the game has told the player about (a refused tap): the chart then holds it as rock.
   if not want_ok and g.sim.blocked(plan[0].pos,12):g.sim.tell_rock(0,"point",plan[0].pos)
   if g.mission_hud.chart_choice.compile_ok(u.pos,plan)==want_ok:return plan
 return []
func hold(g,plan):
 var u=g.sim.units[0];u.route_plan=plan.duplicate(true);u.route=[{"pos":plan[0].pos,"stop":true}];u.chart_stop="New terrain";u.hold=""
 g.mission_hud.dismiss();g._refresh();await settle()
func run():
 root.size=Vector2i(2520,1080);await settle()
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://chart-stop-card.save"
 g.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(g);await settle();g.set_process(false)
 g._start_mission(12);g.sim.sirens=[];PlayerDive.launch_drones(g.sim);g._refresh();await settle()
 g.sim.mission[PlayerDive.Rules.KEY]=false
 await acknowledge_warning(g)
 var choice=g.mission_hud.chart_choice
 var safe=goal_where(g,true);var rock=goal_where(g,false)
 check(g.sim.terrain_chart!=null,"mission has an earned chart");check(not safe.is_empty() and not rock.is_empty(),"fixture finds a flyable and an unflyable goal")
 # Flyable course: CONTINUE COURSE is offered and takes the course.
 await hold(g,safe)
 check(choice.panel.visible and choice.continue_button.visible,"flyable kept course shows CONTINUE COURSE")
 await click(choice.continue_button)
 check(not g.sim.units[0].has("chart_stop") and not choice.panel.visible,"CONTINUE COURSE sets the course and closes the card")
 # Course into rock: no CONTINUE, a line says so, REPLAN answers the stop and the card stays closed after the planner.
 await hold(g,rock)
 check(choice.panel.visible and not choice.continue_button.visible,"unflyable kept course hides CONTINUE COURSE")
 check(choice.prompt.text.contains("tap open water"),"the card tells the player to tap open water")
 await click(choice.replan_button)
 check(g.screen=="program","REPLAN opens the planner")
 await close_program(g);g.mission_hud.dismiss();g._refresh();await settle()
 check(g.sim.units[0].has("chart_stop") and not choice.panel.visible,"leaving the planner returns to the dive with the card closed")
 # A direct CONTINUE that cannot be flown closes the card and says why.
 g.sim.units[0].erase("chart_stop");await hold(g,rock);choice.answered.clear();g._refresh();await settle()
 choice.continue_course();await settle()
 check(choice.answered.get(0,false) and not choice.panel.visible,"a refused CONTINUE closes the card (the strip line is set after the order; the test build overwrites it with a save error)")
 # A new order clears the stop; a later stop asks again.
 g.sim.units[0].erase("chart_stop");g._refresh();await settle()
 await hold(g,safe)
 check(choice.panel.visible,"a later stop opens the card again")
 print("CHART STOP CARD CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
