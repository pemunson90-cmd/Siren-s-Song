extends SceneTree
# Isolated local recovery fixture exercising the real model, actual touch route,
# and real renderer when requested. This is not an earned campaign journey.
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
func advance(sim,seconds:float):
 sim.paused=false
 for n in roundi(seconds*60):sim.advance(1./60.)
 sim.paused=true
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="physical-module-recovery-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false)
  game.completed=[0,1,2,3,4,5];game.unlocked=5;game.fitted_equipment.drone_a="drone_deep_cells";game._start_mission(6);await settle()
  var sim=game.sim;var label="cover" if dimensions.x==2520 else "inner"
  for enemy in sim.sirens:enemy.stun=100.
  sim.units[1].pos=sim.units[0].pos;sim.units[1].battery=0;advance(sim,1./60.)
  game._refresh();await settle()
  check(sim.salvage_sites().size()==1 and sim.salvage_context("drone_deep_cells").ready,"real fitted-drone loss offers local recoverable hardware")
  await capture(label+"-known-salvage")
  var marker=game.ocean.salvage_markers()[0]
  await tap(game.ocean.global_position+marker.rect.get_center())
  check(game.mission_hud.page=="salvage" and game.mission_hud.extra.salvage.visible,"actual known salvage opens its contextual recovery control")
  await capture(label+"-recovery-context")
  await tap(game.mission_hud.extra.salvage.get_global_rect().get_center())
  check(sim.module_recovery_status().jobs[0].get("item","")=="drone_deep_cells" and sim.noises.any(func(n):return n.label=="RECOVERY WINCH"),"ordinary touch starts real local audible winch work")
  advance(sim,2.);game._refresh();await settle()
  await tap(game.mission_hud.fleet.buttons[2].get_global_rect().get_center())
  check(sim.selected==2 and "RECOVER" in game.mission_hud.fleet.telemetry[0].text and "DEEP CELLS" in game.mission_hud.fleet.telemetry[0].text,"background craft keeps its actual module job visible after another station is selected")
  check(game.mission_hud.fleet.readouts.all(func(reading):return reading.rect.encloses(game.mission_hud.fleet.telemetry[reading.unit].get_rect())),"module-only task reserves the full actual Label bounds")
  var plates=game.mission_hud.fleet.readouts.map(func(reading):return reading.rect)
  check(game.ocean.salvage_markers().all(func(marker):return not plates.any(func(plate):return plate.intersects(marker.rect))),"salvage badges avoid the full visual telemetry plate even though only station handles block chart input")
  await capture(label+"-recovery-progress")
  advance(sim,2.1);game._refresh();await settle()
  check(sim.module_recovery_status().cargo[0]==["drone_deep_cells"] and sim.mission.launch_equipment.quietus.is_empty(),"real completed retrieval carries an inert module without installing it on Quietus")
  var card=game.mission_hud.fleet.telemetry[0]
  check("CARGO" in card.text and "INACTIVE" in card.text and game.get_global_rect().encloses(card.get_global_rect()),"remote carried module remains identifiable inactive and fully on screen")
  check(game.mission_hud.fleet.readouts.all(func(reading):return reading.rect.encloses(game.mission_hud.fleet.telemetry[reading.unit].get_rect())),"module-only inactive cargo reserves the full actual Label bounds")
  var available=card.size.x-card.get_theme_stylebox("normal").get_minimum_size().x
  check(Array(card.text.split("\n")).all(func(line):return card.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,card.get_theme_font_size("font_size")).x<=available),"actual cargo state and complete module identity fit without ellipsis on either screen")
  await capture(label+"-inactive-cargo")
  var before=sim.snapshot();game._refresh();await settle()
  check(sim.snapshot()==before,"paused module presentation does not advance work resources or sensing")
  game.queue_free();await settle()
 print("MODULE RECOVERY RUNTIME UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
