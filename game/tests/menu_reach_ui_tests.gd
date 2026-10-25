extends SceneTree
# Focused touch journey for shared title settings and Operations navigation.
const FrontSettings=preload("res://src/presentation/frontend/frontend_settings.gd")
const SettingsStore=preload("res://src/persistence/settings_store.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 6:await process_frame
func frames(count):
	for n in count:await process_frame
func tap(point):
	for down in [true,false]:
		var e=InputEventScreenTouch.new();e.index=0;e.position=point;e.pressed=down;root.push_input(e,true);await process_frame
		var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;root.push_input(mouse,true);await process_frame
	await settle()
func android_back(count=1):
	for n in count:root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await settle()
func escape_key():
	for down in [true,false]:
		var event=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=down;root.push_input(event,true);await process_frame
	await settle()
func button(node,id):
	if node==null:return null
	for b in node.find_children("*","Button",true,false):
		if b.get_meta("ui_action","")==id and b.is_visible_in_tree():return b
	return null
func control(node,id):
	if node==null:return null
	for c in node.find_children("*","Control",true,false):
		if c.get_meta("ui_action","")==id and c.is_visible_in_tree():return c
	return null
func press(node,id):
	var b=button(node,id)
	check(b!=null,"visible action "+id)
	if b==null:return false
	var parent=b.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(b);await settle()
	await tap(b.get_global_rect().get_center());return true
func slide(node,id,value):
	var s=control(node,id)
	check(s!=null,"visible slider "+id)
	if s==null:return false
	var parent=s.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(s);await settle()
	var rect=s.get_global_rect();await tap(Vector2(lerpf(rect.position.x,rect.end.x,value),rect.get_center().y));return true
func clean(path):
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(path+suffix)
func capture(label):
	var dir=OS.get_environment("SIRENS_044_CAPTURE_DIR")
	if dir.is_empty() or DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(dir+"/%s-%dx%d.png"%[label,root.size.x,root.size.y])==OK,"native shared view captured "+label)
