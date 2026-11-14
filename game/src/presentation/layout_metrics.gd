extends RefCounted
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
# Android reports safe area in physical display pixels; UI uses scaled canvas coordinates.
static func content_rect(viewport_size: Vector2,window_size: Vector2,safe_area: Rect2) -> Rect2:
	if window_size.x<=0 or window_size.y<=0 or safe_area.size.x<=0 or safe_area.size.y<=0: return Rect2(Vector2.ZERO,viewport_size)
	var clipped=safe_area.intersection(Rect2(Vector2.ZERO,window_size))
	var ratio=viewport_size/window_size
	return Rect2(clipped.position*ratio,clipped.size*ratio)

static func touch_height(viewport_size: Vector2,window_size: Vector2,density_dpi: float) -> float:
	var scale=minf(window_size.x/maxf(1,viewport_size.x),window_size.y/maxf(1,viewport_size.y))
	# A 56dp row accommodates two 14dp text lines plus themed padding.
	# 48dp remains the minimum external hit-size gate, not a required row height.
	return ceil(maxf(48,56*maxf(96,density_dpi)/160.0/maxf(0.01,scale)))

# Menu panel width. One column is 800 wide on a portrait screen (more on a landscape one, see reading_column); the campaign hub uses two columns when
# the screen is landscape and each column can still hold a full-size touch row (cover screen, tablets).
const MENU_COLUMN=800.
const MENU_MARGIN=48.
const MENU_COLUMN_GAP=24.
const MENU_PANEL_PADDING=56.
# The gap between the budget bars of one craft (POWER, CARGO, NOISE, ENDURANCE), across and between rows.
const BAR_STRIP_GAP=12.
static func hub_wide(viewport_size: Vector2,touch_h: float,text_scale: float=1.) -> bool:
	var column_min=maxf(640.,touch_h*7.)
	if viewport_size.x>=viewport_size.y*1.6 and viewport_size.x-MENU_MARGIN>=2.*column_min+MENU_COLUMN_GAP+MENU_PANEL_PADDING:return true
	# Near-square screens (the unfolded inner screen) take the preparation screens' rule: an operation card
	# (number, name, state tag, "Recover ... first") fits the same column a tool row does, scaled with the text.
	return prep_wide(viewport_size,touch_h,text_scale)
# Preparation screens (Fittings, Career and Expedition tools) use two columns in any orientation once each
# column can hold a tool row (name, count and two touch buttons) at the current touch height. Text wraps inside
# a column, so large text does not widen what a column needs; it only widens the longest word a row cannot
# break, which is measured here with the font the buttons use. The canvas is at least 1280 wide, so this is true
# on the tablet-shaped inner screen (1280 wide, touch 87) and the cover screen (1680 wide, touch 98) at every
# text size, and false on a portrait phone, where touch rows are taller.
const PREP_COLUMN_MIN=480.
const PREP_COLUMN_TOUCHES=6.
const PREP_LONGEST_WORD="RECONNAISSANCE"
const PREP_WORD_PADDING_TOUCHES=.6
static func column_need(touch_h: float,text_scale: float) -> float:
	var font_px=maxi(17,roundi(touch_h*.29*text_scale))
	var word=ThemeDB.fallback_font.get_string_size(PREP_LONGEST_WORD,HORIZONTAL_ALIGNMENT_LEFT,-1,font_px).x+touch_h*PREP_WORD_PADDING_TOUCHES
	return maxf(maxf(PREP_COLUMN_MIN,touch_h*PREP_COLUMN_TOUCHES),word)
static func prep_wide(viewport_size: Vector2,touch_h: float,text_scale: float) -> bool:
	return viewport_size.x-MENU_MARGIN>=2.*column_need(touch_h,text_scale)+MENU_COLUMN_GAP+MENU_PANEL_PADDING
# A single column on a landscape or near-square screen takes the width a line of text can be read at, not a fixed 800:
# about 75 characters at the current button font, never narrower than 800 and never wider than the screen. A portrait
# phone keeps its 800.
const MENU_READING_CHARS=75.
const MENU_CHAR_EM=.5
static func reading_column(viewport_size: Vector2,touch_h: float) -> float:
	if viewport_size.x<viewport_size.y:return MENU_COLUMN
	var font_px=maxi(17,roundi(touch_h*.29*Settings.text_scale()))
	return maxf(MENU_COLUMN,MENU_READING_CHARS*MENU_CHAR_EM*font_px+MENU_PANEL_PADDING)
