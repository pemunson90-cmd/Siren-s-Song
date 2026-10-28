extends Control
const UiMetrics=preload("res://src/presentation/flow/ui_metrics.gd")
const PhotoReview=preload("res://src/presentation/flow/photo_review.gd")
const CampaignFlow=preload("res://src/presentation/flow/campaign_flow.gd")
const Recon=preload("res://src/simulation/recon_consequences.gd")
const Endings=preload("res://src/campaign/endings.gd")
const CraftUpgrades=preload("res://src/equipment/craft_upgrades.gd")
const EarlyReward=preload("res://src/campaign/early_reward/early_reward.gd")
const ExpeditionOperations=preload("res://src/presentation/expedition_operations.gd")
const ExpeditionCampaign=preload("res://src/campaign/expedition_campaign.gd")
const Simulation = preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
const Soundscape=preload("res://src/audio/soundscape.gd")
const MetricsTransport=preload("res://src/diagnostics/metrics_transport.gd")
const OceanView = preload("res://src/presentation/ocean_view.gd")
const ModuleRecovery=preload("res://src/presentation/module_recovery_view.gd")
const WarningChain=preload("res://src/presentation/warning_chain_view.gd")
const BlackwaterDelivery=preload("res://src/presentation/blackwater_delivery_view.gd")
const RecipientView=preload("res://src/presentation/warning_recipient_view.gd")
const WitnessView=preload("res://src/presentation/witness_evacuation_view.gd")
const FleetInventory=preload("res://src/campaign/fleet_inventory.gd")
const OnboardingText=preload("res://src/campaign/onboarding_text.gd")
const FrontendSettings=preload("res://src/presentation/frontend/frontend_settings.gd")
const SettingsStore=preload("res://src/persistence/settings_store.gd")
var sim = Simulation.new()
var store=SaveStore.new()
var sound
var save_clock:=0.0
var save_error:=""
var save_retry_pending:=false
var archive_warning:=""
var archive_status:VBoxContainer
var archive_status_text:Label
var save_retry_button:Button
var archive_dismiss_button:Button
var settings={"music":0.5,"effects":0.8,"mute":false}
var scroll: ScrollContainer
var ocean
var route_editor
var mission_hud
var hud: Control
var title_label: Label
var status_label: Label
var log_label: Label
var detail_label: Label
var pause_button: Button
var unit_buttons: Array=[]
var order_buttons: Dictionary={}
var menu: PanelContainer
var panel_box: VBoxContainer
var screen := "menu":
	set(value):
		screen = value
		if ocean != null:
			ocean.presenting_mission = value == "mission"
			if value != "mission" and ocean.optical_feed != null: ocean.optical_feed.hide()
		if value != "mission" and lock_warning != null: lock_warning.hide()
		if value != "mission" and audio_captions != null: audio_captions.hide()
var mission_index := 0
var active_started := false
var applying_safe_area := false
var unlocked := 0
var completed: Array=[]
var expedition:Dictionary={}
var end_of_line_seen=false
var fleet:Dictionary={}
var economy:Dictionary=preload("res://src/campaign/economy.gd").new_state()
var challenge_records:Dictionary={}
var fitted_equipment:Dictionary=preload("res://src/equipment/equipment_catalog.gd").default_loadout()
var upgrade := "endurance"
var capture_scenario := ""
var frame := 0
var capture_path := ""
var menu_buttons: Array=[]
var recovered_evidence: Dictionary={}
var photo_records: Dictionary={}
var photo_intel: Dictionary={}
const PhotoIntel=preload("res://src/campaign/photo_intel.gd")
const PhotoView=preload("res://src/presentation/photo_view.gd")
const PhotoCapture=preload("res://src/simulation/photo_capture.gd")
var diagnostic_ready := ""
var diagnostic_records: Dictionary={}
var diagnostic_roles: Dictionary={}
var diagnostic_role_route_ready:=false
var map_gesture=preload("res://src/input/map_gesture.gd").new()
var zoom_buttons: Array=[]
var advanced_button: Button
var advanced_orders:=false
var decoy_armed:=false
var decoy_unit:=-1
var knock_armed:=false
var targeting_feedback:=""
var knock_press:Dictionary={}
var ui_touch_height:=48.0
var mission_row_heights:=Vector3.ZERO
var mission_reflow_pending:=false
var menu_footer: HBoxContainer
var scroll_report_timer: Timer
var metrics_session:=""
var metrics_serial:=0
var departure_confirmation=""
var hints_seen:Array=[]
var early_reward:Dictionary={}
var lock_warning
var audio_captions
var settings_path="user://settings.json"
func _ready() -> void:
	get_tree().auto_accept_quit=false
	_theme()
	ocean=OceanView.new(); add_child(ocean)
	zoom_buttons.append(_button(ocean,"−",func(): _chart_zoom(1.0/1.4)))
	zoom_buttons.append(_button(ocean,"+",func(): _chart_zoom(1.4)))
	zoom_buttons.append(_button(ocean,"FIT",func(): ocean.fit_chart(); _view_changed()))
	hud=Control.new(); hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); hud.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(hud)
	title_label=_label(hud,"",26)
	status_label=_label(hud,"",17)
	log_label=_label(hud,"",16)
	detail_label=_label(hud,"",16); detail_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	pause_button=_button(hud,"▶  RESUME",_pause)
	for i in 3:
		var id=i
		unit_buttons.append(_button(hud,["QUIETUS","DRONE A","DRONE B"][i],func(): _order("select",{"unit":id})))
	var orders=[["ping","SONAR"],["camera","CAMERA"],["silent","SILENT"],["queue","+ QUEUE"],["hold","HOLD"],["emp","DISRUPT"],["decoy","DECOY"],["recon","SURVEY"],["contact_hold","IF CONTACT"],["wait_drone","WAIT DRONE"],["waypoint_mode","WAYPOINT: PASS"],["program","PLAN ROUTE"],["knock","TORPEDO"]]
	for o in orders:
		var order=o[0]
		order_buttons[order]=_button(hud,o[1],func(): _primary_action() if order=="camera" else _order(order))
	advanced_button=_button(hud,"MORE ORDERS",_toggle_advanced)
	order_buttons["home"]=_button(hud,"EXTRACT",_recovery_route)
	order_buttons["menu"]=_button(hud,"OPERATIONS",func(): sim.paused=true; _show_campaign())
	for button in [pause_button,advanced_button]+unit_buttons+order_buttons.values():
		button.minimum_size_changed.connect(_queue_mission_reflow)
	mission_hud=preload("res://src/presentation/mission_hud.gd").new();hud.add_child(mission_hud);mission_hud.setup(self)
	audio_captions=preload("res://src/presentation/accessibility/caption_view.gd").new();hud.add_child(audio_captions)
	lock_warning=preload("res://src/presentation/lock_warning.gd").new();hud.add_child(lock_warning)
	menu=PanelContainer.new(); add_child(menu)
	# Shaped text can shrink a previous minimum after container reflow.
	# Reapply the window bounds once that minimum settles.
	menu.minimum_size_changed.connect(_layout,CONNECT_DEFERRED)
	var stack=VBoxContainer.new(); stack.add_theme_constant_override("separation",12); menu.add_child(stack)
	# Archive state belongs to the session, outside disposable menu contents and
	# transient world messages. Keep it visible above the menu's scrolling body.
	archive_status=VBoxContainer.new();archive_status.name="ArchiveStatus";stack.add_child(archive_status)
	archive_status_text=_label(archive_status,"",17);archive_status_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	archive_status_text.add_theme_color_override("font_color",Color("efc28d"))
	var archive_actions=HBoxContainer.new();archive_actions.add_theme_constant_override("separation",12);archive_status.add_child(archive_actions)
	save_retry_button=_button(archive_actions,"RETRY SAVE",_save_archive,"retry_save");save_retry_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	archive_dismiss_button=_button(archive_actions,"DISMISS NOTICE",_dismiss_archive_warning,"ack_archive_warning");archive_dismiss_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	_update_archive_status()
	scroll=ScrollContainer.new(); scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; stack.add_child(scroll)
	scroll_report_timer=Timer.new(); scroll_report_timer.one_shot=true; scroll_report_timer.wait_time=0.15; add_child(scroll_report_timer)
	scroll_report_timer.timeout.connect(_report_targets)
	scroll.get_v_scroll_bar().value_changed.connect(func(_value): scroll_report_timer.start())
	panel_box=VBoxContainer.new(); panel_box.size_flags_horizontal=Control.SIZE_EXPAND_FILL; panel_box.add_theme_constant_override("separation",14); scroll.add_child(panel_box)
	menu_footer=HBoxContainer.new(); menu_footer.add_theme_constant_override("separation",12); stack.add_child(menu_footer); menu_footer.hide()
	route_editor=preload("res://src/presentation/route_program_panel.gd").new(); add_child(route_editor)
	sound=Soundscape.new(); add_child(sound)
	preload("res://src/presentation/first_siren_cue/first_siren_cue.gd").install(self)
	preload("res://src/presentation/death_cause/cause_log.gd").install(self)
	resized.connect(_layout)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="): capture_scenario=arg.get_slice("=",1)
		if arg.begins_with("--capture-path="): capture_path=arg.trim_prefix("--capture-path=")
	_start_mission(0)
	active_started=false
	if capture_scenario.is_empty(): _load_archive(); _show_campaign(); _boot_frontend()
	else: _scenario(capture_scenario)
	_layout()
