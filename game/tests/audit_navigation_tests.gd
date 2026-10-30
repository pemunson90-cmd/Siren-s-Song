extends "res://tests/fix2_menu_ui_tests.gd"
# Handoff 120 (audit 091 F4/F9/F10/F11): repeat-stop continue-or-replan choice, direct
# newest-record and current-branch access, compact launch economics, debrief damage record.
# Presentation and input only: every check that touches the simulation compares against
# the ordinary order path the player already had.
const Sim=preload("res://src/simulation/simulation.gd")
const Branch=preload("res://src/presentation/current_branch.gd")
const OperationCatalog=preload("res://src/campaign/operation_catalog.gd")
const LaunchSummary=preload("res://src/presentation/launch_summary.gd")
const Effects=preload("res://src/simulation/field_tool_effects.gd")
var case_label=""
func check(ok,label):super.check(ok,label+" "+case_label)
func make_game(shape:Vector2i,scale:float):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 var prefs=Prefs.SettingsStore.DEFAULTS.duplicate();prefs.text_scale=scale;Prefs.apply(prefs,game);await settle()
 return game
const Prefs=preload("res://src/presentation/frontend/frontend_settings.gd")
# The earned-course wall fixture from earned_course_continuity_tests, on the live game sim.
func wall_fixture(s)->void:
 s.sirens=[];s.mission.erase("depth_geometry");s.mission.rocks=[];s.mission.structures=[Rect2(800,380,80,240)]
 s.mission.world_size=Vector2(1600,960);s.mission.region_revision=1;s.mission.start=Vector2(240,500);s.mission.earned_terrain=true;s.mission.launch_seed=Rect2(80,80,640,800)
 s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 s.selected=0;s.units[0].pos=Vector2(240,500);s.units[0].vel=Vector2.ZERO;s.units[0].angle=0;s.units[0].route=[];s.units[0].erase("route_plan");s.units[0].hold=""
 s.units[1].alive=false;s.units[2].alive=false
func measure_wall(s)->void:
 s.terrain_chart.observe([{"pos":Vector2(600,500),"radius":330.0}],{})
 s.known=s.terrain_chart.clear_cells.duplicate();s.mission.terrain_chart=s.terrain_chart.snapshot()
func move_for(s,seconds:float)->void:
 for n in int(seconds*60):s._move(s.units[0],Sim.STEP,42.0,false,true,true)
func chart_stop_case(shape:Vector2i,scale:float)->void:
 case_label=str(["chart",shape,scale])
 var game=await make_game(shape,scale)
 game._start_mission(0);await settle()
 var s=game.sim;wall_fixture(s);s.paused=true
 var goal=Vector2(1200,500)
 check(s.command("route",{"point":goal}),"fixture accepts an unmeasured goal")
 game._refresh();await settle()
 var choice=game.mission_hud.chart_choice
 check(choice!=null and not choice.panel.visible,"no choice while the course runs")
 measure_wall(s);move_for(s,30)
 check(s.units[0].get("chart_stop","")=="New terrain","fixture reaches a real chart stop")
 var held=s.units[0].pos;move_for(s,2)
 check(s.units[0].pos.distance_to(held)<1.0,"a chart stop never travels on by itself")
 game._refresh();await settle()
 check(choice.panel.visible and button(game,"chart_continue")!=null and button(game,"chart_replan")!=null,"one continue-or-replan choice appears at the stop")
 check(not choice.fresh.is_empty(),"faces measured since the last decision are marked as the new edge")
 check(choice.prompt.text.contains("Retained destination") and not choice.prompt.text.contains("—"),"prompt names the retained destination without an em dash")
 var panel_rect=choice.panel.get_global_rect()
 check(game.get_viewport_rect().encloses(panel_rect),"choice stays on screen")
 check(panel_rect.size.y<game.get_viewport_rect().size.y*.45,"chart decision leaves most of the chart visible at large text")
 check(not panel_rect.has_point(game.ocean.screen_position(s.units[0].pos)),"chart decision leaves the selected craft visible")
 # Twin: the manual replot of the same destination the audit player issued at every stop.
 var twin=Sim.new();twin.start(0);wall_fixture(twin);twin.paused=true
 twin.command("route",{"point":goal});measure_wall(twin);move_for(twin,30)
 check(twin.units[0].pos.is_equal_approx(s.units[0].pos),"twin reaches the identical stop")
 var goals=s.route_goals().duplicate(true)
 twin.command("route",{"point":goal})
 await press(game,"chart_continue")
 check(s.route_goals()==goals,"continue keeps the retained destination")
 check(s.units[0].route==twin.units[0].route and s.units[0].has("chart_stop")==twin.units[0].has("chart_stop"),"continue installs exactly the course a manual replot installs")
 move_for(s,3);move_for(twin,3)
 check(s.units[0].pos.is_equal_approx(twin.units[0].pos) and s.units[0].vel.is_equal_approx(twin.units[0].vel),"continue moves identically to the manual replot")
 # Second stop: the replan path opens the course editor and leaves the plan untouched.
 move_for(s,30);game._refresh();await settle()
 if choice.panel.visible:
  var kept=s.route_goals().duplicate(true)
  await press(game,"chart_replan")
  check(game.screen=="program" and s.route_goals()==kept,"replan opens the course editor with intent retained")
 game.queue_free();await settle()
