extends SceneTree
# Handoff 039: real debrief screen, real touch, both Fold7 shapes.
const Lines=preload("res://src/presentation/consequence_lines.gd")
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
func debrief(game,id:int):
 game._start_mission(id)
 var m=game.sim.mission
 for o in m.get("objectives",[]):o["captured"]=true
 m.recovered=true;m.chosen_route="deep"
 game.sim.outcome="won";game._debrief();game._layout();await settle()
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  for id in [14,22,29]:
   var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/fit_label_main.gd"));game.fixture_dpi=420.;game.capture_scenario="consequence-lines-ui"
   root.add_child(game);await settle();game.set_process(false)
   game.completed=[0,1,2,3,4,5]
   game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered deep carrier"},"completed":[6,7,9,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
   await debrief(game,id)
   var base=Lines.LINES[id]
   var found=labels(game,[]).filter(func(l):return l.is_visible_in_tree() and l.text.begins_with(base))
   check(found.size()==1,"%s op %d shows its consequence line once"%[str(dimensions),id])
   if found.size()==1:
    var label=found[0]
    var rect=label.get_global_rect()
    check(game.get_global_rect().encloses(rect) or label.get_parent() is Container,"op %d line sits inside the screen"%id)
    var font=label.get_theme_font("font");var fs=label.get_theme_font_size("font_size")
    var need=font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,rect.size.x,fs).y
    check(rect.size.x>0 and need<=rect.size.y+1.,"op %d line is not clipped by its own box"%id)
    var record=labels(game,[]).filter(func(l):return l.is_visible_in_tree() and l.text.contains("Vey /") or l.text.contains("Rill /") or l.text.contains("Nera /"))
    check(record.is_empty() or record[0].get_global_rect().position.y>=rect.position.y,"op %d line is above the record text"%id)
   var buttons={}
   for b in game.panel_box.get_children():
    if b is Button and b.text in ["RETRY EXPEDITION","OPERATIONS ARCHIVE"]:buttons[b.text]=b
   check(buttons.size()==2,"op %d retry and archive buttons exist"%id)
   for key in buttons:
    game.scroll.ensure_control_visible(buttons[key]);await settle()
    check(game.scroll.get_global_rect().grow(1.).encloses(buttons[key].get_global_rect()) and buttons[key].size.y>0.,"%s op %d %s is reachable inside the scroll viewport"%[str(dimensions),id,key])
   if buttons.has("RETRY EXPEDITION"):
    game.scroll.ensure_control_visible(buttons["RETRY EXPEDITION"]);await settle()
    await tap(buttons["RETRY EXPEDITION"].get_global_rect().get_center())
    check(game.screen=="briefing","op %d actual RETRY touch opens the briefing (screen=%s)"%[id,str(game.screen)])
   game.queue_free();await settle()
 print("CONSEQUENCE LINES UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
