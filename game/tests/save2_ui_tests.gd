extends "res://tests/fix2_menu_ui_tests.gd"
# SAVE2 touch path: real host menu controls, pinned profile sidecar and fresh restore session.
const Save2Store=preload("res://src/persistence/save_states/save2_store.gd")
const Table=preload("res://src/persistence/save_states/save2_table.gd")

func target_visible(node,id,host,label)->void:
	var b=button(node,id)
	check(b!=null,label+" control exists")
	if b==null:return
	var parent=b.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(b);await settle()
	var rect=b.get_global_rect();var viewport=host.get_viewport_rect()
	check(rect.size.y>=host.ui_touch_height-1.0 and rect.position.y>=0 and rect.end.y<=viewport.size.y,label+" retains the 48 dp touch target inside the viewport")

func metadata_text(node):
	var text=""
	for label in node.find_children("*","Label",true,false):text+=label.text+"\n"
	return text

func replacement_host()->Node:
	for child in root.get_children():
		if child.get_meta("save2_replaced",false):return child
	return null

func cleanup(path:String,settings:String)->void:
	for base in [path,settings]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(base+suffix)
	var manager=Save2Store.new(path);var sidecar=manager.directory
	for kind in Table.KINDS:
		for index in range(Table.count(kind)):
			var entry=manager.entry_path(kind,index)
			for suffix in ["",".bak",".tmp",".save2-stage"]:DirAccess.remove_absolute(entry+suffix)
	for journal in [sidecar+"/transaction",sidecar+"/transaction.tmp"]:DirAccess.remove_absolute(journal)
	for folder in [sidecar+"/manual",sidecar+"/fork",sidecar+"/pending",sidecar]:DirAccess.remove_absolute(folder)

func capture(stage:String,shape:Vector2i)->void:
	var capture_dir=OS.get_environment("SIRENS_043_CAPTURE_DIR")
	if capture_dir.is_empty() or DisplayServer.get_name()=="headless":return
	if not DirAccess.dir_exists_absolute(capture_dir):check(DirAccess.make_dir_recursive_absolute(capture_dir)==OK,"SAVE2 native capture directory exists")
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	var stem=capture_dir+"/save2-ui-%s-%dx%d"%[stage,shape.x,shape.y]
	var path=stem+".png";var serial=0
	while FileAccess.file_exists(path):serial+=1;path=stem+"-%d.png"%serial
	check(root.get_texture().get_image().save_png(path)==OK,"native SAVE2 stage captured: "+stage)

func reveal_control(control:Control)->void:
	var parent=control.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(control);await settle()

