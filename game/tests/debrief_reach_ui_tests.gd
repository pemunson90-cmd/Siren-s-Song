extends SceneTree
# WP-11 (cold review 6, I6): primary buttons are reachable without scrolling.
# (a) A loss debrief shows RETRY and OPERATIONS ARCHIVE on its first screen, on
# the opening path (op 0) and the later-campaign path (op 15, Needle Strait).
# (b) The Expedition pre-dive page pins BEGIN and RETURN in the footer, and each
# grey LOAD names its reason.
const RunState=preload("res://src/campaign/runs/run_state.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		for id in [0,15]:await loss_case(shape,id)
		await expedition_case(shape)
	print("DEBRIEF REACH UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func lose(game):
	var s=game.sim
	s.mission.rocks=[];s.mission.structures=[];s._build_navigation();s._configure_terrain();s._configure_depth_charts()
	var e=s.sirens[0].duplicate(true);e.pos=s.units[0].pos+Vector2(300,0);e.home=e.pos;e.goal=e.pos;e.route=[];e.patrol_points=[];e.stun=0.;e.band=s.units[0].band;e.transition={}
	s.sirens=[e];s.units[0].silent=false;s.paused=false;s.command("ping")
	for i in 3000:
		s.advance(0.1)
		if not s.outcome.is_empty():break
	# Some sites hold Sirens that do not strike here; the layout under test only needs a loss.
	if s.outcome.is_empty():s.hull=0.0;s.outcome="lost";s.message="Quietus hull failed."
func loss_case(shape:Vector2i,id:int):
	var tag="%dx%d op %d"%[shape.x,shape.y,id]
	root.size=shape;await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
	game.store.path="user://wp11-debrief-%d.save"%Time.get_ticks_usec()
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game._start_mission(id);await settle()
	await lose(game)
	check(game.sim.outcome=="lost","setup: scripted loss "+tag)
	game._debrief();game._layout();await settle()
	game.scroll.scroll_vertical=0;await settle()
	var view=game.scroll.get_global_rect().grow(1.)
	var found={}
	for b in game.panel_box.find_children("*","Button",true,false):
		if str(b.get_meta("action","")) in ["retry","back"]:found[b.get_meta("action")]=b
	check(found.size()==2,"setup: RETRY and OPERATIONS ARCHIVE exist "+tag)
	for key in found:
		check(found[key].is_visible_in_tree() and view.encloses(found[key].get_global_rect()),"%s is on the first screen without scrolling %s"%[found[key].text,tag])
	var labels=game.panel_box.get_children().filter(func(c):return c is Label)
	check(not labels.is_empty() and labels[0].get_index()<found.get("retry",labels[0]).get_index(),"the loss heading stays above the actions "+tag)
	game.queue_free();await settle()
func expedition_case(shape:Vector2i):
	var tag="expedition %dx%d"%[shape.x,shape.y]
	root.size=shape;await settle()
	var host=load("res://scenes/main.tscn").instantiate();host.set_script(load("res://tests/density_main.gd"))
	host.capture_scenario="runtime-test";host.store.path="user://wp11-exp-%d.save"%Time.get_ticks_usec()
	if shape.x==2520:host.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(host);await settle();host.set_process(false)
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(load("res://src/presentation/runs/expedition_session.gd"))
	session.campaign_host=host;session.run_state=RunState.new_run(1270840417)
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();host.add_child(session);await settle()
	session._layout();await settle();session.scroll.scroll_vertical=0;await settle()
	check(session.screen=="expedition_menu","setup: the Expedition pre-dive page is shown "+tag)
	var buttons=session.find_children("*","Button",true,false)
	var begin=buttons.filter(func(b):return b.get_meta("ui_action",b.get_meta("action",""))=="run_begin")
	var back=buttons.filter(func(b):return b.get_meta("ui_action",b.get_meta("action",""))=="run_return")
	var area=session.get_global_rect().grow(1.)
	check(begin.size()==1 and begin[0].is_visible_in_tree() and area.encloses(begin[0].get_global_rect()) and not session.scroll.is_ancestor_of(begin[0]),"BEGIN is pinned on screen outside the scrolling page "+tag)
	check(back.size()==1 and back[0].is_visible_in_tree() and area.encloses(back[0].get_global_rect()),"RETURN TO MODES is pinned on screen "+tag)
	var loads=buttons.filter(func(b):return b.text.begins_with("LOAD +1"))
	check(not loads.is_empty(),"setup: LOAD buttons exist "+tag)
	var grey=loads.filter(func(b):return b.disabled)
	check(not grey.is_empty(),"setup: some LOAD buttons are grey "+tag)
	for b in grey:check(" / " in b.text and not b.tooltip_text.is_empty(),"grey %s names its reason %s"%[b.text,tag])
	for b in loads.filter(func(b):return not b.disabled):check(not " / " in b.text,"an available %s carries no reason %s"%[b.text,tag])
	var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
	for b in begin+back:check(b.size.y*dp>=48.,"%s keeps a 48 dp target %s"%[b.text,tag])
	host.queue_free();await settle()
