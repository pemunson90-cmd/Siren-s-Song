extends SceneTree
# THREAT READ through the real Main without a render check: the chart draw runs
# with the shutter reach while framing, lock chips stay off the lock card and
# inside the chart, a drone loss reaches the HUD log line and the chart, and the
# controls page lists the craft loss pause beside the other pause aids.
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/settings_store.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const TR=preload("res://src/presentation/threat_read/threat_read.gd")
const TT=preload("res://src/presentation/threat_read/threat_read_table.gd")
var checks=0
var failures=0
var game
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
func redraw():
	game._refresh();game.ocean.queue_redraw();await settle()
func step(seconds:float):
	game.sim.paused=false
	for n in roundi(seconds*60):game.tactical_aids.advance(Sim.STEP)
	game.sim.paused=true
func beam(quietus_near:bool):
	game._start_mission(2);await settle()
	var s=game.sim;s.mission.rocks=[];s.mission.structures=[];s._build_navigation()
	s.units[2].alive=false
	if quietus_near:s.units[1].alive=false;s.units[0].pos=Vector2(900,840)
	else:s.units[0].pos=Vector2(400,2000);s.units[1].alive=true;s.units[1].pos=Vector2(900,840)
	s.sirens=[s.sirens[0]];var e=s.sirens[0]
	e.pos=Vector2(1060,840);e.home=e.pos;e.goal=e.pos;e.route=[];e.stun=0.;e.lock=0.;e.target=-1
	s.contacts={};s.known={}
	# The fixture removes craft by hand; prime the loss observer after that.
	TR.reset();TR.observe(s)
	game.ocean.sim=s;game.ocean.focus_craft()
	await redraw()
	return s
func run():
	root.size=Vector2i(1280,720);await process_frame;await process_frame
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test";root.add_child(game)
	# A fresh file name per run; nothing is removed afterwards (no-deletion rule).
	game.store.path="user://threat-read-ui-%d.save"%Time.get_ticks_usec()
	await settle()
	game.hints_seen=["move","pause","drone","sweep","noise"]
	Settings.apply(Store.sanitize({}))
	# 1 / Framing a photograph draws the panel's shutter reach.
	game._start_mission(0);await settle()
	var s=game.sim;s.sirens=[];s.units[1].alive=false;s.units[2].alive=false
	var spire=Vector2(1300,300);var facing=2.74
	s.units[0].pos=spire+Vector2.from_angle(facing+PI)*150;s.units[0].angle=facing;s.units[0].vel=Vector2.ZERO
	game.ocean.sim=s;game.ocean._process(0.0);await redraw()
	var reach=TR.shutter_reach(s)
	check(not reach.is_empty() and is_equal_approx(float(TR.last_draw.reach),float(reach.radius)),"the chart draw ran with the panel's shutter reach (%.0f)"%float(TR.last_draw.reach))
	# 2 / Quietus lock: a chip beside the craft, never over the lock card.
	s=await beam(true)
	step(1.5);await redraw()
	var card=game.lock_warning
	check(card.visible and not TR.lock_rows(s).is_empty(),"a Quietus lock shows the card and has a countdown row")
	var chips=TR.last_draw.chips
	check(chips.size()==1 and chips[0].text==TR.lock_rows(s)[0].text,"one lock chip is drawn beside Quietus: %s"%str(chips))
	var chart=Rect2(Vector2.ZERO,game.ocean.size)
	for chip in chips:
		check(not chip.rect.intersects(card.banner),"the lock chip does not cover the lock card")
		check(chart.encloses(chip.rect) and chip.rect.position.y>=game.ocean.instrument_top,"the lock chip stays inside the chart below the instruments")
	# 3 / Drone loss: chart mark and HUD log line.
	s=await beam(false)
	for n in 60*7:
		s.paused=false;game.tactical_aids.advance(Sim.STEP)
		if not s.units[1].alive:break
	s.paused=true;await redraw()
	check(not s.units[1].alive,"the real beam destroys drone A under Main")
	check(game.log_label.text.contains("DRONE A LOST · SIREN BEAM FROM"),"the HUD log line names cause and bearing: %s"%game.log_label.text)
	check(int(TR.last_draw.losses)==1,"the wreck mark and bearing ray are drawn")
	check(TR.last_draw.chips.any(func(c):return str(c.text).begins_with("DRONE A LOST")),"the loss label is placed on the chart")
	# 4 / Settings: the toggle sits with the other pause aids.
	Settings.apply(Store.sanitize({}))
	game._settings_menu();await settle()
	var tab=find_action("settings_page_controls")
	if tab!=null:tab.pressed.emit();await settle()
	var notice=find_action("setting_auto_pause_lock");var loss=find_action("setting_auto_pause_loss")
	check(loss!=null and loss.text=="TACTICAL AID: PAUSE ON CRAFT LOSS: OFF","the controls page lists the craft loss pause, off by default")
	if notice!=null and loss!=null:check(loss.get_index()==notice.get_index()+1 and loss.get_parent()==notice.get_parent(),"the toggle sits right after the lock warning pause")
	if loss!=null:
		loss.pressed.emit();await settle()
		loss=find_action("setting_auto_pause_loss")
		check(loss!=null and loss.text.ends_with(": ON"),"the toggle switches on")
	game.queue_free();await process_frame
	TR.reset();Settings.apply(Store.sanitize({}))
	print("THREAT READ UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func find_action(id:String):
	for control in root.find_children("*","BaseButton",true,false):
		if control.is_visible_in_tree() and control.get_meta("action",control.get_meta("ui_action",""))==id:return control
	return null
