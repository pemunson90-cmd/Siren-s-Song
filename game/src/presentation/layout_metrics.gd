extends RefCounted
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
# The touch height of the latest layout, so a width question that is not given one (Main._layout asks only for
# the viewport) can still size a reading column to the current text.
static var last_touch:=48.
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
	last_touch=ceil(maxf(48,56*maxf(96,density_dpi)/160.0/maxf(0.01,scale)))
	return last_touch

# Menu panel width. One column is 800 wide on a portrait screen (more on a landscape one, see reading_column); the campaign hub uses two columns when
# the screen is landscape and each column can still hold a full-size touch row (cover screen, tablets).
const MENU_COLUMN=800.
const MENU_MARGIN=48.
const MENU_COLUMN_GAP=24.
const MENU_PANEL_PADDING=56.
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
static func reading_column(viewport_size: Vector2) -> float:
	if viewport_size.x<viewport_size.y:return MENU_COLUMN
	var font_px=maxi(17,roundi(last_touch*.29*Settings.text_scale()))
	return maxf(MENU_COLUMN,MENU_READING_CHARS*MENU_CHAR_EM*font_px+MENU_PANEL_PADDING)
# Width of one text column inside the menu panel (the whole inner width when not wide).
static func menu_column_width(viewport_size: Vector2,wide: bool) -> float:
	var inner=menu_width(viewport_size,wide)-MENU_PANEL_PADDING
	return (inner-MENU_COLUMN_GAP)/2. if wide else inner
static func menu_width(viewport_size: Vector2,wide: bool) -> float:
	if wide: return minf(2.*MENU_COLUMN+MENU_COLUMN_GAP+MENU_PANEL_PADDING,viewport_size.x-MENU_MARGIN)
	return minf(reading_column(viewport_size),viewport_size.x-MENU_MARGIN)
# Hub rows are touch targets at the 48dp gate; the 56dp touch height is the roomy default for other screens.
static func dense_height(touch_h: float) -> float:
	return maxf(48.,roundf(touch_h*48./56.))
