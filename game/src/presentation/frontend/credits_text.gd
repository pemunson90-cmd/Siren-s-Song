extends RefCounted
# Credits content: creator line, engine, tools, then the audio attribution resource.
# Seam: Frontend._credits_screen calls credits(); lines() is the unchanged attribution renderer.
# Revert: call lines() directly in the frontend to restore the audio-only credits.
# TODO(pat): name the creator line; the owner has not specified it.
const CREATOR := "An independent reconnaissance game"
const ENGINE := ["Made with Godot Engine 4.6.3.",
	"Copyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.",
	"Released under the MIT License. See godotengine.org/license."]
const TOOLS := ["Godot editor and GDScript. GitHub Actions for automated checks.",
	"AI assisted development with Claude Code and Codex."]
static func credits(resource: Resource) -> Array:
	var out := [{"text": "SIREN'S SONG", "heading": true}, {"text": CREATOR, "heading": false},
		{"text": "ENGINE", "heading": true}]
	for text in ENGINE: out.append({"text": text, "heading": false})
	out.append({"text": "TOOLS", "heading": true})
	for text in TOOLS: out.append({"text": text, "heading": false})
	return out + lines(resource)
# Turns the attribution resource (markdown prose) into display lines.
# Content is shown verbatim apart from markdown markers; nothing is added or dropped.
static func lines(resource: Resource) -> Array:
	var raw: String = ""
	if resource != null and resource.has_meta("attribution"): raw = str(resource.get_meta("attribution"))
	var out := []
	for source in raw.split("\n"):
		var text := source.strip_edges()
		if text.is_empty(): continue
		var heading := text.begins_with("#")
		text = text.lstrip("#").strip_edges().replace("**", "")
		if not text.is_empty(): out.append({"text": text, "heading": heading})
	return out
