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
