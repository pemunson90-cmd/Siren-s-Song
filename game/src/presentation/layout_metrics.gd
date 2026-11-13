extends RefCounted
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

# Menu panel width. One column is 800 wide as it always was; the campaign hub uses two columns when
# the screen is landscape and each column can still hold a full-size touch row (cover screen, tablets).
const MENU_COLUMN=800.
const MENU_MARGIN=48.
const MENU_COLUMN_GAP=24.
const MENU_PANEL_PADDING=56.
static func hub_wide(viewport_size: Vector2,touch_h: float) -> bool:
	var column_min=maxf(640.,touch_h*7.)
	return viewport_size.x>=viewport_size.y*1.6 and viewport_size.x-MENU_MARGIN>=2.*column_min+MENU_COLUMN_GAP+MENU_PANEL_PADDING
static func menu_width(viewport_size: Vector2,wide: bool) -> float:
	if wide: return minf(2.*MENU_COLUMN+MENU_COLUMN_GAP+MENU_PANEL_PADDING,viewport_size.x-MENU_MARGIN)
	return minf(MENU_COLUMN,viewport_size.x-MENU_MARGIN)
# Hub rows are touch targets at the 48dp gate; the 56dp touch height is the roomy default for other screens.
static func dense_height(touch_h: float) -> float:
	return maxf(48.,roundf(touch_h*48./56.))
