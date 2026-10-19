extends Control
const Simulation = preload("res://src/simulation/simulation.gd")
const OceanView = preload("res://src/presentation/ocean_view.gd")
var sim = Simulation.new()
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
var unlocked := 0
var completed: Array=[]
var upgrade := "endurance"
var capture_scenario := ""
var frame := 0
var menu_buttons: Array=[]
func _ready() -> void:
	get_tree().auto_accept_quit=false
	_theme()
	ocean=OceanView.new(); add_child(ocean)
	hud=Control.new(); hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); hud.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(hud)
	title_label=_label(hud,"",26)
	status_label=_label(hud,"",17)
	log_label=_label(hud,"",16)
	detail_label=_label(hud,"",16); detail_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	pause_button=_button(hud,"▶  RESUME",_pause)
	for i in 3:
		var id=i
		unit_buttons.append(_button(hud,["QUIETUS","DRONE A","DRONE B"][i],func(): _order("select",{"unit":id})))
	var orders=[["ping","SONAR"],["camera","CAMERA"],["silent","SILENT"],["queue","+ QUEUE"],["hold","HOLD"],["emp","DISRUPT"],["decoy","DECOY"],["recon","SURVEY"],["contact_hold","IF CONTACT"],["wait_drone","WAIT DRONE"]]
	for o in orders:
		var order=o[0]
		order_buttons[order]=_button(hud,o[1],func(): _order(order))
	order_buttons["home"]=_button(hud,"EXTRACT",func(): _order("emergency",{"point":sim.mission.extraction}))
	order_buttons["menu"]=_button(hud,"OPERATIONS",func(): sim.paused=true; _show_campaign())
	menu=PanelContainer.new(); add_child(menu); panel_box=VBoxContainer.new(); panel_box.add_theme_constant_override("separation",14); menu.add_child(panel_box)
	resized.connect(_layout)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scenario="): capture_scenario=arg.get_slice("=",1)
	_start_mission(0)
	if capture_scenario.is_empty(): _show_campaign()
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
	var b=Button.new(); b.text=text; b.custom_minimum_size=Vector2(0,48); b.pressed.connect(action); b.focus_mode=Control.FOCUS_NONE; parent.add_child(b); return b
func _layout() -> void:
	if ocean==null: return
	var wide=size.x/size.y>1.6
	title_label.position=Vector2(26,18); title_label.size=Vector2(size.x-52,34)
	status_label.position=Vector2(28,58); status_label.size=Vector2(size.x-56,28)
	var panel=Rect2(size.x-324,106,296,size.y-158) if wide else Rect2(26,size.y-294,size.x-52,244)
	ocean.position=Vector2(26,106); ocean.size=Vector2(size.x-376,size.y-158) if wide else Vector2(size.x-52,size.y-426)
	pause_button.position=panel.position; pause_button.size=Vector2(panel.size.x,48)
	for i in 3:
		unit_buttons[i].position=panel.position+Vector2(i*(panel.size.x/3),60); unit_buttons[i].size=Vector2(panel.size.x/3-4,48)
	var keys=["ping","camera","silent","queue","hold","emp","decoy","recon","contact_hold","wait_drone","home","menu"]
	var columns=2 if wide else 6
	var start=panel.position+Vector2(0,120)
	for i in keys.size():
		var b=order_buttons[keys[i]]
		b.position=start+Vector2((i%columns)*(panel.size.x/columns),(i/columns)*56)
		b.size=Vector2(panel.size.x/columns-6,48)
		b.add_theme_font_size_override("font_size",15 if wide else 13)
	detail_label.position=panel.position+Vector2(0,468 if wide else 234); detail_label.size=Vector2(panel.size.x,130); detail_label.visible=wide and size.y>720
	log_label.position=Vector2(28,size.y-38); log_label.size=Vector2(size.x-56,28)
	if menu!=null:
		menu.position=Vector2(maxf(24,(size.x-690)/2),maxf(12,(size.y-menu.size.y)/2)); menu.size.x=minf(690,size.x-48)
func _start_mission(index: int) -> void:
	mission_index=index; sim.start(index,upgrade); ocean.sim=sim; screen="mission"; menu.hide(); hud.show(); _refresh()
func _order(order: String,args: Dictionary={}) -> void:
	sim.command(order,args); _refresh()
func _pause() -> void:
	sim.paused=not sim.paused; _refresh()
func _process(dt: float) -> void:
	frame+=1
	if screen=="mission":
		sim.advance(dt)
		if not sim.outcome.is_empty(): _debrief()
		_refresh()
