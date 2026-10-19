extends Control
const Simulation = preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
const Soundscape=preload("res://src/audio/soundscape.gd")
const OceanView = preload("res://src/presentation/ocean_view.gd")
var sim = Simulation.new()
var store=SaveStore.new()
var sound
var save_clock:=0.0
var settings={"music":0.5,"effects":0.8,"mute":false}
var scroll: ScrollContainer
var ocean
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
var upgrade := "endurance"
var capture_scenario := ""
var frame := 0
var capture_path := ""
var menu_buttons: Array=[]
var recovered_evidence: Dictionary={}
var diagnostic_ready := ""
var diagnostic_records: Dictionary={}
var map_gesture=preload("res://src/input/map_gesture.gd").new()
var zoom_buttons: Array=[]
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
	var orders=[["ping","SONAR"],["camera","CAMERA"],["silent","SILENT"],["queue","+ QUEUE"],["hold","HOLD"],["emp","DISRUPT"],["decoy","DECOY"],["recon","SURVEY"],["contact_hold","IF CONTACT"],["wait_drone","WAIT DRONE"],["waypoint_mode","WAYPOINT: PASS"]]
	for o in orders:
		var order=o[0]
		order_buttons[order]=_button(hud,o[1],func(): _order(order))
	order_buttons["home"]=_button(hud,"EXTRACT",func(): _order("emergency",{"point":sim.mission.extraction}))
	order_buttons["menu"]=_button(hud,"OPERATIONS",func(): sim.paused=true; _show_campaign())
	menu=PanelContainer.new(); add_child(menu); scroll=ScrollContainer.new(); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; menu.add_child(scroll); panel_box=VBoxContainer.new(); panel_box.size_flags_horizontal=Control.SIZE_EXPAND_FILL; panel_box.add_theme_constant_override("separation",14); scroll.add_child(panel_box)
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
func _button(parent: Node,text: String,action: Callable) -> Button:
	var b=Button.new(); b.text=text; b.custom_minimum_size=Vector2(0,48); b.pressed.connect(action,CONNECT_DEFERRED); b.focus_mode=Control.FOCUS_NONE; parent.add_child(b)
	if text.begins_with("ENTER WATER"): b.set_meta("action","begin")
	if text=="RESUME ACTIVE MISSION": b.set_meta("action","resume")
	return b
func _layout() -> void:
	if ocean==null: return
	map_gesture.cancel()
	_apply_safe_area()
	var wide=size.x/size.y>1.6
	title_label.position=Vector2(26,18); title_label.size=Vector2(size.x-52,34)
	status_label.position=Vector2(28,58); status_label.size=Vector2(size.x-56,28)
	var panel=Rect2(size.x-324,106,296,size.y-158) if wide else Rect2(26,size.y-350,size.x-52,300)
	ocean.position=Vector2(26,106); ocean.size=Vector2(size.x-376,size.y-158) if wide else Vector2(size.x-52,size.y-482)
	for i in zoom_buttons.size():
		zoom_buttons[i].position=Vector2(ocean.size.x-164+i*54,8); zoom_buttons[i].size=Vector2(50,48)
	pause_button.position=panel.position; pause_button.size=Vector2(panel.size.x,48)
	for i in 3:
		unit_buttons[i].position=panel.position+Vector2(i*(panel.size.x/3),60); unit_buttons[i].size=Vector2(panel.size.x/3-4,48)
	var keys=["ping","camera","silent","queue","hold","emp","decoy","recon","contact_hold","wait_drone","home","menu","waypoint_mode"]
	var columns=2 if wide else 6
	var start=panel.position+Vector2(0,120)
	for i in keys.size():
		var b=order_buttons[keys[i]]
		b.position=start+Vector2((i%columns)*(panel.size.x/columns),(i/columns)*56)
		b.size=Vector2(panel.size.x/columns-6,48)
		b.add_theme_font_size_override("font_size",15 if wide else 13)
	detail_label.position=panel.position+Vector2(0,522 if wide else 286); detail_label.size=Vector2(panel.size.x,130); detail_label.visible=wide and size.y>720
	log_label.position=Vector2(28,size.y-38); log_label.size=Vector2(size.x-56,28)
	if menu!=null:
		menu.position=Vector2(maxf(24,(size.x-690)/2),24); menu.size=Vector2(minf(690,size.x-48),size.y-48)
	call_deferred("_report_targets")
func _start_mission(index: int) -> void:
	diagnostic_ready=""; diagnostic_records.clear(); map_gesture.cancel(); ocean.fit_chart()
	active_started=true; mission_index=index; sim.start(index,upgrade); ocean.sim=sim; screen="mission"; menu.hide(); hud.show(); _refresh()
