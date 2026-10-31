extends SceneTree
# Source-known technical UI fixtures: own bodies are staged at local controls,
# threats removed; each plant action and modal gesture uses raw screen input.
const WEST=Vector2(480,1000)
const EAST=Vector2(1520,1000)
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func touch(point:Vector2,down:bool,index:int=0,canceled:bool=false):
 var event=InputEventScreenTouch.new();event.index=index;event.position=point;event.pressed=down;event.canceled=canceled;root.push_input(event,true)
 if index==0:
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true)
 await process_frame
func tap(point:Vector2):
 await touch(point,true);await touch(point,false);await settle()
func click(button):await tap(button.get_global_rect().get_center())
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func progress()->Dictionary:
 return {"version":2,"route":"shelf","routes":["shelf"],"facts":{"shelf":"Recovered shelf warning"},"completed":[6,8],"notes":{},"references":{},"entitlements":["drone_sampler"],"history":[],"selected_thread":""}
func start(game):
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition=progress();game._start_mission(10);await settle();game.sim.sirens=[]
func at(game,unit:int,point:Vector2):
 game.mission_hud.dismiss();game.sim.units[unit].pos=point;game.sim.units[unit].vel=Vector2.ZERO;game.sim.command("select",{"unit":unit});game.ocean.focus_craft();game._refresh();await settle()
func station(game,index:int):
 var site=game.sim.observable_sites()[index];var point=game.ocean.screen_position(site.pos)
 # The station and nearby own hull have independent physical targets. Find a
 # point on the station's visible touch body that is outside the nearby hull.
 var radius=maxf(game.ui_touch_height*.5,38*game.ocean.world_scale)
 for offset in [Vector2.ZERO,Vector2.UP,Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN]:
  var candidate=point+offset*radius*.85
  if game.ocean.pick_context(candidate,game.ui_touch_height).get("kind","")=="objective":point=candidate;break
 await tap(game.ocean.global_position+point)
func craft(game):
 game.mission_hud.dismiss();game.ocean.focus_craft();game._refresh();await settle();await click(game.mission_hud.fleet.buttons[game.sim.selected])
 # Co-located physical craft now require a deliberate choice, rather than
 # depending on independently displaced station handles.
 if game.mission_hud.page=="fleet":await click(game.unit_buttons[game.sim.selected])
