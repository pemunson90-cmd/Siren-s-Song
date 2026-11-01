extends SceneTree
# Item 140: every debrief path (recovered, lost, expedition) shows one dive time / hull / life support line.
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func labels(node,found:Array)->Array:
 if node is Label:found.append(node)
 for child in node.get_children():labels(child,found)
 return found
func stat_lines(game)->Array:
 var re=RegEx.new();re.compile("Dive time \\d\\d:\\d\\d\\s*/\\s*Hull \\d+%\\s*/\\s*Life support \\d+%")
 return labels(game,[]).filter(func(l):return l.is_visible_in_tree() and re.search(l.text)!=null).map(func(l):return l.text)
func case(game,id:int,outcome:String,tag:String):
 game._start_mission(id);await settle();game.set_process(false)
 var s=game.sim
 s.outcome=outcome;s.elapsed=125.;s.hull=63.;s.oxygen=41.;s.message="Quietus went silent."
 if outcome=="won":s.mission.recovered=true
 game._debrief();game._layout();await settle()
 var found=stat_lines(game)
 check(found.size()==1,tag+": exactly one stats line (found %d)"%found.size())
 if found.size()==1:check(found[0]=="Dive time 02:05  /  Hull 63%  /  Life support 41%",tag+": line carries the sim values: "+found[0])
func session_case():
 var path="user://dive-end-stats.save"
 for file in [path,path+".runs"]:
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
 var host=load("res://scenes/main.tscn").instantiate()
 host.capture_scenario="runtime-test";host.store.path=path;root.add_child(host);await settle()
 host.economy=preload("res://src/campaign/economy.gd").new_state("standard",true)
 host._show_campaign();host._save_archive()
 var front=load("res://src/presentation/frontend/frontend.gd").new()
 host.add_child(front);front.setup(host,true);front._mode_select();await settle()
 preload("res://src/campaign/runs/run_archive.gd").persist(host,preload("res://src/campaign/runs/run_state.gd").new_run(12345))
 preload("res://src/presentation/runs/modes_frontend.gd").start(front);await settle()
 var session=host.get_node_or_null("ExpeditionSession")
 check(session!=null,"expedition session opens")
 if session!=null:
  session._begin();await settle()
  var s=session.sim
  s.outcome="won";s.elapsed=125.;s.hull=63.;s.oxygen=41.
  session._debrief();await settle()
  var found=stat_lines(session)
  check(found.size()==1,"expedition run result: exactly one stats line (found %d)"%found.size())
  if found.size()==1:check(found[0]=="Dive time 02:05  /  Hull 63%  /  Life support 41%","expedition run result carries the sim values: "+found[0])
 host.queue_free();await settle()

func run():
 root.size=Vector2i(2520,1080);await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/fit_label_main.gd"));game.fixture_dpi=420.;game.capture_scenario="dive-end-stats-ui"
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5]
 game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered deep carrier"},"completed":[6,7,9,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
 await case(game,0,"won","classic won")
 await case(game,0,"lost","classic lost")
 await case(game,9,"won","expedition won")
 await case(game,9,"lost","expedition lost")
 game.queue_free();await settle()
 await session_case()
 print("DIVE END STATS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