# Title/settings/credits overlay. Any failure leaves the original campaign menu as the boot screen.
func _boot_frontend() -> void:
	var script=load("res://src/presentation/frontend/frontend.gd")
	if script==null or not script.can_instantiate(): return
	var front=script.new(); add_child(front)
	front.settings_store.path=settings_path
	if not front.setup(self): remove_child(front); front.queue_free()
func _theme() -> void:
	var t=Theme.new(); t.default_font_size=17
	var normal=StyleBoxFlat.new(); normal.bg_color=Color("102831"); normal.border_color=Color("36545d"); normal.set_border_width_all(1); normal.set_corner_radius_all(5); normal.content_margin_left=12; normal.content_margin_right=12; normal.content_margin_top=10; normal.content_margin_bottom=10
	var hover=normal.duplicate(); hover.bg_color=Color("20444c"); hover.border_color=Color("6bd5cb")
	var pressed=normal.duplicate(); pressed.bg_color=Color("37605e")
	t.set_stylebox("normal","Button",normal); t.set_stylebox("hover","Button",hover); t.set_stylebox("pressed","Button",pressed); t.set_stylebox("focus","Button",hover)
	t.set_color("font_color","Button",Color("d0e0df")); t.set_color("font_hover_color","Button",Color("ffffff")); t.set_color("font_color","Label",Color("c3d5d6"))
	var p=StyleBoxFlat.new(); p.bg_color=Color("0a1b25"); p.border_color=Color("47636a"); p.set_border_width_all(1); p.content_margin_left=28; p.content_margin_right=28; p.content_margin_top=22; p.content_margin_bottom=22
	t.set_stylebox("panel","PanelContainer",p); theme=t
func _label(parent: Node,text: String,font_size: int) -> Label:
	var l=Label.new(); l.text=text; l.add_theme_font_size_override("font_size",font_size); parent.add_child(l); return l
func _button(parent: Node,text: String,action: Callable,action_id: String="") -> Button:
	var b=Button.new(); b.text=text; b.custom_minimum_size=Vector2(0,ui_touch_height); b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.pressed.connect(action,CONNECT_DEFERRED); b.focus_mode=Control.FOCUS_ALL; parent.add_child(b)
	if parent==menu_footer: b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	# Let ScrollContainer observe touch-emulated drags begun on menu rows.
	# Its scroll-begin notification cancels the button click; taps still activate.
	if parent==panel_box: b.mouse_filter=Control.MOUSE_FILTER_PASS
	if not action_id.is_empty(): b.set_meta("action",action_id); b.set_meta("ui_action",action_id)
	return b
func ui_density_dpi() -> float:
	return DisplayServer.screen_get_dpi()
func ui_density_source() -> String:
	return "android_display_metrics_density_dpi" if OS.get_name()=="Android" else "desktop_display_server_dpi"
func _queue_mission_reflow() -> void:
	if mission_reflow_pending: return
	mission_reflow_pending=true; call_deferred("_reflow_mission")
func _measured_mission_rows() -> Vector3:
	var heights=Vector3(ui_touch_height,ui_touch_height,ui_touch_height)
	for button in [pause_button,advanced_button]: heights.x=maxf(heights.x,button.get_minimum_size().y)
	for button in unit_buttons: heights.y=maxf(heights.y,button.get_minimum_size().y)
	for button in order_buttons.values(): heights.z=maxf(heights.z,button.get_minimum_size().y)
	return heights
func _reflow_mission() -> void:
	mission_reflow_pending=false
	if screen=="mission" and not _measured_mission_rows().is_equal_approx(mission_row_heights): _layout(false)
func _layout(cancel_gesture:bool=true) -> void:
	if ocean==null:return
	if cancel_gesture:map_gesture.cancel()
	_apply_safe_area()
	ui_touch_height=preload("res://src/presentation/layout_metrics.gd").touch_height(get_viewport_rect().size,Vector2(get_window().size),ui_density_dpi())
	var h=ui_touch_height
	# One maximum-stock reserve scale; NEXT-dive supplies never rescale a live dive.
	ocean.position=Vector2.ZERO;ocean.size=size;ocean.feedback_font_size=maxi(14,roundi(h*.26*FrontendSettings.text_scale()));ocean.instrument_top=h+24;ocean.instrument_height=h;ocean.oxygen_capacity=120.
	_refresh()
	if mission_hud!=null:
		mission_hud.layout(size,h);mission_row_heights=_measured_mission_rows()
		ocean.ui_blocked_rects=mission_hud.occupied_rects().map(func(r):return Rect2(r.position-ocean.global_position,r.size))
	if menu!=null:
		menu.position=Vector2(maxf(24,(size.x-800)/2),24); menu.size=Vector2(minf(800,size.x-48),size.y-48)
		if archive_status_text!=null:archive_status_text.add_theme_font_size_override("font_size",maxi(17,roundi(h*.26*FrontendSettings.text_scale())))
		for button in menu.find_children("*","Button",true,false):
			button.custom_minimum_size.y=h; button.add_theme_font_size_override("font_size",maxi(17,roundi(h*0.29*FrontendSettings.text_scale())))
		for slider in menu.find_children("*","Slider",true,false): slider.custom_minimum_size.y=h
	if route_editor!=null and route_editor.visible: route_editor.configure(size,h)
	call_deferred("_report_targets")
