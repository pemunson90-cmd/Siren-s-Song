extends SceneTree
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
 for n in 3:await process_frame
func pointer(point:Vector2,down:bool):
 var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func tap(point:Vector2):await pointer(point,true);await pointer(point,false);await frames()
func button_click(point:Vector2):
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.position=point;event.global_position=point;event.pressed=down;root.push_input(event,true);await process_frame
 await frames()
func setup(g):
 g._start_mission(0);g.sim.units[0].pos=Vector2(400,500);g.sim.units[0].route=[{"pos":Vector2(300,700),"stop":true}];g.mission_hud.open("tools");g._refresh();await frames()
func run():
 root.size=Vector2i(1280,720);await frames()
 var g=load("res://scenes/main.tscn").instantiate();g.capture_scenario="decoy-aim-tests";root.add_child(g);g.set_process(false);await setup(g)
 var original=g.sim.snapshot();await button_click(g.order_buttons.decoy.get_global_rect().get_center())
 var supported=g.get_property_list().any(func(p):return p.name=="decoy_armed")
 check(supported,"decoy has explicit transient targeting state")
 check(g.sim.snapshot()==original,"arming spends no buoy and does not change route/hold/pause")
 if not supported:g.queue_free();await frames();finish();return
 check(g.decoy_armed and g.ocean.decoy_targeting and "CANCEL" in g.order_buttons.decoy.text and "160m" in g.detail_label.text,"armed mode has truthful bounded preview and cancel copy")
 var good=g.ocean.screen_position(Vector2(300,500))+g.ocean.global_position
 var bad=g.ocean.screen_position(Vector2(560,500))+g.ocean.global_position
 await tap(bad)
 check(g.decoy_armed and g.sim.tools.decoy==3 and g.sim.noises.is_empty(),"rock tap keeps aim and refuses spend")
 await tap(good)
 check(not g.decoy_armed and g.sim.tools.decoy==2 and g.sim.noises.size()==1 and g.sim.noises[0].pos.distance_to(Vector2(300,500))<0.1,"touch deploys at deliberately chosen water point exactly once")
 check(g.sim.units[0].route==original.units[0].route,"deployment does not become a movement order")
 for cancel in ["decoy","select","program","menu","knock"]:
  await setup(g);g._order("decoy");good=g.ocean.screen_position(Vector2(300,500))+g.ocean.global_position;await pointer(good,true)
  if cancel=="menu":g._show_campaign()
  else:g._order(cancel,{"unit":1} if cancel=="select" else {})
  await pointer(good,false);await frames()
  check(g.sim.tools.decoy==3 and g.sim.noises.is_empty() and g.sim.units[0].route==original.units[0].route,"cancel/"+cancel+" after press cannot deploy or turn into route")
 await setup(g);g._order("knock");g._order("decoy");check(g.decoy_armed and not g.knock_armed,"decoy arm cancels torpedo")
 g._order("knock");check(g.knock_armed and not g.decoy_armed,"torpedo arm cancels decoy")
 await setup(g);g._order("decoy");good=g.ocean.screen_position(Vector2(300,500))+g.ocean.global_position;await pointer(good,true)
 var drag=InputEventScreenDrag.new();drag.index=0;drag.position=good+Vector2(45,0);root.push_input(drag,true);await process_frame;await pointer(drag.position,false);await frames()
 check(g.decoy_armed and g.sim.tools.decoy==3 and g.sim.units[0].route==original.units[0].route,"pan remains navigation while armed")
 g._chart_zoom(1.4);g.ocean.fit_chart();g._view_changed()
 check(g.decoy_armed and g.sim.tools.decoy==3 and g.sim.units[0].route==original.units[0].route,"zoom/FIT cannot deploy or change route")
 await setup(g);g._order("select",{"unit":1});g._order("decoy");g.sim.units[1].alive=false;g.sim.selected=0;g._refresh()
 check(not g.decoy_armed and not g.ocean.decoy_targeting,"automatic lost-drone selection cannot carry deployment aim to Quietus")
 await setup(g);g._order("decoy");g.sim.outcome="won";g._refresh();check(not g.decoy_armed and not g.ocean.decoy_targeting,"ended dive removes transient cue")
 g.queue_free();await frames();finish()
func finish():print("DECOY AIM UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
