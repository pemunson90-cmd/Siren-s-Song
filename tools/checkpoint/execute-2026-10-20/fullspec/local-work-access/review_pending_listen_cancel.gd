extends SceneTree
var g
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func advance(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):s.advance(1./60.)
 s.paused=true
func touch(p,down,cancel=false):
 var e=InputEventScreenTouch.new();e.index=0;e.position=p;e.pressed=down;e.canceled=cancel;root.push_input(e,true)
func mouse(p,down):
 var e=InputEventMouseButton.new();e.device=InputEvent.DEVICE_ID_EMULATION;e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true)
func run():
 root.size=Vector2i(2520,1080);await settle()
 g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="review-pending-listen";g.fixture_safe_area=Rect2(136,0,2384,1080);root.add_child(g);await settle();g.set_process(false)
 g.completed=[0,1,2,3,4,5];g.unlocked=5;g.expedition={"version":2,"route":"shelf","routes":["shelf"],"facts":{"shelf":"Recovered branch","confluence_route":"overt"},"completed":[6,8,10,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"shelf"}
 g._start_mission(13);var s=g.sim;s.sirens=[];s.units[0].pos=Vector2(1840,1080);s.units[0].vel=Vector2.ZERO;s.command("camera");advance(s,6.2)
 s.units[0].pos=Vector2(1840,380);s.units[0].vel=Vector2.ZERO;advance(s,.8);g.ocean.focus_craft();g._refresh();g.mission_hud.open("object",{"kind":"objective","subkind":"warning_gate","name":"SERVICE GATE","pos":Vector2(1840,380)});await settle()
 var button=g.order_buttons.camera;var p=button.get_global_rect().get_center();var before=s.snapshot()
 print("BEFORE enabled=",not button.disabled," label=",button.text," informed=",s.warning_recipient_status().informed," captures=",s.captures)
 touch(p,true);mouse(p,true);await process_frame;touch(p,false,true);mouse(p,false);await settle()
 print("AFTER_CANCEL same_snapshot=",s.snapshot()==before," captures=",s.captures," page=",g.mission_hud.page," popup=",g.advanced_orders)
 g.queue_free();await settle();quit()
