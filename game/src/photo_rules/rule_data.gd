extends RefCounted
# PHOTO RULES / AUTHORED DATA. One optional subject that only the deep water
# shows, so the pressure sleeve has a reason to be fitted.
#
# THE DEEP SEAM (operation 1, Split Channel). A cable runs into a seam in the
# west shelf wall. It is sighted as an area on the chart from the start and as an
# unidentified shape from the MIDDLE band, but it can be photographed only from
# DEEP (subject.bands = [2]). It sits about 165 m from the western patroller's
# loop: going down and coming back are exposed in both bands for 4 s each (2.5 s
# with the pressure sleeve, for 0.75 oxygen a hop), and the deep exposure draws
# 0.075 oxygen a second. The loop clock (photo_rules/loop_clock.gd) tells the
# player when the patrol is on the far side. It is optional: the operation
# finishes without it, and a bare Quietus can still take it (the sleeve only
# shortens the exposed shifts).
#
# Patrol loops: every patroller on operations 0 to 5 already walks an authored
# circuit (campaign/tutorial_missions.gd `circuits`; operation 1 and 2 loops are
# four-point circuits around their relays), and photo_findings.gd files that circuit
# as the loop the clock reads. No loop is rewritten here.
#
# Seam: operation_catalog.make() calls RuleData.apply(m,id) after the photo data
# pass. Remove that line (or set SUBJECT_ENABLED=false) and the seam is gone; the
# record key `deep_seam` stays registered in photo_ops.gd, harmlessly.
# Story text is a short placeholder.
const Table = preload("res://src/photo_rules/rule_table.gd")
const BandTable = preload("res://src/photo_depth/band_table.gd")
const PhotoOps = preload("res://src/campaign/photo_ops.gd")
const OPERATION := 1
const POS := Vector2(520, 1180)

static func apply(m: Dictionary, id: int) -> void:
	if id != OPERATION or not Table.ENABLED or not Table.SUBJECT_ENABLED or not (2 in BandTable.SHOOT_BANDS):
		return
	var subject: Dictionary = PhotoOps.S(1.57, 90.0, 0.12, ["seam"], [
		PhotoOps.F("seam", "SEAM MOUTH", 0.0, PI, 0.06, -0.2, {"glow": 0.1}),
		PhotoOps.F("cable", "SEAM CABLE", 0.0, 1.2, 0.4, 0.4, {"intel": "deep_seam", "gloss": Table.TEXT.deep_gloss, "finding": {"kind": "note", "text": Table.TEXT.deep_find}})],
		{"reveal": Table.TEXT.deep_name, "bands": [2], "band": 2})
	if not m.has("photo_hidden"):
		m["photo_hidden"] = []
	m.photo_hidden.append({"key": "deep_seam", "pos": POS, "sight": 200.0, "seen_as": Table.TEXT.deep_seen, "found": false,
		"lead": {"r": 200.0, "off": Vector2(40, -50), "alias": Table.TEXT.deep_alias}, "evidence": Table.TEXT.deep_evidence, "subject": subject})
	m.brief += Table.TEXT.deep_brief
