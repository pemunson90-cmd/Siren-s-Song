extends SceneTree
# Actual model + injected touch, with explicit own-position/threat fixtures.
# Sampling, navigation, transfer and winch run through real commands/physics.
var checks=0
var failures=0
var folder=""
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func settle():
 for n in 6:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
 await settle()
func advance(game,seconds:float):
 game.sim.paused=false
 for n in roundi(seconds*60):game.sim.advance(1./60.)
 game.sim.paused=true;game._process(0);await settle()
func craft(game,unit:int):
 game.mission_hud.dismiss();await settle()
 if game.sim.selected!=unit or game.ocean.chart_camera.mode!="follow":await tap(game.mission_hud.fleet.buttons[unit].get_global_rect().get_center())
 if not game.advanced_orders:await tap(game.mission_hud.fleet.buttons[unit].get_global_rect().get_center())
 if game.mission_hud.page=="fleet":await tap(game.unit_buttons[unit].get_global_rect().get_center())
func sample(game,unit:int,index:int):
 game.sim.units[unit].pos=game.sim.mission.objectives[index].pos+Vector2(0,130);game.sim.units[unit].vel=Vector2.ZERO;game._refresh();await settle()
 await craft(game,unit);check(not game.order_buttons.camera.disabled,"actual local SAMPLE is available for receiver/resample")
 await tap(game.order_buttons.camera.get_global_rect().get_center());await advance(game,2.1)