func _start_mission(index: int) -> void:
	fitted_equipment=FleetInventory.reconcile_fitting(fitted_equipment,FleetInventory.available(_equipment_entitlements(),fleet))
	var launch=FleetInventory.launch(fitted_equipment,_equipment_entitlements(),fleet,index,_campaign_completed())
	if not launch.ok:sim.message="Fitting unavailable · choose available hardware or BARE";return
	launch.launch["context"]=_launch_context(index)
	# The first call builds the paused display before loading an archive. Even
	# blocked recovery needs valid craft/UI; later player launches stay guarded.
	if not sim.mission.is_empty() and not preload("res://src/persistence/save_states/save2_controller.gd").before_launch(self,index):return
	if mission_hud!=null and mission_hud.guard!=null:mission_hud.guard.reset()
	diagnostic_ready=""; diagnostic_records.clear(); diagnostic_roles.clear(); diagnostic_role_route_ready=false; map_gesture.cancel(); advanced_orders=false; knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false
	call_deferred("_layout")
	if route_editor!=null: route_editor.hide()
	active_started=true; mission_index=index; sim.start(index,upgrade,launch.launch)
	if mission_hud!=null:
		mission_hud.hints.dismiss();mission_hud.tool_help.cancel()
		mission_hud.subject={};mission_hud.page="craft"
	ocean.sim=sim; ocean.focus_craft(); screen="mission"; menu.hide(); hud.show(); _refresh()
func _primary_action() -> void:
	if decoy_armed or knock_armed:
		decoy_armed=false;knock_armed=false;map_gesture.cancel();knock_press.clear();sim.message="Targeting cancelled";_refresh();return
	var photographic=sim.camera_context()
	if photographic.get("ready",false) and preload("res://src/simulation/photo_context.gd").is_photo(sim,photographic):_order("camera");return
	var shelter=preload("res://src/presentation/shelf_habitat_view.gd").nearest(sim)
	if not shelter.is_empty():mission_hud.open("habitat",shelter);return
	var station=WarningChain.nearest_station(sim)
	if not station.is_empty():mission_hud.open("plant",station);return
	var witness=WitnessView.site(sim)
	if not witness.is_empty() and (not advanced_orders or mission_hud.page=="craft"):mission_hud.open("salvage",{"kind":"salvage","item":witness.item,"name":witness.name.to_upper(),"pos":witness.pos});return
	var recipient=RecipientView.primary_subject(sim)
	if not recipient.is_empty() and (not advanced_orders or mission_hud.page=="craft"):
		mission_hud.open("object",recipient);_refresh();return
	_order("camera")
func _recovery_route() -> void:
	var destinations=sim.extraction_corridors()
	if preload("res://src/presentation/expedition_view.gd").entry(sim):
		destinations.append({"pos":sim.mission.extraction,"name":"INCOMPLETE WITHDRAWAL","withdrawal":true})
	if destinations.size()==1:_order("route",{"point":destinations[0].pos})
	elif not destinations.is_empty():mission_hud.open_recovery(destinations)
func _order(order: String,args: Dictionary={}) -> void:
	if advanced_orders and order!="select":
		mission_hud.dismiss()
	if order=="program":
		knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false
		map_gesture.cancel(); sim.paused=true; screen="program"; hud.hide(); menu.hide()
		for button in zoom_buttons: button.hide()
		print("SS_SCREEN program paused=",sim.paused)
		route_editor.open(self); call_deferred("_report_targets"); _save_archive(); return
	if order=="decoy" and not args.has("point"):
		targeting_feedback=""
		map_gesture.cancel(); knock_armed=false; ocean.knock_targeting=false
		if sim.units[sim.selected].alive and sim.tools.decoy>0 and sim.outcome.is_empty():decoy_armed=not decoy_armed;decoy_unit=sim.selected
		else:decoy_armed=false;sim.message="Decoy unavailable · no charge spent"
		_refresh(); print("SS_DECOY_AIM armed=",decoy_armed," selected=",sim.selected); call_deferred("_report_targets"); return
	if order=="knock" and not args.has("target"):
		targeting_feedback=""
		map_gesture.cancel();decoy_armed=false;ocean.decoy_targeting=false
		if sim.selected==0 and sim.units[0].alive and sim.tools.get("knock",0)>0 and sim.outcome.is_empty(): knock_armed=not knock_armed
		else: knock_armed=false; sim.message="Knockdown: Quietus launcher or torpedoes unavailable."
		_refresh(); return
	map_gesture.cancel()
	var aiming=knock_armed;var aiming_decoy=decoy_armed
	knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false
	var undo_record={}
	if order=="route" and sim.outcome.is_empty() and mission_hud!=null and mission_hud.guard!=null:undo_record=mission_hud.guard.capture()
	var accepted=sim.command(order,args)
	if accepted and not undo_record.is_empty():mission_hud.guard.arm_undo(undo_record)
	if order=="knock" and not accepted: knock_armed=aiming
	if order=="decoy" and not accepted:decoy_armed=aiming_decoy
	if not accepted and (knock_armed or decoy_armed):targeting_feedback=sim.message
	print("SS_ORDER ",order," accepted=",accepted," selected=",sim.selected," queued=",sim.queue_mode)
	_refresh(); _save_archive()
	if accepted and order=="camera": call_deferred("_report_targets")
func _pause() -> void:
	sim.paused=not sim.paused; print("SS_PAUSE paused=",sim.paused); _refresh(); _save_archive()
func _confirm_module_departure()->void:
	ModuleRecovery.confirm_departure(self)
func _process(dt: float) -> void:
	frame+=1
	if frame==4 and not capture_path.is_empty(): _take_capture()
	if sound!=null: sound.update(sim,dt,screen=="mission")
	if screen=="mission" and not sim.paused:
		save_clock+=dt
		if save_clock>5.0: _save_archive(); save_clock=0.0
	if screen=="mission":
		sim.advance(dt)
		_observation_diagnostics()
		if not sim.outcome.is_empty(): _debrief()
		elif sim.has_method("departure_context") and sim.departure_context().get("pending",false): _confirm_module_departure()
		_refresh()