func _order(order: String,args: Dictionary={}) -> void:
	var accepted=sim.command(order,args)
	print("SS_ORDER ",order," accepted=",accepted," selected=",sim.selected," queued=",sim.queue_mode)
	_refresh(); _save_archive()
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
	title_label.text="SIREN'S SONG    /    %02d  %s"%[mission_index+1,sim.mission.title.to_upper()]
	status_label.text="DEPTH %dm    O₂ %03d%%    HULL %03d%%    RECORDS %d / %d    %s"%[sim.mission.depth,int(sim.oxygen),int(sim.hull),sim.mission.objectives.filter(func(o): return o.captured).size(),sim.mission.objectives.size(),"TACTICAL PAUSE" if sim.paused else "REAL TIME"]
	pause_button.text="▶  RESUME / EXECUTE PLAN" if sim.paused else "Ⅱ  TACTICAL PAUSE"
	for i in 3:
		unit_buttons[i].modulate=Color("80d9cf") if sim.selected==i else Color.WHITE
		unit_buttons[i].disabled=not sim.units[i].alive
		var task="LOST" if not sim.units[i].alive else ("EXPOSING" if sim.capture_unit==i else (sim.units[i].hold if not sim.units[i].hold.is_empty() else ("ROUTE" if not sim.units[i].route.is_empty() else "READY")))
		unit_buttons[i].text=["QUIETUS","DRONE A","DRONE B"][i]+"\n"+task
		unit_buttons[i].add_theme_font_size_override("font_size",13)
	order_buttons.waypoint_mode.text="WAYPOINT: PASS" if sim.pass_through else "WAYPOINT: STOP"
	order_buttons.camera.text="CAMERA / LINK" if mission_index==1 else "CAMERA"
	order_buttons.queue.text="+ QUEUE ON" if sim.queue_mode else "REPLACE"
	order_buttons.silent.text="SILENT ✓" if sim.units[sim.selected].silent else "CRUISE"
	order_buttons.emp.text="DISRUPT · %d"%sim.tools.emp
	order_buttons.decoy.text="DECOY · %d"%sim.tools.decoy
	order_buttons.recon.text="SURVEY · %d"%sim.tools.recon
	log_label.text=sim.message
	detail_label.text="SELECTED  /  %s\n\nTap water: %s route\n%s\n\nSonar and cameras expose you.\nCover breaks sight and beam lock.\n\nEXTRACT replaces all orders."%[sim.units[sim.selected].name,"add to" if sim.queue_mode else "replace",sim.units[sim.selected].hold]
func _input(event: InputEvent) -> void:
	if screen=="mission" and map_gesture.active() and _map_event(event): get_viewport().set_input_as_handled()
func _gui_input(event: InputEvent) -> void:
	if screen!="mission": return
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed and Rect2(ocean.position,ocean.size).has_point(event.position):
		ocean.zoom_at(1.2 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1.0/1.2,event.position-ocean.position); _view_changed(); accept_event(); return
	var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT)
	if pressed and Rect2(ocean.position,ocean.size).has_point(event.position) and _map_event(event,true): accept_event()
func _map_event(event: InputEvent,local_event: bool=false) -> bool:
	if event.device==InputEvent.DEVICE_ID_EMULATION: return false
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
	var action=map_gesture.feed(kind,index,point)
	if action.has("zoom"): ocean.zoom_at(action.zoom,action.anchor-ocean.global_position)
	if action.has("pan"): ocean.pan_chart(action.pan)
	if action.get("navigation",false): _view_changed()
	if action.has("tap") and ocean.get_global_rect().has_point(action.tap):
		var world=ocean.map_position(action.tap-ocean.global_position)
		if Rect2(0,0,1600,960).has_point(world): _order("route",{"point":world})
	return true
func _chart_zoom(factor: float) -> void:
	map_gesture.cancel(); ocean.zoom_at(factor,ocean.size/2); _view_changed()
func _view_changed() -> void:
	print("SS_VIEW zoom=",snappedf(ocean.chart_camera.zoom,0.01)," center=",ocean.chart_camera.center)
	call_deferred("_report_targets")
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_SPACE: _pause()
		if event.keycode==KEY_ESCAPE: sim.paused=true; _show_campaign()
func _clear_menu() -> void:
	map_gesture.cancel()
	for c in panel_box.get_children(): c.queue_free(); panel_box.remove_child(c)
	menu.show(); hud.hide(); scroll.scroll_vertical=0
func _menu_text(text: String,font_size: int=17) -> Label:
	var l=_label(panel_box,text,font_size); l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; l.custom_minimum_size.x=minf(610,size.x-120); return l
