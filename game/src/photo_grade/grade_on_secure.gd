extends RefCounted
# GRADE ON SECURE (Pat decision D3, 23 Oct 2026). Appends the frame's quality and
# letter grade to the "Record secured" message the moment the record is filed,
# so the player learns how good the frame was without waiting for the debrief.
# A B or C frame also says what would raise it (the viewfinder's own hint) and what
# a better frame changes: the archive keeps the best intel quality per detail and
# camera research is cut from that intel (campaign/photo_intel.gd). No currency is
# paid per photograph, so no pay is promised.
# UI text only: reads the record's existing photo_quality, writes nothing else,
# changes no rule. Numbers and the on/off switch live in the table below.
# REVERT: set `enabled` to false (or revert the one wrapper in
# Simulation._record_secured); behavior returns to the old message exactly.
const TABLE:={"grade_a":0.85,"grade_b":0.6}
# The log line stays short: "Record secured · 47% C · better: closer, lit or still". The camera panel
# keeps the longer words (what a better frame changes) on its own line.
const TEXT:={"frame":" · %d%% %s","better":" · better: %s","panel_filed":"FRAME %d FILED · %d%% %s","panel_better":"BETTER FRAME: %s · it raises the intel kept for camera research"}
static var enabled:=true
static func letter(quality:float)->String:
	return "A" if quality>=float(TABLE.grade_a) else "B" if quality>=float(TABLE.grade_b) else "C"
# `hint` is what a better frame needs (FrameForecast.hint); empty adds no advice.
static func note(record:Dictionary,hint:String="")->String:
	if not enabled or not record.has("photo_quality"):return ""
	var q:=float(record.photo_quality)
	var text:String=TEXT.frame%[roundi(q*100.0),letter(q)]
	if letter(q)!="A" and not hint.is_empty():text+=TEXT.better%hint
	return text
