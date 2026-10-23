extends RefCounted
# GRADE ON SECURE (Pat decision D3, 23 Oct 2026). Appends the frame's quality and
# letter grade to the "Record secured" message the moment the record is filed,
# so the player learns how good the frame was without waiting for the debrief.
# UI text only: reads the record's existing photo_quality, writes nothing else,
# changes no rule. Numbers and the on/off switch live in the table below.
# REVERT: set `enabled` to false (or revert the one wrapper in
# Simulation._record_secured); behavior returns to the old message exactly.
const TABLE:={"grade_a":0.85,"grade_b":0.6}
static var enabled:=true
static func letter(quality:float)->String:
	return "A" if quality>=float(TABLE.grade_a) else "B" if quality>=float(TABLE.grade_b) else "C"
static func note(record:Dictionary)->String:
	if not enabled or not record.has("photo_quality"):return ""
	var q:=float(record.photo_quality)
	return " · frame %d%% grade %s"%[roundi(q*100.0),letter(q)]