# Width of one text column inside the menu panel (the whole inner width when not wide).
static func menu_column_width(viewport_size: Vector2,wide: bool,touch_h: float) -> float:
	var inner=menu_width(viewport_size,wide,touch_h)-MENU_PANEL_PADDING
	return (inner-MENU_COLUMN_GAP)/2. if wide else inner
static func menu_width(viewport_size: Vector2,wide: bool,touch_h: float) -> float:
	if wide: return minf(2.*MENU_COLUMN+MENU_COLUMN_GAP+MENU_PANEL_PADDING,viewport_size.x-MENU_MARGIN)
	return minf(reading_column(viewport_size,touch_h),viewport_size.x-MENU_MARGIN)
# WP-93: a button that wraps its text breaks only between words. Its width is never less than its longest word
# and the button's own padding, at whatever font size it carries now (Main._button calls this on every theme change).
static func keep_words_whole(button:Button)->void:
	if button.autowrap_mode==TextServer.AUTOWRAP_OFF or button.text.is_empty():return
	var need:=word_floor(button)
	if need>button.custom_minimum_size.x:button.custom_minimum_size.x=need
static func word_floor(button:Button)->float:
	var font:Font=button.get_theme_font("font");var font_px:int=button.get_theme_font_size("font_size")
	var widest:=0.
	for word in button.text.replace("\n"," ").split(" ",false):widest=maxf(widest,font.get_string_size(word,HORIZONTAL_ALIGNMENT_LEFT,-1,font_px).x)
	return ceilf(widest+button.get_theme_stylebox("normal").get_minimum_size().x)
# WP-96: the footer row (briefing and review buttons) is a flow row too. When every button's longest word fits on one line they
# share the line equally; when they do not, each takes a full row's worth and the row drops them onto further lines.
# The row never takes more than max_height of the panel: at a very large text size its labels shrink (never below
# FOOTER_MIN_FONT) so the page above it keeps room to scroll.
const FOOTER_MIN_FONT=17
static func share_row(row:FlowContainer,room:float,max_height:float)->void:
	var buttons=row.get_children().filter(func(c):return c is Button and c.visible)
	if buttons.is_empty():return
	var gap:=float(row.get_theme_constant("h_separation"))
	var font:Font=buttons[0].get_theme_font("font");var px:int=buttons[0].get_theme_font_size("font_size")
	var widest:=0.;var share:=0.;var rows:=1
	while true:
		for b in buttons:b.add_theme_font_size_override("font_size",px)
		widest=0.
		for b in buttons:widest=maxf(widest,word_floor(b))
		share=(room-gap*(buttons.size()-1))/buttons.size()
		rows=1 if share>=widest else buttons.size()
		var tall:=0.
		for b in buttons:
			var pad:Vector2=b.get_theme_stylebox("normal").get_minimum_size()
			tall=maxf(tall,font.get_multiline_string_size(b.text.replace("\n"," "),HORIZONTAL_ALIGNMENT_LEFT,maxf(1.,(share if rows==1 else room)-pad.x),px).y+pad.y)
		# A row is never expected to be shorter than one touch row.
		if rows*tall+gap*(rows-1)<=maxf(max_height,buttons[0].custom_minimum_size.y) or px<=FOOTER_MIN_FONT:break
		px=maxi(FOOTER_MIN_FONT,px-4)
	var width:=maxf(share,widest) if rows==1 else minf(room,widest)
	for b in buttons:
		# A fixed two-line label wider than its share gives up its line break and wraps between words instead.
		if b.autowrap_mode==TextServer.AUTOWRAP_OFF and rows==1 and b.get_minimum_size().x>share:
			b.text=b.text.replace("\n"," ");b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.custom_minimum_size.x=0
		b.custom_minimum_size.x=width
# WP-96: a row of buttons that shares one line (hub links, craft tabs, research tabs) is a flow row. Each button keeps its
# label on one line at its own width, and the row drops buttons onto a second line when they no longer fit, so no word breaks.
static func flow_row(parent:Node,gap:int)->HFlowContainer:
	var row:=HFlowContainer.new();row.add_theme_constant_override("h_separation",gap);row.add_theme_constant_override("v_separation",gap)
	row.alignment=FlowContainer.ALIGNMENT_CENTER;row.size_flags_horizontal=Control.SIZE_EXPAND_FILL;parent.add_child(row)
	return row
static func flow_button(button:Button,touch_h:float)->void:
	button.autowrap_mode=TextServer.AUTOWRAP_OFF;button.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size.x=touch_h
# Hub rows are touch targets at the 48dp gate; the 56dp touch height is the roomy default for other screens.
static func dense_height(touch_h: float) -> float:
	return maxf(48.,roundf(touch_h*48./56.))
