extends SceneTree
# Isolated multi-craft control fixtures, not an earned campaign journey.
var checks=0
var failures=0
var capture_dir=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for frame in 6:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func capture(name:String):
 if not capture_dir.is_empty() and DisplayServer.get_name()!="headless":
  await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))
func tactical(s):
 var state=s.snapshot()
 for field in ["selected","queue_mode","message"]:state.erase(field)
 return state
func touch(point:Vector2,down:bool,id:int=0):
 var event=InputEventScreenTouch.new();event.index=id;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):capture_dir=arg.trim_prefix("--capture-dir=")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="fleet-instruments"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game._start_mission(1);await settle()
  var s=game.sim;var hud=game.mission_hud;var name="cover" if dimensions.x==2520 else "inner"
  for enemy in s.sirens:enemy.stun=100.
  for pair in [[1,0],[2,1]]:
   s.units[pair[0]].pos=s.mission.objectives[pair[1]].pos+Vector2(0,100)
   s.command("select",{"unit":pair[0]});check(s.command("camera"),"actual separated exposure begins")
  s.command("select",{"unit":0});check(s.command("route",{"point":s.units[0].pos+Vector2(0,-160)}),"Quietus routes while two drones acquire")
  var origin=s.units[0].pos;s.paused=false
  for n in 60:s.advance(1./60.)
  check(s.units[0].pos.distance_to(origin)>1 and s.capture_feedback(1).elapsed>.9 and s.capture_feedback(2).elapsed>.9,"real movement and both acquisition clocks run together")
  s.paused=true;game._refresh();await settle();await capture(name+"-parallel")
  var fleet=hud.get("fleet")
  check(fleet!=null,"distributed fleet instruments exist on actual chart")
  if fleet==null:game.queue_free();await settle();continue
  check(fleet.buttons.size()==3 and fleet.buttons.all(func(b):return b.is_visible_in_tree()),"every living craft remains reachable without FLEET menu")
  check("WEST RELAY" in fleet.buttons[1].text and "EAST RELAY" in fleet.buttons[2].text and "25%" in fleet.buttons[1].text,"simultaneous exposures identify owner target and actual progress")
  for b in fleet.buttons:
   check(b.size.y+.1>=game.ui_touch_height and game.get_global_rect().encloses(b.get_global_rect()),"instrument retains bounded full-size touch target "+name+" "+b.text+" "+str(b.get_global_rect())+" bounds "+str(game.get_global_rect()))
  for id in fleet.buttons.size():
   for other in range(id):check(not fleet.buttons[id].get_global_rect().intersects(fleet.buttons[other].get_global_rect()),"simultaneous task instruments remain individually legible and tappable")
  check(fleet.readouts.any(func(r):return r.offscreen),"separated craft receives directional edge instrument")
  var before=tactical(s)
  var start=fleet.buttons[2].get_global_rect().get_center()
  await touch(start,true)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=start+Vector2(90,20);drag.relative=Vector2(90,20);root.push_input(drag,true);await process_frame
  await touch(drag.position,false);await settle()
  check(s.selected==0 and tactical(s)==before and not game.advanced_orders,"drag beginning on marker never selects opens orders or becomes route")
  await touch(start,true);await touch(game.global_position+game.size*.6,true,1)
  await touch(game.global_position+game.size*.6,false,1);await touch(start,false);await settle()
  check(s.selected==0 and tactical(s)==before and not game.advanced_orders,"second finger during marker touch cannot become a water order")
  game.ocean.pan_chart(Vector2(-400,200));game._refresh();await settle()
  await tap(fleet.buttons[0].get_global_rect().get_center())
  check(game.ocean.chart_camera.mode=="follow" and not game.advanced_orders and tactical(s)==before,"selected craft marker first restores focus from manual view without opening orders")
  await tap(fleet.buttons[2].get_global_rect().get_center())
  check(s.selected==2 and game.ocean.chart_camera.mode=="follow" and not game.advanced_orders,"first craft-marker tap selects and focuses without opening orders")
  check(tactical(s)==before,"selection preserves all routes simultaneous work resources clocks and pause")
  await tap(fleet.buttons[2].get_global_rect().get_center())
  check(game.advanced_orders and hud.page=="craft" and tactical(s)==before,"second selected-marker tap opens craft context without tactical action")
  await tap(hud.extra.inspect.get_global_rect().get_center())
  check(hud.page=="inspect" and hud.instrument_info.is_visible_in_tree(),"full detailed STATUS remains accessible")
  hud.dismiss();await settle()
  await tap(game.pause_button.get_global_rect().get_center());check(not s.paused,"pause remains directly reachable beside instruments")
  await tap(game.pause_button.get_global_rect().get_center());check(s.paused,"pause resumes unlimited planning")
  # Actual snapshot restoration must preserve parallel work and its readouts.
  var snapshot=s.snapshot();check(s.restore(snapshot),"actual partial multi-craft state restores")
  game._refresh();await settle()
  check("25%" in fleet.buttons[1].text and "25%" in fleet.buttons[2].text,"restored instruments retain per-craft exposure clocks")
  var enemy=s.sirens[0];enemy.pos=s.units[2].pos+Vector2(130,0);enemy.stun=0.;enemy.lock=2.;enemy.target=2;enemy.mode="ACQUIRE"
  s._observe();game._refresh();await settle();await capture(name+"-danger")
  check(game.ocean.contact_entries().any(func(e):return e.urgent and "DRONE B" in e.text) and not "BEAM" in hud.alarm.text,"fresh beam warning retains craft attribution in its single contact readout")
  check(fleet.buttons.all(func(b):return b.is_visible_in_tree()),"fresh danger and parallel work retain fleet access")
  hud.open("craft");await settle();await capture(name+"-danger-context")
  check(hud.alarm.visible and "BEAM" in hud.alarm.text and not game.ocean.contact_readout_entries().any(func(e):return e.urgent),"popup transfers fresh warning above projection without duplicating it")
  hud.dismiss();await settle()
  var live=s.sirens;var texts=fleet.buttons.map(func(b):return b.text);var warnings=game.ocean.contact_entries();s.sirens=[];game._refresh()
  check(texts==fleet.buttons.map(func(b):return b.text) and warnings==game.ocean.contact_entries(),"instruments and warnings depend on own state and cached observations rather than hidden live roster")
  s.sirens=live
  s.captures[1]={};s.units[1].hold="SCOUT_STOP";game._refresh();await settle()
  check("SCOUT STOP" in fleet.buttons[1].text,"own SCOUT stop stays legible while another craft is selected")
  s.units[1].alive=false;game._refresh();await settle()
  check(not fleet.buttons[1].is_visible_in_tree(),"lost craft cannot remain an actionable live marker")
  s.captures[2]={};game._refresh();await settle()
  check(not "\n" in fleet.buttons[0].text,"idle peer instrument stays a compact single line")
  for fixture in [{"mission":12,"unit":0,"verb":"ACTUATE","fitted":{}},{"mission":12,"unit":1,"verb":"FIELD SAMPLE","fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}},{"mission":13,"unit":0,"verb":"TRANSMIT","fitted":{}}]:
   s.start(fixture.mission,"endurance",{"fitted":fixture.fitted});s.sirens=[]
   s.units[fixture.unit].pos=Vector2(1830,1080) if fixture.mission==13 else s.mission.objectives[0].pos+Vector2(0,80)
   s.command("select",{"unit":fixture.unit});check(s.command("camera"),"actual "+fixture.verb+" fixture begins")
   game._refresh();await settle()
   check(fleet.buttons[fixture.unit].text.contains(fixture.verb+" 0%"),"public operation/equipment context names "+fixture.verb+" correctly")
  game.queue_free();await settle()
 print("FLEET INSTRUMENTS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