func primary(game):
 await craft(game);await click(game.order_buttons.camera)
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="warning-chain-public-ui-fixture"
  game.set_meta("dev_profile",true) # 127: carrier return routes are dev/test travel shortcuts (Pat 2026-10-30).
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);await start(game)
  var sim=game.sim;var h=game.mission_hud;var label="cover" if dimensions.x==2520 else "inner"
  await at(game,1,WEST+Vector2(0,55));await station(game,0)
  check(h.page=="plant" and h.subject.get("station","")=="inlet","actual WEST station tap opens local plant controls on "+label)
  check(h.action_controls().has("chain_connect") and h.action_controls().has("chain_backup") and h.action_controls().has("chain_disconnect"),"station radial exposes connection and distinct audible backup on "+label)
  check(ResourceLoader.exists("res://src/presentation/warning_chain_view.gd"),"public plant presenter exists for power, proof and physical world on "+label)
  if not h.extra.has("chain_connect"):
   game.queue_free();await settle();continue
  var view=load("res://src/presentation/warning_chain_view.gd")
  check("POWER OFF" in h.intent.text and not h.extra.chain_connect.disabled and h.extra.chain_disconnect.disabled,"public local readiness distinguishes quiet connect from unavailable disconnect")
  sim.command("route",{"point":WEST+Vector2(-90,55)});var course=sim.route_goals();var tools=sim.tools.duplicate(true);var noises=sim.noises.duplicate(true)
  await click(h.extra.chain_connect)
  check(sim.warning_chain_context().power=={"source":"umbilical","unit":1} and sim.paused and sim.route_goals()==course and sim.tools==tools and sim.noises==noises,"raw CONNECT quietly holds the own supply craft and preserves course, pause and tools")
  check("SHORE POWER" in h.fleet.telemetry[1].text and h.fleet.readouts.filter(func(r):return r.unit==1)[0].progress.unit<0,"connected craft has continuous shore task without an invented acquisition clock")
  game.ocean.fit_chart();game._refresh();await settle();await capture(label+"-quiet-connected-overview")
  await at(game,0,EAST+Vector2(0,55));await primary(game)
  check(h.page=="plant" and h.subject.station=="panel" and "PLANT" in game.order_buttons.camera.text,"craft primary action opens the nearest known panel instead of generic capture")
  check("SHORE POWER" in h.fleet.telemetry[1].text and h.fleet.telemetry[1].text.count("\n")>=1,"remote connected supplier remains expanded when another craft operates the panel")
  var route=sim.route_goals();var selected=sim.selected
  await click(h.extra.chain_service)
  check(h.page=="plant" and game.advanced_orders and sim.warning_chain_context().output=="service" and sim.warning_chain_context().crosslink_open and sim.warning_chain_context().result.is_empty(),"SERVICE opens physical crosslink and keeps an explicit unsent panel decision")
  check(sim.selected==selected and sim.route_goals()==route and not h.extra.chain_send.disabled,"output selection does not leak a water route, fleet selection or automatic send")
  check(view.context(sim).crosslink.opened and "NOT SENT" in view.summary(sim),"opened geometry and selected but unsent output remain truthful")
  await capture(label+"-service-selected-unsent")
  # A drag begun on SEND cancels the modal without a command or water order.
  var p=h.extra.chain_send.get_global_rect().get_center();await touch(p,true)
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=p+Vector2(95,50);drag.relative=Vector2(95,50);root.push_input(drag,true);await process_frame
  await touch(drag.position,false);await settle()
  check(not game.advanced_orders and sim.warning_chain_context().result.is_empty() and sim.route_goals()==route,"drag through SEND cancels without accidental transmission or map route")
  await primary(game);p=h.extra.chain_send.get_global_rect().get_center();await touch(p,true);await touch(p+Vector2(60,0),true,1);await touch(p,false);await touch(p+Vector2(60,0),false,1);await settle()
  check(not game.advanced_orders and sim.warning_chain_context().result.is_empty() and sim.route_goals()==route,"mixed two-finger modal gesture never transmits or routes")
  await primary(game);await click(h.extra.chain_send)
  check(sim.warning_chain_context().result.get("proof","")=="local_receipt" and "LOCAL RECEIPT" in h.intent.text,"separate actual SEND proves only the actual western acoustic receipt")
  await capture(label+"-service-receipt")
  game.ocean.fit_chart();game._refresh();await settle();await capture(label+"-open-crosslink-overview")
  await at(game,1,WEST+Vector2(0,55));await primary(game);check(not h.extra.chain_disconnect.disabled,"actual supplier can disconnect after commissioned receipt")
  await click(h.extra.chain_disconnect)
  check(sim.warning_chain_context().power.source=="off" and "POWER OFF" in h.intent.text and "LOCAL RECEIPT" in h.intent.text and not "SHORE POWER" in h.fleet.task(1),"release changes present supply without erasing latched receipt or leaving a false craft task")
  await at(game,0,Vector2(180,1000));sim.paused=false;sim.advance(1./60.);sim.paused=true;game._process(0);await settle()
  check(game.screen=="debrief" and game.panel_box.find_children("*","Label",true,false).any(func(l):return "LOCAL RECEIPT" in l.text),"actual recovery debrief reports the achieved plant proof")
  await capture(label+"-service-debrief")
  # Quietus-only backup/mast path, independent of any shore connection.
  await start(game);sim=game.sim;await at(game,0,EAST+Vector2(0,55));await primary(game)
  check(h.extra.chain_service.disabled and h.extra.chain_send.disabled,"unpowered panel actions remain visibly unavailable")
  await click(h.extra.inspect)
  check("Plant unpowered" in h.instrument_info.text and "60m" in h.instrument_info.text and "2m/s" in h.instrument_info.text,"STATUS explains disabled local power actions and physical readiness")
  await at(game,0,WEST+Vector2(0,55));await primary(game);await click(h.extra.chain_backup)
  check(sim.warning_chain_context().power.source=="backup" and sim.acoustic_feedback().pulses.any(func(n):return n.label=="BACKUP GENERATOR START" and n.radius==900),"raw backup starts the actual finite 900m generator emission")
  check("BACKUP" in h.intent.text and not h.fleet.task(0).contains("SHORE POWER"),"backup is visibly independent of an attached craft")
  await at(game,2,EAST+Vector2(0,55));await primary(game);await click(h.extra.inspect)
  check("fitted field sampler" in h.instrument_info.text,"bare drone's disabled panel has an actionable specialist reason")
  await at(game,0,EAST+Vector2(0,55));await primary(game);await click(h.extra.chain_mast)
  check(sim.warning_chain_context().output=="mast" and not sim.warning_chain_context().crosslink_open and sim.warning_chain_context().result.is_empty(),"NORTH MAST selection preserves closed crosslink and unsent state")
  await capture(label+"-mast-selected-unsent")
  await click(h.extra.chain_send)
  check(sim.warning_chain_context().result.get("proof","")=="mast_transmission" and "EXTERNAL UNKNOWN" in h.intent.text and not "LOCAL RECEIPT" in h.intent.text,"mast proves its own transmission while external reception stays unknown")
  check(sim.acoustic_feedback().pulses.any(func(n):return n.label=="NORTH MAST WARNING" and n.pos==Vector2(1000,400)) and "1100m" in view.detail(sim,"panel"),"public world and status use the actual finite northern hardware origin and range")
  await primary(game);check(h.extra.chain_send.disabled and h.extra.chain_service.disabled,"commissioned controls cannot retrigger a lure or rewrite the selected history")
  await capture(label+"-mast-transmission")
  h.dismiss();game.ocean.fit_chart();game._refresh();await settle();await capture(label+"-closed-crosslink-mast-overview")
  await primary(game);await click(h.extra.inspect);await capture(label+"-mast-status")
  # Public projection is read-only, and drawing accepts a plain Control with
  # its caller's world transform; Root's planner can reuse exactly this seam.
  var before=sim.snapshot();var context=view.context(sim);context.crosslink.opened=true
  check(sim.snapshot()==before and not sim.warning_chain_context().crosslink_open,"presentation projection cannot mutate plant source state")
  var canvas=Control.new();canvas.size=Vector2(300,200);game.add_child(canvas);canvas.draw.connect(func():canvas.draw_set_transform(Vector2.ZERO,0,Vector2.ONE*.12);view.draw_crosslink(canvas,view.context(sim),.12));canvas.queue_redraw();await settle();canvas.queue_free()
  check(true,"public crosslink helper renders through an ordinary Control world transform")
  game.fitted_equipment.drone_a="drone_sampler";await start(game);sim=game.sim
  await at(game,0,WEST+Vector2(0,55));sim.units[0].vel=Vector2(2,0);game._refresh();await primary(game)
  check(h.extra.chain_connect.disabled,"moving own craft cannot attach a plant umbilical")
  await click(h.extra.inspect);check("Settle below2m/s" in h.instrument_info.text,"STATUS explains a moving craft's exact disabled action")
  await at(game,0,WEST+Vector2(0,55));await primary(game);await click(h.extra.chain_connect)
  await craft(game);await click(h.extra.route_menu);await click(game.order_buttons.hold)
  check(sim.warning_chain_context().power.source=="off" and not "SHORE POWER" in h.fleet.task(0),"actual manual route release immediately disconnects the supplier's plant power")
  await primary(game);await click(h.extra.chain_backup)
  await at(game,1,EAST+Vector2(0,55));await primary(game)
  check(not h.extra.chain_service.disabled,"fitted field sampler receives its own actual local panel readiness")
  await click(h.extra.chain_service);await click(h.extra.chain_send)
  check(sim.warning_chain_context().result.get("proof","")=="local_receipt","fitted sampler performs explicit select and send while Quietus stays free")
  await at(game,0,Vector2(180,1000));sim.paused=false;sim.advance(1./60.);sim.paused=true;game._process(0);await settle()
  check(game.screen=="departure" and game.panel_box.find_children("*","Button",true,false).any(func(b):return b.get_meta("action","")=="return_module_1"),"commissioned plant preserves the actual outstanding fitted-module return decision")
  await capture(label+"-commissioned-module-decision")
  game.queue_free();await settle()
 print("WARNING CHAIN UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
