extends "res://src/main.gd"
# Independent career flow. Never calls campaign debrief, ending or SAVE2 mutation.
# Revert: remove the mode seam; the campaign never reads career resources/facts.
const Career=preload("res://src/campaign/career/career_state.gd")
const CareerArchive=preload("res://src/campaign/career/career_archive.gd")
const CareerTable=preload("res://src/campaign/career/career_table.gd")
const CareerBoard=preload("res://src/presentation/career/career_board.gd")
const RiderDive=preload("res://src/presentation/career/rider_dive.gd")
var accept_rider=true
var campaign_host
var career_state:Dictionary={}
var return_to_list:Callable
var selected_contract="brannock_watch"
var prior_mode=Node.PROCESS_MODE_INHERIT
var prior_visibility:Array=[]
var prior_sound_suspended=false
var result_pending=false
var save_failed=false
var snapshot_ready=false
var active_envelope:Dictionary={}
var pinned_path=""
func freeze_campaign()->void:
	prior_mode=campaign_host.process_mode;prior_sound_suspended=campaign_host.sound.system_suspended
	for child in campaign_host.get_children():
		if child is CanvasItem:prior_visibility.append({"node":child,"visible":child.visible});child.hide()
	campaign_host.sound.suspend();campaign_host.process_mode=Node.PROCESS_MODE_DISABLED
func _bind_state()->void:
	economy=career_state.economy;expedition=career_state.progress;fitted_equipment=career_state.fitted
func _ready()->void:
	pinned_path=campaign_host.store.path
	if DevState.marked(self):set_meta("dev_profile",true)
	active_envelope=preload("res://src/campaign/mode_dev.gd").active(campaign_host,"career") if DevState.marked(self) else campaign_host.get_meta("career_active",{}).duplicate(true)
	if career_state.in_flight:selected_contract=career_state.active
	sim=RiderDive.new()
	_bind_state();hints_seen=OnboardingText.HINTS.keys();settings=campaign_host.settings.duplicate();capture_scenario="career-session"
	super._ready();active_started=false
	if not active_envelope.is_empty():
		active_started=CareerArchive.Active.restore_sim(sim,active_envelope,career_state,"career")
		if active_started:tactical_aids.restore_history(active_envelope.get("tactical_pause_history"))
		mission_index=sim.mission.id;ocean.sim=sim;ocean.focus_craft()
	snapshot_ready=true
	FrontendSettings.apply(FrontendSettings.current,self);sound.muted=campaign_host.sound.muted
	_show_campaign();_layout()
func _scenario(_name:String)->void:pass
func _load_archive()->void:pass
func _apply_safe_area()->void:pass
func ui_density_dpi()->float:
	return campaign_host.ui_density_dpi() if is_instance_valid(campaign_host) else super.ui_density_dpi()
func ui_density_source()->String:
	return campaign_host.ui_density_source() if is_instance_valid(campaign_host) else super.ui_density_source()
func _save_archive()->void:
	if not snapshot_ready or DevState.marked(self):return
	# A failed between-dive write owns its exact candidate until committed.
	var held:Dictionary=campaign_host.get_meta("career_archive_state",{})
	if campaign_host.get_meta("career_archive_dirty",false) and not held.get("in_flight",false):
		career_state=held.duplicate(true);_bind_state();active_envelope={}
		save_failed=not _persist_state(career_state)
		return
	career_state.fitted=fitted_equipment.duplicate(true)
	if active_started and career_state.in_flight and not result_pending:
		active_envelope=CareerArchive.Active.capture("career",career_state,sim,active_envelope)
		active_envelope["tactical_pause_history"]=tactical_aids.saved_history()
	else:active_envelope={}
	save_failed=not _persist_state(career_state,active_envelope)
func _enter_water()->void:
	if save_failed:CareerBoard.show(self);return
	super._enter_water()
func _persist_state(state:Dictionary,envelope:Dictionary={})->bool:
	if DevState.marked(self):return false
	if campaign_host.store.path!=pinned_path:
		campaign_host.set_meta("career_save_error","Profile changed. Return to the original profile and retry.")
		return false
	return CareerArchive.persist(campaign_host,state,envelope)
func _equipment_entitlements()->Array:return career_state.progress.entitlements
func _campaign_completed()->Array:return career_state.progress.completed
func _launch_context(_index:int)->Dictionary:
	return {"completed":career_state.progress.completed.duplicate(),"facts":career_state.progress.facts.duplicate(true)}
func _start_mission(_index:int)->void:
	sim.configure(career_state.get("rider",{}))
	super._start_mission(CareerTable.CONTRACTS[selected_contract].op)
func _show_campaign()->void:
	if not is_inside_tree():return
	if result_pending:_result_menu();return
	if not sim.outcome.is_empty() and active_started:_debrief();return
	CareerBoard.show(self)
