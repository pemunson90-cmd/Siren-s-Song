extends Control
const ExpeditionOperations=preload("res://src/presentation/expedition_operations.gd")
const ExpeditionCampaign=preload("res://src/campaign/expedition_campaign.gd")
const Simulation = preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
const Soundscape=preload("res://src/audio/soundscape.gd")
const MetricsTransport=preload("res://src/diagnostics/metrics_transport.gd")
const OceanView = preload("res://src/presentation/ocean_view.gd")
var sim = Simulation.new()
var store=SaveStore.new()
var sound
var save_clock:=0.0
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
var screen := "menu"
var mission_index := 0
var active_started := false
var applying_safe_area := false
var unlocked := 0
var completed: Array=[]
var expedition:Dictionary={}
var upgrade := "endurance"
var capture_scenario := ""
var frame := 0
var capture_path := ""
var menu_buttons: Array=[]
var recovered_evidence: Dictionary={}
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
var knock_press:Dictionary={}
var ui_touch_height:=48.0
var mission_row_heights:=Vector3.ZERO
var mission_reflow_pending:=false
var menu_footer: HBoxContainer
var scroll_report_timer: Timer
var metrics_session:=""
var metrics_serial:=0
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
	order_buttons["home"]=_button(hud,"EXTRACT",func(): _order("emergency",{"point":sim.mission.extraction}))
	order_buttons["menu"]=_button(hud,"OPERATIONS",func(): sim.paused=true; _show_campaign())
	for button in [pause_button,advanced_button]+unit_buttons+order_buttons.values():
		button.minimum_size_changed.connect(_queue_mission_reflow)
	mission_hud=preload("res://src/presentation/mission_hud.gd").new();hud.add_child(mission_hud);mission_hud.setup(self)
	menu=PanelContainer.new(); add_child(menu)
	# Shaped text can shrink a previous minimum after container reflow.
	# Reapply the window bounds once that minimum settles.
	menu.minimum_size_changed.connect(_layout,CONNECT_DEFERRED)
	var stack=VBoxContainer.new(); stack.add_theme_constant_override("separation",12); menu.add_child(stack)
	scroll=ScrollContainer.new(); scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; stack.add_child(scroll)
	scroll_report_timer=Timer.new(); scroll_report_timer.one_shot=true; scroll_report_timer.wait_time=0.15; add_child(scroll_report_timer)
	scroll_report_timer.timeout.connect(_report_targets)
	scroll.get_v_scroll_bar().value_changed.connect(func(_value): scroll_report_timer.start())
	panel_box=VBoxContainer.new(); panel_box.size_flags_horizontal=Control.SIZE_EXPAND_FILL; panel_box.add_theme_constant_override("separation",14); scroll.add_child(panel_box)
	menu_footer=HBoxContainer.new(); menu_footer.add_theme_constant_override("separation",12); stack.add_child(menu_footer); menu_footer.hide()
	route_editor=preload("res://src/presentation/route_program_panel.gd").new(); add_child(route_editor)
	sound=Soundscape.new(); add_child(sound)
	resized.connect(_layout)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="): capture_scenario=arg.get_slice("=",1)
		if arg.begins_with("--capture-path="): capture_path=arg.trim_prefix("--capture-path=")
	_start_mission(0)
	active_started=false
	if capture_scenario.is_empty(): _load_archive(); _show_campaign()
	else: _scenario(capture_scenario)
	_layout()
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
	var b=Button.new(); b.text=text; b.custom_minimum_size=Vector2(0,ui_touch_height); b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; b.pressed.connect(action,CONNECT_DEFERRED); b.focus_mode=Control.FOCUS_NONE; parent.add_child(b)
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
	ocean.position=Vector2.ZERO;ocean.size=size;ocean.feedback_font_size=maxi(14,roundi(h*.26));ocean.instrument_top=h+24;ocean.instrument_height=h;ocean.oxygen_capacity=120. if upgrade=="endurance" else 100.
	_refresh()
	if mission_hud!=null:
		mission_hud.layout(size,h);mission_row_heights=_measured_mission_rows()
		ocean.ui_blocked_rects=mission_hud.occupied_rects().map(func(r):return Rect2(r.position-ocean.global_position,r.size))
	if menu!=null:
		menu.position=Vector2(maxf(24,(size.x-800)/2),24); menu.size=Vector2(minf(800,size.x-48),size.y-48)
		for button in menu.find_children("*","Button",true,false):
			button.custom_minimum_size.y=h; button.add_theme_font_size_override("font_size",maxi(17,roundi(h*0.29)))
		for slider in menu.find_children("*","Slider",true,false): slider.custom_minimum_size.y=h
	if route_editor!=null and route_editor.visible: route_editor.configure(size,h)
	call_deferred("_report_targets")