func _refresh() -> void:
	if lock_warning!=null:lock_warning.refresh(self)
	if decoy_armed and (screen!="mission" or sim.selected!=decoy_unit or not sim.units[sim.selected].alive or sim.tools.decoy<=0 or not sim.outcome.is_empty()):decoy_armed=false
	ocean.decoy_targeting=decoy_armed
	if knock_armed and (screen!="mission" or sim.selected!=0 or not sim.units[0].alive or not sim.outcome.is_empty()): knock_armed=false
	ocean.knock_targeting=knock_armed; ocean.knock_touch_size=ui_touch_height
	if not knock_armed and not decoy_armed:targeting_feedback=""
	title_label.text="SIREN'S SONG    /    %02d  %s"%[mission_index+1,sim.mission.title.to_upper()]
	status_label.text="DEPTH %dm    O₂ %03d%%    HULL %03d%%    RECORDS %d / %d    %s"%[sim.mission.depth,int(sim.oxygen),int(sim.hull),sim.mission.objectives.filter(func(o): return o.captured and not o.get("optional",false)).size(),sim.mission.objectives.filter(func(o): return not o.get("optional",false)).size(),"TACTICAL PAUSE" if sim.paused else "REAL TIME"]
	pause_button.text="▶ RESUME" if sim.paused else "Ⅱ PAUSE"
	for i in 3:
		var work=sim.capture_feedback(i)
		var capture_task={"receiver":"LISTEN","exchange":"SAMPLE","uplink":"LINK"}.get(PhotoCapture.obj(sim,work.target).get("kind",""),"PHOTO" if PhotoCapture.applies(PhotoCapture.obj(sim,work.target)) else "CAMERA") if work.unit>=0 else ""
		unit_buttons[i].modulate=Color("80d9cf") if sim.selected==i else Color.WHITE
		unit_buttons[i].disabled=not sim.units[i].alive
		var task="LOST" if not sim.units[i].alive else (capture_task if work.unit>=0 else (sim.units[i].hold if not sim.units[i].hold.is_empty() else ("ROUTE" if not sim.units[i].route.is_empty() else "READY")))
		task={"SCOUT_STOP":"ALERT"}.get(task,task)
		unit_buttons[i].text=["QUIETUS","DRONE A","DRONE B"][i]+"\n"+task
		unit_buttons[i].add_theme_font_size_override("font_size",maxi(14,roundi(ui_touch_height*0.26*FrontendSettings.text_scale())))
	order_buttons.waypoint_mode.text="PASS\nPOINTS" if sim.pass_through else "STOP AT\nPOINTS"
	ocean.optical_feed.receiver_font_size=maxi(17,roundi(ui_touch_height*0.29*FrontendSettings.text_scale()))
	ocean.optical_feed.touch_height=ui_touch_height
	order_buttons.camera.text="SAMPLE" if sim.mission.get("blackwater_revision",0)==1 else "CAMERA\nLISTEN" if sim.mission.get("finale_revision",0)==1 else ("CAMERA\nLINK" if mission_index==1 else "CAMERA")
	var camera_target:int=int(sim.camera_context().get("target",-1))
	if camera_target==-2 or (camera_target>=0 and PhotoCapture.applies(PhotoCapture.obj(sim,camera_target))):order_buttons.camera.text="PHOTO"
	elif camera_target>=0 and PhotoCapture.obj(sim,camera_target).get("kind","")=="receiver" and sim.mission.get("blackwater_revision",0)!=1:order_buttons.camera.text="LISTEN"
	order_buttons.queue.text="+ QUEUE ON" if sim.queue_mode else "REPLACE"
	order_buttons.program.text="PLAN\nROUTE"
	order_buttons.silent.text=("LOW\nPROFILE" if sim.units[sim.selected].silent else "OPEN\nPROFILE") if sim.selected>0 else ("SILENT ✓" if sim.units[0].silent else "CRUISE")
	order_buttons.knock.text="CANCEL\nTORPEDO" if knock_armed else "TORPEDO\n%d"%sim.tools.get("knock",0)
	order_buttons.knock.disabled=not knock_armed and (sim.selected!=0 or not sim.units[0].alive or sim.tools.get("knock",0)<=0)
	order_buttons.emp.text="DISRUPT\n%d"%sim.tools.emp
	order_buttons.emp.disabled=sim.tools.emp<=0
	order_buttons.decoy.text="CANCEL\nDECOY" if decoy_armed else "DECOY\n%d"%sim.tools.decoy
	order_buttons.decoy.disabled=sim.tools.decoy<=0 and not decoy_armed
	order_buttons.recon.text="SURVEY\n%d"%sim.tools.recon
	order_buttons.recon.disabled=sim.tools.recon<=0
	log_label.text=preload("res://src/presentation/archive/voice_feed.gd").log_text(self,sim.message)
	if sim.mission.get("well_revision",0)==1 and sim.mission.objectives[0].captured:
		var comparison="MATCH RECORDED" if not sim.mission.well_observation.is_empty() else ("REFERENCE LOGGED" if not sim.mission.well_reference.is_empty() else "UNVERIFIED")
		log_label.text="WELL · %s | %s"%[comparison,log_label.text]
	advanced_button.text="BACK\nORDERS" if advanced_orders else "MORE\nORDERS"
	order_buttons.menu.text="MENU"
	var scout=sim.scout_context()
	order_buttons.contact_hold.text="IF\nCONTACT" if sim.selected==0 else ("FLEET\nGUARD" if scout.state=="legacy" else ("SCOUT\nRESUME" if scout.state=="stopped" else ("SCOUT\nON" if scout.state=="armed" else "SCOUT\nGUARD")))
	order_buttons.wait_drone.text="WAIT\nDRONE"
	var mode="ADD TO ROUTE" if sim.queue_mode else "REPLACE ROUTE"
	var goals=sim.route_goals(); var intent=""
	if not goals.is_empty(): intent="TO 1: %s / %s · "%[route_editor.mode_label(goals[0].mode,sim.selected>0),"STOP" if goals[0].stop else "PASS"]
	if sim.selected>0:intent="DRIVE %s · "%["QUIET42" if sim.units[sim.selected].get("drone_drive","transit")=="quiet" else "TRANSIT96"]+intent
	var context=sim.camera_context().text
	if scout.state=="armed":context="SCOUT: own passive contact stops · route kept"
	elif scout.state=="stopped":context=("SCOUT braking" if sim.units[sim.selected].vel.length()>2 else "SCOUT holding")+" · own contact · route kept · SCOUT resumes"
	elif scout.state=="legacy":context="FLEET GUARD · any fresh fleet contact holds"
	detail_label.text="%s · %s · %s%s"%[sim.units[sim.selected].name.to_upper(),mode,intent,context]
	if decoy_armed:detail_label.text="DECOY · %s · CLEAR PATH · 160m · 15s · CANCEL"%sim.units[sim.selected].name.to_upper()
	if knock_armed: detail_label.text="TORPEDO · QUIETUS · 150m · noisy flight · impact pins 8s · tap fresh S# · CANCEL"
	if mission_hud!=null:mission_hud.refresh()
	if audio_captions!=null:audio_captions.refresh(self)
func _focus_craft() -> void:
	map_gesture.cancel();ocean.focus_craft();_refresh();_view_changed()
func _toggle_advanced() -> void:
	if advanced_orders:mission_hud.dismiss()
	else:mission_hud.open("craft",{"kind":"craft","unit":sim.selected,"pos":sim.units[sim.selected].pos})
func _input(event:InputEvent) -> void:
	if screen!="mission":return
	if mission_hud.owns_pointer(event):get_viewport().set_input_as_handled();return
	if mission_hud.fleet.handle_input(event):get_viewport().set_input_as_handled();return
	if advanced_orders:
		map_gesture.cancel();knock_press.clear()
		if mission_hud.popup_input(event):get_viewport().set_input_as_handled()
		return
	if not map_gesture.active():return
	var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed)
	if pressed and (not ocean.get_global_rect().has_point(event.position) or mission_hud.blocks(event.position)):
		map_gesture.cancel();return
	if _map_event(event):get_viewport().set_input_as_handled()
func _gui_input(event: InputEvent) -> void:
	if screen!="mission": return
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		if mission_hud.blocks(event.position+global_position):return
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed and Rect2(ocean.position,ocean.size).has_point(event.position):
		map_gesture.cancel(); ocean.zoom_at(1.2 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1.0/1.2,event.position-ocean.position); _view_changed(); accept_event(); return
	var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT)
	if pressed and Rect2(ocean.position,ocean.size).has_point(event.position) and _map_event(event,true): accept_event()