func route_home(game,unit:int):
 await craft(game,unit);await tap(game.order_buttons.program.get_global_rect().get_center())
 var editor=game.route_editor;var goal=game.sim.units[0].pos+Vector2(0,-25 if unit==1 else 25)
 await tap(editor.preview.global_position+editor.preview.screen_position(goal))
 var done=editor.find_children("*","Button",true,false).filter(func(b):return b.get_meta("action","")=="close")[0]
 await tap(done.get_global_rect().get_center())
 game.sim.paused=false
 for n in 3600:
  game.sim.advance(1./60.)
  if game.sim.units[unit].route.is_empty() and game.sim.units[unit].vel.length()<2.:break
 game.sim.paused=true;game._process(0);await settle()
 check(game.sim.units[unit].pos.distance_to(goal)<10. and game.sim.units[unit].vel.length()<2.,"carrier physically follows its actual STOP route to a settled Quietus rendezvous")
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="blackwater-delivery-runtime-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game.completed=[0,1];game.unlocked=2;game._start_mission(2);await settle()
  var sim=game.sim;sim.sirens=[];var h=game.mission_hud;var label="cover" if dimensions.x==2520 else "inner"
  await sample(game,1,0);await sample(game,2,1)
  check(game.screen=="mission" and sim.outcome.is_empty() and sim.blackwater_delivery_status().cargo==[[],[0],[1]],"two real distant drone samples preserve the active return instead of winning at home Quietus")
  check(not sim.departure_context().available and "Q ABOARD 0/2" in h.intent.text,"missing exchange data never opens module abandonment or pretends physical delivery")
  await capture(label+"-buffers-return-needed")
  await route_home(game,1);await craft(game,1);check(not h.extra.blackwater_handoff.disabled,"physical local carrier return enables its own transfer")
  await tap(h.extra.blackwater_handoff.get_global_rect().get_center())
  check(sim.blackwater_delivery_status().cargo[0]==[0] and sim.outcome.is_empty() and game.screen=="mission","first real local touch transfers only REQUEST and retains the remaining return")
  await route_home(game,2);await craft(game,2);await tap(h.extra.blackwater_handoff.get_global_rect().get_center())
  check(sim.blackwater_delivery_status().complete and sim.outcome.is_empty(),"second local transfer completes cargo while tactical pause still defers recovery physics")
  await advance(game,1./60.)
  check(game.screen=="debrief" and sim.outcome=="won" and game.panel_box.find_children("*","Label",true,false).any(func(l):return "DELIVERED 2/2" in l.text),"normal recovery after actual carrier return shows only the exchange aboard Quietus")
  # Kit + data loss uses a single genuine own-wreck winch.
  game.completed=[0,1,2,3,4,5];game.unlocked=5;game.fitted_equipment.drone_a="drone_deep_cells";game._start_mission(2);await settle();sim=game.sim;sim.sirens=[]
  await sample(game,1,0);var wreck=sim.units[1].pos;sim.units[1].battery=0;await advance(game,1./60.)
  var sites=sim.salvage_sites();check(sites.size()==1 and sites[0].packets==[0] and sites[0].item=="drone_deep_cells","real loss creates one combined kit and REQUEST buffer wreck")
  sim.units[0].pos=wreck+Vector2(0,40);sim.units[0].vel=Vector2.ZERO;sim.command("select",{"unit":0});game.ocean.focus_craft();game._refresh();await settle()
  var marker=game.ocean.salvage_markers()[0]
  check(marker.lines.has("REQUEST BUFFER") and marker.lines.has("DEEP CELLS"),"single visible wreck names both actual recoverable contents")
  await tap(game.ocean.global_position+marker.rect.get_center());await tap(h.extra.salvage.get_global_rect().get_center());await advance(game,2.)
  check(sim.module_recovery_status().jobs[0].get("elapsed",0.)>=1.9,"one touch starts the actual shared four-second kit and buffer winch")
  check("RAW DATA" in h.fleet.telemetry[0].text and "REQUEST" in h.fleet.telemetry[0].text,"combined winch identifies its needed packet as well as the recoverable kit during work")
  await craft(game,0);check(game.order_buttons.camera.disabled,"active winch blocks overlapping SAMPLE through public readiness")
  h.dismiss();await settle()
  var plates=h.fleet.readouts.map(func(reading):return reading.rect)
  check(h.fleet.readouts.all(func(reading):return not reading.detail_visible or reading.rect.encloses(h.fleet.telemetry[reading.unit].get_rect())),"combined task reservation encloses each actually visible exact readout")
  check(game.ocean.salvage_markers().all(func(site):return not plates.any(func(plate):return plate.intersects(site.rect))),"combined data badge avoids every full expanded task readout while only actual station handles block water input")
  print("COMBINED_PLATE_BOUNDS ",label," reserved=",h.fleet.readouts.filter(func(reading):return reading.unit==0)[0].rect," actual=",h.fleet.telemetry[0].get_rect()," minimum=",h.fleet.telemetry[0].get_combined_minimum_size()," marker=",game.ocean.salvage_markers()[0].rect)
  await capture(label+"-combined-winch")
  await advance(game,2.2)
  check(sim.blackwater_delivery_status().packets[0].aboard and sim.module_recovery_status().cargo[0]==["drone_deep_cells"] and sim.salvage_sites().is_empty(),"one completed real winch puts raw data aboard and keeps recovered kit inactive")
  check("REQUEST" in h.fleet.telemetry[0].text and "INACTIVE CARGO" in h.fleet.telemetry[0].text,"same readable craft plate distinguishes actual aboard packet from inactive hardware")
  var card=h.fleet.telemetry[0];var available=card.size.x-card.get_theme_stylebox("normal").get_minimum_size().x
  check(Array(card.text.split("\n")).all(func(line):return card.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,card.get_theme_font_size("font_size")).x<=available) and game.get_global_rect().encloses(card.get_global_rect()),"simultaneous data and inactive kit remain fully readable on each screen shape")
  await capture(label+"-combined-cargo")
  # Loss also remains recoverable by the original fixed-relay SAMPLE fallback.
  game.fitted_equipment.drone_a="";game._start_mission(2);await settle();sim=game.sim;sim.sirens=[]
  await sample(game,1,0);sim.units[1].battery=0;await advance(game,1./60.)
  check(sim.blackwater_delivery_status().packets[0].recorded and not sim.blackwater_delivery_status().packets[0].aboard,"lost raw buffer retains the actual field note without delivery")
  await sample(game,0,0)
  check(sim.blackwater_delivery_status().packets[0].aboard and sim.salvage_sites().is_empty(),"Quietus actual resample recovers needed data without a compulsory wreck retrieval")
  # Explicit own-position fixture isolates the existing module departure choice
  # from missing/complete raw data; physical carrier travel is checked above.
  game.fitted_equipment.drone_b="drone_deep_cells";game._start_mission(2);await settle();sim=game.sim;sim.sirens=[]
  await sample(game,1,0);await sample(game,0,1)
  sim.units[0].pos=sim.mission.extraction;sim.units[0].vel=Vector2.ZERO;sim.units[1].pos=sim.units[0].pos+Vector2(40,0);sim.units[1].vel=Vector2.ZERO;sim.units[2].pos=sim.units[0].pos+Vector2(300,0);sim.units[2].vel=Vector2.ZERO
  await advance(game,1./60.)
  check(game.screen=="mission" and not sim.departure_context().available,"remote REQUEST prevents a missing-kit departure choice even with both field notes and Quietus at recovery")
  await craft(game,1);await tap(h.extra.blackwater_handoff.get_global_rect().get_center());await advance(game,1./60.)
  check(game.screen=="departure" and sim.blackwater_delivery_status().complete and sim.departure_context().left.size()==1,"delivered data restores the existing outstanding module decision without auto-abandonment")
  check(game.panel_box.find_children("*","Button",true,false).any(func(b):return b.get_meta("action","")=="return_module_2") and game.panel_box.find_children("*","Label",true,false).any(func(l):return "DRONE DEEP CELLS" in l.text),"delivery and module return coexist in one actionable recovery decision")
  await capture(label+"-delivered-module-decision")
  game.queue_free();await settle()
 print("BLACKWATER DELIVERY RUNTIME UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