func _start_mission(index: int) -> void:
	diagnostic_ready=""; diagnostic_records.clear(); diagnostic_roles.clear(); diagnostic_role_route_ready=false; map_gesture.cancel(); advanced_orders=false; knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false
	call_deferred("_layout")
	if route_editor!=null: route_editor.hide()
	active_started=true; mission_index=index; sim.start(index,upgrade); ocean.sim=sim; ocean.focus_craft(); screen="mission"; menu.hide(); hud.show(); _refresh()
func _primary_action() -> void:
	if decoy_armed or knock_armed:
		decoy_armed=false;knock_armed=false;map_gesture.cancel();knock_press.clear();_refresh();return
	_order("camera")
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
		map_gesture.cancel(); knock_armed=false; ocean.knock_targeting=false
		if sim.units[sim.selected].alive and sim.tools.decoy>0 and sim.outcome.is_empty():decoy_armed=not decoy_armed;decoy_unit=sim.selected
		else:decoy_armed=false;sim.message="Decoy unavailable · no charge spent"
		_refresh(); print("SS_DECOY_AIM armed=",decoy_armed," selected=",sim.selected); call_deferred("_report_targets"); return
	if order=="knock" and not args.has("target"):
		map_gesture.cancel();decoy_armed=false;ocean.decoy_targeting=false
		if sim.selected==0 and sim.units[0].alive and sim.tools.get("knock",0)>0 and sim.outcome.is_empty(): knock_armed=not knock_armed
		else: knock_armed=false; sim.message="Knockdown: Quietus launcher or torpedoes unavailable."
		_refresh(); return
	map_gesture.cancel()
	var aiming=knock_armed;var aiming_decoy=decoy_armed
	knock_armed=false; ocean.knock_targeting=false; decoy_armed=false; ocean.decoy_targeting=false
	var accepted=sim.command(order,args)
	if order=="knock" and not accepted: knock_armed=aiming
	if order=="decoy" and not accepted:decoy_armed=aiming_decoy
	print("SS_ORDER ",order," accepted=",accepted," selected=",sim.selected," queued=",sim.queue_mode)
	_refresh(); _save_archive()
	if accepted and order=="camera": call_deferred("_report_targets")
func _pause() -> void:
	sim.paused=not sim.paused; print("SS_PAUSE paused=",sim.paused); _refresh(); _save_archive()
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
		_refresh()
