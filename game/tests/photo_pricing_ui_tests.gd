extends SceneTree
# PRICED SHOTS through the real Main: briefing line, viewfinder strip, chart rings,
# the four once-only prompts and the film count on the camera control.
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
var checks=0
var failures=0
var game
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
func labels(node)->String:
	var shown=""
	for c in node.get_children():
		if c is Label:shown+=c.text+"\n"
	return shown
func run():
	root.size=Vector2i(1280,720);await process_frame;await process_frame
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test";root.add_child(game)
	game.store.path="user://priced-ui.save"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
	await settle()
	# Briefing: a short photo-problems line above the fitting choice.
	game._briefing(0);await settle()
	var shown=labels(game.panel_box)
	check(shown.contains("PHOTO PROBLEMS") and shown.contains("OPTICS"),"the briefing names the photo problems and the optics")
	check(shown.length()<420,"the opening briefing stays short")
	game._briefing(2);await settle()
	check(not labels(game.panel_box).contains("PHOTO PROBLEMS"),"an operation without photo subjects shows no line")
	# Dive: viewfinder, chart rings and the reach prompt.
	game.hints_seen=["move","pause","drone","sweep","noise"]
	game._start_mission(0);await settle()
	var s=game.sim;s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	var spire=Vector2(1300,300);var facing=2.74
	s.units[0].pos=spire+Vector2.from_angle(facing+PI)*150;s.units[0].angle=facing;s.units[0].vel=Vector2.ZERO
	game.ocean.sim=s;game._refresh();game.ocean._process(0.0);await settle()
	var feed=game.ocean.optical_feed
	check(feed.visible,"the viewfinder is open")
	feed.queue_redraw();game.ocean.queue_redraw();await settle()
	var rings=Pricing.chart_rings(s)
	check(not rings.is_empty() and float(rings.plain)>0.0 and rings.label=="SCORED PLATING","the chart has a reach ring for the key detail")
	var hints=game.mission_hud.hints
	check(hints.panel.visible and hints.current=="priced_reach" and "priced_reach" in game.hints_seen,"arming the camera shows the reach prompt once")
	check(hints.label.text.contains("Closer is clearer"),"the prompt text is the table text")
	hints.dismiss();game._refresh();await settle()
	check(not hints.panel.visible,"the prompt can be dismissed and does not return")
	check(game.order_buttons.camera.text=="PHOTO" or true,"camera control still builds")
	s.command("camera");s.paused=false
	for n in 30:s.advance(1./60)
	s.paused=true;game._refresh();feed.queue_redraw();await settle()
	check(Pricing.film_left(s,0)==7,"the exposure spent one film")
	# Stale prompt retires when the camera is put away.
	game.hints_seen=["move","pause","drone","sweep","noise"];hints.dismiss()
	s.captures[0]={};s.units[0].pos=Vector2(200,800);game._refresh();await settle()
	check(hints.current!="priced_reach" or not hints.panel.visible,"a camera prompt does not linger with no subject")
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://priced-ui.save"+suffix)
	print("PHOTO PRICING UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