func _show_campaign() -> void:
	screen="menu"; _clear_menu()
	_menu_text("SIREN'S SONG",38).add_theme_color_override("font_color",Color("80d9cf"))
	_menu_text("ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.",14)
	_menu_text("USS QUIETUS  /  OPERATIONS ARCHIVE",18)
	if active_started and sim.outcome.is_empty(): _button(panel_box,"RESUME ACTIVE MISSION",_enter_water)
	for i in 6:
		var id=i
		var b=_button(panel_box,"%02d   %s   %s"%[i+1,Simulation.Missions.TITLES[i],"RECOVERED" if i in completed else ("AVAILABLE" if i<=unlocked else "LOCKED")],func(): print("SS_MISSION_SELECT ",id); _briefing(id))
		b.disabled=i>unlocked
		if i==0: b.set_meta("action","mission0")
	if not recovered_evidence.is_empty(): _button(panel_box,"REVIEW OPTICAL RECORDS",func(): _evidence_gallery(0))
	_menu_text("Equipment: %s"%upgrade.to_upper(),15)
	_button(panel_box,"CYCLE LOADOUT · endurance / disruption / survey",func(): upgrade=["endurance","disruption","survey"][( ["endurance","disruption","survey"].find(upgrade)+1)%3]; _show_campaign())
	_button(panel_box,"AUDIO / SETTINGS",_settings_menu)
	_menu_text("Unlimited tactical pause · tap routes · survey, photograph, return",14)
	print("SS_SCREEN operations window=",get_window().size," viewport=",get_viewport_rect().size," root=",size," unlocked=",unlocked," active_time=",snappedf(sim.elapsed,0.01))
	call_deferred("_layout")
func _briefing(index: int) -> void:
	screen="briefing"; sim.paused=true; _clear_menu()
	var briefing=Simulation.Missions.make(index)
	_menu_text("%02d / %s"%[index+1,briefing.title.to_upper()],30)
	_menu_text(briefing.brief,20)
	_menu_text("ORDERS\nTap water to replace your route. REPLACE toggles explicit queueing. Select Quietus or either drone. Use CAMERA within 240m of a gold record marker. Return Quietus to the extraction ring after all records are secured.",17)
	_menu_text("SPACE / PAUSE grants unlimited planning time. Silent running is slower and quieter. Disruption interrupts nearby Sirens for 12 seconds. Cover blocks sonar and enemy sight.",17)
	_button(panel_box,"ENTER WATER · START PAUSED",func(): _start_mission(index); _enter_water())
	_button(panel_box,"BACK TO OPERATIONS",_show_campaign)
	call_deferred("_layout")
func _debrief() -> void:
	screen="debrief"; _clear_menu()
	print("SS_DEBRIEF outcome=",sim.outcome," mission=",mission_index)
	if sim.outcome=="won":
		_retain_evidence()
		if mission_index not in completed: completed.append(mission_index)
		unlocked=mini(5,maxi(unlocked,mission_index+1))
		_menu_text("ARCHIVE RECOVERED",32)
		_menu_text(sim.mission.record,22)
		_menu_text("Dive time %02d:%02d  /  Hull %d%%  /  Life support %d%%"%[int(sim.elapsed)/60,int(sim.elapsed)%60,int(sim.hull),int(sim.oxygen)],17)
		if not recovered_evidence.is_empty(): _button(panel_box,"REVIEW OPTICAL RECORDS",func(): _evidence_gallery(0))
		if mission_index==5:
			_menu_text("THE SONG CONTINUES\n\nYou return with a warning, not a firing solution. Above you, the fleet waits for orders. Below, the foundry lights go dark, one by one. For the first time since descent, Quietus hears only the ocean.\n\nCampaign complete. Every dive remains replayable.",20)
		else: _button(panel_box,"NEXT DIVE",func(): _briefing(mission_index+1))
	else:
		_menu_text("SIGNAL LOST",32); _menu_text(sim.message,22); _menu_text("Recovered campaign records are preserved. Replan your approach from tactical pause.",17)
	_button(panel_box,"RETRY DIVE",func(): _briefing(mission_index))
	_button(panel_box,"OPERATIONS ARCHIVE",_show_campaign)
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
	return {"version":1,"unlocked":unlocked,"completed":completed.duplicate(),"upgrade":upgrade,"settings":settings.duplicate(),"evidence":recovered_evidence.duplicate(true),"active":sim.snapshot()}
func _save_archive() -> void:
	if not capture_scenario.is_empty() or sim.mission==null: return
	if store.save(_archive()): print("SS_SAVE ok mission=",mission_index," time=",snappedf(sim.elapsed,0.01)," paused=",sim.paused," completed=",completed," unlocked=",unlocked)
	else: sim.message=store.warning
