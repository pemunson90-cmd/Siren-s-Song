extends RefCounted
# Credits content: creator line, engine, tools, then the audio attribution resource.
# Seam: Frontend._credits_screen calls credits(); lines() is the unchanged attribution renderer.
# Revert: call lines() directly in the frontend to restore the audio-only credits.
# TODO(pat): name the creator line; the owner has not specified it.
const CREATOR := "An independent reconnaissance game"
const ENGINE := ["Made with Godot Engine 4.6.3.",
	"Copyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.",
	"Released under the MIT License. See godotengine.org/license."]
const RECORD_POINTER := "Full audio source and licence record: in the game files."
# Player-facing filter for the attribution record. The resource itself stays complete (it is
# the licence record); the screen shows only the credits. A line is shown when it is not
# engineering detail (TECH_WORDS: file names, hashes, byte counts, code names, tool commands,
# error codes, mirror notes) and either names a credit (CREDIT_WORDS: a work, author, source,
# edit or licence; the raw text is tested so a **bold** author line counts) or continues a
# shown line that stopped mid-sentence (the record wraps long sentences over several lines).
const CREDIT_WORDS := ["licen", "creative commons", "cc-by", "attribution", "source:", "submitted", "author", "collection of sounds", "endorsement", "edited", "**"]
const TECH_WORDS := [".wav", ".json", ".gd", ".tres", ".py", ".zip", ".markdown", "sha256", "bytes", "`", "http403", "lane archive", "mirrors"]
const TOOLS := ["Godot editor and GDScript. GitHub Actions for automated checks.",
	"AI assisted development with Claude Code and Codex."]
static func credits(resource: Resource) -> Array:
	var out := [{"text": "SIREN'S SONG", "heading": true}, {"text": preload("res://src/presentation/public_copy.gd").present(CREATOR), "heading": false},
		{"text": "ENGINE", "heading": true}]
	for text in ENGINE: out.append({"text": text, "heading": false})
	out.append({"text": "TOOLS", "heading": true})
	for text in TOOLS: out.append({"text": text, "heading": false})
	out += screen_lines(resource)
	out.append({"text": RECORD_POINTER, "heading": false})
	return out
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
static func is_credit(text: String) -> bool:
	var low := text.to_lower()
	for word in CREDIT_WORDS:
		if low.contains(word): return true
	return false
static func is_technical(text: String) -> bool:
	var low := text.to_lower()
	for word in TECH_WORDS:
		if low.contains(word): return true
	return false
# Attribution lines for the credits screen: see the filter notes above. Same line format as lines().
static func screen_lines(resource: Resource) -> Array:
	var raw: String = ""
	if resource != null and resource.has_meta("attribution"): raw = str(resource.get_meta("attribution"))
	var out := []
	var open := false # the previous line was shown and stopped mid-sentence
	for source in raw.split("\n"):
		var line := source.strip_edges()
		if line.is_empty(): open = false; continue
		if is_technical(line) or not (is_credit(line) or open): open = false; continue
		var heading := line.begins_with("#")
		var text := line.lstrip("#").strip_edges().replace("**", "")
		open = not heading and (text.right(1).is_valid_int() or text.right(1).to_lower() != text.right(1).to_upper() or text.right(1) == ",")
		if not text.is_empty(): out.append({"text": text, "heading": heading})
	return out
