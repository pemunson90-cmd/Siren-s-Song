extends Control
# [AI-DESIGNED] UI review C4 (Pat approved 2026-11-12): full-screen title backdrop.
# The game's own dive-chart look: dark water, depth shading, basalt rock drawn by
# the dive's terrain drawing (confluence_world.gd), and one small Quietus drawn by
# the dive's craft drawing (art_renderer.gd) drifting across with a faint sonar ring.
# Cost: the static layer (water, rock, scrim) is drawn once per size change; only the
# small animated layer redraws. Processing stops whenever this node is not visible.
# Layout uses no random numbers, so captures and tests see the same picture.
const Terrain = preload("res://src/presentation/confluence_world.gd")
const Art = preload("res://src/presentation/art/art_renderer.gd")
const Names = preload("res://src/names.gd")
const UiStyle = preload("res://src/presentation/ui_style.gd")
const FrontendSettings = preload("res://src/presentation/frontend/frontend_settings.gd")
const CELL := 40.0
const WORLD_HEIGHT := 700.0		# the chart is laid out 700 units tall and scaled to the screen height
const DRIFT_SPEED := 14.0		# screen pixels per second at 1080 px tall
const RING_PERIOD := 9.0
const RING_LIFE := 4.0
const MENU_WIDTH := 700.0		# the plate behind the menu column and the wordmark
# Tests set this to freeze the animation; reduced-motion also freezes it.
var frozen := false
var elapsed := 0.0
var static_layer: Control
var craft_layer: Control
var chart_scale := 1.0
var craft_scale := 1.0
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
	chart_scale = maxf(size.y, 1.0) / WORLD_HEIGHT
	craft_scale = clampf(size.y / 540.0, 1.0, 3.0)
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
# Where the craft is now, on screen. Starts a third of the way across and loops.
func craft_position(at: float = elapsed) -> Vector2:
	var span := size.x + 360.0
	var x := fposmod(size.x * 0.3 + 180.0 + at * DRIFT_SPEED * craft_scale, span) - 180.0
	return Vector2(x, size.y * 0.36 + sin(at * 0.5) * 6.0 * craft_scale)
# Deterministic chart in world units: a seabed ridge line plus an outcrop at each side.
func _floor_y(x: float, world_w: float) -> float:
	var base := WORLD_HEIGHT * 0.80
	return base - 26.0 * sin(x * 0.011 + 0.6) - 15.0 * sin(x * 0.027 + 2.0) - 70.0 * exp(-pow((x - world_w * 0.5) / (world_w * 0.22), 2.0))
func _chart(world_w: float) -> Dictionary:
	var clear: Array = []
	var faces: Array = []
	var side := minf(world_w * 0.12, 190.0)
	for cx in int(ceil(world_w / CELL)):
		var x := (cx + 0.5) * CELL
		var floor_y := _floor_y(x, world_w)
		for cy in int(ceil(WORLD_HEIGHT / CELL)):
			var y := (cy + 0.5) * CELL
			if y < floor_y - CELL * 0.5 and x > side * (0.55 + 0.35 * sin(y * 0.02)) and x < world_w - side * (0.55 + 0.35 * cos(y * 0.02 + 1.0)):
				clear.append(Vector2i(cx, cy))
	# Seabed, wound left to right so the rock lies below (the dive's winding rule).
	var step := 22.0
	var n := int(ceil(world_w / step))
	for i in n:
		var a := Vector2(i * step, _floor_y(i * step, world_w)); var b := Vector2((i + 1) * step, _floor_y((i + 1) * step, world_w))
		faces.append([a, b])
	# Left outcrop, wound downward (rock to the left); right outcrop, wound upward (rock to the right).
	var rows := int(ceil(WORLD_HEIGHT / step))
	for i in rows:
		var y0 := i * step; var y1 := (i + 1) * step
		faces.append([Vector2(side * (0.55 + 0.35 * sin(y0 * 0.02)), y0), Vector2(side * (0.55 + 0.35 * sin(y1 * 0.02)), y1)])
		faces.append([Vector2(world_w - side * (0.55 + 0.35 * cos(y1 * 0.02 + 1.0)), y1), Vector2(world_w - side * (0.55 + 0.35 * cos(y0 * 0.02 + 1.0)), y0)])
	return {"cell_size": CELL, "clear_cells": clear, "surface_segments": faces}
func _paint_static(canvas: Control) -> void:
	var s := canvas.size
	if s.x < 2.0 or s.y < 2.0: return
	canvas.draw_rect(Rect2(Vector2.ZERO, s), UiStyle.TITLE_WATER)
	# Depth shading: lighter near the surface, darker toward the floor.
	var bands := 12
	for i in bands:
		var t := float(i) / float(bands - 1)
		canvas.draw_rect(Rect2(0, s.y * i / bands, s.x, ceilf(s.y / bands) + 1.0), Color(UiStyle.TITLE_DEEP, 0.50 * t * t + 0.06))
	var world_w := s.x / chart_scale
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * chart_scale)
	Terrain.draw_terrain(canvas, _chart(world_w), chart_scale)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Soft plate behind the wordmark and the menu column: feathered edges, readable text.
	var plate := minf(MENU_WIDTH, s.x)
	var left := (s.x - plate) * 0.5
	var feather := 8
	for i in feather:
		var t := float(i + 1) / float(feather)
		var inset := plate * 0.16 * (1.0 - t)
		canvas.draw_rect(Rect2(left + inset, 0, plate - inset * 2.0, s.y), Color(UiStyle.TITLE_SCRIM, 0.09 * t + 0.02))
	# Dim the whole picture a little so the chart stays background.
	canvas.draw_rect(Rect2(Vector2.ZERO, s), Color(UiStyle.TITLE_DEEP, 0.22))
func _paint_craft(canvas: Control) -> void:
	var at := craft_position()
	# One faint sonar ring every few seconds, centred on the craft.
	var phase := fposmod(elapsed, RING_PERIOD)
	if phase < RING_LIFE:
		var t := phase / RING_LIFE
		var radius := (40.0 + t * 260.0) * craft_scale
		canvas.draw_arc(at, radius, 0.0, TAU, 64, Color(UiStyle.TITLE_RING, 0.22 * (1.0 - t)), 2.0 * craft_scale)
	canvas.draw_set_transform(at, 0.0, Vector2.ONE * craft_scale)
	Art.craft(canvas, 0, "standard")
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
