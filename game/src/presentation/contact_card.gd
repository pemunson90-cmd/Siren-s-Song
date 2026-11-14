extends Control
# [AI-DESIGNED] UI review B6 (Pat approved 2026-11-12)
# Tapping a Siren contact that is drawn on the chart opens this small card instead of setting a route.
# It shows only what the player's own sensors have observed: the readout label of the contact (id, role if
# identified, mode, depth band, lock or charge), its range and bearing from the selected craft, how old the
# observation is, and, for a role the player has identified, the dossier's tell and counterplay lines.
# It reads sim.contacts only (never sim.sirens), so a stale contact keeps its last observed position.
# Opening or closing it is information, not an order: dive time is never held or changed by it.
# A tap anywhere else on the chart closes it (and does nothing else); the QUIET CLOSE button also closes it.
const Identity=preload("res://src/simulation/contact_identity.gd")
const Dossier=preload("res://src/presentation/siren_dossier/dossier_table.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Compass=preload("res://src/presentation/compass.gd")
const FEED=preload("res://src/presentation/contact_feedback.gd")
var host
var key:=-1
var panel:PanelContainer
var title_label:Label
var facts_label:Label
var tell_label:Label
var counter_label:Label
var close_button:Button
var shown:Dictionary={}
var _look_key:=""
var _fit:Dictionary={}
var _sim=null
func setup(owner)->void:
	host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel=PanelContainer.new();panel.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(panel)
	var box:=VBoxContainer.new();box.add_theme_constant_override("separation",6);panel.add_child(box)
	title_label=_label(box);facts_label=_label(box);tell_label=_label(box);counter_label=_label(box)
	var row:=HFlowContainer.new();row.add_theme_constant_override("h_separation",8);box.add_child(row)
	close_button=Button.new();close_button.text="CLOSE";close_button.focus_mode=Control.FOCUS_NONE
	close_button.pressed.connect(close,CONNECT_DEFERRED);close_button.set_meta("action","contact_close");close_button.set_meta("ui_action","contact_close");row.add_child(close_button)
	var chip:=StyleBoxFlat.new();chip.bg_color=Color(.018,.055,.075,.94);chip.border_color=Color("ed8e79");chip.set_border_width_all(1);chip.set_corner_radius_all(6)
	chip.content_margin_left=12;chip.content_margin_right=12;chip.content_margin_top=8;chip.content_margin_bottom=8
	panel.add_theme_stylebox_override("panel",chip)
	panel.hide()
	panel.minimum_size_changed.connect(func():call_deferred("_refit"))
func _label(parent:Node)->Label:
	var l:=Label.new();l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(l);return l
# The observed readout entry for a contact id, or {} when that contact is no longer drawn.
static func entry_for(sim,id:int)->Dictionary:
	for entry in FEED.entries(sim.contacts,sim.elapsed,sim.units,sim.line_clear,sim.contact_target):
		if entry.key==id:return entry
	return {}
# The card's words, built from the cached contact only. Keys: title, facts, tell, counter, range, bearing, age.
static func describe(sim,id:int)->Dictionary:
	var entry=entry_for(sim,id)
	if entry.is_empty() or not sim.contacts.has(id):return {}
	var c=sim.contacts[id];var from=sim.units[sim.selected].pos;var across=c.pos-from
	var age=maxf(0.,sim.elapsed-float(c.time));var distance=roundi(from.distance_to(c.pos))
	var bearing=Compass.bearing(across)
	var seen="SEEN NOW" if entry.fresh else "SEEN %ds AGO"%int(age)
	var result={"key":id,"title":entry.text,"fresh":entry.fresh,"range":distance,"bearing":bearing,"age":age,"facts":"RANGE %dm · BEARING %03d° · %s"%[distance,bearing,seen],"tell":"","counter":""}
	# The dossier's lines, only for a role the player has identified in this dive.
	if Identity.known(sim,id):
		var role=str(sim.sonar.identified[id])
		for row in Dossier.ROLES:
			if row.id==role:result["tell"]="OBSERVABLE TELL · "+row.tell;result["counter"]="COUNTERPLAY · "+row.counter
	return result
func is_open()->bool:
	return key>=0 and panel!=null and panel.visible
func open(id:int)->void:
	if host==null or describe(host.sim,id).is_empty():return
	key=id;host.ocean.selected_contact=id;host.ocean.queue_redraw();host._refresh()
func close()->void:
	if key<0 and not panel.visible:return
	key=-1;host.ocean.selected_contact=-1;panel.hide();host.ocean.queue_redraw();host._refresh()
func reset()->void:
	key=-1;shown={}
	if panel!=null:panel.hide()
	if host!=null and host.ocean!=null:host.ocean.selected_contact=-1
func blocks(point:Vector2)->bool:
	return panel!=null and panel.visible and panel.get_global_rect().has_point(point)
# Called by the HUD's own refresh with the chart width, touch height, font size and the floor above the status text.
func refresh(bounds:Vector2,h:float,font:int,floor_y:float)->void:
	# A new dive (a different simulation) never inherits an open card.
	if host.sim!=_sim:_sim=host.sim;key=-1;host.ocean.selected_contact=-1
	if key>=0 and (host.advanced_orders or host.knock_armed or host.decoy_armed or describe(host.sim,key).is_empty()):
		key=-1;host.ocean.selected_contact=-1;host.ocean.queue_redraw()
	panel.visible=key>=0
	if key<0:shown={};return
	shown=describe(host.sim,key)
	title_label.text=shown.title;facts_label.text=shown.facts
	tell_label.text=shown.tell;tell_label.visible=not shown.tell.is_empty()
	counter_label.text=shown.counter;counter_label.visible=not shown.counter.is_empty()
	title_label.add_theme_color_override("font_color",Palette.chart_color("threat",Color("ed8e79") if shown.fresh else Color("b09a94")))
	for l in [title_label,facts_label,tell_label,counter_label,close_button]:l.add_theme_font_size_override("font_size",font)
	var look:=str(Palette.high_contrast())
	if look!=_look_key:_look_key=look;UiStyle.apply_for(close_button,"contact_close")
	close_button.custom_minimum_size=Vector2(h*1.55,h)
	var width:=bounds.x-24 if host.mission_hud.text_scale>=1.5 else minf(bounds.x-24,640.)
	panel.custom_minimum_size=Vector2(maxf(1.,width),0);panel.reset_size()
	_fit={"bounds":bounds,"h":h,"floor":floor_y}
	place(bounds.x,floor_y,h)
# Wrapped labels settle their height after the width is set.
func _refit()->void:
	if not panel.visible or host==null or _fit.is_empty():return
	panel.reset_size();place(_fit.bounds.x,_fit.floor,_fit.h)
# The card never covers the contact or the selected craft: bottom centre first, then top centre, then the edges and the middle rows.
func contact_rect(h:float)->Rect2:
	var at:Vector2=host.ocean.screen_position(host.sim.contacts[key].pos) if key>=0 and host.sim.contacts.has(key) else Vector2(-1e6,-1e6)
	var half:=maxf(h*.6,72.*host.ocean.world_scale)
	return Rect2(at-Vector2.ONE*half,Vector2.ONE*half*2)
func craft_rect(h:float)->Rect2:
	var at:Vector2=host.ocean.screen_position(host.sim.units[host.sim.selected].pos)
	return Rect2(at-Vector2.ONE*h*.6,Vector2.ONE*h*1.2)
func place(width:float,floor_y:float,h:float)->void:
	var dims:=panel.size;var top:=maxf(host.mission_hud.threat_floor(),h*2)
	var bottom:=maxf(top,floor_y-dims.y-10);var middle:=clampf((top+bottom)/2,top,bottom)
	var left:=clampf(12.,0.,maxf(0.,width-dims.x));var centre:=clampf((width-dims.x)/2,0.,maxf(0.,width-dims.x));var right:=maxf(0.,width-dims.x-12.)
	var avoid:Array[Rect2]=[contact_rect(h).grow(h*.25),craft_rect(h).grow(h*.25)]
	var guard=host.mission_hud.guard
	if guard!=null and guard.panel.visible:avoid.append(guard.panel.get_rect().grow(8))
	var best:=Vector2(centre,bottom);var least:=INF
	for at in [Vector2(centre,bottom),Vector2(centre,top),Vector2(left,bottom),Vector2(right,bottom),Vector2(left,top),Vector2(right,top),Vector2(left,middle),Vector2(right,middle),Vector2(centre,middle)]:
		var rect:=Rect2(at,dims);var covered:=0.
		for area in avoid:
			var over:=rect.intersection(area);covered+=over.size.x*over.size.y
		if covered<least:least=covered;best=at
		if covered==0.:break
	panel.position=best
