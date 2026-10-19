extends RefCounted
# Android reports safe area in physical display pixels; UI uses scaled canvas coordinates.
static func content_rect(viewport_size: Vector2,window_size: Vector2,safe_area: Rect2) -> Rect2:
	if window_size.x<=0 or window_size.y<=0 or safe_area.size.x<=0 or safe_area.size.y<=0: return Rect2(Vector2.ZERO,viewport_size)
	var clipped=safe_area.intersection(Rect2(Vector2.ZERO,window_size))
	var ratio=viewport_size/window_size
	return Rect2(clipped.position*ratio,clipped.size*ratio)
