extends RefCounted
# One drawing of a rock island, shared by the dive chart (ocean_view.gd _rock) and the title
# backdrop (frontend/title_backdrop.gd): a dark lower shelf, the stone fill, the basalt texture,
# hatched cliff faces on the edges that run right to left, a light line on the others.
# `k` scales the shelf offset, hatch spacing and line widths; the dive passes 1.0.
const SHELF := Vector2(9, 23)
const HATCH := Vector2(7, 21)
const TEXTURE_SPAN := 400.0
# The look of a region with no style of its own.
const STONE := Color("31474c")
const TINT := Color(0.72, 0.85, 0.86)
const EDGE := Color(0.49, 0.65, 0.66, 0.55)
static func rock(canvas: CanvasItem, poly: PackedVector2Array, origin: Vector2, basalt: Texture2D, stone: Color, tint: Color, edge: Color, stroke: float, k: float = 1.0) -> void:
	var lower := PackedVector2Array(); var uv := PackedVector2Array()
	for p in poly:
		lower.append(p + SHELF * k); uv.append((p - origin) / (Vector2.ONE * TEXTURE_SPAN * k))
	canvas.draw_colored_polygon(lower, Color("030b11"))
	canvas.draw_colored_polygon(poly, stone)
	canvas.draw_polygon(poly, PackedColorArray([tint]), uv, basalt)
	var step := maxi(1, int(round(8.0 * k)))
	for n in poly.size():
		var a := poly[n]; var b := poly[(n + 1) % poly.size()]
		if b.x < a.x:
			canvas.draw_colored_polygon(PackedVector2Array([a, b, b + SHELF * k, a + SHELF * k]), Color("11252e"))
			for d in range(0, int(a.distance_to(b)), step):
				var p := a.move_toward(b, d)
				canvas.draw_line(p, p + HATCH * k, Color(0.2, 0.35, 0.39, 0.5), 2 * k)
		else: canvas.draw_line(a, b, edge, 1.8 * k)
	canvas.draw_polyline(poly, Color(0.17, 0.26, 0.3, 0.5), stroke)