func _map_event(event: InputEvent,local_event: bool=false) -> bool:
	if event.device==InputEvent.DEVICE_ID_EMULATION: return false
	if event is InputEventScreenTouch and event.canceled: map_gesture.cancel(); knock_press.clear(); return true
	var kind=""; var index=-1; var point=Vector2.ZERO
	if event is InputEventScreenTouch:
		kind="press" if event.pressed else "release"; index=event.index; point=event.position
	elif event is InputEventScreenDrag:
		kind="move"; index=event.index; point=event.position
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		kind="press" if event.pressed else "release"; point=event.position
	elif event is InputEventMouseMotion and map_gesture.active():
		kind="move"; point=event.position
	if kind.is_empty(): return false
	if local_event: point+=global_position
	if kind=="press" and not map_gesture.active():
		knock_press={"armed":knock_armed,"decoy":decoy_armed,"unit":sim.selected,"key":ocean.knock_aim_key(point-ocean.global_position) if knock_armed else -1}
	var action=map_gesture.feed(kind,index,point)
	if action.has("zoom"): ocean.zoom_at(action.zoom,action.anchor-ocean.global_position)
	if action.has("pan"): ocean.pan_chart(action.pan)
	if action.get("navigation",false): _view_changed()
	if action.has("tap") and ocean.get_global_rect().has_point(action.tap) and not mission_hud.blocks(action.tap):
		if knock_armed or knock_press.get("armed",false):
			if knock_armed and knock_press.get("armed",false):_target_knockdown(action.tap,knock_press.get("key",-1))
			knock_press.clear(); return true
		if decoy_armed or knock_press.get("decoy",false):
			if decoy_armed and knock_press.get("decoy",false) and knock_press.get("unit",-1)==sim.selected:
				_order("decoy",{"point":ocean.map_position(action.tap-ocean.global_position)})
			knock_press.clear(); return true
		var context=ocean.pick_context(action.tap-ocean.global_position,ui_touch_height)
		if not context.is_empty():
			if context.kind=="craft" and context.unit!=sim.selected:_order("select",{"unit":context.unit})
			mission_hud.open("inspect" if context.get("subkind","")=="concealed" else "habitat" if context.kind=="habitat" else "object" if context.kind=="objective" else "salvage" if context.kind=="salvage" else "fleet" if context.kind=="fleet" else "craft",context);return true
		var world=ocean.map_position(action.tap-ocean.global_position)
		if Rect2(Vector2.ZERO,ocean.world_size()).has_point(world): mission_hud.guard.tap_water(world)
	if action.has("ended") or action.has("tap"):knock_press.clear()
	return true
func _target_knockdown(point: Vector2,intended:int=-2) -> void:
	var chosen=ocean.knock_aim_key(point-ocean.global_position) if intended==-2 else intended
	if chosen<0 or not ocean.knock_visible_targets().any(func(c):return c.key==chosen):
		sim.message="Choose an S# FIRE box or a clear contact · no torpedo spent"
		for id in sim.contacts:
			var contact=sim.contacts[id]
			if sim.elapsed-contact.time>=.3:continue
			if ocean.screen_position(contact.pos).distance_to(point-ocean.global_position)>maxf(ui_touch_height/2,43*ocean.world_scale):continue
			if contact.get("mode","") in ["DISRUPTED","PINNED"]:
				sim.message="S%d %s · shot declined · no torpedo spent"%[int(id)+1,"disrupted" if contact.mode=="DISRUPTED" else "already snared"]
				break
			var distance=sim.units[0].pos.distance_to(contact.pos)
			if distance>sim.KNOCK_RANGE:
				sim.message="S%d out of range · %dm / %dm · no torpedo spent"%[int(id)+1,ceili(distance),roundi(sim.KNOCK_RANGE)]
				break
		targeting_feedback=sim.message; _refresh(); return
	_order("knock",{"target":chosen})
func _chart_zoom(factor: float) -> void:
	map_gesture.cancel(); ocean.zoom_at(factor,ocean.size/2); _view_changed()
func _view_changed() -> void:
	_refresh()
	_save_archive()
	print("SS_VIEW zoom=",snappedf(ocean.chart_camera.zoom,0.01)," center=",ocean.chart_camera.center)
	call_deferred("_report_targets")
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if _frontend_back():get_viewport().set_input_as_handled();return
	if screen=="program":
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE: route_editor.close()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		# SPACE pauses only live play; menus, briefing and settings never touch mission pause.
		if event.keycode==KEY_SPACE and screen=="mission": _pause()
		if event.keycode==KEY_ESCAPE:
			if advanced_orders:mission_hud._back()
			elif knock_armed or decoy_armed:_primary_action()
			else:sim.paused=true;_show_campaign()
func _clear_menu() -> void:
	var resolution=get_node_or_null("ConfluenceResolution")
	if resolution!=null:remove_child(resolution);resolution.queue_free()
	advanced_orders=false
	if mission_hud!=null:mission_hud.instruments_open=false
	if route_editor!=null: route_editor.hide()
	knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false; map_gesture.cancel()
	for button in zoom_buttons: button.hide()
	for parent in [panel_box,menu_footer]:
		for c in parent.get_children(): c.queue_free(); parent.remove_child(c)
	menu_footer.hide()
	menu.show(); hud.hide(); scroll.scroll_vertical=0
func _menu_text(text: String,font_size: int=17) -> Label:
	var l=_label(panel_box,text,roundi(font_size*ui_touch_height/48.0*preload("res://src/presentation/frontend/frontend_settings.gd").text_scale())); l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; l.custom_minimum_size.x=minf(610,size.x-120); return l
func _loadout_stock(choice: String) -> Array:
	return CampaignFlow.loadout_stock(self, choice)
func _show_campaign() -> void:
	CampaignFlow.show_campaign(self)
# A campaign with nothing recovered yet has no progress to resume or replace.
func _campaign_pristine()->bool:
	return CampaignFlow.campaign_pristine(self)
func _show_fittings()->void:
	CampaignFlow.show_fittings(self)
func _show_economy()->void:
	preload("res://src/presentation/economy_panel.gd").show(self)
func _cycle_loadout()->void:
	CampaignFlow.cycle_loadout(self)
func _orders_text(briefing:Dictionary) -> String:
	return CampaignFlow.orders_text(self, briefing)
const RULES_TEXT="SPACE / PAUSE grants unlimited planning time. Silent running is slower and quieter. Disruption interrupts nearby Sirens for 12 seconds. Quietus torpedoes travel noisily up to 150m; impact pins one Siren for 8s. Cover blocks sonar, enemy sight and torpedoes."
func _briefing(index: int) -> void:
	CampaignFlow.briefing(self, index)
func _fold_fit(nodes:Array,holder:Array) -> void:
	CampaignFlow.fold_fit(self, nodes, holder)
func _reference(index:int) -> void:
	CampaignFlow.show_reference(self, index)
func _launch_context(index:int)->Dictionary:
	return CampaignFlow.launch_context(self, index)
func _equipment_entitlements()->Array:
	return CampaignFlow.equipment_entitlements(self)
