extends SceneTree
var game
func _initialize(): call_deferred("run")
func run():
 Input.set_emulate_touch_from_mouse(true)
 root.size=Vector2i(2520,1080); await process_frame; await process_frame
 game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="scroll-probe";root.add_child(game)
 await process_frame; await process_frame;game.active_started=false;game._show_campaign();await process_frame;await process_frame;await process_frame
 print("SCROLL_CAP touch=",DisplayServer.is_touchscreen_available()," mouse_from_touch=",Input.is_emulating_mouse_from_touch()," area=",game.scroll.get_global_rect())
 var area=game.scroll.get_global_rect();var start=area.position+Vector2(area.size.x*.5,area.size.y*.8)
 var motion=InputEventMouseMotion.new();motion.position=start;motion.global_position=start;root.push_input(motion,true)
 var press=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=start;press.device=InputEvent.DEVICE_ID_EMULATION
 root.push_input(press,true);await process_frame
 var last=start
 for step in 30:
  var next=start-Vector2(0,area.size.y*.55*(step+1)/30.0)
  motion=InputEventMouseMotion.new();motion.position=next;motion.global_position=next;motion.relative=next-last;motion.button_mask=MOUSE_BUTTON_MASK_LEFT;motion.device=InputEvent.DEVICE_ID_EMULATION
  root.push_input(motion,true);last=next;await process_frame
 var release=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;release.position=last;release.device=InputEvent.DEVICE_ID_EMULATION
 root.push_input(release,true)
 await create_timer(1).timeout
 print("SCROLL_PROBE offset=",game.scroll.scroll_vertical," screen=",game.screen," vbar=",game.scroll.get_v_scroll_bar().value)
 game.queue_free();await process_frame;await create_timer(.5).timeout;quit()
