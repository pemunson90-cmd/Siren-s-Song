extends SceneTree
# Back audit (WP-80): every screen a player can reach gets one system Back and we record where it lands.
# The exit hook and clock are replaced, so the run never quits. The expected table below is the rule:
# Back goes one level up toward Operations; only the top screens arm "Press Back again to exit"; a dive is never ended:
# Back closes what is open in it, else does what its MENU button does (the dive is kept for RESUME).
const Confirm=preload("res://src/presentation/back_exit/back_exit_confirm.gd")
const MenuReach=preload("res://src/presentation/frontend/menu_reach.gd")
const ModeLauncher=preload("res://src/presentation/frontend/mode_launcher.gd")
var checks=0
var failures=0
var now=100000
var quits=0
var rows=[]
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func on_quit():quits+=1
func fresh():
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false);game._show_campaign();await settle()
 game.back_exit=Confirm.new();game.add_child(game.back_exit)
 game.back_exit.quit_hook=on_quit;game.back_exit.clock=func():return now
 quits=0
 return game
func where(game):
 for mode in ["CareerSession","ExpeditionSession","ChallengeSession"]:
  var session=game.get_node_or_null(mode)
  if session!=null:return mode+":"+session.screen
 var front=game.get_node_or_null("Frontend")
 if front!=null:return "Frontend:"+front.screen
 if game.get_node_or_null("RouteMapView")!=null:return "route_map(view still open) host="+game.screen
 if game.get_node_or_null("ArcCard")!=null:return "ArcCard over "+game.screen
 return game.screen
# One audit row: open the screen, press Back once, record the landing place and the side effects.
func audit(label:String,open:Callable,expect:String,expect_toast:=false,after_check:Callable=Callable()):
 var game=await fresh()
 await open.call(game)
 var before=where(game)
 root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
 var after=where(game)
 var armed=game.back_exit.armed
 rows.append("%-34s | %-34s | %s%s"%[label,before,after," (toast armed)" if armed else ""])
 check(after==expect,"%s: Back from %s lands on %s (wanted %s)"%[label,before,after,expect])
 check(quits==0,label+": one Back never quits")
 check(armed==expect_toast,label+": the exit toast is "+("shown" if expect_toast else "not shown"))
 if after_check.is_valid():after_check.call(game)
 game.queue_free();await settle()
func press(game,id):
 for b in game.find_children("*","Button",true,false):
  if b.get_meta("action","")==id and b.is_visible_in_tree():b.pressed.emit();await settle();return true
 return false
func dive(game,index:=0):
 game._start_mission(index);game._enter_water();game.sim.paused=false;await settle()
