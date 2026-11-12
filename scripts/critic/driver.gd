extends SceneTree
# Critic play kit driver, version 4.
#
# Runs the game's own main scene and turns JSON requests into real parsed input
# events. It never calls game code, reads game state or changes a save. A blind
# critic plays through it from screenshots.
#
# Protocol: the client writes one request file `<control>/request-<id>.json`
# (written under a temporary name, then renamed). The driver executes it and
# writes `<control>/result-<id>.json` the same way. One file per request, so a
# reply is never overwritten and never half-read. Requests run in name order.
#
# Environment: PLAYKIT_CONTROL (folder), PLAYKIT_SIZE (`WIDTHxHEIGHT`, optional).

var control := ""
var busy := false
var wanted_size := Vector2i.ZERO


func _initialize() -> void:
	Input.emulate_mouse_from_touch = true
	control = OS.get_environment("PLAYKIT_CONTROL")
	var size_text := OS.get_environment("PLAYKIT_SIZE")
	if size_text.contains("x"):
		var parts := size_text.split("x")
		wanted_size = Vector2i(int(parts[0]), int(parts[1]))
	call_deferred("_launch")


func _launch() -> void:
	var main = load(ProjectSettings.get_setting("application/run/main_scene"))
	root.add_child(main.instantiate())
	if wanted_size != Vector2i.ZERO:
		await process_frame
		# The desktop may be smaller than the requested client area. The window
		# is allowed to extend past it; captures read the full rendered viewport.
		DisplayServer.window_set_position(Vector2i.ZERO)
		DisplayServer.window_set_size(wanted_size)


func _process(_delta: float) -> bool:
	if busy or control.is_empty():
		return false
	var names: Array = []
	var dir := DirAccess.open(control)
	if dir == null:
		return false
	for name in dir.get_files():
		if name.begins_with("request-") and name.ends_with(".json"):
			names.append(name)
	if names.is_empty():
		return false
	names.sort()
	busy = true
	_serve(names[0])
	return false


func _serve(name: String) -> void:
	var path := control.path_join(name)
	var id := name.trim_prefix("request-").trim_suffix(".json")
	var raw := FileAccess.get_file_as_string(path)
	if raw.begins_with(String.chr(0xfeff)):
		raw = raw.substr(1)
	var parser := JSON.new()
	var result: Dictionary
	if parser.parse(raw) != OK or not parser.data is Dictionary:
		result = {"ok": false, "error": "Request is not a JSON object: %s" % parser.get_error_message()}
	else:
		result = await _execute(parser.data)
	result["id"] = id
	DirAccess.rename_absolute(path, control.path_join("done-" + name))
	var temporary := control.path_join("result-%s.tmp" % id)
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t"))
	file.close()
	DirAccess.rename_absolute(temporary, control.path_join("result-%s.json" % id))
	if result.get("quit", false):
		quit()
		return
	busy = false


func _to_window(pos: Vector2) -> Vector2:
	return pos * Vector2(DisplayServer.window_get_size()) / Vector2(root.get_texture().get_image().get_size())