func _refresh() -> void:
	if decoy_armed and (screen!="mission" or sim.selected!=decoy_unit or not sim.units[sim.selected].alive or sim.tools.decoy<=0 or not sim.outcome.is_empty()):decoy_armed=false
	ocean.decoy_targeting=decoy_armed
	if knock_armed and (screen!="mission" or sim.selected!=0 or not sim.units[0].alive or not sim.outcome.is_empty()): knock_armed=false
	ocean.knock_targeting=knock_armed; ocean.knock_touch_size=ui_touch_height
	title_label.text="SIREN'S SONG    /    %02d  %s"%[mission_index+1,sim.mission.title.to_upper()]
	status_label.text="DEPTH %dm    O₂ %03d%%    HULL %03d%%    RECORDS %d / %d    %s"%[sim.mission.depth,int(sim.oxygen),int(sim.hull),sim.mission.objectives.filter(func(o): return o.captured).size(),sim.mission.objectives.size(),"TACTICAL PAUSE" if sim.paused else "REAL TIME"]
	pause_button.text="▶ RESUME" if sim.paused else "Ⅱ PAUSE"
	var capture_task="CAMERA"
	if sim.capture_unit>=0 and sim.capture_target>=0 and sim.capture_target<sim.mission.objectives.size():
		capture_task={"receiver":"LISTEN","exchange":"SAMPLE","uplink":"LINK"}.get(sim.mission.objectives[sim.capture_target].get("kind",""),"CAMERA")
	for i in 3:
		unit_buttons[i].modulate=Color("80d9cf") if sim.selected==i else Color.WHITE
		unit_buttons[i].disabled=not sim.units[i].alive
		var task="LOST" if not sim.units[i].alive else (capture_task if sim.capture_unit==i else (sim.units[i].hold if not sim.units[i].hold.is_empty() else ("ROUTE" if not sim.units[i].route.is_empty() else "READY")))
		task={"SCOUT_STOP":"ALERT"}.get(task,task)
		unit_buttons[i].text=["QUIETUS","DRONE A","DRONE B"][i]+"\n"+task
		unit_buttons[i].add_theme_font_size_override("font_size",maxi(14,roundi(ui_touch_height*0.26)))
	order_buttons.waypoint_mode.text="PASS\nPOINTS" if sim.pass_through else "STOP AT\nPOINTS"
	ocean.optical_feed.receiver_font_size=maxi(14,roundi(ui_touch_height*0.25))
	order_buttons.camera.text="SAMPLE" if sim.mission.get("blackwater_revision",0)==1 else "CAMERA\nLISTEN" if sim.mission.get("finale_revision",0)==1 else ("CAMERA\nLINK" if mission_index==1 else "CAMERA")
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
	log_label.text=sim.message
	if sim.mission.get("well_revision",0)==1 and sim.mission.objectives[0].captured:
		var comparison="MATCH RECORDED" if not sim.mission.well_observation.is_empty() else ("REFERENCE LOGGED" if not sim.mission.well_reference.is_empty() else "UNVERIFIED")
		log_label.text="WELL · %s | %s"%[comparison,sim.message]
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
func _focus_craft() -> void:
	map_gesture.cancel();ocean.focus_craft();_refresh();_view_changed()
func _toggle_advanced() -> void:
	if advanced_orders:mission_hud.dismiss()
	else:mission_hud.open("craft",{"kind":"craft","unit":sim.selected,"pos":sim.units[sim.selected].pos})
func _input(event:InputEvent) -> void:
	if screen!="mission":return
	if mission_hud.owns_pointer(event):get_viewport().set_input_as_handled();return
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
			mission_hud.open("object" if context.kind=="objective" else "fleet" if context.kind=="fleet" else "craft",context);return true
		var world=ocean.map_position(action.tap-ocean.global_position)
		if Rect2(Vector2.ZERO,ocean.world_size()).has_point(world): _order("route",{"point":world})
	if action.has("ended") or action.has("tap"):knock_press.clear()
	return true
func _target_knockdown(point: Vector2,intended:int=-2) -> void:
	var chosen=ocean.knock_aim_key(point-ocean.global_position) if intended==-2 else intended
	if chosen<0 or not ocean.knock_visible_targets().any(func(c):return c.key==chosen):
		sim.message="Choose an S# FIRE box or a clear contact · no torpedo spent"; _refresh(); return
	_order("knock",{"target":chosen})
func _chart_zoom(factor: float) -> void:
	map_gesture.cancel(); ocean.zoom_at(factor,ocean.size/2); _view_changed()
func _view_changed() -> void:
	_save_archive()
	print("SS_VIEW zoom=",snappedf(ocean.chart_camera.zoom,0.01)," center=",ocean.chart_camera.center)
	call_deferred("_report_targets")
func _unhandled_key_input(event: InputEvent) -> void:
	if screen=="program":
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE: route_editor.close()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_SPACE: _pause()
		if event.keycode==KEY_ESCAPE:
			if advanced_orders:_toggle_advanced()
			elif knock_armed or decoy_armed:_primary_action()
			else:sim.paused=true;_show_campaign()
func _clear_menu() -> void:
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
	var l=_label(panel_box,text,roundi(font_size*ui_touch_height/48.0)); l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; l.custom_minimum_size.x=minf(610,size.x-120); return l
func _loadout_stock(choice: String) -> Array:
	return {"endurance":[120,2,2],"disruption":[100,3,2],"survey":[100,2,3]}.get(choice,[100,2,2])
