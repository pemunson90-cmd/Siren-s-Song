extends "res://src/main.gd"
# Reuses the playable Main scene with a challenge-only Simulation and result flow.
# Parent campaign nodes are frozen and their visibility restored verbatim on return.
# Results use a separate challenge archive; campaign bytes are never written.
# Revert: remove the frontend entry/session and Main's small challenge profile field.
const Archive=preload("res://src/campaign/challenges/challenge_archive.gd")
const Challenges=preload("res://src/campaign/challenges/challenge_catalog.gd")
const ChallengeRun=preload("res://src/campaign/challenges/challenge_run.gd")
const ChallengeRecords=preload("res://src/campaign/challenges/challenge_records.gd")
const ChallengeRules=preload("res://src/campaign/challenges/challenge_rules.gd")
var campaign_host
var challenge_id=""
var return_to_list:Callable
var prior_mode=Node.PROCESS_MODE_INHERIT
var prior_visibility:Array=[]
var prior_sound_suspended=false
var recorded=false
var abandoned=false
func freeze_campaign()->void:
	prior_mode=campaign_host.process_mode
	prior_sound_suspended=campaign_host.sound.system_suspended
	for child in campaign_host.get_children():
		if child is CanvasItem:prior_visibility.append({"node":child,"visible":child.visible});child.hide()
	campaign_host.sound.suspend();campaign_host.process_mode=Node.PROCESS_MODE_DISABLED
func _ready()->void:
	sim=ChallengeRun.new();sim.configure(challenge_id)
	upgrade=str(sim.definition.loadout);fitted_equipment=Challenges.fitting(sim.definition)
	# These are completed-operation replays; the campaign's teaching flags are untouched.
	hints_seen=OnboardingText.HINTS.keys()
	settings=campaign_host.settings.duplicate();capture_scenario="challenge-session"
	super._ready()
	active_started=true
	FrontendSettings.apply(FrontendSettings.current,self);sound.muted=campaign_host.sound.muted
	_layout()
func _scenario(_name:String)->void:pass
func _load_archive()->void:pass
func _save_archive()->void:pass
func _apply_safe_area()->void:
	# The child fills the parent's already-correct safe rectangle once.
	pass
func ui_density_dpi()->float:
	return campaign_host.ui_density_dpi() if is_instance_valid(campaign_host) else super.ui_density_dpi()
func ui_density_source()->String:
	return campaign_host.ui_density_source() if is_instance_valid(campaign_host) else super.ui_density_source()
func _start_mission(_index:int)->void:
	recorded=false;abandoned=false
	super._start_mission(int(sim.definition.op))
func _refresh()->void:
	super._refresh();_challenge_status()
func _layout(cancel_gesture:bool=true)->void:
	super._layout(cancel_gesture);_challenge_status()
func _challenge_status()->void:
	if status_label==null:return
	status_label.visible=screen=="mission"
	if not status_label.visible:return
	status_label.text="CHALLENGE · "+ChallengeRules.status(sim)
	if sim.message.begins_with("CHALLENGE"):status_label.text=sim.message
	status_label.position=Vector2(12,ui_touch_height+24);status_label.size=Vector2(maxf(1,size.x-24),ui_touch_height)
	status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;status_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	status_label.add_theme_font_size_override("font_size",maxi(14,roundi(ui_touch_height*.25*FrontendSettings.text_scale())))
	for id in unit_buttons.size():
		if id not in sim.launched:unit_buttons[id].text=["QUIETUS","DRONE A","DRONE B"][id]+"\nASHORE"
func _unhandled_key_input(event:InputEvent)->void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		# Consume before returning: _show_campaign may detach this session.
		get_viewport().set_input_as_handled()
	super._unhandled_key_input(event)
func _show_campaign()->void:
	if not is_inside_tree():return
	if recorded or not sim.outcome.is_empty():_return();return
	sim.paused=true;screen="challenge_menu";_clear_menu()
	_menu_text(sim.definition.title,30);_menu_text(Challenges.description(sim.definition),20)
	_button(panel_box,"RESUME ATTEMPT",_enter_water,"challenge_resume")
	_button(panel_box,"END ATTEMPT",func():abandoned=true;_debrief(),"challenge_abandon")
	call_deferred("_layout")
func _record_result()->void:
	if recorded:return
	recorded=true
	campaign_host.challenge_records=ChallengeRecords.add(campaign_host.challenge_records,challenge_id,sim.result(abandoned))
	Archive.persist(campaign_host)
func _debrief()->void:
	if recorded:return
	_record_result();_result_menu()
func _result_menu()->void:
	sim.paused=true;screen="challenge_result";_clear_menu()
	var result=sim.result(abandoned)
	_menu_text("CHALLENGE LOST" if result.loss else "CHALLENGE RECOVERED",30)
	_menu_text(sim.definition.title,20);_menu_text(ChallengeRecords.summary(result),17)
	if result.loss:_menu_text(sim.rule_failure if not sim.rule_failure.is_empty() else ("Attempt ended." if abandoned else sim.message),17)
	else:_menu_text("PARS %d / 3"%ChallengeRecords.pars(sim.definition,result),20)
	if not str(campaign_host.get_meta("challenge_save_error","")).is_empty():
		_menu_text("PROGRESS NOT SAVED\nResults are held in this session.\n"+str(campaign_host.get_meta("challenge_save_error","")),17)
		_button(panel_box,"RETRY SAVE",func():Archive.persist(campaign_host);_result_menu(),"challenge_retry_save")
	_button(panel_box,"RETRY CHALLENGE",func():_start_mission(int(sim.definition.op));_enter_water(),"challenge_retry")
	_button(panel_box,"BACK TO CHALLENGES",_return,"challenge_return")
	call_deferred("_layout")
func _return()->void:
	if not recorded:abandoned=true;_record_result()
	for item in prior_visibility:
		if is_instance_valid(item.node):item.node.visible=item.visible
	campaign_host.process_mode=prior_mode
	if not prior_sound_suspended:campaign_host.sound.resume()
	get_parent().remove_child(self)
	if return_to_list.is_valid():return_to_list.call()
	queue_free()