func run():
 # Title and its pages: Operations is the origin, so each page returns one level up.
 await audit("title at launch",func(g):g._boot_frontend();await settle(),"Frontend:title",true)
 await audit("title from Operations",func(g):MenuReach.open(g,"title");await settle(),"menu")
 await audit("settings from Operations",func(g):g._settings_menu();await settle(),"menu")
 await audit("settings (reach row)",func(g):MenuReach.open(g,"settings");await settle(),"menu")
 await audit("game modes",func(g):MenuReach.open(g,"modes");await settle(),"menu")
 await audit("challenges",func(g):MenuReach.open(g,"challenges");await settle(),"menu")
 await audit("credits",func(g):MenuReach.open(g,"credits");await settle(),"menu")
 await audit("expeditions list",func(g):MenuReach.open(g,"modes");await settle();load("res://src/presentation/runs/modes_frontend.gd").expeditions(g.get_node("Frontend"));await settle(),"Frontend:modes")
 await audit("Operations",func(g):await settle(),"menu",true)
 await audit("region card",func(g):g._briefing(0);await settle();preload("res://src/presentation/arcs/arc_card.gd").present(g,preload("res://src/campaign/arcs/arc_table.gd").ARCS[0],false);await settle(),"briefing")
 await audit("briefing",func(g):g._briefing(0);await settle();g.get_node("ArcCard").dismiss();await settle(),"menu")
 await audit("field manual",func(g):g._briefing(0);await settle();g._reference(0);await settle(),"briefing")
 await audit("launch costs",func(g):g._briefing(0);await settle();preload("res://src/presentation/launch_summary.gd").show(g,0);await settle(),"briefing")
 await audit("launch guard",func(g):g._briefing(0);await settle();await dive(g);g._show_campaign();g._briefing(0);await settle();g.screen="launch_guard";preload("res://src/presentation/flow/campaign_flow.gd").confirm_launch(g,0);await settle(),"briefing")
 await audit("FITTINGS",func(g):g._show_fittings();await settle(),"menu")
 await audit("SUPPLIES",func(g):g._show_economy();await settle(),"menu")
 await audit("ROUTE MAP",func(g):preload("res://src/presentation/route_map/route_map_view.gd").open(g);await settle(),"menu")
 await audit("ARCHIVE",func(g):load("res://src/presentation/archive/archive_view.gd").show(g);await settle(),"menu")
 await audit("RESEARCH",func(g):load("res://src/presentation/research/research_view.gd").show(g);await settle(),"menu")
 await audit("SIREN DOSSIER from Operations",func(g):load("res://src/presentation/siren_dossier/siren_dossier.gd").show(g);await settle();check(dossier_button(g)=="BACK TO OPERATIONS","dossier from Operations names Operations"),"menu")
 await audit("SIREN DOSSIER from ARCHIVE",func(g):load("res://src/presentation/archive/archive_view.gd").show(g);await settle();await press(g,"siren_dossier");await settle();check(dossier_button(g)=="BACK TO ARCHIVE","dossier from the archive names the archive"),"archive")
 await audit("FIELD RECORDS gallery",func(g):await gallery(g),"menu")
 await audit("photographic intelligence",func(g):await gallery(g);g._intel_screen();await settle(),"evidence")
 await audit("HARD SAVES",func(g):preload("res://src/persistence/save_states/save2_controller.gd").open(g);await settle(),"menu")
 await audit("erase confirmation",func(g):g._confirm_new_campaign();await settle(),"menu")
 # A dive is never ended or quit: Back closes what is open, else acts as the MENU button (Operations, dive kept).
 await audit("dive, nothing open",func(g):await dive(g),"menu",false,dive_kept)
 await audit("dive, torpedo armed",func(g):await dive(g);g.knock_armed=true;g.ocean.knock_targeting=true,"mission",false,func(g):check(not g.knock_armed,"Back disarms the torpedo"))
 await audit("dive, order wheel open",func(g):await dive(g);g._toggle_advanced();await settle(),"mission",false,func(g):check(not g.advanced_orders,"Back closes the order wheel"))
 await audit("dive, route editor open",func(g):await dive(g);g._order("program");await settle(),"mission",false,func(g):check(not g.route_editor.visible,"Back closes the route editor"))
 await audit("dive, contact card open",func(g):await dive(g);await open_card(g),"mission",false,func(g):check(not g.mission_hud.contact_card.is_open(),"Back closes the contact card"))
 await audit("result after a dive",func(g):await dive(g);g.sim.outcome="lost";g._debrief();await settle(),"menu")
 # Mode sessions run on their own Main; the session reports its own screen.
 # The contract board's button says BACK TO GAME MODES; Android Back lands on the same screen (critic 14 Nov).
 await audit("career contract board",func(g):await mode(g,"career"),"Frontend:modes")
 await audit("expedition menu",func(g):await mode(g,"expedition"),"Frontend:expeditions")
 await audit("challenge dive",func(g):await mode(g,"challenge"),"ChallengeSession:challenge_menu")
 await audit("expedition dive",func(g):await mode(g,"expedition");await mode_dive(g,"ExpeditionSession"),"ExpeditionSession:expedition_menu")
 await audit("expedition end confirm",func(g):await mode(g,"expedition");await mode_dive(g,"ExpeditionSession");g.get_node("ExpeditionSession")._confirm_end();await settle(),"ExpeditionSession:expedition_menu")
 await audit("challenge end confirm",func(g):await mode(g,"challenge");g.get_node("ChallengeSession")._confirm_end();await settle(),"ChallengeSession:challenge_menu")
 # The launch title exits on a second Back inside the window, like Operations.
 var game=await fresh();game._boot_frontend();await settle()
 for n in 2:
  root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST);await settle()
 check(quits==1 and game.get_node_or_null("Frontend")!=null,"second Back on the launch title quits through the hook")
 game.queue_free();await settle()
 print("BACK AUDIT (screen | Back pressed on | Back landed on)")
 for row in rows:print("  ",row)
 print("BACK AUDIT CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
func open_card(game):
 var card=game.mission_hud.contact_card
 card.key=0;card.panel.show()
 check(card.is_open(),"contact card fixture is open")
 await settle()
func dive_kept(game):
 check(game.active_started and game.sim.outcome.is_empty() and game.sim.paused,"Back in a dive keeps the dive, paused, for RESUME")
func dossier_button(game):
 for b in game.find_children("*","Button",true,false):
  if b.get_meta("action","")=="siren_dossier_back":return b.text
 return ""
func gallery(game):
 game.recovered_evidence={"well_pattern":{"name":"WELL PATTERN","caption":"Test record.","optical":"well_pattern"}}
 game._evidence_gallery(0);await settle()
func mode(game,kind:String):
 MenuReach.open(game,"modes");await settle()
 var front=game.get_node("Frontend")
 if kind=="career":
  var State=load("res://src/campaign/career/career_state.gd");var Archive=load("res://src/campaign/career/career_archive.gd")
  Archive.persist(game,State.new_career());load("res://src/presentation/career/career_frontend.gd").start(front)
 elif kind=="expedition":
  var Archive=load("res://src/campaign/runs/run_archive.gd");var State=load("res://src/campaign/runs/run_state.gd")
  Archive.persist(game,State.new_run(1));load("res://src/presentation/runs/modes_frontend.gd").start(front)
 else:
  ModeLauncher.launch(front,load("res://src/presentation/frontend/challenge_session.gd"),"ChallengeSession",{"challenge_id":"shelf_passive","return_to_list":func():pass})
 await settle()
func mode_dive(game,node_name:String):
 var session=game.get_node(node_name)
 session._begin();await settle()