func _touch(index: int, pos: Vector2, down: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = _to_window(pos)
	event.pressed = down
	Input.parse_input_event(event)


func _move(index: int, from: Vector2, to: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = _to_window(to)
	event.relative = _to_window(to - from)
	Input.parse_input_event(event)


func _point(c: Dictionary, x_key: String, y_key: String) -> Vector2:
	return Vector2(float(c.get(x_key, 0)), float(c.get(y_key, 0)))


func _execute(c: Dictionary) -> Dictionary:
	var result := {"command": c.get("command", ""), "ok": true}
	var pos := _point(c, "x", "y")
	match c.get("command", ""):
		"click":
			_touch(0, pos, true)
			await process_frame
			_touch(0, pos, false)
		"hold":
			_touch(0, pos, true)
			await create_timer(clampf(float(c.get("seconds", 0.8)), 0.0, 10.0)).timeout
			_touch(0, pos, false)
		"drag":
			var finish := _point(c, "to_x", "to_y")
			var steps := clampi(int(c.get("steps", 20)), 1, 600)
			var seconds := clampf(float(c.get("seconds", 0.5)), 0.0, 20.0)
			_touch(0, pos, true)
			var last := pos
			for i in range(1, steps + 1):
				var next := pos.lerp(finish, float(i) / steps)
				_move(0, last, next)
				last = next
				await create_timer(seconds / steps).timeout
			_touch(0, finish, false)
		"pinch":
			# Two fingers on a horizontal line through (x, y), moving from
			# `from_gap` pixels apart to `to_gap` pixels apart.
			var from_gap := float(c.get("from_gap", 200))
			var to_gap := float(c.get("to_gap", 400))
			var steps := clampi(int(c.get("steps", 20)), 1, 600)
			var seconds := clampf(float(c.get("seconds", 0.5)), 0.0, 20.0)
			var a := pos - Vector2(from_gap / 2.0, 0)
			var b := pos + Vector2(from_gap / 2.0, 0)
			_touch(0, a, true)
			_touch(1, b, true)
			for i in range(1, steps + 1):
				var gap := lerpf(from_gap, to_gap, float(i) / steps)
				var next_a := pos - Vector2(gap / 2.0, 0)
				var next_b := pos + Vector2(gap / 2.0, 0)
				_move(0, a, next_a)
				_move(1, b, next_b)
				a = next_a
				b = next_b
				await create_timer(seconds / steps).timeout
			_touch(0, a, false)
			_touch(1, b, false)
		"key":
			var keycode := OS.find_keycode_from_string(str(c.get("key", "")))
			for pressed in [true, false]:
				var event := InputEventKey.new()
				event.keycode = keycode
				event.pressed = pressed
				Input.parse_input_event(event)
				await process_frame
		"back":
			# The Android back button reaches the game as this notification.
			root.propagate_notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		"wait":
			await create_timer(clampf(float(c.get("seconds", 1)), 0.0, 120.0)).timeout
		"screenshot":
			await RenderingServer.frame_post_draw
			var image := root.get_texture().get_image()
			result["native_size"] = [image.get_width(), image.get_height()]
			var scale := clampf(float(c.get("scale", 1.0)), 0.1, 1.0)
			if scale < 1.0:
				image.resize(int(image.get_width() * scale), int(image.get_height() * scale), Image.INTERPOLATE_LANCZOS)
			result["path"] = str(c.get("path", ""))
			result["saved_size"] = [image.get_width(), image.get_height()]
			result["error"] = image.save_png(result["path"])
			result["ok"] = result["error"] == OK
		"geometry":
			result["texture_size"] = str(root.get_texture().get_image().get_size())
			result["visible_rect"] = str(root.get_visible_rect())
			result["window_size"] = str(DisplayServer.window_get_size())
			result["screen_size"] = str(DisplayServer.screen_get_size())
		"labels":
			var labels: Array = []
			_labels(root, labels)
			result["labels"] = labels
		"batch":
			# Runs several commands in order and stops at the first failure.
			var results: Array = []
			for step in c.get("steps", []):
				if not step is Dictionary or step.get("command", "") in ["batch", "quit"]:
					results.append({"ok": false, "error": "A batch step must be a plain command"})
					result["ok"] = false
					break
				var step_result: Dictionary = await _execute(step)
				results.append(step_result)
				if not step_result.get("ok", false):
					result["ok"] = false
					break
			result["results"] = results
		"quit":
			result["quit"] = true
		_:
			result["ok"] = false
			result["error"] = "Unknown command"
	return result


func _labels(node: Node, output: Array) -> void:
	var layer_visible := true
	var ancestor := node
	while ancestor != null:
		if ancestor is CanvasLayer and not ancestor.visible:
			layer_visible = false
		ancestor = ancestor.get_parent()
	if node is Control and node.is_visible_in_tree() and layer_visible:
		if node is Label or node is Button or node is RichTextLabel:
			var image_size := Vector2(root.get_texture().get_image().get_size())
			var pixel_scale := image_size / Vector2(DisplayServer.window_get_size())
			var transform: Transform2D = Transform2D.IDENTITY.scaled(pixel_scale) * root.get_final_transform() * node.get_global_transform_with_canvas()
			var rect: Rect2 = transform * Rect2(Vector2.ZERO, node.size)
			if rect.intersects(Rect2(Vector2.ZERO, image_size)) and not str(node.text).is_empty():
				output.append({"text": node.text, "rect": [int(rect.position.x), int(rect.position.y), int(rect.size.x), int(rect.size.y)]})
	for child in node.get_children():
		_labels(child, output)
