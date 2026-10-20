extends SceneTree
# Public-projection fixtures, not earned sampling or model finishability proof.
class DeliverySim:
 extends "res://src/simulation/simulation.gd"
 var delivery={"packets":[{"id":0,"name":"REQUEST","recorded":true,"aboard":false,"carriers":[1],"salvage":[]},{"id":1,"name":"REPLY","recorded":true,"aboard":false,"carriers":[2],"salvage":[]}],"cargo":[[],[0],[1]],"jobs":[{},{},{}],"complete":false,"text":"Field notes retained; deliver raw packets to Quietus"}
 var local_ready=false
 var requests=[]
 var wreck_sites=[]
 var extra_modules=[]
 func blackwater_delivery_status()->Dictionary:return delivery.duplicate(true) if mission.id==2 else {}
 func blackwater_handoff_context(carrier:int)->Dictionary:return {"carrier":carrier,"ready":local_ready,"reason":"READY · TRANSFER TO QUIETUS" if local_ready else "Settle both craft within60m with clear line of sight","packets":delivery.cargo[carrier],"distance":40. if local_ready else 420.,"range":60.}
 func salvage_sites()->Array:return wreck_sites if mission.id==2 else super.salvage_sites()
 func module_recovery_status()->Dictionary:
  var result=super.module_recovery_status()
  if mission.id==2:result.modules.append_array(extra_modules)
  return result
 func salvage_context(item:String,unit_id:int=-1)->Dictionary:
  if wreck_sites.any(func(site):return site.item==item):return {"ready":true,"reason":"READY · one combined wreck winch","active":false,"elapsed":0.,"duration":4.,"distance":40.,"range":60.,"noise_radius":520.}
  return super.salvage_context(item,unit_id)
 func command(order:String,args:Dictionary={})->bool:
  if order=="blackwater_handoff":requests.append({"order":order,"args":args.duplicate(true)});return local_ready
  if order=="salvage" and wreck_sites.any(func(site):return site.item==args.get("item","")):requests.append({"order":order,"args":args.duplicate(true)});return true
  return super.command(order,args)
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func touch(point:Vector2,down:bool,id:int=0):
 var event=InputEventScreenTouch.new();event.index=id;event.position=point;event.pressed=down;root.push_input(event,true);await process_frame