func _campaign_completed()->Array:
	return CampaignFlow.campaign_completed(self)
func _equipment_context()->Dictionary:
	return CampaignFlow.equipment_context(self)
func _choose_equipment(slot:String,item:String,index:int)->void:
	CampaignFlow.choose_equipment(self, slot, item, index)
func _debrief() -> void:
	CampaignFlow.debrief(self)
func _sync_craft_upgrades()->void:
	CampaignFlow.sync_craft_upgrades(self)
func _show_photo_grade(records:Array)->void:
	PhotoReview.show_photo_grade(self, records)
func _show_ending()->void:
	CampaignFlow.show_ending(self)
func _confirm_new_campaign()->void:
	CampaignFlow.confirm_new_campaign(self)
func _new_campaign()->void:
	CampaignFlow.new_campaign(self)
func _scenario(name: String) -> void:
	if name=="menu": _show_campaign(); return
	sim.command("route",{"point":Vector2(1000,800)})
	sim.command("select",{"unit":1}); sim.command("route",{"point":Vector2(900,240)})
	sim.command("select",{"unit":2}); sim.command("route",{"point":Vector2(1280,480)})
	sim.command("select",{"unit":0}); sim.command("ping")
	if name=="debrief": sim.outcome="won"; _debrief()
	if name=="ending": _start_mission(5); sim.outcome="won"; _debrief()
	if name=="briefing": _briefing(0)
	if name=="camera":
		_start_mission(0); sim.command("select",{"unit":1}); sim.command("route",{"point":Vector2(1300,510)}); sim.paused=false
		for n in 250:
			sim.advance(0.1)
			if sim.units[1].route.is_empty() and sim.units[1].vel.length()<2: break
		sim.command("camera")
		for n in 20: sim.advance(0.1)
		sim.paused=true
	if name=="beam":
		_start_mission(0); sim.command("route",{"point":Vector2(700,200)}); sim.paused=false
		var anchored=false
		for n in 1600:
			sim.advance(0.1)
			var beam=false
			for c in sim.contacts.values():
				if c.lock>0.1 and not anchored: sim.command("hold"); anchored=true
				if c.lock>=4.15 and sim.elapsed-c.time<0.3: beam=true
			if beam or not sim.outcome.is_empty(): break
		sim.paused=true
	if name=="split":
		_start_mission(1)
		for id in [1,2,0]:
			sim.command("select",{"unit":id}); sim.command("route",{"point":[Vector2(840,780),Vector2(420,490),Vector2(1220,490)][id]})
		sim.paused=false
		for n in 70: sim.advance(0.1)
		sim.command("select",{"unit":1}); sim.command("camera"); sim.command("select",{"unit":0})
		for n in 15: sim.advance(0.1)
		sim.paused=true
	if name in ["field","threat"]:
		_start_mission(3 if name=="field" else 2)
		sim.command("route",{"point":Vector2(1200,480) if name=="field" else Vector2(760,410)})
		sim.command("select",{"unit":1}); sim.command("route",{"point":Vector2(1320,430) if name=="field" else Vector2(1000,600)})
		sim.command("select",{"unit":2}); sim.command("route",{"point":Vector2(1300,740)})
		sim.command("select",{"unit":0}); sim.paused=false
		for n in 330:
			sim.advance(0.1)
			for c in sim.contacts.values():
				if c.lock>1 and sim.tools.emp>0: sim.command("emp"); break
		sim.command("ping")
		if name=="camera": sim.command("camera")
		sim.paused=true

func _archive() -> Dictionary:
	var data={"version":SaveStore.VERSION,"unlocked":unlocked,"completed":completed.duplicate(),"upgrade":upgrade,"settings":settings.duplicate(),"evidence":recovered_evidence.duplicate(true),"active":sim.snapshot(),"chart_view":ocean.chart_camera.snapshot()}
	if not photo_records.is_empty():data["photo_records"]=photo_records.duplicate(true)
	if not photo_intel.is_empty():data["intel"]=photo_intel.duplicate(true)
	if not expedition.is_empty():data["expedition"]=expedition.duplicate(true)
	if not fleet.is_empty():data["fleet"]=fleet.duplicate(true)
	data["economy"]=economy.duplicate(true)
	if not hints_seen.is_empty():data["hints_seen"]=hints_seen.duplicate()
	if not early_reward.is_empty():data["early_reward"]=early_reward.duplicate(true)
	preload("res://src/presentation/first_siren_cue/cue_archive.gd").write(self,data)
	preload("res://src/presentation/finale/finale.gd").write(self,data)
	preload("res://src/presentation/archive/voice_feed.gd").write(self,data)
	preload("res://src/persistence/save_states/save2_controller.gd").write(self,data)
	data["equipment"]=preload("res://src/equipment/equipment_catalog.gd").canonical(fitted_equipment)
	return data
func _save_archive() -> void:
	_write_archive(false)
func _retry_archive()->void:
	if not save_retry_pending:return
	save_retry_pending=false
	_write_archive(true)
func _write_archive(retry:bool)->void:
	if not capture_scenario.is_empty() or sim.mission==null:return
	_sync_craft_upgrades()
	if store.save(_archive()):
		save_retry_pending=false;save_error=""
		print("SS_SAVE ok mission=",mission_index," time=",snappedf(sim.elapsed,0.01)," paused=",sim.paused," completed=",completed," unlocked=",unlocked)
	elif retry:
		save_error=store.warning;sim.message=save_error
		print("SS_SAVE retry_failed reason=",store.warning," active.captures=",sim.captures)
	else:
		print("SS_SAVE retry_pending reason=",store.warning," active.captures=",sim.captures)
		if not save_retry_pending:
			save_retry_pending=true;call_deferred("_retry_archive")
	_update_archive_status()
func _dismiss_archive_warning()->void:
	archive_warning="";_update_archive_status()
func _update_archive_status()->void:
	if archive_status==null:return
	var lines=[]
	if not save_error.is_empty():lines.append("PROGRESS NOT SAVED\n"+save_error+"\nCurrent progress is held in this session only.")
	if not archive_warning.is_empty():lines.append("ARCHIVE NOTICE\n"+archive_warning)
	var text="\n\n".join(lines);var changed=archive_status_text.text!=text
	archive_status_text.text=text;archive_status.visible=not text.is_empty()
	save_retry_button.visible=not save_error.is_empty();archive_dismiss_button.visible=not archive_warning.is_empty()
	if changed:call_deferred("_layout")
