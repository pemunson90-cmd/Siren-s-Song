extends Control
# WP-111: a cue on the menu's scrolling body (briefing, hub, fittings) that there is more below: a fade at the bottom
# edge and a "MORE BELOW" chip, in the chip style of the camera panel's "MORE v" cue. It goes away at the end of the
# text. It takes no taps. Presentation only: it reads the scroll position and changes nothing.
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Prefs=preload("res://src/presentation/frontend/frontend_settings.gd")
const TEXT="MORE BELOW v"
const FADE_LINES=2.4	# the fade is this many label lines tall
const FONT_SHARE=0.24	# of the touch height, times the text setting
const FONT_MIN=14
const END_SLACK=3.0	# pixels from the end that count as the end
const CHIP_FILL=Color("1d2a22")	# the camera panel's chip colours (shutter_table COLORS)
const CHIP_TEXT=Color("e0bf83")
var scroll:ScrollContainer
var host:Control
var more:=false
static func install(main:Control,body:ScrollContainer)->Control:
	var cue=load("res://src/presentation/scroll_cue.gd").new()
	cue.name="ScrollCue";cue.scroll=body;cue.host=main
	main.add_child(cue)
	return cue
func _ready()->void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE;top_level=true;hide()
func font_px()->int:
	var touch:float=host.ui_touch_height if host!=null and "ui_touch_height" in host else 48.0
	return maxi(FONT_MIN,roundi(touch*FONT_SHARE*Prefs.text_scale()))
# More text lies below the visible part of the scroll.
func more_below()->bool:
	if scroll==null or not is_instance_valid(scroll) or not scroll.is_visible_in_tree():return false
	var bar:=scroll.get_v_scroll_bar()
	return bar.max_value-bar.page-float(scroll.scroll_vertical)>END_SLACK
func _process(_delta:float)->void:
	var now:=more_below()
	if not now and not more:return
	var area:Rect2=scroll.get_global_rect() if now else Rect2()
	var fade:float=font_px()*FADE_LINES
	if now and (not visible or global_position!=area.position+Vector2(0,area.size.y-fade) or size!=Vector2(area.size.x,fade)):
		global_position=area.position+Vector2(0,area.size.y-fade);size=Vector2(area.size.x,fade)
	if now!=more or now!=visible:
		more=now;visible=now;queue_redraw()
func _draw()->void:
	var clear:=Color(UiStyle.PANEL_FILL,0.0)
	draw_polygon(PackedVector2Array([Vector2.ZERO,Vector2(size.x,0),size,Vector2(0,size.y)]),PackedColorArray([clear,clear,Color(UiStyle.PANEL_FILL,0.96),Color(UiStyle.PANEL_FILL,0.96)]))
	var font:=ThemeDB.fallback_font
	var px:=int(font_px())
	var width:=font.get_string_size(TEXT,HORIZONTAL_ALIGNMENT_LEFT,-1,px).x
	var chip:=Rect2(Vector2((size.x-width)/2.0-8.0,size.y-px-10.0),Vector2(width+16.0,px+6.0))
	draw_rect(chip,CHIP_FILL)
	draw_string(font,Vector2(chip.position.x+8.0,chip.end.y-4.0),TEXT,HORIZONTAL_ALIGNMENT_LEFT,-1,px,CHIP_TEXT)
