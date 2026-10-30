extends RefCounted
# Placeholder-quality first-play guidance. One verb per prompt, one or two lines.
# Prompts are shown once per campaign (ids are saved); warnings pause for reading.
const MAX_OPERATION := 4
const FIRST_USE_HINTS := ["first_depth", "first_emit", "first_research", "first_field_tool"]
const Priced = preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
# Short briefing lines for the opening operations. The full rules stay in the field manual.
const GOALS := {
	0: "GOAL: photograph the signal spire, then bring Quietus home.\nDANGER: Sirens hunt by sound. Go slowly and keep rock between you and them.",
	1: "GOAL: photograph the WEST and EAST relays, then link them at the uplink.\nDANGER: patrol Sirens cover both approaches. Scout with a drone first.",
	2: "GOAL: SAMPLE the REQUEST and REPLY relays and bring both records home.\nDANGER: Sirens hear every sonar ping. Listen first.",
	3: "GOAL: photograph the heat source and the structure it feeds, then return home.\nDANGER: the open plant edge has little cover. Plan your way back before the second photo.",
	4: "GOAL: collect three records around the well, then return home.\nDANGER: a fast Siren follows noise. Break its view before its beam fires.",
	5: "GOAL: photograph the crown and wakes, then LISTEN at the lee receiver and return home.\nDANGER: Quietus must collect the six-second listening record. Use the southern rocks for cover."
}
const HINTS := {
	"move": {"text": "Tap QUIETUS or a drone, then tap open water to plan a route. Nothing moves until you press RESUME.", "ops": [0]},
	"pause": {"text": "PAUSE is always at top left. Time stops, and you can plan, inspect and change orders as long as you like.", "ops": [0]},
	"drone": {"text": "Send a drone ahead to look. Drones are expendable. Quietus is not.", "ops": [0]},
	"sweep": {"text": "A Siren heard noise and is walking to that spot. The cue gives its bearing and seconds. Time is paused. Slow down or go SILENT, and keep rock between you and it.", "ops": [0, 1, 2, 3]},
	"warning": {"text": "A Siren has noticed you, so time is paused. Its warning shows the bearing and seconds left. Break line of sight, slow down or go SILENT, then press RESUME.", "ops": [0, 1, 2, 3]},
	"noise": {"text": "Speed makes noise. Fast movement is heard from farther away. SILENT running is slower and quieter.", "ops": [0, 1, 2]},
	"priced_reach": Priced.HINTS.priced_reach,
	"priced_light": Priced.HINTS.priced_light,
	"priced_window": Priced.HINTS.priced_window,
	"priced_film": Priced.HINTS.priced_film,
	"first_depth": {"text": "Depth changes hold the craft still and expose it in both bands. A normal crossing takes four seconds; the pressure sleeve shortens it.", "ops": []},
	"first_emit": {"text": "EMIT spends reserve and makes noise. Returns take time; SECTOR and POWER set the next pulse's coverage and reach.", "ops": []},
	"first_research": {"text": "Recovered material and its regional account unlock research. Check RESEARCH or SUPPLIES for the project and its cost before choosing it.", "ops": []},
	"first_field_tool": {"text": "Field tools spend finite stock. Hold a tool button for its rules; SUPPLIES prepares the next launch, while RESUME keeps this dive's stock.", "ops": []}
}
# Keep the legacy priced-shots rollback marker for existing saves.
static var SAVED_HINT_IDS=HINTS.keys()+["priced_gone"]
static func goal(index: int) -> String:
	return GOALS.get(index, "")
static func hint_text(id: String) -> String:
	return HINTS.get(id, {}).get("text", "")
static func applies(id: String, operation: int) -> bool:
	if id in FIRST_USE_HINTS: return operation >= 0 and operation <= 40
	return HINTS.has(id) and operation in HINTS[id].ops
# Saved first-run flags: a short list of known hint ids. Anything else is rejected.
static func valid_seen(value: Variant) -> bool:
	if not value is Array or value.size() > SAVED_HINT_IDS.size(): return false
	var unique := []
	for id in value:
		if not id is String or not id in SAVED_HINT_IDS or id in unique: return false
		unique.append(id)
	return true
static func reference_text(brief: String) -> String:
	return "FIELD MANUAL\n\n" + brief + "\n\nORDERS\nTap a craft for its command ring; FLEET chooses a station. Tap empty water to mark a route, then confirm it if the craft already has orders. Craft → ROUTE → REPLACE / QUEUE changes append intent; PASS / STOP decides whether queued points are flown through or stopped at. PAUSE stays available. Drag / pinch inspects freely; FOCUS follows the craft and FIT shows the region.\n\nLAYERS AND NOISE\nPAUSE gives unlimited planning time. Silent running is slower and quieter. Changing depth layer takes 4 stationary seconds during which the craft is exposed in both layers. Sweeper Sirens hear farther than patrols and search longer, but follow only the last noise they heard; their cue shows direction and seconds since it was heard. Disruption interrupts nearby Sirens for 12 seconds. Quietus torpedoes travel noisily up to 150m; impact pins one Siren for 8s. Cover blocks sonar, enemy sight and torpedoes."