func records_case(shape:Vector2i,scale:float)->void:
 case_label=str(["records",shape,scale])
 var game=await make_game(shape,scale)
 game.recovered_evidence.clear()
 for n in 45:game.recovered_evidence["audit_record_%d"%n]={"name":"RECORD %d"%(n+1),"caption":"Caption %d."%(n+1),"optical":"audit_record_%d"%n}
 game.recovered_evidence.audit_record_44.name="DRILLERS AND GUARDS AT THE GLASS"
 game._evidence_gallery(0);await settle()
 var newest=button(game,"newest_record")
 check(newest!=null and game.scroll.get_global_rect().encloses(newest.get_global_rect()),"NEWEST RECORD is reachable without scrolling")
 await press(game,"newest_record")
 var text=""
 for label in game.panel_box.find_children("*","Label",true,false):text+=label.text+"\n"
 check(text.contains("45 OF 45") and text.contains("DRILLERS AND GUARDS AT THE GLASS"),"one tap reaches the newest of 45 records")
 for id in ["previous_record","next_record","newest_record"]:
  var nav=button(game,id)
  check(nav!=null and game.scroll.get_global_rect().encloses(nav.get_global_rect()),"navigation stays visible above long record titles: "+id)
 check(button(game,"newest_record")!=null and button(game,"newest_record").disabled,"newest record says it is already newest")
 await press(game,"previous_record");text=""
 for label in game.panel_box.find_children("*","Label",true,false):text+=label.text+"\n"
 check(text.contains("44 OF 45"),"previous steps back one record")
 await press(game,"next_record");await press(game,"next_record");text=""
 for label in game.panel_box.find_children("*","Label",true,false):text+=label.text+"\n"
 check(text.contains("1 OF 45"),"next still wraps to the first record")
 game.queue_free();await settle()
func branch_checks()->void:
 case_label="branch"
 check(Branch.pick([],[7,8])==-1,"no recovery names no branch")
 var tested=false
 for id in OperationCatalog.registered_ids():
  var pre=OperationCatalog.definition(id).get("prerequisites",[])
  if pre.is_empty():continue
  var other=-1
  for alt in OperationCatalog.registered_ids():
   if alt!=id and pre[0] not in OperationCatalog.definition(alt).get("prerequisites",[]):other=alt;break
  if other<0:continue
  check(Branch.pick([pre[0]],[other,id])==id,"most recent recovery selects its continuation over an earlier listed row")
  tested=true;break
 check(tested,"catalog has a continuation fixture")