func move(point:Vector2,delta:Vector2,id:int=0):
 var event=InputEventScreenDrag.new();event.index=id;event.position=point;event.relative=delta;root.push_input(event,true);await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 check(ResourceLoader.exists("res://src/presentation/blackwater_delivery_view.gd"),"Blackwater distinguishes recorded notes, carried buffers and delivery aboard Quietus")
 if failures:finish();return
 var View=load("res://src/presentation/blackwater_delivery_view.gd")
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="blackwater-delivery-ui-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game.sim=DeliverySim.new();game._start_mission(2);await settle()
  var sim=game.sim;var h=game.mission_hud;var label="cover" if dimensions.x==2520 else "inner";var before=sim.snapshot()
  check("0/2" in View.summary(sim) and "2/2" in View.summary(sim) and sim.snapshot()==before,"read-only summary distinguishes two retained notes from zero packets aboard")
  check("REQUEST" in h.fleet.telemetry[1].text and "REPLY" in h.fleet.telemetry[2].text and "BUFFER" in h.fleet.telemetry[1].text,"remote craft telemetry identifies actual packet cargo without claiming delivery")
  check("ABOARD 0/2" in h.intent.text,"ordinary chart status keeps actual delivery count visible")
  await capture(label+"-remote-buffers")
  # Isolate route ownership from known terrain while retaining packet telemetry.
  sim.mission.rocks=[];sim.mission.structures=[];sim._build_navigation();sim.units[0].pos=Vector2(450,620);sim.units[1].pos=Vector2(900,720);sim.units[2].pos=Vector2(1460,160)
  game.ocean.fit_chart();game._refresh();await settle()
  var reading=h.fleet.telemetry[0];var point=reading.get_global_rect().get_center();var world=game.ocean.map_position(point-game.ocean.global_position)
  await tap(point)
  check(sim.route_goals().size()==1 and sim.route_goals()[0].pos.distance_to(world)<1. and not game.advanced_orders,"packet telemetry preserves a permitted water tap as a route command")
  before=sim.snapshot();var camera=game.ocean.chart_camera.snapshot();point=h.fleet.buttons[1].get_global_rect().get_center()
  await touch(point,true);await move(point+Vector2(90,35),Vector2(90,35));await touch(point+Vector2(90,35),false);await settle()
  check(sim.snapshot()==before and game.ocean.chart_camera.snapshot()!=camera,"drag from the buffered craft ring pans without a route or transfer")
  sim.command("select",{"unit":1});game._refresh();h.open("craft");await settle()
  check(game.order_buttons.camera.visible and game.order_buttons.camera.text=="SAMPLE" and h.extra.blackwater_handoff.visible and h.extra.blackwater_handoff.disabled,"remote carrier keeps SAMPLE and shows a disabled explicit local transfer")
  h.open("inspect");await settle();check("60m" in h.instrument_info.text and "settle" in h.instrument_info.text.to_lower(),"carrier status explains local handoff readiness from public context")
  sim.local_ready=true;h.open("craft");await settle();before=sim.snapshot()
  var transfer=h.extra.blackwater_handoff.get_global_rect().get_center()
  await touch(transfer,true);await move(transfer+Vector2(100,40),Vector2(100,40));await touch(transfer+Vector2(100,40),false);await settle()
  check(sim.requests.is_empty() and sim.snapshot()==before,"drag through local TRANSFER is owned by the popup and cannot send data or a route")
  h.open("craft");await settle();transfer=h.extra.blackwater_handoff.get_global_rect().get_center()
  await touch(transfer,true);await touch(transfer+Vector2(180,20),true,1);await touch(transfer,false);await touch(transfer+Vector2(180,20),false,1);await settle()
  check(sim.requests.is_empty() and sim.snapshot()==before,"multi-touch on TRANSFER cancels the complete gesture without data or world orders")
  h.open("craft");await settle();transfer=h.extra.blackwater_handoff.get_global_rect().get_center()
  await touch(transfer,true)
  var cancel=InputEventScreenTouch.new();cancel.index=0;cancel.position=transfer;cancel.pressed=false;cancel.canceled=true;root.push_input(cancel,true);await process_frame
  await touch(transfer,false);await settle()
  check(sim.requests.is_empty() and sim.snapshot()==before,"canceled local transfer never becomes a late data command")
  h.open("craft");await settle()
  await tap(h.extra.blackwater_handoff.get_global_rect().get_center())
  check(sim.requests==[{"order":"blackwater_handoff","args":{"carrier":1}}] and sim.snapshot()==before and not game.advanced_orders,"separate touch sends exactly the selected carrier transfer without routing selecting or mutating projected cargo")
  sim.command("select",{"unit":0});game._refresh();h.open("craft");await settle()
  await tap(h.extra.blackwater_data.get_global_rect().get_center())
  check(h.page=="delivery" and h.extra.blackwater_a.visible and h.extra.blackwater_b.visible,"Quietus transfer context separates both carrier identities")
  await capture(label+"-local-transfer")
  await tap(h.extra.blackwater_b.get_global_rect().get_center())
  check(sim.requests.back()=={"order":"blackwater_handoff","args":{"carrier":2}} and sim.selected==0,"Quietus handoff chooses the named carrier while retaining its own selected station")
  sim.delivery.cargo=[[],[],[]];sim.delivery.jobs[1]={"item":"blackwater_buffer_1","elapsed":2.,"duration":4.};game._refresh();await settle()
  check("RECOVER" in h.fleet.telemetry[1].text and "50%" in h.fleet.telemetry[1].text,"buffer-only winch has its own craft progress even without a module job")
  sim.delivery.jobs[1]={};sim.delivery.cargo=[[0],[],[1]];sim.delivery.packets[0].aboard=true;sim.delivery.packets[0].carriers=[0];game._refresh();await settle()
  check("ABOARD" in h.fleet.telemetry[0].text and "REQUEST" in h.fleet.telemetry[0].text and "1/2" in View.summary(sim),"aboard packet and remaining remote packet retain distinct ownership")
  check("DELIVERED 1/2" in View.debrief_text(sim) and "DELIVERED 2/2" not in View.debrief_text(sim),"debrief projection reports only actual aboard packet count")
  sim.delivery.packets[1].carriers=[];sim.delivery.packets[1].salvage=["blackwater_buffer_2"];sim.delivery.cargo[2]=[]
  check("REPLY" in View.detail(sim) and "wreck" in View.detail(sim).to_lower(),"lost remote buffer remains described as recoverable data rather than delivered evidence")
  sim.wreck_sites=[{"item":"drone_deep_cells","name":"DRONE DEEP CELLS","pos":sim.units[0].pos+Vector2(0,-50),"packets":[0,1]}];game.ocean.focus_craft();game._refresh();await settle()
  sim.extra_modules=[{"item":"drone_deep_cells","name":"DRONE DEEP CELLS","state":"salvage","unit":-1,"pos":sim.wreck_sites[0].pos},{"item":"drone_survey_array","name":"DRONE SURVEY ARRAY","state":"salvage","unit":-1,"pos":sim.wreck_sites[0].pos}];game._refresh();await settle()
  var markers=game.ocean.salvage_markers()
  check(markers.size()==1,"one public co-located kit and data site has one wreck marker")
  check(markers[0].lines.has("DEEP CELLS") and markers[0].lines.has("SURVEY ARRAY") and markers[0].lines.has("REQUEST BUFFER") and markers[0].lines.has("REPLY BUFFER"),"one wreck marker names all public co-located kit and packet contents")
  var plates=h.fleet.readouts.map(func(reading):return reading.rect)
  check(h.fleet.readouts.all(func(reading):return not reading.detail_visible or reading.rect.encloses(h.fleet.telemetry[reading.unit].get_rect())) and markers.all(func(marker):return not plates.any(func(plate):return plate.intersects(marker.rect))),"two-kit and two-buffer badge avoids actual rings and visible exact readouts")
  await tap(game.ocean.global_position+markers[0].rect.get_center())
  check(h.page=="salvage" and h.extra.salvage.visible,"combined wreck reuses the ordinary local recovery action")
  h.open("inspect");await settle()
  check("REQUEST BUFFER" in h.instrument_info.text and "REPLY BUFFER" in h.instrument_info.text and "DEEP CELLS" in h.instrument_info.text,"one wreck context names both packet buffers and its optional kit")
  await capture(label+"-combined-wreck")
  h.open("salvage",{"kind":"salvage","item":"drone_deep_cells","name":"WRECK RECOVERY","pos":sim.wreck_sites[0].pos});await settle();await tap(h.extra.salvage.get_global_rect().get_center())
  check(sim.requests.back()=={"order":"salvage","args":{"item":"drone_deep_cells"}},"one explicit winch command addresses the combined public wreck site")
  game._start_mission(0);game._refresh();await settle();h.open("craft");await settle()
  check(not h.extra.blackwater_handoff.visible and not h.extra.blackwater_data.visible and "BUFFER" not in h.fleet.telemetry[0].text,"delivery affordances disappear outside Blackwater without changing tutorial craft controls")
  game.queue_free();await settle()
 finish()
func finish():
 print("BLACKWATER DELIVERY UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