func _load_archive() -> void:
	var saved=store.load_game()
	preload("res://src/presentation/finale/finale.gd").restore(self,saved)
	if not saved.is_empty():
		unlocked=saved.unlocked; completed=saved.completed; upgrade=saved.upgrade; settings=saved.settings
		early_reward=saved.get("early_reward",{}).duplicate(true)
		expedition=saved.get("expedition",{}).duplicate(true)
		fleet=saved.get("fleet",{}).duplicate(true)
		photo_intel=saved.get("intel",{}).duplicate(true)
		fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").canonical(saved.get("equipment",{}))
		fitted_equipment=FleetInventory.reconcile_fitting(fitted_equipment,FleetInventory.available(_equipment_entitlements(),fleet))
		var Economy=preload("res://src/campaign/economy.gd")
		economy=saved.economy.duplicate(true) if saved.has("economy") else Economy.legacy_state(fitted_equipment)
		recovered_evidence=saved.get("evidence",{})
		photo_records=saved.get("photo_records",{}).duplicate(true)
		preload("res://src/presentation/archive/voice_feed.gd").restore(self,saved)
		hints_seen=saved.get("hints_seen",[]).duplicate()
		preload("res://src/presentation/first_siren_cue/cue_archive.gd").restore_types(self,saved)
		if saved.get("active") is Dictionary and sim.restore(saved.active):
			preload("res://src/presentation/first_siren_cue/cue_archive.gd").restore(self,saved)
			active_started=true; mission_index=sim.mission.id; ocean.sim=sim
			ocean._sync_camera()
			var chart_view=saved.get("chart_view",{})
			if chart_view is Dictionary:ocean.chart_camera.restore(chart_view)
			print("SS_RESTORE ok mission=",mission_index," time=",snappedf(sim.elapsed,0.01)," paused=",sim.paused," completed=",completed," unlocked=",unlocked)
	preload("res://src/persistence/save_states/save2_controller.gd").restore(self,saved)
	sound.music_volume=settings.get("music",0.5); sound.effects_volume=settings.get("effects",0.8); sound.muted=settings.get("mute",false)
	if not store.warning.is_empty():archive_warning=store.warning;sim.message=store.warning
	_update_archive_status()
func _settings_menu() -> void:
	if preload("res://src/presentation/frontend/menu_reach.gd").settings(self):return
	_clear_menu(); screen="settings"
	_menu_text("QUIETUS / SETTINGS",30)
	_menu_text("Actionable sound cues also appear in the tactical display. Audio pauses when you suspend the dive.",18)
	for field in ["music","effects"]:
		var key=field
		_menu_text("%s VOLUME"%key.to_upper(),17)
		var slider=HSlider.new(); slider.min_value=0; slider.max_value=1; slider.step=0.05; slider.value=settings.get(key,0.5); slider.custom_minimum_size.y=ui_touch_height; slider.set_meta("ui_action","volume_"+key); panel_box.add_child(slider)
		slider.value_changed.connect(func(value): settings[key]=value; sound.set(key+"_volume",value); _save_archive())
	var audio_modes=HBoxContainer.new(); audio_modes.add_theme_constant_override("separation",8); panel_box.add_child(audio_modes)
	var mute_button=_button(panel_box,"MUTE: %s"%("ON" if sound.muted else "OFF"),func(): sound.muted=not sound.muted; settings.mute=sound.muted; _save_archive(); _settings_menu(),"mute")
	var night_button=_button(panel_box,"NIGHT MODE: %s"%("ON" if FrontendSettings.current.night_mode else "OFF"),func():_set_accessibility("night_mode",not FrontendSettings.current.night_mode),"setting_night_mode")
	for button in [mute_button,night_button]:
		button.reparent(audio_modes); button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	_menu_text("TEXT SIZE · applies to menus and the dive display",17)
	var sizes=HBoxContainer.new(); sizes.add_theme_constant_override("separation",8); panel_box.add_child(sizes)
	for choice in [["NORMAL",1.0],["LARGE",1.3],["EXTRA LARGE",1.5]]:
		var scale:float=choice[1]
		var b=Button.new(); b.text=choice[0]; b.custom_minimum_size=Vector2(0,ui_touch_height); b.size_flags_horizontal=Control.SIZE_EXPAND_FILL; b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		b.focus_mode=Control.FOCUS_ALL; b.toggle_mode=true; b.button_pressed=is_equal_approx(FrontendSettings.text_scale(),scale)
		b.set_meta("action","text_scale_%d"%roundi(scale*100)); b.set_meta("ui_action","text_scale_%d"%roundi(scale*100))
		b.pressed.connect(_set_text_scale.bind(scale),CONNECT_DEFERRED); sizes.add_child(b)
	for cap in [30,60]:
		var selected_cap:int=cap
		var b=Button.new(); b.text="CAP %d FPS"%selected_cap; b.custom_minimum_size=Vector2(0,ui_touch_height); b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		b.focus_mode=Control.FOCUS_ALL; b.toggle_mode=true; b.button_pressed=FrontendSettings.current.frame_cap==selected_cap
		b.set_meta("action","frame_cap_%d"%selected_cap); b.set_meta("ui_action","frame_cap_%d"%selected_cap)
		b.pressed.connect(_set_accessibility.bind("frame_cap",selected_cap),CONNECT_DEFERRED); audio_modes.add_child(b)
	_button(panel_box,"SHOW FIRST-DIVE TIPS AGAIN",func(): hints_seen=[]; _save_archive(); sim.message="Tips will show again in the opening operations"; _settings_menu(),"reset_tips")
	for row in [["safe_palette","SAFE PALETTE"],["audio_captions","AUDIO CAPTIONS"],["haptics","HAPTICS"]]:
		var key:String=row[0]
		_button(panel_box,"%s: %s"%[row[1],"ON" if FrontendSettings.current[key] else "OFF"],func():_set_accessibility(key,not FrontendSettings.current[key]),"setting_"+key)
	preload("res://src/presentation/ops_home/ops_home.gd").settings_entry(self)
	_button(menu_footer,"BACK TO OPERATIONS",_show_campaign,"back"); menu_footer.show()
	call_deferred("_layout")
func _set_text_scale(scale:float) -> void:
	_set_accessibility("text_scale",scale)
func _set_accessibility(key:String,value:Variant) -> void:
	var front=get_node_or_null("Frontend")
	if front!=null and front.embedded_settings:
		front._set_value(key,value);front._settings_screen();return
	var store_settings=SettingsStore.new()
	store_settings.path=settings_path
	var values=store_settings.load_settings()
	values[key]=value
	values=SettingsStore.sanitize(values)
	FrontendSettings.apply(values,self)
	store_settings.save_settings(values)
	_settings_menu()
func _notification(what: int) -> void:
	# The isolated challenge session owns lifecycle handling while the campaign is frozen.
	if get_node_or_null("ChallengeSession")!=null:return
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		if sim.mission!=null:
			knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false; map_gesture.cancel()
			sim.paused=true; _save_archive()
			if sound!=null: sound.suspend()
			print("SS_LIFECYCLE suspended paused=true")
	if what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:
		if sound!=null: sound.resume()
		if is_node_ready() and is_inside_tree() and hud!=null:
			print("SS_LIFECYCLE foreground")
			call_deferred("_report_targets")
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		_save_archive(); get_tree().quit()
	if what==NOTIFICATION_WM_GO_BACK_REQUEST:
		sim.paused=true; _save_archive(); call_deferred("_android_back")

func _frontend_back()->bool:
	if preload("res://src/persistence/save_states/save2_controller.gd").back(self):return true
	var front=get_node_or_null("Frontend")
	if front==null or not front.has_method("back"):return false
	front.back()
	return true
var back_exit=null
func _back_exit_handled()->bool:
	if back_exit==null:back_exit=preload("res://src/presentation/back_exit/back_exit_confirm.gd").new();add_child(back_exit)
	return back_exit.handle(self)
func _android_back()->void:
	if not is_inside_tree() or _frontend_back():return
	if _back_exit_handled():return
	# Match Escape in the route instrument, after Android's notification traversal.
	if screen=="program":route_editor.close()
	elif screen=="mission" and advanced_orders:mission_hud._back()
	else:_show_campaign()

