extends SceneTree
var game
func _initialize():call_deferred("probe")
func settle():
 for n in 6:await process_frame
func touch(p:Vector2,down:bool,cancel:bool=false):
 var e=InputEventScreenTouch.new();e.index=0;e.position=p;e.pressed=down;e.canceled=cancel;root.push_input(e,true)
func mouse(p:Vector2,down:bool):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true)
func probe():
 root.size=Vector2i(2520,1080);await settle()
 game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="review-shelf-cancel";game.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(game);await settle();game.set_process(false)
 game._start_mission(8);var s=game.sim;s.sirens=[];s.units[0].pos=Vector2(1120,1520);s.units[0].vel=Vector2.ZERO;s.paused=true;game._refresh()
 game.mission_hud.open("habitat",{"kind":"habitat","site":"alarm","name":"COMMUNAL RESONATOR","pos":Vector2(1120,1480)});await settle()
 var button=game.mission_hud.extra.shelf_alarm;var p=button.get_global_rect().get_center();var before=s.snapshot()
 print("BEFORE ready=",not button.disabled," used=",s.mission.shelf_habitat.alarm_used)
 touch(p,true);mouse(p,true);await process_frame
 touch(p,false,true);mouse(p,false);await settle()
 print("AFTER_CANCEL used=",s.mission.shelf_habitat.alarm_used," same_snapshot=",s.snapshot()==before," advanced=",game.advanced_orders," page=",game.mission_hud.page)
 game.queue_free();await settle();quit()
