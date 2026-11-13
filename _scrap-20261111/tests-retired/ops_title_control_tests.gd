extends SceneTree
# WP-14: the campaign Operations panel has a TITLE control at the top, on both Fold shapes.
const OpsTable=preload("res://src/presentation/ops_home/ops_home_table.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func button(node,id):
	for b in node.find_children("*","Button",true,false):
		if b.get_meta("ui_action",b.get_meta("action",""))==id and b.is_visible_in_tree():return b
	return null
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
	print("OPS TITLE CONTROL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func open_panel(shape):
	root.size=shape;await settle()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.capture_scenario="runtime-test"
	game.store.path="user://wp14-ops-%d.save"%Time.get_ticks_usec()
	game.settings_path="user://wp14-ops-%d-settings.json"%Time.get_ticks_usec()
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game.completed=[0];game.unlocked=1
	game._show_campaign();game._layout();await settle()
	game.scroll.scroll_vertical=0;await settle()
	return game
func state(game):
	var front=game.get_node_or_null("Frontend")
	return [game.screen,front.screen if front!=null else ""]
func shape_case(shape:Vector2i):
	var tag="%dx%d"%[shape.x,shape.y]
	var game=await open_panel(shape)
	check(game.screen=="menu","setup: Operations panel shown "+tag)
	var top=button(game,"ops_title")
	check(top!=null and OpsTable.TOP_TITLE,"top TITLE control exists "+tag)
	if top!=null:
		check(top.text=="TITLE","top control is labelled TITLE "+tag)
		check(game.scroll.get_global_rect().grow(1.).encloses(top.get_global_rect()),"top TITLE is on screen without scrolling "+tag)
		var dp=float(root.size.x)/root.get_visible_rect().size.x*160./420.
		check(top.size.y*dp>=48. and top.size.x*dp>=48.,"top TITLE is at least 48 dp "+tag)
		var rect=top.get_global_rect()
		for b in game.find_children("*","Button",true,false):
			if b!=top and b.is_visible_in_tree():check(not rect.intersects(b.get_global_rect()),"top TITLE overlaps no button (%s) %s"%[b.text,tag])
	# The existing bottom-row TITLE and the top control reach the same state.
	var bottom=button(game,"menu_title")
	check(bottom!=null,"bottom-row TITLE is kept "+tag)
	var expected=[]
	if bottom!=null:
		bottom.pressed.emit();await settle();expected=state(game)
	check(expected==["menu","title"],"bottom TITLE reaches the title screen "+tag)
	game.queue_free();await settle()
	game=await open_panel(shape)
	top=button(game,"ops_title")
	if top!=null:
		top.pressed.emit();await settle()
		check(state(game)==expected,"top TITLE reaches the same title state as the bottom row "+tag)
	game.queue_free();await settle()
