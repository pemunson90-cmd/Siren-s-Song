extends "res://src/main.gd"
# Isolated Main/Simulation pair, following challenge_session. Campaign/SAVE2 never write here.
# Revert: remove mode entry and this folder; retain archive for future runs.
const RunState=preload("res://src/campaign/runs/run_state.gd")
const RunArchive=preload("res://src/campaign/runs/run_archive.gd")
const RunSimulation=preload("res://src/campaign/runs/expedition_run.gd")
const RunTable=preload("res://src/campaign/runs/run_table.gd")
const RunOffers=preload("res://src/campaign/runs/run_offers.gd")
const SummaryView=preload("res://src/presentation/runs/run_summary_view.gd")
const OfferView=preload("res://src/presentation/runs/offer_view.gd")
var campaign_host
var run_state:Dictionary={}
var return_to_list:Callable
var prior_mode=Node.PROCESS_MODE_INHERIT
var prior_visibility:Array=[]
var prior_sound_suspended=false
var recorded=false
var accept_rider=true
var snapshot_ready=false
var save_failed=false
var active_envelope:Dictionary={}
var pinned_path=""
func freeze_campaign()->void:
	prior_mode=campaign_host.process_mode;prior_sound_suspended=campaign_host.sound.system_suspended
	for child in campaign_host.get_children():
		if child is CanvasItem:prior_visibility.append({"node":child,"visible":child.visible});child.hide()
	campaign_host.sound.suspend();campaign_host.process_mode=Node.PROCESS_MODE_DISABLED
func _ready()->void:
	pinned_path=campaign_host.store.path
	if DevState.marked(self):set_meta("dev_profile",true)
	active_envelope=preload("res://src/campaign/mode_dev.gd").active(campaign_host,"runs") if DevState.marked(self) else campaign_host.get_meta("runs_active",{}).duplicate(true)
	sim=RunSimulation.new();sim.configure(run_state)
	upgrade=run_state.loadout;fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").default_loadout()
	hints_seen=OnboardingText.HINTS.keys();settings=campaign_host.settings.duplicate();capture_scenario="expedition-session"
	super._ready();active_started=false
	if not active_envelope.is_empty():
		active_started=RunArchive.Active.restore_sim(sim,active_envelope,run_state,"runs")
		mission_index=sim.mission.id;ocean.sim=sim;ocean.focus_craft()
	snapshot_ready=true
	FrontendSettings.apply(FrontendSettings.current,self);sound.muted=campaign_host.sound.muted
	_show_campaign();_layout()
func _scenario(_name:String)->void:pass
func _load_archive()->void:pass
func _save_archive()->void:
	if not snapshot_ready or DevState.marked(self):return
	if active_started and run_state.in_flight and not recorded:
		active_envelope=RunArchive.Active.capture("runs",run_state,sim,active_envelope)
		save_failed=not _persist_state(run_state,active_envelope)
	elif recorded:save_failed=not _persist_state(run_state)

func _persist_state(state:Dictionary,envelope:Dictionary={})->bool:
	if DevState.marked(self):return false
	if campaign_host.store.path!=pinned_path:
		campaign_host.set_meta("runs_save_error","Profile changed. Return to the original profile and retry.")
		return false
	return RunArchive.persist(campaign_host,state,envelope)
func _apply_safe_area()->void:pass
func ui_density_dpi()->float:
	return campaign_host.ui_density_dpi() if is_instance_valid(campaign_host) else super.ui_density_dpi()
func ui_density_source()->String:
	return campaign_host.ui_density_source() if is_instance_valid(campaign_host) else super.ui_density_source()
func _start_mission(_index:int)->void:
	# Main builds its paused display before the player commits a stage.
	super._start_mission(RunState.current_operation(run_state))
func _show_campaign()->void:
	if not is_inside_tree():return
	if recorded or run_state.status!="active":_result_menu();return
	if RunOffers.pending(run_state):OfferView.show(self);return
	if not sim.outcome.is_empty():_debrief();return
	sim.paused=true;screen="expedition_menu";_clear_menu()
	_menu_text("EXPEDITION · SEED %d"%run_state.seed,30)
	_menu_text("OPERATION %d / %d · %s"%[run_state.cursor+1,run_state.operations.size(),sim.mission.title.to_upper()],20)
	_menu_text(sim.mission.brief,17)
	_menu_text("%s LOADOUT · %s · STARTING HUNT %d\nTools carry across recovered operations. Film and oxygen replenish for each dive."%[run_state.loadout.to_upper(),RunTable.SCARCITY[run_state.scarcity].to_upper(),RunState.starting_hunt(run_state,RunState.current_operation(run_state))],17)
	if active_started:
		if save_failed:
			_menu_text("SAVE PENDING · "+str(campaign_host.get_meta("runs_save_error","")),17)
			_button(panel_box,"RETRY SAVE",func():_save_archive();_show_campaign(),"run_retry_save")
		_menu_text(sim.rider_status(),17)
		_button(panel_box,"RESUME DIVE",_enter_water,"run_resume")
		_button(panel_box,"END DIVE · LOSE RUN",func():_debrief(true),"run_abandon")
	else:
		var rider=RunState.rider_offer(run_state)
		_menu_text(RunState.Riders.description(rider,RunState.rider_bonus_text(rider)),17)
		if not rider.is_empty():
			_button(panel_box,"RIDER · "+("ACCEPTED" if accept_rider else "DECLINED"),preload("res://src/presentation/rider_choice.gd").toggle.bind(self,_show_campaign),"run_rider")
		_button(panel_box,"BEGIN OPERATION · START PAUSED",_begin,"run_begin")
		_button(panel_box,"RETURN TO MODES",_return,"run_return")
	call_deferred("_layout")
