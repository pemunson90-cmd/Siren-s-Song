extends Control
# [AI-DESIGNED] UI review C4 (Pat approved 2026-11-12): full-screen title backdrop.
# The game's own dive-chart look: dark water with depth shading, rock islands drawn by the
# dive's rock drawing (art/rock_painter.gd), and one small Quietus drawn by the dive's craft
# drawing (art_renderer.gd) drifting through open water below the menu with a faint sonar ring.
# Cost: the static layer (water, rock, plate) is drawn once per size change; only the small
# animated layer redraws. Processing stops whenever this node is not visible.
# Layout uses no random numbers, so captures and tests see the same picture.
const RockPainter = preload("res://src/presentation/art/rock_painter.gd")
const Art = preload("res://src/presentation/art/art_renderer.gd")
const UiStyle = preload("res://src/presentation/ui_style.gd")
const FrontendSettings = preload("res://src/presentation/frontend/frontend_settings.gd")
const BASALT = preload("res://assets/materials/basalt.png")
const DESIGN_HEIGHT := 1080.0	# sizes below are for a screen this tall and scale with the height
const DRIFT_SPEED := 9.0		# pixels per second at the design height
const LANE := 0.80				# the craft's depth as a share of the screen height: open water below the menu
const RING_PERIOD := 9.0
const RING_LIFE := 4.0
const RING_REACH := 170.0
const MENU_WIDTH := 760.0		# the plate behind the menu column and the wordmark
const ROCK_POINTS := 11
# Rock islands: centre as a share of the screen, radius as a share of the rock unit, and a shape seed.
# They sit at the edges and corners, clear of the menu column and of the craft's lane.
const ROCKS := [
	[0.06, 0.16, 0.21, 0.3], [0.21, 0.44, 0.10, 1.7], [0.91, 0.10, 0.17, 2.6], [0.85, 0.47, 0.14, 4.1],
	[0.03, 1.02, 0.17, 5.2], [0.57, 1.06, 0.13, 0.9], [0.99, 0.98, 0.16, 3.3],
]
# Tests set this to freeze the animation; reduced-motion also freezes it.
var frozen := false
var elapsed := 0.0
var static_layer: Control
var craft_layer: Control
var unit := 1.0		# screen pixels per design pixel
class Layer extends Control:
	var painter: Callable
	var quietus = preload("res://assets/craft/quietus.png")	# art_renderer.gd reads view.quietus
	func _draw() -> void:
		if painter.is_valid(): painter.call(self)
func _init() -> void:
	name = "TitleBackdrop"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	static_layer = Layer.new(); static_layer.name = "StaticChart"; static_layer.painter = _paint_static
	static_layer.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED	# the basalt tiles across a wide rock, as in the dive
	craft_layer = Layer.new(); craft_layer.name = "DriftingCraft"; craft_layer.painter = _paint_craft
	for layer in [static_layer, craft_layer]:
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(layer)
func _ready() -> void:
	resized.connect(_on_resized)
	visibility_changed.connect(_sync_processing)
	_sync_processing()
	_on_resized()
func _on_resized() -> void:
	unit = clampf(size.y / DESIGN_HEIGHT, 0.5, 2.0)
	static_layer.queue_redraw(); craft_layer.queue_redraw()
# Processing runs only while the backdrop can be seen (title shown, node in the tree).
func _sync_processing() -> void:
	set_process(is_inside_tree() and is_visible_in_tree() and not frozen)
func set_frozen(value: bool) -> void:
	frozen = value; _sync_processing()
func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_EXIT_TREE: _sync_processing()
func _process(delta: float) -> void:
	if frozen or FrontendSettings.reduced_motion(): return
	elapsed += delta
	craft_layer.queue_redraw()
# Where the craft is now, on screen. Starts a quarter of the way across and loops.
func craft_position(at: float = elapsed) -> Vector2:
	var margin := 200.0 * unit
	var span := size.x + margin * 2.0
	var x := fposmod(size.x * 0.25 + margin + at * DRIFT_SPEED * unit, span) - margin
	return Vector2(x, size.y * LANE + sin(at * 0.4) * 5.0 * unit)
# One island outline: a ring of points whose distance from the centre wobbles with the seed.
func rock_outline(spec: Array) -> PackedVector2Array:
	var centre := Vector2(spec[0] * size.x, spec[1] * size.y)
	var radius: float = spec[2] * minf(size.y, size.x * 0.6)
	var shape: float = spec[3]
	var points := PackedVector2Array()
	for i in ROCK_POINTS:
		var angle := TAU * i / ROCK_POINTS
		var reach := radius * (0.86 + 0.09 * sin(i * 2.3 + shape) + 0.04 * sin(i * 5.1 + shape * 2.0))	# gentle, so no outline folds inward
		points.append(centre + Vector2(cos(angle) * 1.25, sin(angle)) * reach)
	return points
func _paint_static(canvas: Control) -> void:
	var s := canvas.size
	if s.x < 2.0 or s.y < 2.0: return
	canvas.draw_rect(Rect2(Vector2.ZERO, s), UiStyle.TITLE_WATER)
	# Depth shading: lighter near the surface, darker toward the floor, in steps too fine to see.
	var bands := 48
	for i in bands:
		var t := float(i) / float(bands - 1)
		var y0 := floorf(s.y * i / bands)
		canvas.draw_rect(Rect2(0, y0, s.x, floorf(s.y * (i + 1) / bands) - y0), Color(UiStyle.TITLE_DEEP, 0.55 * t * t) if t > 0.45 else Color(UiStyle.ACCENT, 0.07 * (1.0 - t / 0.45)))
	for spec in ROCKS:
		var outline := rock_outline(spec)
		var origin := outline[0]
		for p in outline: origin = Vector2(minf(origin.x, p.x), minf(origin.y, p.y))
		RockPainter.rock(canvas, outline, origin, BASALT, RockPainter.STONE, RockPainter.TINT, RockPainter.EDGE, 2.0 * unit, unit)
	# Soft plate behind the wordmark and the menu column: feathered edges, readable text.
	var plate := minf(MENU_WIDTH * unit, s.x)
	var left := (s.x - plate) * 0.5
	var feather := 10
	for i in feather:
		var t := float(i + 1) / float(feather)
		var inset := plate * 0.14 * (1.0 - t)
		canvas.draw_rect(Rect2(left + inset, 0, plate - inset * 2.0, s.y * 0.72), Color(UiStyle.TITLE_SCRIM, 0.07 * t + 0.02))
func _paint_craft(canvas: Control) -> void:
	var at := craft_position()
	# One faint sonar ring every few seconds, centred on the craft.
	var phase := fposmod(elapsed, RING_PERIOD)
	if phase < RING_LIFE:
		var t := phase / RING_LIFE
		canvas.draw_arc(at, (30.0 + t * RING_REACH) * unit, 0.0, TAU, 64, Color(UiStyle.TITLE_RING, 0.30 * (1.0 - t)), 2.0 * unit)
	canvas.draw_set_transform(at, 0.0, Vector2.ONE * 2.0 * unit)
	Art.craft(canvas, 0, "standard")
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
