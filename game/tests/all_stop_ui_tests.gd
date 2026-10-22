extends SceneTree
# ALL STOP through the real radial HUD: the ROUTE menu offers it for Quietus, a real
# tap shuts the engines down, the label shows the restart, and a drone is not offered it.
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 7:await process_frame
func touch(point,pressed,index=0):
	var e=InputEventScreenTouch.new();e.position=point;e.index=index;e.pressed=pressed;root.push_input(e,true);await process_frame
func mouse(point,pressed):
	var e=InputEventMouseButton.new();e.position=point;e.button_index=MOUSE_BUTTON_LEFT;e.device=InputEvent.DEVICE_ID_EMULATION;e.pressed=pressed;root.push_input(e,true);await process_frame
func click(button):
	var p=button.get_global_rect().get_center()
	await touch(p,true);await mouse(p,true);await touch(p,false);await mouse(p,false);await settle()
func run():
	root.size=Vector2i(2520,1080);await settle()
	var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://all-stop-ui.save"
	g.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(g);await settle();g.set_process(false);g._start_mission(0);await settle()
	var h=g.mission_hud;var s=g.sim
	check(h.extra.has("all_stop"),"the HUD builds an ALL STOP control")
	h.open("craft",{"kind":"craft","unit":0,"pos":s.units[0].pos});await settle()
	await click(h.extra.route_menu)
	check(h.page=="route" and h.extra.all_stop.visible and h.extra.all_stop.text.begins_with("ALL STOP"),"the ROUTE menu offers ALL STOP with its oxygen price")
	var oxygen:float=s.oxygen
	await click(h.extra.all_stop)
	check(AllStop.stopped(s.units[0]) and s.oxygen<oxygen,"a real tap shuts the engines down and draws oxygen")
	check(h.page=="route" and h.extra.all_stop.text.begins_with("ENGINES"),"the menu stays open and now offers the restart")
	await click(h.extra.all_stop)
	check(AllStop.restarting(s.units[0]) and h.extra.all_stop.text.begins_with("ENGINES") and h.extra.all_stop.text.contains("6"),"a second tap orders the restart and shows the countdown")
	s.selected=1;s.units[1].alive=true;g._refresh();h.open("craft",{"kind":"craft","unit":1,"pos":s.units[1].pos});await settle()
	await click(h.extra.route_menu)
	check(not h.extra.all_stop.visible,"a drone is not offered ALL STOP")
	g.queue_free();await settle()
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://all-stop-ui.save"+suffix)
	print("ALL STOP UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
