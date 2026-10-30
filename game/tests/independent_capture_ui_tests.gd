extends SceneTree
var checks=0
var failures=0
var game
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 4:await process_frame
func tap(point:Vector2):
 for down in [true,false]:
  var event=InputEventScreenTouch.new();event.index=0;event.position=point;event.pressed=down
  root.push_input(event,true);await process_frame
  # Native buttons receive the platform's emulated mouse delivery as well.
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down
  root.push_input(mouse,true);await process_frame
 await settle()
func choose(id:int):
 if game.advanced_orders:await tap(game.mission_hud.close_button.get_global_rect().get_center())
 await tap(game.advanced_button.get_global_rect().get_center())
 await tap(game.unit_buttons[id].get_global_rect().get_center())
func run():
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="independent-capture-ui"
  game.set_script(preload("res://tests/density_main.gd"));root.add_child(game);await settle();game.set_process(false);game._start_mission(1)
  for pair in [[1,0],[2,1]]:game.sim.units[pair[0]].pos=game.sim.mission.objectives[pair[1]].pos+Vector2(0,100)
  await settle()
  for id in [2,1]:
   await choose(id);await tap(game.order_buttons.camera.get_global_rect().get_center())
   check(game.sim.capture_feedback(id).unit==id,"%s touch commands start craft%d independently"%[dimensions,id])
   if id==2:
    for enemy in game.sim.sirens:enemy.stun=100.0
    game.sim.paused=false
    for n in 60:game.sim.advance(1.0/60)
    game.sim.paused=true;game._refresh();await settle()
  var progress=game.sim.snapshot().captures.duplicate(true)
  check(game.mission_hud.fleet.status(1).contains("PHOTO") and game.mission_hud.fleet.status(2).contains("PHOTO"),"%s fleet reports both cameras working"%dimensions)
  for id in [2,1,0,1]:
   await choose(id)
   # Commands own the screen; inspect the selected feed after returning to water.
   check(game.advanced_orders and not game.ocean.optical_feed.visible,"%s station controls reserve the screen"%dimensions)
   await tap(game.mission_hud.close_button.get_global_rect().get_center())
   check(not game.advanced_orders,"%s real BACK returns to the selected optical station"%dimensions)
   check(game.sim.selected==id,"%s touch switches optical station to craft%d"%[dimensions,id])
   check(game.ocean.optical_feed.visible==(id>0),"%s optical inset follows selected working station%d"%[dimensions,id])
   if id>0:check(game.sim.capture_target==id-1 and game.sim.capture_unit==id and is_equal_approx(game.sim.capture_time,1.0 if id==2 else 0.0),"%s selected feed projects its own record and elapsed time%d"%[dimensions,id-1])
   check(game.sim.snapshot().captures==progress,"%s station switching preserves every exposure"%dimensions)
  game.queue_free();await settle();await create_timer(0.25).timeout
 print("INDEPENDENT CAPTURE UI CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