func _show_campaign() -> void:
	screen="menu"; _clear_menu()
	_menu_text("SIREN'S SONG",38).add_theme_color_override("font_color",Color("80d9cf"))
	_menu_text("ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.",14)
	_menu_text("USS QUIETUS  /  OPERATIONS ARCHIVE",18)
	if active_started and sim.outcome.is_empty():
		_button(panel_box,"RESUME ACTIVE MISSION",_enter_water,"resume")
		_menu_text("Resuming preserves the active dive's equipment.",14)
	for i in 6:
		var id=i
		var b=_button(panel_box,"%02d   %s   %s"%[i+1,Simulation.Missions.TITLES[i],"RECOVERED" if i in completed else ("AVAILABLE" if i<=unlocked else "LOCKED")],func(): print("SS_MISSION_SELECT ",id); _briefing(id))
		b.disabled=i>unlocked
		b.set_meta("action","mission%d"%i)
	ExpeditionOperations.operations(self)
	if not recovered_evidence.is_empty(): _button(panel_box,"REVIEW FIELD RECORDS",func(): _evidence_gallery(0),"evidence")
	_menu_text("Field records remain reviewable after loss or abandonment. Only successful extraction advances the campaign.",14)
	var stock=_loadout_stock(upgrade)
	_menu_text("NEXT DIVE / RETRY · %s\nO₂ %d%% · DISRUPT %d · SURVEY %d"%[upgrade.to_upper(),stock[0],stock[1],stock[2]],15)
	var rows=["COMPARE: O₂ / DISRUPT / SURVEY"]
	for choice in ["endurance","disruption","survey"]:
		var supplies=_loadout_stock(choice)
		rows.append("%s · %d%% / %d / %d"%[choice.to_upper(),supplies[0],supplies[1],supplies[2]])
	_menu_text("\n".join(rows),14)
	_menu_text("ALL: 3 DECOYS · 2 DRONES · 2 TORPEDOES\nDISRUPT: 12s · SURVEY: 8s, audible",14)
	_button(panel_box,"CYCLE LOADOUT · endurance / disruption / survey",func(): upgrade=["endurance","disruption","survey"][( ["endurance","disruption","survey"].find(upgrade)+1)%3]; _show_campaign(),"loadout")
	_button(panel_box,"AUDIO / SETTINGS",_settings_menu,"settings")
	print("SS_SCREEN operations window=",get_window().size," viewport=",get_viewport_rect().size," root=",size," unlocked=",unlocked," active_time=",snappedf(sim.elapsed,0.01))
	call_deferred("_layout")
func _briefing(index: int) -> void:
	if index>=6 and index not in ExpeditionCampaign.available(completed,expedition):return
	screen="briefing"; sim.paused=true; _clear_menu()
	var briefing=Simulation.Missions.make(index)
	_menu_text("%02d / %s"%[index+1,briefing.title.to_upper()],30)
	_menu_text(briefing.brief,20)
	if ExpeditionOperations.briefing(self,index):pass
	elif briefing.get("blackwater_revision",0)==1:
		_menu_text("ORDERS\nTap a craft for its command ring; FLEET chooses a station. Empty water plots its route. ROUTE → REPLACE / QUEUE changes append intent. PAUSE stays available. Settle and SAMPLE for two seconds. Quietus receives within156m; drones within214.5m. Cover blocks reception. An audible SONAR may prompt a local relay replay; a decoded packet explains its partner's handshake. Return Quietus after both records.",17)
	else:
		_menu_text("ORDERS\nTap a craft for its command ring; FLEET chooses a station. Tap empty water to replace its route. Craft → ROUTE → REPLACE / QUEUE changes append intent. PAUSE stays available. Drag / pinch inspects freely; FOCUS follows the craft and FIT shows the region. CAMERA works within 240m of a gold record marker. Return Quietus after all records are secured.",17)
	_menu_text("SPACE / PAUSE grants unlimited planning time. Silent running is slower and quieter. Disruption interrupts nearby Sirens for 12 seconds. Quietus torpedoes travel noisily up to 150m; impact pins one Siren for 8s. Cover blocks sonar, enemy sight and torpedoes.",17)
	var stock=_loadout_stock(upgrade)
	_menu_text("NEXT DIVE / RETRY · %s\nO₂ %d%% · DISRUPT %d · SURVEY %d · 3 DECOYS · 2 DRONES · 2 TORPEDOES"%[upgrade.to_upper(),stock[0],stock[1],stock[2]],17)
	_button(menu_footer,"ENTER WATER\nSTART PAUSED",func(): _start_mission(index); _enter_water(),"begin")
	_button(menu_footer,"BACK TO\nOPERATIONS",_show_campaign,"back")
	menu_footer.show()
	call_deferred("_layout")
