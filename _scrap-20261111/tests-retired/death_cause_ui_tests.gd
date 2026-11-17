extends SceneTree
# Handoff 046: the loss debrief with the cause line, real touch, both Fold7 shapes, classic and expedition paths.
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.global_position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func labels(node,found:Array)->Array:
 if node is Label:found.append(node)
 for child in node.get_children():labels(child,found)
 return found
# A real ping loss on the live game simulation, observed by the installed observer.
func lose(game,ping:bool):
 var s=game.sim
 s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(700,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.stun=0.;e.band=s.units[0].band;e.transition={}
 s.sirens=[e]
 for id in range(1,s.units.size()):s.units[id].alive=false
 s.units[0].silent=true;s.paused=false
 var log=game.hud.get_node("DeathCauseLog")
 if ping:s.command("ping")
 for i in 3000:
  s.advance(0.1);log.sample()
  if not s.outcome.is_empty():break
func case(game,id:int,ping:bool,dimensions):
 var tag="%s op %d %s"%[str(dimensions),id,"ping" if ping else "no record"]
 game._start_mission(id);await settle();game.set_process(false)
 await lose(game,ping)
 check(game.sim.outcome=="lost" and "Siren beam" in game.sim.message,tag+": scripted beam loss")
 game._debrief();game._layout();await settle()
 var found=labels(game,[]).filter(func(l):return l.is_visible_in_tree() and l.text.begins_with("It was drawn by:"))
 var last=labels(game,[]).filter(func(l):return l.is_visible_in_tree() and (l.text.begins_with("Last observed") or l.text.begins_with("A Siren beam hit")))
 check(last.size()==1,tag+": the existing loss line is still shown once")
 if ping:
  check(found.size()==1 and "ACTIVE SONAR" in found[0].text,tag+": the cause line is shown once")
  if found.size()==1 and last.size()==1:
   var label=found[0];var rect=label.get_global_rect()
   var font=label.get_theme_font("font");var fs=label.get_theme_font_size("font_size")
   var need=font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,rect.size.x,fs).y
   check(rect.size.x>0 and need<=rect.size.y+1.,tag+": cause line is not clipped by its own box")
   check(label.get_parent() is Container and rect.position.x>=0 and rect.end.x<=game.get_global_rect().end.x+1.,tag+": cause line stays inside the screen width")
   check(rect.position.y>=last[0].get_global_rect().position.y,tag+": cause line sits under the existing line")
 else:
  check(found.is_empty(),tag+": no cause line when nothing was recorded")
 var buttons={}
 var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
 for b in game.panel_box.get_children():
  if b is Button and b.text in ["RETRY OPERATION","RETRY DIVE","OPERATIONS ARCHIVE"]:buttons[b.text]=b
 check(buttons.size()==2 and buttons.has("OPERATIONS ARCHIVE"),tag+": retry and archive buttons exist")
 for key in buttons:
  game.scroll.ensure_control_visible(buttons[key]);await settle()
  check(game.scroll.get_global_rect().grow(1.).encloses(buttons[key].get_global_rect()) and buttons[key].size.y*dp>=48.,tag+": %s is reachable with a 48 dp target"%key)
 if ping:
  var log=game.hud.get_node("DeathCauseLog");log.ring.clear();log.lock_start.clear()
  game._debrief();game._layout();await settle()
  check(labels(game,[]).filter(func(l):return l.is_visible_in_tree() and l.text.begins_with("It was drawn by:")).is_empty(),tag+": an empty record removes the cause line again")
  await android_back()
  check(game.screen=="menu",tag+": Android Back leaves the loss debrief (screen=%s)"%str(game.screen))
func android_back():
 root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
 await settle()
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/fit_label_main.gd"));game.fixture_dpi=420.;game.capture_scenario="death-cause-ui"
  root.add_child(game);await settle();game.set_process(false)
  game.completed=[0,1,2,3,4,5]
  game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered deep carrier"},"completed":[6,7,9,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
  await case(game,0,true,dimensions)
  await case(game,9,true,dimensions)
  game.queue_free();await settle()
 print("DEATH CAUSE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
