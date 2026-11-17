extends Control
# WP-111: a cue on the menu's scrolling body (briefing, hub, fittings) that there is more below: a "MORE BELOW" chip,
# in the chip style of the camera panel's "MORE v" cue. It goes away at the end of the text. It takes no taps.
# WP-117 (blind critic round 9): the chip no longer fades over the last lines. It sits in its own strip under the
# scrolling body (the bottom margin, always reserved so the body does not resize when the chip comes and goes), so it
# never covers a line of text. It shows only when more than a line of content really runs on below the visible area,
# and never on a front-end screen (title, Game Modes) that covers the menu body, where nothing is below. Presentation
# only: it reads the scroll position and changes nothing.
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Prefs=preload("res://src/presentation/frontend/frontend_settings.gd")
const TEXT="MORE BELOW v"
const FONT_SHARE=0.24	# of the touch height, times the text setting
const FONT_MIN=14
const MIN_LINES=1.0	# less than this many label lines below the visible area is not "more"
const STRIP_PAD=8.0	# strip height beyond the chip text
const CHIP_FILL=Color("1d2a22")	# the camera panel's chip colours (shutter_table COLORS)
const CHIP_TEXT=Color("e0bf83")
var scroll:ScrollContainer
var host:Control
var strip:Control
var more:=false
static func install(main:Control,body:ScrollContainer)->Control:
	var cue=load("res://src/presentation/scroll_cue.gd").new()
	cue.name="ScrollCue";cue.scroll=body;cue.host=main
	# WP-117: the reserved strip sits right under the scrolling body in its column.
	var strip:=Control.new();strip.name="ScrollCueStrip";strip.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var column:=body.get_parent()
	column.add_child(strip);column.move_child(strip,body.get_index()+1)
	cue.strip=strip
	main.add_child(cue)
	return cue
func _ready()->void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE;top_level=true;hide()
func font_px()->int:
	var touch:float=host.ui_touch_height if host!=null and "ui_touch_height" in host else 48.0
	return maxi(FONT_MIN,roundi(touch*FONT_SHARE*Prefs.text_scale()))
# A front-end screen (title, Game Modes, profiles) is drawn over the menu body: nothing of the body is on show.
func covered()->bool:
	if host==null:return false
	var front=host.get_node_or_null("Frontend")
	return front!=null and front.visible and not front.get("embedded_settings")
# How far the content runs on below the visible area, in pixels.
func hidden_below()->float:
	if scroll==null or not is_instance_valid(scroll):return 0.0
	var bar:=scroll.get_v_scroll_bar()
	return bar.max_value-bar.page-float(scroll.scroll_vertical)
# More text lies below the visible part of the scroll: by more than a line.
func more_below()->bool:
	if scroll==null or not is_instance_valid(scroll) or not scroll.is_visible_in_tree() or covered():return false
	return hidden_below()>float(font_px())*MIN_LINES
func _process(_delta:float)->void:
	var px:=float(font_px())
	if strip!=null and is_instance_valid(strip) and strip.custom_minimum_size.y!=px+STRIP_PAD:strip.custom_minimum_size=Vector2(0,px+STRIP_PAD)
	var now:=more_below()
	if not now and not more and not visible:return
	if now and strip!=null and is_instance_valid(strip):
		var area:Rect2=strip.get_global_rect()
		if global_position!=area.position or size!=area.size:global_position=area.position;size=area.size
	if now!=more or now!=visible:
		more=now;visible=now;queue_redraw()
func _draw()->void:
	var font:=ThemeDB.fallback_font
	var px:=int(font_px())
	var width:=font.get_string_size(TEXT,HORIZONTAL_ALIGNMENT_LEFT,-1,px).x
	var chip:=Rect2(Vector2((size.x-width)/2.0-8.0,maxf(0.0,(size.y-px-6.0)/2.0)),Vector2(width+16.0,px+6.0))
	draw_rect(chip,CHIP_FILL)
	draw_string(font,Vector2(chip.position.x+8.0,chip.end.y-4.0),TEXT,HORIZONTAL_ALIGNMENT_LEFT,-1,px,CHIP_TEXT)