func _debrief() -> void:
	screen="debrief"; _clear_menu()
	print("SS_DEBRIEF outcome=",sim.outcome," mission=",mission_index)
	if ExpeditionOperations.debrief(self):return
	if sim.outcome=="won":
		_retain_evidence()
		if mission_index not in completed: completed.append(mission_index)
		unlocked=mini(5,maxi(unlocked,mission_index+1))
		_menu_text("ARCHIVE RECOVERED",32)
		_menu_text(sim.mission.record,22)
		_menu_text("Dive time %02d:%02d  /  Hull %d%%  /  Life support %d%%"%[int(sim.elapsed)/60,int(sim.elapsed)%60,int(sim.hull),int(sim.oxygen)],17)
		if mission_index==5:
			_menu_text("YOUR FIELD RECORD · ACROSS DIVES",14)
			_menu_text(preload("res://src/campaign/archive_recap.gd").summary(recovered_evidence),14)
		if not recovered_evidence.is_empty(): _button(panel_box,"REVIEW FIELD RECORDS",func(): _evidence_gallery(0),"evidence")
		if mission_index==5:
			var discovery="The crown points into the trench. Unarmed wakes lead away from the fracture. Quietus’ hydrophones resolve what the images could not: they are evacuating.\n\n" if sim.mission.get("finale_revision",0)==1 else ""
			_menu_text("THE SONG CONTINUES\n\n"+discovery+"You return with a warning, not a firing solution. Above you, the fleet waits for orders. Below, the foundry lights go dark, one by one. For the first time since descent, Quietus hears only the ocean.\n\nIntroductory arc complete. Every dive remains replayable.",20)
			if 6 in ExpeditionCampaign.available(completed,expedition):_button(panel_box,"BEYOND THE WARNING / THE DIVERGENCE",func():_briefing(6),"expedition6")
		else: _button(panel_box,"NEXT DIVE",func(): _briefing(mission_index+1),"next_dive")
	else:
		_menu_text("SIGNAL LOST",32); _menu_text(sim.message,22); _menu_text("Field records remain reviewable after loss or abandonment. Only successful extraction advances the campaign.",17)
	_button(panel_box,"RETRY DIVE",func(): _briefing(mission_index),"retry")
	_button(panel_box,"OPERATIONS ARCHIVE",_show_campaign,"back")
	_save_archive()
	call_deferred("_layout")
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
	var data={"version":1,"unlocked":unlocked,"completed":completed.duplicate(),"upgrade":upgrade,"settings":settings.duplicate(),"evidence":recovered_evidence.duplicate(true),"active":sim.snapshot(),"chart_view":ocean.chart_camera.snapshot()}
	if not expedition.is_empty():data["expedition"]=expedition.duplicate(true)
	return data
func _save_archive() -> void:
	if not capture_scenario.is_empty() or sim.mission==null: return
	if store.save(_archive()): print("SS_SAVE ok mission=",mission_index," time=",snappedf(sim.elapsed,0.01)," paused=",sim.paused," completed=",completed," unlocked=",unlocked)
	else: sim.message=store.warning
func _load_archive() -> void:
	var saved=store.load_game()
	if not saved.is_empty():
		unlocked=saved.unlocked; completed=saved.completed; upgrade=saved.upgrade; settings=saved.settings
		expedition=saved.get("expedition",{}).duplicate(true)
		recovered_evidence=saved.get("evidence",{})
		if saved.get("active") is Dictionary and sim.restore(saved.active):
			active_started=true; mission_index=sim.mission.id; ocean.sim=sim
			ocean._sync_camera()
			var chart_view=saved.get("chart_view",{})
			if chart_view is Dictionary:ocean.chart_camera.restore(chart_view)
			print("SS_RESTORE ok mission=",mission_index," time=",snappedf(sim.elapsed,0.01)," paused=",sim.paused," completed=",completed," unlocked=",unlocked)
	sound.music_volume=settings.get("music",0.5); sound.effects_volume=settings.get("effects",0.8); sound.muted=settings.get("mute",false)
	if not store.warning.is_empty(): sim.message=store.warning