func shape_case(shape:Vector2i)->void:
	root.size=shape;await settle()
	var stem="user://save2-ui-%dx%d"%[shape.x,shape.y]
	var archive=stem+".save";var settings=stem+"-settings.json"
	cleanup(archive,settings)
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
	game.store.path=archive;game.settings_path=settings
	root.add_child(game);await settle();game.set_process(false)
	game.completed=[0];game.unlocked=1;game.upgrade="survey";game.active_started=false;game._show_campaign();game.capture_scenario="";await settle()
	check(game.store.valid(game._archive()),"source-known campaign fixture is valid")
	var home=button(game,"save2_home")
	check(home!=null,"Operations exposes the SAVE2 hard saves entry")
	if home==null:
		game.queue_free();await settle();cleanup(archive,settings);return
	var launch=button(game,"launch_details")
	if launch!=null:check(home.get_global_rect().position.y<launch.get_global_rect().position.y,"HARD SAVES appears before Launch Details")
	await target_visible(game,"save2_home",game,"Operations hard saves")
	if await press(game,"save2_home"):
		check(game.screen=="save2","touch opens SAVE2 from Operations")
		check(metadata_text(game).contains(Table.EXACT_WARNING),"the exact-restore warning is visible")
		check(metadata_text(game).contains(Table.PROFILE_NOTICE),"the profile-slot copy/export notice is visible")
		await capture("manual-list",shape)
		await target_visible(game,"save2_save_0",game,"empty manual Save Here")
		var line=game.find_children("*","LineEdit",true,false).front() if not game.find_children("*","LineEdit",true,false).is_empty() else null
		check(line!=null,"manual slot has an editable name")
		if line!=null:line.text="Quiet Route"
		var expected=game._archive().duplicate(true)
		if await press(game,"save2_save_0"):
			check(game.screen=="save2" and button(game,"save2_confirm")==null,"an empty slot saves with one Save Here action")
			var initial_manager=Save2Store.new(archive);var saved=initial_manager.inspect("manual",0)
			check(saved.status=="ready" and saved.record.get("label")=="Quiet Route","the named manual snapshot is stored with metadata")
			check(saved.data==expected,"the manual sidecar stores the complete campaign archive without transport metadata")
			game.upgrade="disruption"
			var mutated=game._archive()
			check(mutated.upgrade=="disruption" and mutated.completed==expected.get("completed",[]),"the fixture changes a campaign field after saving")
			if await press(game,"save2_load_0"):
				check(button(game,"save2_confirm")!=null and metadata_text(game).contains("Quiet Route"),"load confirmation names the selected save")
				if await press(game,"save2_cancel"):
					check(button(game,"save2_load_0")!=null and game.upgrade=="disruption","Cancel returns to the save list without restoring")
				if await press(game,"save2_load_0"):
					await android_back()
					check(button(game,"save2_load_0")!=null and game.upgrade=="disruption","Android Back leaves a confirmation one level at a time")
					if await press(game,"save2_load_0") and await press(game,"save2_confirm"):
						await settle()
						var loaded=replacement_host()
						check(loaded!=null,"successful load constructs a fresh host marked as the SAVE2 replacement")
						if loaded!=null:
							loaded.set_process(false)
							check(loaded.screen=="menu" and loaded.get_node_or_null("Frontend")==null,"restore returns to unobscured Operations")
							check(loaded.upgrade==expected.upgrade and loaded.completed==expected.completed and loaded.unlocked==expected.unlocked,"fresh host restores saved campaign progress exactly")
							check(loaded.fitted_equipment==expected.get("equipment",{}),"fresh host restores saved fitting state")
							check(Save2Store.new(archive).inspect("manual",0).data==expected,"loading retains the complete sidecar snapshot on disk")
							game=loaded
							load("res://src/persistence/save_states/save2_ui.gd").show(game,"manual","operations")
							await settle()
							if await press(game,"save2_delete_0"):
								check(button(game,"save2_confirm")!=null and metadata_text(game).contains("Quiet Route"),"delete confirmation names the selected hard save")
								if await press(game,"save2_cancel"):
									check(Save2Store.new(archive).inspect("manual",0).status=="ready","Cancel leaves the named hard save intact")
									if await press(game,"save2_delete_0") and await press(game,"save2_confirm"):
										check(Save2Store.new(archive).inspect("manual",0).status=="empty","confirmed deletion clears the selected hard-save slot")
										var reseed=Save2Store.new(archive);var current=game._archive()
										check(reseed.save_manual(0,current,"Erase guard",false,"missing"),"test fixture restores a hard save for erase-isolation checks")
										check(reseed.save_fork("first_ending",current,"Before first ending"),"test fixture stores a fork state for erase-isolation checks")
		# Corrupt occupied slot remains visible, cannot load/overwrite, and remains byte-for-byte intact.
		var manager=Save2Store.new(archive)
		var manual_path=manager.entry_path("manual",0);var fork_path=manager.entry_path("fork",0)
		var manual_bytes=FileAccess.get_file_as_bytes(manual_path);var fork_bytes=FileAccess.get_file_as_bytes(fork_path)
		var entry_path=manager.entry_path("manual",1)
		var corrupt=FileAccess.open(entry_path,FileAccess.WRITE)
		if corrupt!=null:corrupt.store_buffer(PackedByteArray([0,1,2,3,4]));corrupt.close()
		manager.inspect("manual",1)
		load("res://src/persistence/save_states/save2_ui.gd").show(game,"manual","operations")
		await settle()
		var before=FileAccess.get_file_as_bytes(entry_path)
		check(metadata_text(game).contains("Unreadable save"),"corrupt slot is shown as unreadable")
		var unreadable_save=button(game,"save2_save_1")
		check(unreadable_save!=null and unreadable_save.disabled,"unreadable slot cannot be overwritten")
		check(button(game,"save2_load_1")==null,"unreadable slot has no load action")
		check(FileAccess.get_file_as_bytes(entry_path)==before,"reading the corrupt slot retains its original bytes")
		await capture("unreadable-slot",shape)
		await android_back()
		check(game.screen=="menu" and not game.has_meta("save2_ui_page"),"Android Back leaves the saved-state list for its originating Operations screen")
		# ERASE remains in Settings; its original confirmation action stays intact.
		game._settings_menu();await settle()
		var front=game.get_node_or_null("Frontend")
		check(front!=null and button(game,"new_campaign")!=null,"Settings keeps the existing embedded erase entry")
		if front!=null and await press(game,"new_campaign"):
			check(button(game,"confirm_new_campaign")!=null,"the existing erase confirmation action remains unchanged")
			var erase_option=_erase_checkbox(game)
			check(erase_option!=null and not erase_option.button_pressed,"SAVE2 erase control is explicit and unchecked by default")
			await capture("erase-default",shape)
			if await press(game,"back"):
				check(FileAccess.get_file_as_bytes(manual_path)==manual_bytes and FileAccess.get_file_as_bytes(fork_path)==fork_bytes,"default erase confirmation preserves manual and fork state bytes")
				game._settings_menu();await settle();front=game.get_node_or_null("Frontend")
				if front!=null and await press(game,"new_campaign"):
					erase_option=_erase_checkbox(game)
					check(erase_option!=null,"explicit SAVE2 erase checkbox can be opened again")
					if erase_option!=null:
						await reveal_control(erase_option)
						await tap(erase_option.get_global_rect().get_center())
						check(erase_option.button_pressed and game.get_meta("save2_delete_states",false),"touch selects the explicit SAVE2 erase option")
						await capture("erase-checked",shape)
						if await press(game,"confirm_new_campaign"):
							check(Save2Store.new(archive).inspect("manual",0).status=="empty" and Save2Store.new(archive).inspect("fork",0).status=="empty","explicit erase clears both manual and fork states")
	game.queue_free();await settle();cleanup(archive,settings)

func _erase_checkbox(host)->CheckBox:
	for option in host.find_children("*","CheckBox",true,false):
		if option.get_meta("ui_action",option.get_meta("action",""))=="save2_erase_states":return option
	return null

func run()->void:
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
	print("SAVE2 UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
