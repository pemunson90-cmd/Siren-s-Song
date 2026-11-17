extends RefCounted
# WP-52: what a wheel segment shows beyond its name, and the two-tap rule.
#  - A toggle segment carries a small second line with the state it is in (hud_words.gd state_line).
#  - A segment listed in HudWords.TWO_TAP is armed by its first tap: drawn filled with the MAIN role colour, its cost
#    lines and "Tap again to confirm" in the wheel's centre, nothing changed in the simulation. A second tap on the
#    same segment performs it; a tap on another segment, outside the wheel, or a change of craft or page disarms it.
# Presentation only: the order each segment sends is untouched.
const Words=preload("res://src/presentation/hud_words.gd")
const Truthful=preload("res://src/presentation/truthful_commands.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const LINE_NODE="StateLine"
const LOOK_META="armed_look"
const FEEDBACK_META="truthful_feedback"
var armed:=""
var armed_unit:=-1

static func key_of(button:Button)->String:
	return str(button.get_meta("action",""))
func is_armed(button:Button)->bool:
	return armed!="" and key_of(button)==armed
func disarm()->void:
	armed="";armed_unit=-1

# The one entry point for a wheel tap that was released on the segment it was pressed on.
func tap(hud,button:Button)->void:
	var key:String=key_of(button)
	if hud.has_meta(FEEDBACK_META):hud.remove_meta(FEEDBACK_META)
	if not button.disabled and Words.needs_confirm(key,hud.host.sim) and not is_armed(button):
		armed=key;armed_unit=hud.host.sim.selected
		hud.queue_redraw();hud.refresh()
		return
	disarm()
	Truthful.activate(hud,button)

# Every refresh: drop a stale arming, then draw the armed look and the state lines on the segments in the wheel.
func sync(hud)->void:
	var sim=hud.host.sim
	if armed!="":
		var live:bool=hud.host.advanced_orders and armed_unit==sim.selected and Words.needs_confirm(armed,sim)
		live=live and hud.ring_buttons.any(func(b):return key_of(b)==armed and not b.disabled)
		if not live:disarm()
	for b in hud.ring_buttons:
		_look(b,is_armed(b))
		_state_line(hud,b)

func _look(b:Button,on:bool)->void:
	var colors:Dictionary=UiStyle.role_colors(UiStyle.MAIN)
	if on:
		for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_hover_pressed_color"]:b.add_theme_color_override(name,colors.text)
		b.add_theme_constant_override("outline_size",0)
		b.set_meta(LOOK_META,true)
	elif b.has_meta(LOOK_META):
		for name in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_hover_pressed_color"]:b.remove_theme_color_override(name)
		b.add_theme_constant_override("outline_size",3)
		b.remove_meta(LOOK_META)

# The small second line is a child label at the segment's foot; the segment's own text is lifted above it by the
# same height, so the two never overlap. Both shrink with the segment's type (floor STATE_LINE_MIN).
func _state_line(hud,b:Button)->void:
	var text:String=Words.state_line(key_of(b),hud.host.sim)
	var label:Label=b.get_node_or_null(LINE_NODE)
	if text.is_empty():
		if label!=null:label.hide()
		return
	if label==null:
		label=Label.new();label.name=LINE_NODE;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_BOTTOM
		label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);b.add_child(label)
	var font:Font=b.get_theme_font("font");var base:int=b.get_theme_font_size("font_size")
	var margin:float=b.get_theme_stylebox("normal").get_minimum_size().x+2.
	var px:int=maxi(UiStyle.STATE_LINE_MIN,roundi(base*UiStyle.STATE_LINE_SCALE))
	while px>UiStyle.STATE_LINE_MIN and font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,px).x>b.size.x-margin:px-=1
	var height:float=ceilf(font.get_height(px))
	label.text=text;label.add_theme_font_size_override("font_size",px)
	label.add_theme_color_override("font_color",UiStyle.role_colors(UiStyle.MAIN).text if is_armed(b) else UiStyle.QUIET_TEXT)
	label.offset_top=-height-3.;label.offset_bottom=-3.;label.show()
	for state in ["normal","hover","pressed","disabled"]:
		var box:StyleBox=b.get_theme_stylebox(state)
		box.content_margin_bottom=height+3.