func _refresh() -> void:
	title_label.text="SIREN'S SONG    /    %02d  %s"%[mission_index+1,sim.mission.title.to_upper()]
	status_label.text="DEPTH %dm    O₂ %03d%%    HULL %03d%%    RECORDS %d / %d    %s"%[sim.mission.depth,int(sim.oxygen),int(sim.hull),sim.mission.objectives.filter(func(o): return o.captured).size(),sim.mission.objectives.size(),"TACTICAL PAUSE" if sim.paused else "REAL TIME"]
	pause_button.text="▶  RESUME / EXECUTE PLAN" if sim.paused else "Ⅱ  TACTICAL PAUSE"
	for i in 3:
		unit_buttons[i].modulate=Color("80d9cf") if sim.selected==i else Color.WHITE
		unit_buttons[i].disabled=not sim.units[i].alive
	order_buttons.queue.text="+ QUEUE ON" if sim.queue_mode else "REPLACE"
	order_buttons.silent.text="SILENT ✓" if sim.units[sim.selected].silent else "CRUISE"
	order_buttons.emp.text="DISRUPT · %d"%sim.tools.emp
	order_buttons.decoy.text="DECOY · %d"%sim.tools.decoy
	order_buttons.recon.text="SURVEY · %d"%sim.tools.recon
	log_label.text=sim.message
	detail_label.text="SELECTED  /  %s\n\nTap water: %s route\n%s\n\nSonar and cameras expose you.\nCover breaks sight and beam lock.\n\nEXTRACT replaces all orders."%[sim.units[sim.selected].name,"add to" if sim.queue_mode else "replace",sim.units[sim.selected].hold]
func _gui_input(event: InputEvent) -> void:
	if screen!="mission": return
	if (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		var p=event.position
		if Rect2(ocean.position,ocean.size).has_point(p):
			var point=ocean.map_position(p-ocean.position)
			if point.x>=0 and point.y>=0 and point.x<1600 and point.y<960: _order("route",{"point":point})
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_SPACE: _pause()
		if event.keycode==KEY_ESCAPE: sim.paused=true; _show_campaign()
func _clear_menu() -> void:
	for c in panel_box.get_children(): c.queue_free(); panel_box.remove_child(c)
	menu.show(); hud.hide(); menu.size.y=0
func _menu_text(text: String,font_size: int=17) -> Label:
	var l=_label(panel_box,text,font_size); l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; l.custom_minimum_size.x=minf(610,size.x-120); return l
func _show_campaign() -> void:
	screen="menu"; _clear_menu()
	_menu_text("SIREN'S SONG",38).add_theme_color_override("font_color",Color("80d9cf"))
	_menu_text("ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.",14)
	_menu_text("USS QUIETUS  /  OPERATIONS ARCHIVE",18)
	if sim.elapsed>0 and sim.outcome.is_empty(): _button(panel_box,"RESUME ACTIVE MISSION",func(): screen="mission"; menu.hide(); hud.show())
	for i in 6:
		var id=i
		var b=_button(panel_box,"%02d   %s   %s"%[i+1,Simulation.Missions.TITLES[i],"RECOVERED" if i in completed else ("AVAILABLE" if i<=unlocked else "LOCKED")],func(): _briefing(id))
		b.disabled=i>unlocked
	_menu_text("Equipment: %s"%upgrade.to_upper(),15)
	_button(panel_box,"CYCLE LOADOUT · endurance / disruption / survey",func(): upgrade=["endurance","disruption","survey"][( ["endurance","disruption","survey"].find(upgrade)+1)%3]; _show_campaign())
	_menu_text("Unlimited tactical pause · tap routes · survey, photograph, return",14)
	call_deferred("_layout")
func _briefing(index: int) -> void:
	_start_mission(index); screen="briefing"; _clear_menu()
	_menu_text("%02d / %s"%[index+1,sim.mission.title.to_upper()],30)
	_menu_text(sim.mission.brief,20)
	_menu_text("ORDERS\nTap water to replace your route. REPLACE toggles explicit queueing. Select Quietus or either drone. Use CAMERA within 240m of a gold record marker. Return Quietus to the extraction ring after all records are secured.",17)
	_menu_text("SPACE / PAUSE grants unlimited planning time. Silent running is slower and quieter. Disruption interrupts nearby Sirens for 12 seconds. Cover blocks sonar and enemy sight.",17)
	_button(panel_box,"ENTER WATER · START PAUSED",func(): screen="mission"; menu.hide(); hud.show())
	_button(panel_box,"BACK TO OPERATIONS",_show_campaign)
	call_deferred("_layout")
func _debrief() -> void:
	screen="debrief"; _clear_menu()
	if sim.outcome=="won":
		if mission_index not in completed: completed.append(mission_index)
		unlocked=mini(5,maxi(unlocked,mission_index+1))
		_menu_text("ARCHIVE RECOVERED",32)
		_menu_text(sim.mission.record,22)
		_menu_text("Dive time %02d:%02d  /  Hull %d%%  /  Life support %d%%"%[int(sim.elapsed)/60,int(sim.elapsed)%60,int(sim.hull),int(sim.oxygen)],17)
		if mission_index==5:
			_menu_text("THE SONG CONTINUES\n\nYou return with a warning, not a firing solution. Above you, the fleet waits for orders. Below, the foundry lights go dark, one by one. For the first time since descent, Quietus hears only the ocean.\n\nCampaign complete. Every dive remains replayable.",20)
		else: _button(panel_box,"NEXT DIVE",func(): _briefing(mission_index+1))
	else:
		_menu_text("SIGNAL LOST",32); _menu_text(sim.message,22); _menu_text("Recovered campaign records are preserved. Replan your approach from tactical pause.",17)
	_button(panel_box,"RETRY DIVE",func(): _briefing(mission_index))
	_button(panel_box,"OPERATIONS ARCHIVE",_show_campaign)
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
