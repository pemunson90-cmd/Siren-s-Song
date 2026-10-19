extends SceneTree
const Fixtures=preload("res://tests/archive_recap_fixtures.gd")
var folder=""
var checks=0
var failures=0
func _initialize():call_deferred("run")
func settle():
	for n in 16:await process_frame
func still(game,name):
	await settle();await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func click(point):
	var down=InputEventMouseButton.new();down.position=point;down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true
	root.push_input(down,true);await process_frame
	var up=InputEventMouseButton.new();up.position=point;up.button_index=MOUSE_BUTTON_LEFT;up.pressed=false
	root.push_input(up,true);await settle()
func run():
	folder=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(folder)
	for profile in [{"name":"cover","size":Vector2i(2520,1080)},{"name":"inner","size":Vector2i(2184,1968)}]:
		root.size=profile.size;await settle()
		for full in [false,true]:
			var name="fixture-"+("full" if full else "minimal")+"-"+profile.name
			var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.fixture_safe_area=Rect2(136,0,2384,1080) if profile.name=="cover" else Rect2(0,0,2184,1968);game.capture_scenario="synthetic-archive-final-debrief";root.add_child(game);await settle()
			Fixtures.apply(game,full);game._debrief();await settle();game.scroll.scroll_vertical=0
			await still(game,name+"-top");var top=game._ui_metrics()
			game.scroll.scroll_vertical=100000;await still(game,name+"-bottom");var bottom=game._ui_metrics()
			var operations=game.panel_box.get_children().filter(func(c):return c is Button and c.get_meta("action","")=="back")[0]
			var rect=operations.get_global_rect();var visible=game.scroll.get_global_rect().encloses(rect) and game.get_viewport_rect().encloses(rect)
			var archive=var_to_bytes(game.recovered_evidence)
			var labels=game.panel_box.get_children().filter(func(c):return c is Label).map(func(c):return c.text)
			await click(rect.get_center());checks+=1;var ok=visible and game.screen=="menu" and archive==var_to_bytes(game.recovered_evidence)
			if not ok:failures+=1
			print("POINTER ",name," reachable=",visible," operations=",game.screen," archive_unchanged=",archive==var_to_bytes(game.recovered_evidence)," result=",ok)
			FileAccess.open(folder.path_join(name+".json"),FileAccess.WRITE).store_string(JSON.stringify({"fixture":"synthetic final-success UI, not earned campaign/native evidence; current finale keys minimal or all9 keys full","full":full,"labels":labels,"top":top,"bottom":bottom,"operations_reachable":visible,"pointer_opened_operations":game.screen=="menu","archive_unchanged":archive==var_to_bytes(game.recovered_evidence)},"\t"))
			game.queue_free();await settle()
	print("ARCHIVE RECAP POINTER CHECKS ",checks," FAILURES ",failures);await create_timer(.5).timeout;quit(1 if failures else 0)
