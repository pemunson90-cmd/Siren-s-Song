extends "res://tests/fix2_menu_ui_tests.gd"
# SAVE2 touch path: real host menu controls, pinned profile sidecar and fresh restore session.
const Save2Store=preload("res://src/persistence/save_states/save2_store.gd")
const Table=preload("res://src/persistence/save_states/save2_table.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Save2Transaction=preload("res://src/persistence/save_states/save2_transaction.gd")

func target_visible(node,id,host,label)->void:
	var b:Control=null
	for control in node.find_children("*","Control",true,false):
		if control.get_meta("ui_action",control.get_meta("action",""))==id and control.is_visible_in_tree():b=control;break
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

func touch_press(node,id:String)->bool:
	if id!="arc_continue" and node.get_node_or_null("ArcCard")!=null:
		if not await touch_press(node,"arc_continue"):return false
	var control=button(node,id)
	check(control!=null,"visible touch action "+id)
	if control==null:return false
	var activations={"count":0}
	control.pressed.connect(func():activations.count+=1)
	var parent=control.get_parent()
	while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
	if parent!=null:parent.ensure_control_visible(control);await settle()
	var point=root.get_final_transform()*control.get_global_rect().get_center()
	var down=InputEventScreenTouch.new();down.index=0;down.position=point;down.pressed=true;Input.parse_input_event(down);Input.flush_buffered_events();await process_frame
	var release_point=root.get_final_transform()*control.get_global_rect().get_center() if is_instance_valid(control) else point
	var up=InputEventScreenTouch.new();up.index=0;up.position=release_point;up.pressed=false;Input.parse_input_event(up);Input.flush_buffered_events();await process_frame
	await settle()
	if activations.count!=1:print("SAVE2 TOUCH MISS id=",id," screen=",node.get("screen")," page=",node.get_meta("save2_ui_page",{})," rect=",control.get_global_rect()," point=",point," transform=",root.get_final_transform()," viewport=",node.get_viewport_rect()," visible=",control.is_visible_in_tree())
	check(activations.count==1,"single screen touch activates once: "+id)
	return true

# Item 142: a launch over a live dive asks first; replay launches in these cases answer ABANDON.
func launch(node)->bool:
	if not await press(node,"begin"):return false
	if node.screen=="launch_guard":return await press(node,"launch_guard_abandon")
	return true

func has_text(node,text:String)->bool:
	return metadata_text(node).contains(text)

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
	game._set_accessibility("text_scale",1.5);game._show_campaign();await settle()
	var home=button(game,"save2_home")
	check(home!=null,"Operations exposes the SAVE2 hard saves entry")
	if home==null:
		game.queue_free();await settle();cleanup(archive,settings);return
	var launch=button(game,"launch_details")
	if launch!=null:check(home.get_global_rect().position.y<launch.get_global_rect().position.y,"HARD SAVES appears before Launch Details")
	await target_visible(game,"save2_home",game,"Operations hard saves")
	if await touch_press(game,"save2_home"):
		check(game.screen=="save2","touch opens SAVE2 from Operations")
		check(metadata_text(game).contains(Table.EXACT_WARNING),"the exact-restore warning is visible")
		check(metadata_text(game).contains(Table.PROFILE_NOTICE),"the profile-slot copy/export notice is visible")
		await capture("manual-list",shape)
		await target_visible(game,"save2_save_0",game,"empty manual Save Here")
		var line=game.find_children("*","LineEdit",true,false).front() if not game.find_children("*","LineEdit",true,false).is_empty() else null
		check(line!=null,"manual slot has an editable name")
		if line!=null:
			line.text="Quiet Route"
			await target_visible(game,"save2_name_0",game,"manual name field")
			var line_rect=line.get_global_rect();var viewport=game.get_viewport_rect()
			check(line.get_theme_font_size("font_size")==maxi(17,roundi(game.ui_touch_height*.29*1.5)),"150% text scale is applied to the manual name field")
			check(line_rect.size.x>0 and line_rect.size.y>=game.ui_touch_height-1 and line_rect.position.x>=0 and line_rect.end.x<=viewport.size.x and line_rect.position.y>=0 and line_rect.end.y<=viewport.size.y,"150% manual name field keeps its full-width row and touch height inside the viewport")
			await capture("manual-name-visible",shape)
		var expected=game._archive().duplicate(true)
		if await touch_press(game,"save2_save_0"):
			check(game.screen=="save2" and button(game,"save2_confirm")==null,"an empty slot saves with one Save Here action")
			check(has_text(game,"Hard save written.") and not game.archive_warning.contains("Saved-state action needs attention"),"successful save details stay in the scrolling page without growing the sticky banner")
			var initial_manager=Save2Store.new(archive);var saved=initial_manager.inspect("manual",0)
			check(saved.status=="ready" and saved.record.get("label")=="Quiet Route","the named manual snapshot is stored with metadata")
			check(saved.data==expected,"the manual sidecar stores the complete campaign archive without transport metadata")
			var legacy_archive=expected.duplicate(true);legacy_archive[Table.STATE].last_recovered=-1;legacy_archive[Table.STATE].legacy_minimum=true;legacy_archive[Table.STATE].recoveries=3
			var legacy_store=Save2Store.new(archive);var legacy_slot=legacy_store.inspect("manual",2)
			check(legacy_store.save_manual(2,legacy_archive,"Legacy archive",false,legacy_slot.token),"test fixture stores a legacy archive with a known recovery minimum")
			load("res://src/persistence/save_states/save2_ui.gd").show(game,"manual","operations");await settle()
			check(has_text(game,"Unknown (not recorded)"),"unrecorded recovery history clearly labels an unknown last operation")
			load("res://src/persistence/save_states/save2_ui.gd").show(game,"manual","operations");await settle()
			game.upgrade="disruption"
			var mutated=game._archive()
			check(mutated.upgrade=="disruption" and mutated.completed==expected.get("completed",[]),"the fixture changes a campaign field after saving")
			if await touch_press(game,"save2_load_0"):
				check(button(game,"save2_confirm")!=null and metadata_text(game).contains("Quiet Route") and metadata_text(game).contains(Table.EXACT_WARNING),"load confirmation names the selected save and warns about later replacements")
				if await touch_press(game,"save2_cancel"):
					check(button(game,"save2_load_0")!=null and game.upgrade=="disruption","Cancel returns to the save list without restoring")
				if await touch_press(game,"save2_load_0"):
					await android_back()
					check(button(game,"save2_load_0")!=null and game.upgrade=="disruption","Android Back leaves a confirmation one level at a time")
					if await touch_press(game,"save2_load_0") and await touch_press(game,"save2_confirm"):
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
							await target_visible(game,"save2_load_0",game,"named hard save Load")
							await target_visible(game,"save2_delete_0",game,"named hard save Delete")
							if await touch_press(game,"save2_delete_0"):
								check(button(game,"save2_confirm")!=null and metadata_text(game).contains("Quiet Route"),"delete confirmation names the selected hard save")
								await target_visible(game,"save2_cancel",game,"delete cancel")
								if await touch_press(game,"save2_cancel"):
									check(Save2Store.new(archive).inspect("manual",0).status=="ready","Cancel leaves the named hard save intact")
									if await touch_press(game,"save2_delete_0") and await touch_press(game,"save2_confirm"):
										check(Save2Store.new(archive).inspect("manual",0).status=="empty","confirmed deletion clears the selected hard-save slot")
										check(has_text(game,"Saved state deleted.") and not game.archive_warning.contains("Saved-state action needs attention"),"successful delete details stay in the scrolling page without growing the sticky banner")
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
			if erase_option!=null:
				await reveal_control(erase_option)
				var erase_rect=erase_option.get_global_rect();var erase_viewport=game.get_viewport_rect()
				check(erase_rect.size.y>=game.ui_touch_height-1 and erase_rect.position.x>=0 and erase_rect.end.x<=erase_viewport.size.x and erase_rect.position.y>=0 and erase_rect.end.y<=erase_viewport.size.y,"150% erase choice keeps a reachable touch target inside the viewport")
			await capture("erase-default",shape)
			if await press(game,"confirm_new_campaign"):
				check(game.screen=="menu" and game.completed.is_empty() and game.unlocked==0,"unchecked erase confirmation starts the ordinary new campaign")
				check(FileAccess.get_file_as_bytes(manual_path)==manual_bytes and FileAccess.get_file_as_bytes(fork_path)==fork_bytes,"default erase confirmation preserves manual and fork state bytes")
				game.completed=[0,1,2,3,4,5];game.unlocked=5;game.expedition=ending_fixture();game.active_started=false;game._show_campaign();await settle()
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

func prechoice_fixture()->Dictionary:
	return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed"},"completed":[6,7,9,11],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}

func ending_fixture()->Dictionary:
	var completed=[6,7,9,11,12]
	for id in range(14,30):completed.append(id)
	completed.append_array([30,31,32,33,34])
	return {"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed","glass_choice":"salvage","choir_choice":"bypass","choir_people":"landed","choir_plant":"reconnect"},"completed":completed,"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}

func glass_prechoice_fixture()->Dictionary:
	var progress=ending_fixture()
	progress.completed=[6,7,9,11,12,14,15,16,17]
	for key in ["glass_choice","choir_choice","choir_people","choir_plant"]:progress.facts.erase(key)
	return progress

func film_fixture()->Dictionary:
	var archive={}
	for id in [30,31]:
		for index in 2:
			var sim=preload("res://src/simulation/simulation.gd").new();sim.start(id)
			var objective=sim.mission.objectives[index]
			sim.units[0].band=objective.band;sim.units[0].pos=objective.pos+Vector2(-120,0);sim.units[0].angle=0.0
			sim.command("frame",{"mode":"tight","focus":objective.optical})
			Photo.begin(sim,0,index)
			for tick in 300:Photo.tick(sim,0,objective,1.0/60.0);sim.elapsed+=1.0/60.0
			var shot=Photo.finish(sim,0,objective).shot
			check(shot.usable,"later film fixture uses an actual usable frame "+objective.optical)
			archive[objective.optical]={"optical":objective.optical,"name":objective.name,"caption":objective.evidence,"shots":[shot]}
	return archive

func fork_journey_case(shape:Vector2i)->void:
	root.size=shape;await settle()
	var stem="user://save2-fork-ui-%dx%d"%[shape.x,shape.y]
	var archive=stem+".save";var settings=stem+"-settings.json";cleanup(archive,settings)
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
	game.store.path=archive;game.settings_path=settings
	root.add_child(game);await settle();game.set_process(false)
	game.completed=[0,1,2,3,4,5];game.unlocked=5;game.upgrade="survey";game.expedition=prechoice_fixture();game.active_started=false
	check(Campaign.valid(game.expedition),"pre-choice campaign fixture is valid before the first ending")
	check(game.store.valid(game._archive()),"pre-choice host archive validates before real mission launch")
	game._show_campaign();game.capture_scenario="";await settle()
	check(button(game,"expedition12")!=null,"the first-ending resolution mission is available through Operations")
	if await press(game,"expedition12"):
		if await press(game,"begin"):
			check(game.screen=="mission" and game.active_started and game.sim.mission.id==12,"touch launches the authored first-ending resolution mission")
			var manager=Save2Store.new(archive);var pending=manager.inspect("pending",0)
			check(pending.status=="ready" and pending.record.get("event")=="12","real mission launch automatically writes the first-ending pre-choice checkpoint")
			var controller=load("res://src/persistence/save_states/save2_controller.gd")
			controller.open(game,"manual","operations");await settle()
			var mid_dive=button(game,"save2_save_0")
			check(mid_dive!=null and mid_dive.disabled,"manual Save Here is disabled during the active dive")
			await android_back()
			check(game.screen=="menu" and game.active_started,"Back from SAVE2 returns to Operations without ending the active dive")
			var before=game.expedition.duplicate(true)
			game.sim.mission.recovered=true
			game.sim.mission.expedition_facts={"witness_packet":"Recovered occupied witness capsule","witness_repeater":"Tracking float account from the recovered witness","witness_sluice":"Service sluice account from the recovered witness"}
			game.sim.mission.objectives=[{"site_id":"witness_packet","name":"OCCUPIED WITNESS CAPSULE","captured":true,"optional":false}]
			var witness=game.sim.mission.witness_evacuation
			witness.state="landed";witness.pos=game.sim.mission.extraction;witness.carrier=-1;witness.landed_by=0;witness.rescues=0;witness.losses=[];witness.job={}
			game.sim.mission.concealed_harbour.receipt=true;game.sim.mission.concealed_harbour.phase="seated";game.sim.mission.concealed_harbour.connected=false;game.sim.mission.concealed_harbour.carrier=-1;game.sim.mission.concealed_harbour.trail=[]
			game.sim.outcome="won";game._debrief()
			check(12 in game.expedition.get("completed",[]) and Campaign.valid(game.expedition),"real debrief commits a valid authored first-ending recovery before fork publication")
			var fork=manager.inspect("fork",0)
			check(fork.status=="ready" and fork.record.get("event")=="first_ending" and fork.record.get("label")=="Before the first ending","successful first-ending resolution automatically publishes its pre-choice archive")
			check(manager.inspect("pending",0).status=="empty","publishing the fork clears its matching pending checkpoint")
			var first_fork_index=int(fork.index);var expected=fork.data.duplicate(true);var fork_bytes=FileAccess.get_file_as_bytes(manager.entry_path("fork",first_fork_index));var glass_fork_index=-1
			check(expected.get("expedition",{}).get("completed",[])==[6,7,9,11],"fork archive preserves the campaign before the ending recovery")
			# Add later progress, actual film, and a fitting earned from the tutorial route.
			# The completed ending mission is no longer a valid active snapshot in this later campaign.
			game.expedition=ending_fixture();game.sim.start(0);game.sim.paused=true;game.ocean.sim=game.sim
			game.fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").default_loadout();game.fitted_equipment.hull="fast";game.fitted_equipment.quietus_2="quietus_vector_drive"
			game.upgrade="disruption";game.recovered_evidence=film_fixture()
			check(Campaign.valid(game.expedition),"later campaign fixture remains valid")
			check(game.store.valid(game._archive()),"later campaign with film and upgraded fittings remains a valid complete archive")
			# A failed fork publication must leave the briefing and old simulation intact; retry succeeds.
			var later_progress=game.expedition.duplicate(true);var pre_glass=glass_prechoice_fixture()
			var controller_state=controller.ensure_state(game)
			game.expedition=pre_glass
			var pending_archive=game._archive()
			check(Campaign.valid(pre_glass) and game.store.valid(pending_archive),"glass pre-choice retry fixture is a valid campaign archive")
			check(manager.save_pending(pending_archive,18,controller_state.run_id,controller_state.launch_id),"test fixture creates an existing pre-choice checkpoint for a replay launch")
			game.expedition=later_progress;game._show_campaign();await settle()
			game._briefing(18);await settle()
			check(game.screen=="briefing" and button(game,"begin")!=null,"glass replay fixture opens the real briefing screen")
			var old_mission=game.sim.mission.id;var old_elapsed=game.sim.elapsed;var old_active=game.active_started
			for entry in manager.list_entries("fork"):
				if entry.status=="empty" and glass_fork_index<0:glass_fork_index=int(entry.index)
			Save2Transaction.test_failures=["stage"]
			if await launch(game):
				var held=manager.inspect("pending",0)
				check(game.screen=="briefing" and game.active_started==old_active and game.sim.mission.id==old_mission and game.sim.elapsed==old_elapsed,"blocked checkpoint publication leaves the old simulation paused in briefing")
				check(held.status=="ready" and glass_fork_index>=0 and manager.inspect("fork",glass_fork_index).status=="empty","failed fork publication preserves the pending checkpoint and does not enter the old simulation")
				if await launch(game):
					check(game.screen=="mission" and game.active_started and game.sim.mission.id==18,"retry publishes the retained checkpoint and starts the intended replay mission")
					check(manager.inspect("pending",0).status=="empty" and manager.inspect("fork",glass_fork_index).status=="ready","successful retry clears pending only after recording the fork")
			for entry in manager.list_entries("fork"):
				print("SAVE2 UI FORK DEBUG index=",entry.index," status=",entry.status," event=",entry.get("record",{}).get("event",""))
			Save2Transaction.test_failures=[]
			game.active_started=false;game.sim.start(0);game.sim.paused=true;game.ocean.sim=game.sim;game.expedition=later_progress;game._show_campaign();await settle()
			game._show_campaign();await settle()
			game.CampaignFlow.show_ending(game,false);await settle()
			check(game.screen=="ending" and has_text(game,"CAMPAIGN OUTCOME"),"final campaign outcome is labeled after op34")
			check(button(game,"continue_choir")==null and button(game,"continue_glass")==null,"already recovered Choir and Glass continuations stay hidden")
			check(button(game,"save2_forks")!=null,"legacy first-ending screen offers Replay from Fork")
			await capture("first-ending",shape)
			await target_visible(game,"save2_forks",game,"first-ending Replay from Fork")
			if await touch_press(game,"save2_forks"):
				check(game.screen=="save2" and metadata_text(game).contains("Before the first ending"),"first-ending replay opens its chronological fork list")
				await capture("first-ending-fork-list",shape)
				await target_visible(game,"save2_back",game,"first-ending fork Back")
				await android_back()
				check(game.screen=="ending" and has_text(game,"CAMPAIGN OUTCOME"),"fork Back returns to the final campaign outcome")
			game._show_ending();await settle()
			check(game.screen=="photo_ending" and button(game,"save2_forks")!=null,"later photo ending wall offers its fork list")
			check(button(game,"continue_choir")==null and button(game,"continue_glass")==null,"the photo ending wall hides branches already recovered")
			await capture("photo-ending",shape)
			# Reverting SAVE2 restores the original photo/legacy ending flow and choices.
			var enabled=Table.enabled;Table.enabled=false
			game.CampaignFlow.show_ending(game,false);await settle()
			check(game.screen=="ending" and has_text(game,"CAMPAIGN OUTCOME") and button(game,"save2_forks")==null,"SAVE2 off switch preserves the original legacy ending flow")
			check(button(game,"continue_choir")!=null and button(game,"continue_glass")!=null,"SAVE2 off switch restores the original continuation controls")
			game._show_ending();await settle()
			check(game.screen=="photo_ending" and button(game,"save2_forks")==null,"SAVE2 off switch hides Replay from Fork on the photo wall")
			Table.enabled=enabled
			game._show_ending();await settle()
			# Loading from the photo wall opens a named confirmation; Cancel retains the live later campaign.
			await target_visible(game,"save2_forks",game,"photo-wall Replay from Fork")
			if await touch_press(game,"save2_forks"):
				check(metadata_text(game).contains("Before the first ending") and metadata_text(game).contains(Table.EXACT_WARNING),"photo-wall fork list identifies the exact pre-choice restore")
				await target_visible(game,"save2_fork_load_%d"%first_fork_index,game,"first-ending fork Load")
				if await touch_press(game,"save2_fork_load_%d"%first_fork_index):
					check(metadata_text(game).contains("Before the first ending") and metadata_text(game).contains(Table.EXACT_WARNING),"fork load confirmation names the state and states later progress will be replaced")
					await capture("fork-load-confirm",shape)
					var live_expedition=game.expedition.duplicate(true);var live_film=game.recovered_evidence.duplicate(true);var live_fitting=game.fitted_equipment.duplicate(true);var live_upgrade=game.upgrade
					if await touch_press(game,"save2_cancel"):
						check(game.expedition==live_expedition and game.recovered_evidence==live_film and game.fitted_equipment==live_fitting and game.upgrade==live_upgrade,"Cancel preserves later campaign, film, fittings, and the current host")
						check(replacement_host()==null,"Cancel does not construct a replacement host")
					if await touch_press(game,"save2_fork_load_%d"%first_fork_index) and await touch_press(game,"save2_confirm"):
						await settle()
						var fresh=replacement_host()
						check(fresh!=null,"confirmed fork replay constructs a fresh host")
						if fresh!=null:
							fresh.set_process(false)
							check(fresh.screen=="menu" and fresh.get_node_or_null("Frontend")==null,"fork restore returns to unobscured Operations")
							check(fresh.expedition==expected.expedition and fresh.completed==expected.completed and fresh.upgrade==expected.upgrade,"fork replay restores the complete pre-choice campaign exactly")
							check(fresh.recovered_evidence==expected.get("evidence",{}) and fresh.fitted_equipment==expected.get("equipment",{}),"fork replay removes later film and fittings exactly")
							check(Save2Store.new(archive).inspect("fork",first_fork_index).data==expected and FileAccess.get_file_as_bytes(manager.entry_path("fork",first_fork_index))==fork_bytes,"loaded fork remains complete and byte-identical on disk")
							game=fresh
	game.queue_free();await settle();cleanup(archive,settings)

func blocked_cold_case(shape:Vector2i)->void:
	root.size=shape;await settle()
	var archive="user://save2-blocked-cold-%dx%d.save"%[shape.x,shape.y]
	var settings=archive+"-settings.json";cleanup(archive,settings)
	var journal=archive+".save2/transaction"
	check(DirAccess.make_dir_recursive_absolute(journal.get_base_dir())==OK,"blocked cold-start fixture creates its own recovery directory")
	var original=PackedByteArray([1,2,3,4])
	var file=FileAccess.open(journal,FileAccess.WRITE);file.store_buffer(original);file.close()
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
	game.store.path=archive;game.settings_path=settings;root.add_child(game);await settle();game.set_process(false)
	var initialized=game.sim.mission.has("title") and game.sim.units.size()==3
	check(initialized,"unreadable recovery journal still initializes a valid paused presentation simulation")
	check(not game.active_started and game.sim.paused,"blocked cold boot exposes no active dive")
	check(FileAccess.get_file_as_bytes(journal)==original and not FileAccess.file_exists(archive),"blocked cold boot preserves journal bytes and writes no campaign")
	if initialized:
		var front=game.get_node_or_null("Frontend")
		if front!=null:front._continue()
		game._show_campaign();game._briefing(0);await settle()
		var before=game.sim.snapshot().duplicate(true)
		if await touch_press(game,"begin"):
			check(game.screen=="briefing" and not game.active_started and game.sim.snapshot()==before,"real launch stays blocked without entering the presentation simulation")
		check(not game.store.save(game._archive()) and FileAccess.get_file_as_bytes(journal)==original and not FileAccess.file_exists(archive),"blocked recovery still prevents ordinary archive writes")
	game.queue_free();await settle();cleanup(archive,settings)

func off_resume_case(shape:Vector2i)->void:
	root.size=shape;await settle()
	var archive="user://save2-off-resume-%dx%d.save"%[shape.x,shape.y]
	var settings=archive+"-settings.json";cleanup(archive,settings)
	var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
	game.store.path=archive;game.settings_path=settings;root.add_child(game);await settle();game.set_process(false)
	game.capture_scenario="";game.active_started=false
	var tracked=game._archive()[Table.STATE].duplicate(true)
	Table.enabled=false;game._start_mission(0);game.sim.elapsed=13.25;game.sim.paused=true;game._save_archive()
	var saved=game.store.load_game()
	check(game.store.valid(saved) and saved.get("active",{}).get("elapsed")==13.25,"off-switch resume fixture saves an ordinary valid unfinished simulation")
	check(not saved[Table.STATE].between and saved[Table.STATE].launch_id!=tracked.launch_id and saved[Table.STATE].legacy_minimum,"disabled autosave refreshes existing Resume identity and records an honest recovery minimum")
	game.queue_free();await settle();Table.enabled=true
	var fresh=load("res://scenes/main.tscn").instantiate();fresh.set_script(load("res://tests/density_main.gd"));fresh.store.path=archive;fresh.settings_path=settings
	root.add_child(fresh);await settle();fresh.set_process(false)
	var front=fresh.get_node_or_null("Frontend")
	if front!=null:front._continue()
	fresh._show_campaign();await settle()
	check(fresh.active_started and fresh.sim.mission.id==0 and fresh.sim.elapsed==13.25 and button(fresh,"resume")!=null,"cold start after re-enabling SAVE2 retains the unfinished dive and its Resume action")
	if await touch_press(fresh,"resume"):
		check(fresh.screen=="mission" and fresh.sim.elapsed==13.25 and fresh.active_started,"real touch resumes the saved dive without replacing it with a new launch")
	var manager=Save2Store.new(archive)
	check(manager.inspect("pending",0).status=="empty" and manager.list_entries("fork").all(func(e):return e.status=="empty"),"disabled tracking creates no automatic checkpoint files")
	fresh.queue_free();await settle();cleanup(archive,settings)

func run()->void:
	Input.emulate_mouse_from_touch=true
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		await shape_case(shape)
		await fork_journey_case(shape)
		await blocked_cold_case(shape)
		await off_resume_case(shape)
	print("SAVE2 UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