func _begin()->void:
	if active_started or run_state.in_flight or RunOffers.pending(run_state):return
	if not RunArchive._available(campaign_host):
		_menu_text("LAUNCH PAUSED · "+str(campaign_host.get_meta("runs_save_error","")),17);return
	var launched=RunState.launch(run_state,accept_rider)
	run_state=launched;sim.configure(run_state);recorded=false;active_envelope={}
	_start_mission(RunState.current_operation(run_state));_save_archive()
	if save_failed:_show_campaign();return
	_enter_water()
func _debrief(abandoned:bool=false)->void:
	if DevState.block_debrief(self):return
	if recorded:return
	recorded=true;sim.paused=true;screen="expedition_result";_clear_menu()
	run_state=RunState.settle(run_state,sim.result(abandoned))
	run_state=RunOffers.prepare(run_state);active_envelope={}
	_result_menu()
func _result_menu()->void:
	screen="expedition_result";_clear_menu()
	_menu_text("EXPEDITION LOST" if run_state.status=="lost" else "EXPEDITION RECOVERED" if run_state.status=="won" else "OPERATION RECOVERED",30)
	_menu_text("SEED %d · %d / %d RECOVERED"%[run_state.seed,run_state.cursor,run_state.operations.size()],20)
	_menu_text(sim.message,17)
	if not run_state.results.is_empty():
		var r:Dictionary=run_state.results.back().get("rider",{})
		if not r.get("assignment",{}).is_empty():
			_menu_text("RIDER %s · BONUS %s"%["PASSED" if r.passed else "FAILED",RunState.rider_bonus_text(r.assignment) if r.passed else "NONE"],17)
	if run_state.status!="active":SummaryView.session(self)
	else:_show_photo_grade(sim.mission.objectives)
	save_failed=not _persist_state(run_state)
	if save_failed:
		_menu_text("RESULT NOT SAVED · "+str(campaign_host.get_meta("runs_save_error","")),17)
		_button(panel_box,"RETRY SAVE",_result_menu,"run_retry_save")
		call_deferred("_layout");return
	if run_state.status=="active":
		_button(panel_box,"NEXT OPERATION",func():
			if RunOffers.pending(run_state):OfferView.show(self);return
			active_started=false;sim.configure(run_state);_start_mission(RunState.current_operation(run_state));active_started=false
			# The saved result is consumed only when explicitly preparing the next dive.
			recorded=false;_show_campaign()
		,"run_next")
	_button(panel_box,"RETURN TO EXPEDITIONS",_return,"run_return")
	call_deferred("_layout")
func _pick_offer(id:String)->void:
	if not RunState.valid(run_state) or not RunOffers.pending(run_state):return
	var picked=RunOffers.choose(run_state,id)
	if picked==run_state:return
	if not _persist_state(picked):
		OfferView.show(self)
		_menu_text("CHOICE NOT SAVED · "+str(campaign_host.get_meta("runs_save_error","Retry when storage is available.")),17)
		return
	run_state=picked;recorded=false;active_started=false
	sim.configure(run_state);_start_mission(RunState.current_operation(run_state));active_started=false
	_show_campaign()
func _enter_water()->void:
	if save_failed:_show_campaign();return
	super._enter_water()
func _unhandled_key_input(event:InputEvent)->void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:get_viewport().set_input_as_handled()
	super._unhandled_key_input(event)
func _refresh()->void:
	super._refresh()
	if status_label==null:return
	status_label.visible=screen=="mission"
	if not status_label.visible:return
	status_label.text="EXPEDITION · %d / %d · SEED %d"%[run_state.cursor+1,run_state.operations.size(),run_state.seed]
	if not sim.rider_status().is_empty():status_label.text+="\n"+sim.rider_status()
	status_label.position=Vector2(12,ui_touch_height+24);status_label.size=Vector2(maxf(1,size.x-24),ui_touch_height*2)
	status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;status_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
func _return()->void:
	if not is_inside_tree():return
	for item in prior_visibility:
		if is_instance_valid(item.node):item.node.visible=item.visible
	campaign_host.process_mode=prior_mode
	if not prior_sound_suspended:campaign_host.sound.resume()
	get_parent().remove_child(self)
	if return_to_list.is_valid():return_to_list.call()
	queue_free()