func _settings_menu() -> void:
	_clear_menu(); screen="settings"
	_menu_text("QUIETUS / AUDIO",30)
	_menu_text("Actionable sound cues also appear in the tactical display. Audio pauses when you suspend the dive.",18)
	for field in ["music","effects"]:
		var key=field
		_menu_text("%s VOLUME"%key.to_upper(),17)
		var slider=HSlider.new(); slider.min_value=0; slider.max_value=1; slider.step=0.05; slider.value=settings.get(key,0.5); slider.custom_minimum_size.y=ui_touch_height; slider.set_meta("ui_action","volume_"+key); panel_box.add_child(slider)
		slider.value_changed.connect(func(value): settings[key]=value; sound.set(key+"_volume",value); _save_archive())
	_button(panel_box,"MUTE: %s"%("ON" if sound.muted else "OFF"),func(): sound.muted=not sound.muted; settings.mute=sound.muted; _save_archive(); _settings_menu(),"mute")
	_button(menu_footer,"BACK TO OPERATIONS",_show_campaign,"back"); menu_footer.show()
	call_deferred("_layout")
func _notification(what: int) -> void:
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
		sim.paused=true; _save_archive(); _show_campaign()

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
	if snapshot.is_empty(): snapshot=_ui_metrics()
	if OS.get_name()=="Android":
		if metrics_session.is_empty():metrics_session="%d-%d"%[OS.get_process_id(),Time.get_ticks_usec()]
		metrics_serial+=1
		for record in MetricsTransport.encode(snapshot,metrics_session,metrics_serial):print(record)
	else:print("SS_UI_METRICS ",JSON.stringify(snapshot))

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
func _evidence_is_text(entry:Dictionary) -> bool:
	return entry.optical in ExpeditionCampaign.FIELD_RECORDS or entry.optical in ["well_pattern","well_signature"]
func _retain_evidence() -> void:
	for objective in sim.mission.objectives:
		if objective.captured and objective.has("optical"):
			recovered_evidence[objective.optical]={"name":objective.name,"caption":objective.evidence,"optical":objective.optical}
	var signature=sim.well_signature_evidence()
	if not signature.is_empty():recovered_evidence[signature.optical]=signature
func _evidence_gallery(index: int) -> void:
	_retain_evidence()
	if recovered_evidence.is_empty(): _show_campaign(); return
	sim.paused=true; screen="evidence"; _clear_menu()
	var keys=recovered_evidence.keys(); var entry=recovered_evidence[keys[index%keys.size()]]
	_menu_text("FIELD %s RECORDS / %d OF %d"%["ACOUSTIC" if _evidence_is_text(entry) else ("HYDROPHONE" if entry.optical in ["blackwater_request","blackwater_reply"] else "OPTICAL"),index+1,keys.size()],18)
	_menu_text(entry.name,28)
	if not _evidence_is_text(entry):
		var image=TextureRect.new(); image.texture=preload("res://src/presentation/evidence_catalog.gd").IMAGES[entry.optical]
		image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; image.custom_minimum_size=Vector2(0,minf(320,size.y*0.4)); panel_box.add_child(image)
	_menu_text(entry.caption,19)
	if keys.size()>1: _button(panel_box,"NEXT RECORD",func(): _evidence_gallery((index+1)%keys.size()),"next_record")
	_button(menu_footer,"BACK TO OPERATIONS",_show_campaign,"back"); menu_footer.show()
	call_deferred("_layout")

func _rect_values(rect: Rect2) -> Array:
	return [snappedf(rect.position.x,0.001),snappedf(rect.position.y,0.001),snappedf(rect.size.x,0.001),snappedf(rect.size.y,0.001)]
