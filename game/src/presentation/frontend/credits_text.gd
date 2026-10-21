extends RefCounted
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