func _briefing(_index:int)->void:CareerBoard.briefing(self)
func _select_contract(id:String)->void:
	if active_started or save_failed or not Career.open(career_state,id):return
	selected_contract=id;accept_rider=true;CareerBoard.briefing(self)
func _begin()->void:
	if active_started or career_state.in_flight or save_failed:return
	var launched=Career.launch(career_state,selected_contract,accept_rider)
	if not launched.in_flight:return
	career_state=launched;_bind_state();result_pending=false;active_envelope={}
	_start_mission(CareerTable.CONTRACTS[selected_contract].op)
	preload("res://src/campaign/economy.gd").apply_launch(economy,sim)
	_save_archive()
	if save_failed:CareerBoard.show(self);return
	_enter_water()
func _debrief(abandoned:bool=false)->void:
	if DevState.block_debrief(self):return
	if result_pending:return
	if not career_state.in_flight:return
	sim.paused=true
	career_state=Career.settle(career_state,{"outcome":"won" if not abandoned and sim.outcome=="won" else "lost","hull":sim.hull,"alive":[sim.units[1].alive,sim.units[2].alive],"mission":sim.mission,"rider":sim.rider_result()})
	_bind_state();result_pending=true;_save_archive();_result_menu()
func _result_menu()->void:
	sim.paused=true;screen="career_result";_clear_menu()
	_menu_text("CONTRACT RESULT",30);_menu_text(career_state.report,18)
	_show_photo_grade(sim.mission.objectives)
	if save_failed:
		_menu_text("RESULT NOT SAVED · "+str(campaign_host.get_meta("career_save_error","")),17)
		_button(panel_box,"RETRY SAVE",func():_save_archive();_result_menu(),"career_retry")
	else:
		_button(panel_box,"RETURN TO CONTRACT BOARD",func():
			result_pending=false;active_started=false;CareerBoard.show(self)
		,"career_board")
	call_deferred("_layout")
func _show_economy()->void:CareerBoard.supplies(self)
func _refresh()->void:
	super._refresh()
	if status_label==null:return
	status_label.visible=screen=="mission" and not sim.rider_status().is_empty()
	if status_label.visible:
		status_label.text=sim.rider_status()
		status_label.position=Vector2(12,ui_touch_height+24)
		status_label.size=Vector2(maxf(1,size.x-24),ui_touch_height*2)
		status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		status_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
func _show_fittings()->void:CareerBoard.fittings(self)
func _equipment_context()->Dictionary:
	return {"slots":fitted_equipment,"available":_equipment_entitlements(),"catalog":preload("res://src/equipment/equipment_catalog.gd").public_catalog(_equipment_entitlements())}
func _choose_equipment(slot:String,item:String,_index:int)->void:
	if _mutations_blocked():return
	var catalog=preload("res://src/equipment/equipment_catalog.gd")
	var choice=catalog.choose(fitted_equipment,slot,item,_equipment_entitlements())
	if not choice.ok:return
	fitted_equipment=choice.fitted;_save_archive();_show_fittings()
func _mutations_blocked()->bool:
	return active_started or save_failed or campaign_host.get_meta("career_archive_dirty",false)
func _apply_fitting(action:Callable)->void:
	# Shared frame callbacks buy unlocks before choosing, so guard the whole action.
	if _mutations_blocked():return
	action.call()
func _change(action:Callable,redraw:Callable)->void:
	if _mutations_blocked():return
	action.call();_save_archive();redraw.call()
func _frontend_back()->bool:return false
func _back_exit_handled()->bool:return false
func _notification(what:int)->void:
	# Parent campaign ignores lifecycle while CareerSession is installed.
	if not is_node_ready():return
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		sim.paused=true;_save_archive();sound.suspend()
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:sound.resume()
	elif what==NOTIFICATION_WM_GO_BACK_REQUEST:
		sim.paused=true;call_deferred("_android_back")
	elif what==NOTIFICATION_WM_CLOSE_REQUEST:_save_archive();get_tree().quit()
func _android_back()->void:
	if screen=="career_board" and not active_started and not result_pending:_return()
	elif screen=="program":route_editor.close()
	else:sim.paused=true;_show_campaign()
func _unhandled_key_input(event:InputEvent)->void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled();_android_back();return
	super._unhandled_key_input(event)
func _return()->void:
	if active_started or result_pending:return
	# DEV leave must not write the restored or console-jumped simulation.
	if not DevState.marked(self):
		_save_archive()
		if save_failed:CareerBoard.show(self);return
	for item in prior_visibility:
		if is_instance_valid(item.node):item.node.visible=item.visible
	campaign_host.process_mode=prior_mode
	if not prior_sound_suspended:campaign_host.sound.resume()
	get_parent().remove_child(self)
	if return_to_list.is_valid():return_to_list.call()
	queue_free()