func _planner_intent_metrics() -> Dictionary:
	# Only operator-owned state; never serialize the model's hidden enemy state.
	var own_units=[]
	for id in sim.units.size():
		var unit=sim.units[id]; var goals=[]
		for goal in sim.route_goals(id):
			goals.append({"pos":[goal.pos.x,goal.pos.y],"mode":goal.mode,"stop":goal.stop,"legacy":goal.get("legacy",false)})
		var own={"alive":unit.alive,"pos":[unit.pos.x,unit.pos.y],"velocity":[unit.vel.x,unit.vel.y],"battery":unit.battery,"silent":unit.silent,"hold":unit.hold,"goals":goals}
		if id>0:own["drive"]=unit.get("drone_drive","transit")
		own_units.append(own)
	return {"mission":mission_index,"paused":sim.paused,"selected":sim.selected,"elapsed":sim.elapsed,"oxygen":sim.oxygen,"hull":sim.hull,"tools":sim.tools.duplicate(),"queue":sim.queue_mode,"pass_through":sim.pass_through,"units":own_units}
func _ui_metrics(capture_phase: String="layout_only") -> Dictionary:
	var viewport=get_viewport_rect().size; var window=Vector2(get_window().size)
	var safe=Rect2(Vector2.ZERO,window)
	if OS.get_name()=="Android": safe=Rect2(DisplayServer.get_display_safe_area()).intersection(safe)
	var controls: Array=[]; var targets: Dictionary={}
	var planner_visible=screen=="program" and route_editor.is_visible_in_tree()
	if planner_visible:
		for control in route_editor.find_children("*","Button",true,false):
			if control.has_meta("action"): targets[control.get_meta("action")]=control
	elif hud.visible:
		targets=mission_hud.action_controls()
	else:
		var candidates=menu.find_children("*","Button",true,false)+menu.find_children("*","Slider",true,false)
		for control in candidates: targets[control.get_meta("action",control.get_meta("ui_action",str(control.get_instance_id())))]=control
	for action in targets:
		var control=targets[action]
		if not control.is_visible_in_tree(): continue
		var visual:Rect2=control.get_global_rect(); var hit=visual.intersection(Rect2(Vector2.ZERO,viewport))
		var parent=control.get_parent()
		while parent!=null:
			if parent is Control and parent.clip_contents: hit=hit.intersection(parent.get_global_rect())
			parent=parent.get_parent()
		if not hit.has_area(): continue
		controls.append({"action":action,"visual_rect":_rect_values(visual),"hit_rect":_rect_values(hit),"clipped":not hit.is_equal_approx(visual)})
	var capture_state={"phase":capture_phase,"drawn_frame":Engine.get_frames_drawn(),"mission":mission_index,"paused":sim.paused,"selected":sim.selected,"capture_unit":sim.capture_unit,"hud_visible":hud.is_visible_in_tree(),"menu_visible":menu.is_visible_in_tree(),"optical_visible":ocean.optical_feed!=null and ocean.optical_feed.is_visible_in_tree()}
	var result={"schema":1,"screen":screen,"orders_page":"secondary" if advanced_orders else "primary","hud_layout":"radial","context_page":mission_hud.page if advanced_orders else "water","chart_view":{"mode":ocean.chart_camera.mode,"zoom":ocean.chart_camera.zoom,"center":[ocean.chart_camera.center.x,ocean.chart_camera.center.y]},"viewport":[viewport.x,viewport.y],"window":[window.x,window.y],"safe_rect":_rect_values(safe),"density_dpi":ui_density_dpi(),"density_source":ui_density_source(),"chart_rect":_rect_values(ocean.get_global_rect()),"scroll_rect":_rect_values(scroll.get_global_rect().intersection(menu.get_global_rect()).intersection(Rect2(Vector2.ZERO,viewport))),"scroll_vertical":scroll.scroll_vertical,"settings_values":{"music":settings.get("music",0.5),"effects":settings.get("effects",0.8),"mute":settings.get("mute",false)},"capture_state":capture_state,"controls":controls}
	result["context_subject_kind"]=mission_hud.subject.get("subkind","site") if advanced_orders and mission_hud.page=="object" else ""
	if planner_visible:
		var preview=route_editor.preview; var camera=preview.chart_camera; var chart=preview.get_global_rect(); var scale=window/viewport
		result.chart_rect=_rect_values(chart)
		result["planner"]={"preview_physical":_rect_values(Rect2(chart.position*scale,chart.size*scale)),"zoom":camera.zoom,"center":[camera.center.x,camera.center.y],"intent":_planner_intent_metrics()}
	return result
