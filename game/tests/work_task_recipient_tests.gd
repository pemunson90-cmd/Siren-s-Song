extends SceneTree
# 119 (audit 091 F3/F5/F13): object work ownership, named recipient, craft/object
# choice and moving-objective progress. Presentation and input only.
const WorkTask=preload("res://src/presentation/work_task/work_task.gd")
var checks=0
var failures=0
var captures=""
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func frames():
 for n in 4:await process_frame
func tap_at(p:Vector2):
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=p;event.pressed=pressed;root.push_input(event,true);await process_frame
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.position=p;mouse.global_position=p;mouse.pressed=pressed;root.push_input(mouse,true);await process_frame
 await frames()
func tap(button):await tap_at(button.get_global_rect().get_center())
func world_tap(g,pos:Vector2):await tap_at(g.ocean.screen_position(pos)+g.ocean.global_position)
func shot(name:String):
 if captures.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(captures.path_join(name+".png"))
func site_index(g,key:String)->int:
 for i in g.sim.mission.objectives.size():
  if g.sim.mission.objectives[i].get("site_id","")==key:return i
 return -1
func settle(g,id:int,pos:Vector2,band:int=1,face:Vector2=Vector2.INF):
 var u=g.sim.units[id];u.pos=pos;u.vel=Vector2.ZERO;u.band=band;u.route=[];u.transition={}
 if face.is_finite():u.angle=pos.angle_to_point(face)
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):captures=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(captures)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await frames()
  var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://work-task-"+str(dimensions.x)+".save"
  for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(g.store.path+suffix)
  g.capture_scenario="runtime-test"
  root.add_child(g);await frames();g.set_process(false)
  if g.get_node_or_null("Frontend")!=null:g.get_node("Frontend")._dismiss()
  g._start_mission(34);g._enter_water();g.sim.sirens=[];g.sim.paused=true
  var tag=str(dimensions.x)
  var work_pos:Vector2=g.sim.mission.glass_reach.work_pos
  var disc=-1
  for i in g.sim.mission.objectives.size():
   if g.sim.mission.objectives[i].has("glass_effect") and g.sim.mission.objectives[i].pos.distance_to(work_pos)<1.:disc=i
  var wash=site_index(g,"calder_34_wash_bypass")
  check(disc>=0 and wash>=0,"Beneath the Well exposes the disconnect at its Reach work position and the optional wash bypass "+tag)
  if disc<0 or wash<0:g.queue_free();await frames();continue
  var disc_pos:Vector2=g.sim.mission.objectives[disc].pos;var wash_pos:Vector2=g.sim.mission.objectives[wash].pos
  # F3: the disconnect's own projection, not REACH WORK, owns its CAMERA work.
  settle(g,0,disc_pos+Vector2(-150,40));settle(g,1,disc_pos+Vector2(0,30),1,disc_pos);settle(g,2,disc_pos+Vector2(-150,160))
  g._order("select",{"unit":1});g.ocean.focus_craft();g._refresh();await frames()
  await world_tap(g,disc_pos)
  check(g.advanced_orders and g.mission_hud.page=="object" and int(g.mission_hud.subject.get("index",-1))==disc and g.mission_hud.subject.get("subkind","")!="glass_work","tapping the disconnect opens the disconnect's own work projection "+tag)
  check(g.order_buttons.camera in g.mission_hud.ring_buttons and not g.mission_hud.extra.glass_work in g.mission_hud.ring_buttons,"disconnect projection offers its CAMERA work instead of REACH WORK "+tag)
  check(g.mission_hud.task.get("index",-1)==disc and g.mission_hud.task.get("owner",-1)==1,"opening the object names it as DRONE A's chosen task "+tag)
  check(WorkTask.captions(g.sim,g.mission_hud.subject)[0]=="BY DRONE A","object projection names its order recipient before sending "+tag)
  await shot("work-object-"+tag)
  settle(g,1,disc_pos+Vector2(0,30),0,disc_pos)
  check("NEEDS MIDDLE" in WorkTask.captions(g.sim,g.mission_hud.subject),"long object name cannot hide needed band "+tag)
  settle(g,1,disc_pos+Vector2(0,30),1,disc_pos)
  # F5 (1371): object under A while Q is selected asks which one is meant.
  g.mission_hud.dismiss();g._order("select",{"unit":0});g.ocean.focus_craft();g._refresh();await frames()
  await world_tap(g,disc_pos)
  check(g.advanced_orders and g.mission_hud.page=="choose" and 1 in g.mission_hud.choose_units,"object occupied by a different craft shows a visible craft/object choice "+tag)
  check(g.mission_hud.extra.choose_unit_1 in g.mission_hud.ring_buttons and g.mission_hud.extra.choose_object in g.mission_hud.ring_buttons and "BY Q" in g.mission_hud.extra.choose_object.text,"choice names DRONE A and the object order recipient "+tag)
  await shot("work-choose-"+tag)
  var q_route=g.sim.units[0].route.duplicate()
  if g.mission_hud.extra.choose_unit_1.is_visible_in_tree():
   await tap(g.mission_hud.extra.choose_unit_1)
   check(g.sim.selected==1 and g.mission_hud.page=="craft","choosing DRONE A selects the craft under the object "+tag)
  check(g.sim.units[0].route==q_route,"the choice never retasks Quietus "+tag)
  g.mission_hud.dismiss();g._order("select",{"unit":0});g.ocean.focus_craft();g._refresh();await frames()
  await world_tap(g,disc_pos)
  if g.mission_hud.page=="choose" and g.mission_hud.extra.choose_object.is_visible_in_tree():
   await tap(g.mission_hud.extra.choose_object)
   check(g.mission_hud.page=="object" and int(g.mission_hud.subject.get("index",-1))==disc and g.sim.selected==0,"choosing the object keeps Quietus as the named recipient "+tag)
  # F3 (1377): A near the optional bypass, chosen task is the disconnect.
  g.mission_hud.dismiss();g._order("select",{"unit":1});g._refresh()
  var away=(wash_pos-disc_pos).normalized()
  settle(g,1,wash_pos+away*40.,1,wash_pos);g.mission_hud.task={"index":disc,"owner":1};g.ocean.focus_craft();g._refresh();await frames()
  var context=g.sim.camera_context()
  check(int(context.get("target",-1))==wash and context.get("ready",false),"precondition: sim CAMERA would pick the nearer optional bypass "+tag)
  g.mission_hud.open("object",{"kind":"objective","index":disc,"name":g.sim.mission.objectives[disc].name,"pos":disc_pos});g._refresh();await frames()
  check(g.order_buttons.camera.disabled and not g.order_buttons.camera.tooltip_text.is_empty(),"disconnect projection refuses CAMERA aimed at another job and says why "+tag)
  g.mission_hud.open("craft");g._refresh();await frames()
  check(g.order_buttons.camera.disabled and "HELD" in " ".join(g.mission_hud.camera_caption()),"main CAMERA is held instead of starting the optional job "+tag)
  await shot("work-held-"+tag)
  g.mission_hud.dismiss();g._primary_action();g._refresh();await frames()
  check(g.sim.captures.all(func(c):return c.is_empty()),"held CAMERA starts no work "+tag)
  check("LAST · DRONE A · REFUSED · CAMERA HELD" in g.mission_hud.intent.text and "TASK · DRILL FEED DISCONNECT · DRONE A" in g.mission_hud.intent.text,"persistent task and retained refusal are readable on water "+tag)
  g._order("select",{"unit":0});g._refresh();await frames()
  check("LAST · DRONE A · REFUSED" in g.mission_hud.intent.text,"selection does not erase the refusal reason "+tag)
  # The object's own CAMERA works the object once its craft is there.
  g._order("select",{"unit":1});settle(g,1,disc_pos+Vector2(0,30),1,disc_pos);g.ocean.focus_craft();g._refresh();await frames()
  await world_tap(g,disc_pos)
  check(g.mission_hud.page=="object" and not g.order_buttons.camera.disabled and int(g.sim.camera_context().get("target",-1))==disc,"disconnect projection CAMERA is ready at the disconnect "+tag)
  if g.mission_hud.page=="object" and g.order_buttons.camera.is_visible_in_tree() and not g.order_buttons.camera.disabled:
   await tap(g.order_buttons.camera)
   check(int(g.sim.captures[1].get("target",-1))==disc,"actual CAMERA touch in the projection works the disconnect "+tag)
   g._refresh();await frames()
   check("WORKING A" in g.mission_hud.intent.text and "LAST · DRONE A · STARTED" in g.mission_hud.intent.text,"task progress and start result stay on water "+tag)
   await shot("work-progress-"+tag)
  # F13: moving load progress distinguishes motion, escort hold, last fix and arrival.
  g._start_mission(25);g._enter_water();g.sim.sirens=[];g.sim.paused=true
  var state=g.sim.mission.get("iron_choir",{})
  check(not state.get("load",{}).is_empty(),"Last Shift has a physical moving load "+tag)
  if not state.get("load",{}).is_empty():
   var load_pos:Vector2=state.load.pos
   for id in 3:settle(g,id,load_pos+Vector2(-400-id*30,0))
   state.seen={"pos":load_pos,"angle":0.,"hull":100.,"alive":true,"band":state.load.band,"state":"transit","carrier":-1,"time":g.sim.elapsed,"name":state.load.name}
   check("HELD · needs a craft within 200m" in WorkTask.load_status(g.sim),"observed transit beyond escort reads HELD with the support distance "+tag)
   settle(g,1,load_pos+Vector2(-120,0))
   check("MOVING · ESCORT A 120m / 200m" in WorkTask.load_status(g.sim),"observed escorted transit reads MOVING with the escort "+tag)
   g.ocean.focus_craft();g._refresh();await frames()
   check("MOVING · ESCORT" in g.mission_hud.intent.text,"moving objective progress is on the water status "+tag)
   await shot("work-load-"+tag)
   state.seen.time=g.sim.elapsed-6.
   check("LAST FIX 6s" in WorkTask.load_status(g.sim) and "not confirmed" in WorkTask.load_status(g.sim),"stale fix never reads as arrival "+tag)
   state.seen.time=g.sim.elapsed;state.seen.state="arrived"
   check(WorkTask.load_tag(g.sim)=="ARRIVED · CONFIRMED","observed arrival is confirmed at the load "+tag)
   state.seen.time=g.sim.elapsed-6.
   check(WorkTask.load_tag(g.sim)=="ARRIVED \u00b7 CONFIRMED","observed arrival stays confirmed after sight ages "+tag)
  # Ordinary objectives occupied by another craft use the same visible choice.
  g._start_mission(2);g._enter_water();g.sim.sirens=[];g.sim.paused=true
  var ordinary=g.sim.mission.objectives[0].pos
  settle(g,0,ordinary+Vector2(-150,100));settle(g,1,ordinary);settle(g,2,ordinary+Vector2(-200,180))
  g._order("select",{"unit":0});g.ocean.focus_craft();g._refresh();await frames()
  await world_tap(g,ordinary)
  check(g.mission_hud.page=="choose" and 1 in g.mission_hud.choose_units,"ordinary objective overlap offers craft or object choice "+tag)
  g.queue_free();await frames()
 print("WORK TASK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