func shape_case(shape):
	root.size=shape;await settle()
	var stem="user://menu-reach-%d-%d"%[shape.x,shape.y]
	var archive=stem+".save";var settings_path=stem+"-settings.json"
	clean(archive);clean(settings_path);clean(archive+".challenges")
	var game=load("res://scenes/main.tscn").instantiate()
	if shape.x!=960:game.set_script(load("res://tests/density_main.gd"))
	game.store.path=archive;game.settings_path=settings_path
	game.capture_scenario="runtime-test"
	if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
	root.add_child(game);await settle();game.set_process(false)
	game.completed=[0];game.unlocked=1;game._start_mission(1);game.sim.oxygen=57.0;game.sim.hull=93.0
	game._show_campaign();game.capture_scenario="";game._save_archive();game._boot_frontend();await settle()
	var front=game.get_node_or_null("Frontend")
	check(front!=null,"title frontend is present over a seeded profile at "+str(shape))
	if front==null:game.queue_free();await settle();return
	var initial_snapshot=game.sim.snapshot();var initial_profile=game.store.load_game()
	var expected_profile=initial_profile.duplicate(true)
	if await press(front,"frontend_continue"):await settle()
	check(game.screen=="menu","title entry reaches Operations "+str(shape))
	check(game.sim.snapshot()==initial_snapshot,"entering Operations leaves the active dive snapshot alone")
	var settings_action=button(game,"settings")
	check(settings_action!=null,"Operations exposes shared Settings action")
	check(button(game,"new_campaign")==null,"campaign erase is not exposed on Operations")
	if await press(game,"settings"):
		check(game.screen=="settings","Operations opens the shared settings screen")
		var scale=button(game,"text_scale_115")
		check(scale!=null,"shared settings exposes 115 percent text size")
		if scale!=null:
			var rect=scale.get_global_rect()
			check(rect.size.y>=game.ui_touch_height-1,"115 percent control meets the density touch target")
			var par=scale.get_parent()
			while par!=null and not par is ScrollContainer:par=par.get_parent()
			if par!=null:par.ensure_control_visible(scale);await settle()
			await tap(scale.get_global_rect().get_center())
		check(is_equal_approx(FrontSettings.text_scale(),1.15),"115 percent takes effect from Operations settings")
		await capture("settings115")
		for id in ["volume_master","volume_music","volume_effects"]:
			var slider=control(game,id)
			check(slider!=null,"shared settings exposes "+id)
			if slider!=null:check(slider.get_global_rect().size.y>=game.ui_touch_height-1,"slider meets density touch target: "+id)
		if await slide(game,"volume_master",0.7):
			check(absf(AudioServer.get_bus_volume_db(0)-FrontSettings.master_db(0.7))<1.0,"master slider changes the active audio bus")
		if await slide(game,"volume_music",0.55):
			check(absf(float(game.settings.get("music",-1))-0.55)<=0.06,"music slider changes shared sound setting")
		if await slide(game,"volume_effects",0.4):
			check(absf(float(game.settings.get("effects",-1))-0.4)<=0.06,"effects slider changes shared sound setting")
		await press(game,"mute")
		check(AudioServer.is_bus_mute(0) and game.sound.muted and FrontSettings.current.master==0.,"Mute uses the shared master value and active sound bus")
		await press(game,"mute")
		check(not AudioServer.is_bus_mute(0) and not game.sound.muted and FrontSettings.current.master>0.,"Unmute restores the same shared master source")
		for key in ["high_contrast","reduced_motion","haptics","safe_palette","audio_captions"]:
			var action="setting_"+key;var before=FrontSettings.current.get(key,false)
			if await press(game,action):check(FrontSettings.current.get(key,false)!=before,"accessibility setting toggle takes effect: "+key)
		# Exercise the large text layout, then restore the requested persisted scale.
		if await press(game,"text_scale_150"):
			check(is_equal_approx(FrontSettings.text_scale(),1.5),"150 percent text size takes effect")
			await capture("settings150")
			var large=button(game,"text_scale_115")
			if large!=null:check(large.get_global_rect().size.y>=game.ui_touch_height-1,"large text preserves touch target")
			await press(game,"text_scale_115")
		await frames(30)
		await android_back()
		check(game.screen=="menu","Android Back returns from Settings to Operations")
		await settle()
		var saved=SettingsStore.new();saved.path=settings_path;var values=saved.load_settings()
		check(is_equal_approx(float(values.get("text_scale",0)),1.15),"115 percent persists through Back")
		check(absf(float(values.get("effects",-1))-0.4)<=0.06,"effects volume persists through Back")
		check(absf(float(values.get("music",-1))-0.55)<=0.06,"music volume persists through Back")
		# Android Back already saves existing legacy audio mirrors in campaign settings.
		# Compare every other archive field exactly, and require those mirrors match
		# the selected values rather than incorrectly expecting the old audio values.
		expected_profile.settings=game.settings.duplicate(true)
		await press(game,"settings")
		var erase=button(game,"new_campaign")
		check(erase!=null,"existing campaign erase action is available only in Settings")
		if erase!=null and await press(game,"new_campaign"):
			check(game.screen=="new_campaign","Settings erase action opens the existing confirmation")
			if await press(game,"back"):
				check(game.screen=="menu" and game.store.load_game()==expected_profile,"cancel keeps campaign progress and the chosen audio settings")
	# Title navigation offers the original frontend screens; their Back destination is Operations.
	if await press(game,"menu_title"):
		front=game.get_node_or_null("Frontend")
		check(front!=null,"Title route attaches its frontend overlay")
		if front==null:game.queue_free();await settle();return
		check(front.screen=="title","Title action opens original title overlay")
		if await press(front,"frontend_settings"):
			check(front.screen=="settings","title settings is the same original shared interface")
			var selected=button(front,"text_scale_115")
			check(selected!=null and selected.button_pressed,"115 percent stays selected on title settings")
			await press(front,"text_scale_130");await press(front,"text_scale_115")
			await press(front,"frontend_back")
			check(front.screen=="title","settings Back returns to title overlay")
		await press(front,"frontend_continue")
		check(game.screen=="menu" and game.get_node_or_null("Frontend")==null,"title Continue returns to Operations")
		if await press(game,"settings"):
			var roundtrip=button(game,"text_scale_115")
			check(roundtrip!=null and roundtrip.button_pressed,"title 115 percent remains selected in Operations settings")
			await android_back()
	for route in [["menu_challenges","challenges"],["menu_credits","credits"]]:
		if await press(game,route[0]):
			front=game.get_node_or_null("Frontend")
			check(front!=null,"route attaches frontend for "+route[1])
			if front==null:continue
			check(front.screen==route[1],route[1]+" action opens original overlay")
			await capture(route[1])
			if route[1]=="challenges":
				await press(front,"challenge_shelf_passive")
				check(front.screen=="challenge_details","direct challenge entry retains detail navigation")
				await android_back();check(front.screen=="challenges","detail Back returns to direct challenge list first")
			await press(front,"frontend_back")
			check(game.screen=="menu" and game.get_node_or_null("Frontend")==null,route[1]+" Back restores unobscured Operations")
	check(game.sim.snapshot()==initial_snapshot,"menu navigation does not advance or replace dive state")
	var current_profile=game.store.load_game()
	if current_profile!=expected_profile:
		for key in current_profile:
			if current_profile[key]!=expected_profile.get(key):print("MENU_REACH_ARCHIVE_DIFF ",key," before=",expected_profile.get(key)," after=",current_profile[key])
	check(current_profile==expected_profile,"menu navigation preserves every campaign field except deliberately selected audio values")
	await press(game,"menu_title");await android_back()
	check(game.screen=="menu" and game.get_node_or_null("Frontend")==null,"Android Back from direct Title restores unobscured Operations")
	await press(game,"menu_credits");await escape_key()
	check(game.screen=="menu" and game.get_node_or_null("Frontend")==null,"Escape from direct Credits restores unobscured Operations")
	for b in game.find_children("*","Button",true,false):
		if b.is_visible_in_tree() and b.get_meta("ui_action","") in ["settings","menu_title","menu_challenges","menu_credits"]:
			check(b.get_global_rect().size.y>=game.ui_touch_height-1,"Operations control meets host density touch target: "+str(b.get_meta("ui_action")))
	game.queue_free();await settle();clean(archive);clean(settings_path);clean(archive+".challenges")
func run():
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968),Vector2i(960,432)]:await shape_case(shape)
	print("MENU REACH UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
