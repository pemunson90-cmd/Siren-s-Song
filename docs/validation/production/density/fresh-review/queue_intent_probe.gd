extends SceneTree
var game
var failed=false
func _initialize(): call_deferred("run")
func click(point:Vector2):
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true);await process_frame
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
 await process_frame
func button_click(button): await click(button.get_global_rect().get_center())
func map_click(world): await click(game.ocean.global_position+game.ocean.world_offset+world*game.ocean.world_scale)
func run():
 root.size=Vector2i(2184,1968) if "--probe-inner" in OS.get_cmdline_user_args() else Vector2i(2520,1080);await process_frame;await process_frame
 game=load("res://scenes/main.tscn").instantiate()
 if ResourceLoader.exists("res://tests/density_main.gd"):game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="fresh-review-queue-probe";root.add_child(game);await process_frame;await process_frame
 game._start_mission(0);await process_frame;await process_frame;await process_frame
 await button_click(game.unit_buttons[1]);await map_click(Vector2(600,800));await button_click(game.order_buttons.queue)
 await button_click(game.advanced_button);await button_click(game.order_buttons.camera)
 var before=game.sim.units[1].route.duplicate(true)
 print("FRESH_QUEUE before queued=",game.sim.queue_mode," queue_visible=",game.order_buttons.queue.is_visible_in_tree()," detail=",game.detail_label.text," queue_rect=",game.order_buttons.queue.get_global_rect()," log=",game.sim.message," route=",before)
 await map_click(Vector2(900,800))
 print("FRESH_QUEUE after queued=",game.sim.queue_mode," queue_visible=",game.order_buttons.queue.is_visible_in_tree()," route=",game.sim.units[1].route," log=",game.sim.message)
 print("FRESH_LAYOUT chart=",game.ocean.get_global_rect()," viewport=",game.get_viewport_rect()," queue_text=",game.order_buttons.queue.text)
 game.queue_free();await process_frame;await create_timer(0.5).timeout;quit()
