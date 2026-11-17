extends RefCounted
# The one placement of a mode's banner in a dive (Expedition's run line, a rider's status): below the header
# controls and the threat stack, only as wide as its text, so the Hunt chip and the contact lines stay clear
# (WP-11 for Expedition; Naval Career pinned its rider line at a fixed spot and overlapped the contact lines,
# critic 13 Nov).
static func place(host,text:String)->void:
	var label:Label=host.status_label
	label.visible=host.screen=="mission" and not text.is_empty()
	if not label.visible:return
	label.text=text
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var top:float=host.ui_touch_height+24.
	if host.mission_hud!=null:top=maxf(top,host.mission_hud.threat_floor())
	var font=label.get_theme_font("font");var font_size=label.get_theme_font_size("font_size")
	var room:float=maxf(1.,host.size.x-24.)
	var text_size:Vector2=font.get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,room,font_size)
	var pad:Vector2=label.get_theme_stylebox("normal").get_minimum_size()
	label.position=Vector2(12,top);label.size=Vector2(minf(room,ceilf(text_size.x+pad.x+8.)),ceilf(text_size.y+pad.y))