func _take_capture() -> void:
	await RenderingServer.frame_post_draw
	var image=get_viewport().get_texture().get_image()
	var result=image.save_png(capture_path)
	print("SS_CAPTURE ",capture_path," size=",image.get_size()," result=",result)

func _report_targets() -> void:
	await get_tree().process_frame
	if not is_inside_tree(): return
	var capture_phase="layout_only"
	if DisplayServer.get_name()!="headless" and not RenderingServer.get_video_adapter_name().is_empty():
		await RenderingServer.frame_post_draw
		if not is_inside_tree(): return
		capture_phase="post_draw"
	var buttons: Dictionary={}
	if screen=="program" and route_editor.is_visible_in_tree():
		for control in route_editor.find_children("*","Button",true,false):
			if control.is_visible_in_tree() and control.has_meta("action"): buttons[control.get_meta("action")]=control
	elif hud.visible:
		buttons=mission_hud.action_controls()
	elif get_node_or_null("ConfluenceResolution")!=null:
		for child in get_node("ConfluenceResolution").actions.get_children():
			if child is Button and child.has_meta("action"):buttons[child.get_meta("action")]=child
	else:
		for child in panel_box.get_children()+menu_footer.get_children():
			if child is Button and child.has_meta("action"): buttons[child.get_meta("action")]=child
	_emit_ui_metrics(_ui_metrics(capture_phase))
	for key in buttons:
		var p=buttons[key].get_global_rect().get_center()
		print("SS_TARGET ",key," center=",roundi(p.x),",",roundi(p.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
	if hud.visible:
		var center=ocean.get_global_rect().get_center()
		print("SS_TARGET chart_center center=",roundi(center.x),",",roundi(center.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
		var sites=sim.observable_sites()
		if not sites.is_empty():
			var approach=sites[0].pos+Vector2(0,210)
			if sim.blocked(approach,25): approach=sites[0].pos+Vector2(-210,0)
			var objective_point=ocean.global_position+ocean.world_offset+approach*ocean.world_scale
			print("SS_TARGET objective0 center=",roundi(objective_point.x),",",roundi(objective_point.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
		var p=ocean.global_position+ocean.world_offset+Vector2(480,850)*ocean.world_scale
		print("SS_TARGET route center=",roundi(p.x),",",roundi(p.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))

		# Own launch geometry only. Keep10m inside the cap for rounded input pixels.
		if decoy_armed:
			var deployment=sim.units[sim.selected].pos+Vector2(150,0)
			if sim.decoy_target_valid(deployment):
				var mapped=ocean.global_position+ocean.screen_position(deployment)
				print("SS_TARGET role_decoy center=",roundi(mapped.x),",",roundi(mapped.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
		if mission_index==4:
			for action in {"role_observer":Vector2(640,850),"role_home":Vector2(140,800)}:
				var world:Vector2={"role_observer":Vector2(640,850),"role_home":Vector2(140,800)}[action]
				var mapped=ocean.global_position+ocean.world_offset+world*ocean.world_scale
				print("SS_TARGET ",action," center=",roundi(mapped.x),",",roundi(mapped.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))

func _emit_ui_metrics(snapshot: Dictionary={}) -> void:
	UiMetrics.emit_ui_metrics(self, snapshot)
func _enter_water() -> void:
	screen="mission"; menu.hide(); hud.show()
	for button in zoom_buttons: button.show()
	print("SS_SCREEN mission paused=",sim.paused)
	call_deferred("_layout"); _save_archive()

func _apply_safe_area() -> void:
	if OS.get_name()!="Android" or applying_safe_area: return
	applying_safe_area=true
	var viewport_size=get_viewport_rect().size
	var safe=preload("res://src/presentation/layout_metrics.gd").content_rect(viewport_size,Vector2(get_window().size),Rect2(DisplayServer.get_display_safe_area()))
	offset_left=safe.position.x; offset_top=safe.position.y
	offset_right=safe.end.x-viewport_size.x; offset_bottom=safe.end.y-viewport_size.y
	applying_safe_area=false

func _observation_diagnostics() -> void:
	# Read-only validation logs. Hidden AI state never enters the player HUD.
	for id in sim.sirens.size():
		var siren=sim.sirens[id]
		if siren.get("type","patroller")=="patroller": continue
		if diagnostic_roles.get(id,"")!=siren.mode:
			diagnostic_roles[id]=siren.mode
			print("SS_ROLE mission=%d index=%d type=%s mode=%s pos=%.6f,%.6f home=%.6f,%.6f target=%d lock=%.6f time=%.6f"%[mission_index,id,siren.type,siren.mode,siren.pos.x,siren.pos.y,siren.home.x,siren.home.y,siren.target,siren.lock,sim.elapsed])
	var route_ready=mission_index==4 and sim.units[0].alive and sim.units[0].pos.distance_to(Vector2(640,850))<20 and sim.units[0].vel.length()<2
	if route_ready and not diagnostic_role_route_ready: print("SS_ROLE_ROUTE_READY mission=4 unit=0 time=",sim.elapsed)
	diagnostic_role_route_ready=route_ready
	var ready=""
	var unit=sim.units[sim.selected]
	for id in sim.mission.objectives.size():
		var objective=sim.mission.objectives[id]
		if objective.captured and not diagnostic_records.has(id):
			diagnostic_records[id]=true
			print("SS_OBJECTIVE_RECORDED mission=",mission_index," objective=",id)
			_retain_evidence()
	var context=sim.camera_context()
	if unit.alive and context.ready: ready="unit=%d objective=%d"%[sim.selected,context.target]
	if ready!=diagnostic_ready:
		diagnostic_ready=ready
		if not ready.is_empty(): print("SS_CAMERA_READY ",ready)
	if sim.mission.get("well_revision",0)==1 and not sim.mission.well_observation.is_empty() and not recovered_evidence.has("well_signature"):_retain_evidence()
# Frames of one subject accumulate across dives: best frames kept, newest listed last.
func _merge_shots(key:String) -> void:
	PhotoReview.merge_shots(self, key)
func _evidence_is_text(entry:Dictionary) -> bool:
	return PhotoReview.evidence_is_text(self, entry)
func _retain_evidence() -> void:
	PhotoReview.retain_evidence(self)
func _evidence_gallery(index: int,shot_index:int=-1,compare:bool=false) -> void:
	PhotoReview.evidence_gallery(self, index, shot_index, compare)
func _shot_report(shot:Dictionary,at:int,total:int) -> String:
	return PhotoReview.shot_report(self, shot, at, total)
# What this frame taught: each line is a mark the player can act on, drawn on the
# chart of the operation it concerns once the frame resolved it.
func _shot_findings(shot:Dictionary) -> String:
	return PhotoReview.shot_findings(self, shot)
func _shot_difference(a:Dictionary,b:Dictionary,ia:int,ib:int) -> String:
	return PhotoReview.shot_difference(self, a, b, ia, ib)
func _intel_screen() -> void:
	PhotoReview.intel_screen(self)
func _rect_values(rect: Rect2) -> Array:
	return UiMetrics.rect_values(self, rect)
func _planner_intent_metrics() -> Dictionary:
	return UiMetrics.planner_intent_metrics(self)
func _ui_metrics(capture_phase: String="layout_only") -> Dictionary:
	return UiMetrics.ui_metrics(self, capture_phase)