func branch_home_case(shape:Vector2i,scale:float)->void:
 case_label=str(["home",shape,scale])
 var game=await make_game(shape,scale)
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.active_started=false
 game.expedition=preload("res://src/campaign/campaign_consequences.gd").upgrade({"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,37,16,20,17,18,19,22,23,27,24,25,30,31,32,33],"facts":{"deep":"observed","confluence_route":"concealed"}})
 var before=[game.completed.duplicate(),game.expedition.duplicate(true)]
 game._show_campaign();await settle()
 var branch=button(game,"current_branch")
 check(branch!=null,"older optional work does not hide the current Trench continuation")
 if branch!=null:
  check(game.scroll.get_global_rect().encloses(branch.get_global_rect()),"current branch is on the first screen")
  await press(game,"current_branch")
  check(game.screen=="briefing" and Branch.pick(game._campaign_completed(),[game.get_meta("onboard2_fit_index",-1)])>=0,"current branch opens the continuation of the latest recovery")
 print("AUDIT NAV BRANCH ",case_label," shown=",branch!=null)
 check([game.completed,game.expedition]==before,"branch access never changes progress")
 game.queue_free();await settle()
func launch_case(shape:Vector2i,scale:float)->void:
 case_label=str(["launch",shape,scale])
 var game=await make_game(shape,scale)
 game.completed=[0,1,2,3,4,5];game.unlocked=5
 game.expedition=preload("res://src/campaign/campaign_consequences.gd").upgrade({"version":2,"route":"deep","routes":["deep"],"completed":[6],"facts":{"deep":"observed"}})
 var economy=game.economy.duplicate(true)
 var text=LaunchSummary.text(game)
 check(text.contains("THIS LAUNCH") and text.contains("RETRY SAME FIT") and text.contains("FREE"),"summary names launch, retry and the free bare baseline")
 check(text.contains("QUIETUS") and not text.contains("—"),"summary carries one mount line per craft without an em dash")
 check(game.economy==economy,"reading the summary never charges or edits the economy")
 game._briefing(7);await settle()
 var all=""
 for label in game.panel_box.find_children("*","Label",true,false):
  if label.is_visible_in_tree():all+=label.text+"\n"
 if game.screen=="briefing":check(all.contains("RETRY SAME FIT") and all.contains("BARE FLEET FREE") and all.contains("MOUNTED"),"briefing shows launch, retry, bare cost and mounts outside the preparation fold")
 var costs=button(game,"launch_costs")
 check(costs!=null and game.menu_footer.get_global_rect().encloses(costs.get_global_rect()),"launch cost comparison stays one tap away in the pinned footer")
 if costs!=null:
  await press(game,"launch_costs")
  check(game.screen=="reference" and button(game,"back")!=null,"cost comparison opens directly and offers return to launch")
 game.queue_free();await settle()
func damage_case()->void:
 case_label="damage"
 var game=await make_game(Vector2i(2520,1080),1.)
 game._start_mission(0);await settle()
 var s=game.sim;var log=game.hud.get_node_or_null("DamageLog")
 check(log!=null,"damage record is installed")
 if log==null:game.queue_free();await settle();return
 log.sample()
 s.hull=90.;log.sample()
 check(log.events().is_empty(),"a hull write without time passing is set-up, not damage")
 s.elapsed+=1.;s.hull=70.;log.sample()
 s.elapsed+=1.;s.hull=60.;log.sample()
 var rows=log.events()
 check(rows.size()==1 and rows[0].kind=="NOT A COLLISION" and is_equal_approx(rows[0].loss,30.),"close losses merge into one non-collision entry with its total")
 s.elapsed+=10.;Effects.record_collision(s,6.);s.hull=54.;s.message="Hull strike against terrain · 9m/s · hull -6%";log.sample()
 rows=log.events()
 check(rows.size()==2 and rows[1].kind=="COLLISION" and rows[1].note=="terrain at 9m/s","collision is attributed only from the collision ledger and strike text")
 var text=log.summary()
 check(text.contains("HULL -36%") and text.contains("00:12") and text.contains("NOT A COLLISION"),"debrief record states what, when and how much")
 check(not text.contains("—"),"damage record has no em dash")
 s.units[1].alive=false;s.elapsed+=1.;log.sample()
 check(log.summary().contains("LOST"),"a lost drone is recorded")
 # Continuous hazard fields damage hull by less than half a percent per frame.
 # Sample at render cadence so small losses cannot vanish when the observer rebases.
 log.bind(s)
 var initial=s.hull
 for tick in 120:
  s.elapsed+=1./60.;s.hull-=8./60.;log.sample()
 rows=log.events()
 check(rows.size()==1 and is_equal_approx(rows[0].loss,16.) and is_equal_approx(rows[0].after,initial-16.),"two seconds of frame-sized hazard losses retain all sixteen hull points")
 log.bind(s)
 for hit in 13:
  s.elapsed+=3.;s.hull-=1.;log.sample()
 check(log.events().size()==12 and log.summary().contains("HULL -13% OBSERVED") and log.summary().contains("Most recent 12 events"),"bounded event history retains the full observed total and discloses omitted rows")
 game.queue_free();await settle()
func run():
 branch_checks()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for scale in [1.,1.5]:
   await chart_stop_case(shape,scale)
   await records_case(shape,scale)
   await branch_home_case(shape,scale)
   await launch_case(shape,scale)
 await damage_case()
 print("AUDIT NAVIGATION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