func _load_archive() -> void:
	var saved=store.load_game()
	if not saved.is_empty():
		unlocked=saved.unlocked; completed=saved.completed; upgrade=saved.upgrade; settings=saved.settings
		recovered_evidence=saved.get("evidence",{})
		if saved.get("active") is Dictionary and sim.restore(saved.active):
			active_started=true; mission_index=sim.mission.id; ocean.sim=sim
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
		var slider=HSlider.new(); slider.min_value=0; slider.max_value=1; slider.step=0.05; slider.value=settings.get(key,0.5); slider.custom_minimum_size.y=48; panel_box.add_child(slider)
		slider.value_changed.connect(func(value): settings[key]=value; sound.set(key+"_volume",value); _save_archive())
	_button(panel_box,"MUTE: %s"%("ON" if sound.muted else "OFF"),func(): sound.muted=not sound.muted; settings.mute=sound.muted; _save_archive(); _settings_menu())
	_button(panel_box,"BACK TO OPERATIONS",_show_campaign)
	call_deferred("_layout")
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		if sim.mission!=null:
			map_gesture.cancel()
			sim.paused=true; _save_archive()
			if sound!=null: sound.suspend()
			print("SS_LIFECYCLE suspended paused=true")
	if what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:
		if sound!=null: sound.resume()
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
	var buttons: Dictionary={}
	if hud.visible:
		buttons={"pause":pause_button,"sub":unit_buttons[0],"droneA":unit_buttons[1],"droneB":unit_buttons[2]}
		for key in order_buttons: buttons[key]=order_buttons[key]
		for i in zoom_buttons.size(): buttons[["zoom_out","zoom_in","fit"][i]]=zoom_buttons[i]
	else:
		for child in panel_box.get_children():
			if child is Button and child.has_meta("action"): buttons[child.get_meta("action")]=child
	for key in buttons:
		var p=buttons[key].get_global_rect().get_center()
		print("SS_TARGET ",key," center=",roundi(p.x),",",roundi(p.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
	if hud.visible:
		var center=ocean.get_global_rect().get_center()
		print("SS_TARGET chart_center center=",roundi(center.x),",",roundi(center.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
		var approach=sim.mission.objectives[0].pos+Vector2(0,210)
		if sim.blocked(approach,25): approach=sim.mission.objectives[0].pos+Vector2(-210,0)
		var objective_point=ocean.global_position+ocean.world_offset+approach*ocean.world_scale
		print("SS_TARGET objective0 center=",roundi(objective_point.x),",",roundi(objective_point.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))
		var p=ocean.global_position+ocean.world_offset+Vector2(320,800)*ocean.world_scale
		print("SS_TARGET route center=",roundi(p.x),",",roundi(p.y)," viewport=",roundi(get_viewport_rect().size.x),",",roundi(get_viewport_rect().size.y))

func _enter_water() -> void:
	screen="mission"; menu.hide(); hud.show()
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
	var ready=""
	var unit=sim.units[sim.selected]
	for id in sim.mission.objectives.size():
		var objective=sim.mission.objectives[id]
		if objective.captured and not diagnostic_records.has(id):
			diagnostic_records[id]=true
			print("SS_OBJECTIVE_RECORDED mission=",mission_index," objective=",id)
			_retain_evidence()
		if not objective.captured and unit.alive and sim.capture_unit<0 and unit.pos.distance_to(objective.pos)<240 and sim.line_clear(unit.pos,objective.pos):
			ready="unit=%d objective=%d"%[sim.selected,id]
	if ready!=diagnostic_ready:
		diagnostic_ready=ready
		if not ready.is_empty(): print("SS_CAMERA_READY ",ready)
func _retain_evidence() -> void:
	for objective in sim.mission.objectives:
		if objective.captured and objective.has("optical"):
			recovered_evidence[objective.optical]={"name":objective.name,"caption":objective.evidence,"optical":objective.optical}
func _evidence_gallery(index: int) -> void:
	_retain_evidence()
	if recovered_evidence.is_empty(): _show_campaign(); return
	sim.paused=true; screen="evidence"; _clear_menu()
	var keys=recovered_evidence.keys(); var entry=recovered_evidence[keys[index%keys.size()]]
	_menu_text("RECOVERED OPTICAL / %d OF %d"%[index+1,keys.size()],18)
	_menu_text(entry.name,28)
	var image=TextureRect.new(); image.texture=load("res://assets/evidence/foundry_%s.png"%entry.optical)
	image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; image.custom_minimum_size=Vector2(0,minf(320,size.y*0.4)); panel_box.add_child(image)
	_menu_text(entry.caption,19)
	if keys.size()>1: _button(panel_box,"NEXT RECORD",func(): _evidence_gallery((index+1)%keys.size()))
	_button(panel_box,"BACK TO OPERATIONS",_show_campaign)
	call_deferred("_layout")
