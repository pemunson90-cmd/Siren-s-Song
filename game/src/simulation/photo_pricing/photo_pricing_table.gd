extends RefCounted
const Names=preload("res://src/names.gd")
# PRICED SHOTS tunables. Every number and every line of placeholder text that the
# photo_pricing module uses lives here, so balance and wording change in one file.
# Nothing here changes damage, hull, collision, beams, Siren sight or hearing:
# the sight, speed and shutter figures below only MIRROR those rules so the
# player can read them (see the notes beside each).

# Film: finite exposures per craft (index 0 Quietus, 1 and 2 the drones). Every
# exposure that starts spends one, whether it is usable, unusable or interrupted.
const FILM := [8, 4, 4]

# Rings the player is told about. Mirror simulation.gd (Siren sight 290 m, 180 m
# against a silent craft, scaled by readiness) and photo_capture.gd (shutter 520 m,
# flash 760 m). A test checks the shutter figures against photo_capture.
const SIREN_SIGHT := 290.0
const SIREN_SIGHT_SILENT := 180.0
const SHUTTER_RING := 520.0
const FLASH_RING := 760.0
# Speed a Siren closes at once it has heard something (simulation.gd, suspicious
# movement). Used only for the "if heard" estimate; hunters are faster.
const SIREN_ALERT_SPEED := 48.0
const SIREN_SPEED := {Names.ROLE_HUNTER: 64.0}
# A contact older than this is not used for the estimate (simulation.gd expires them at 20 s).
const CONTACT_MAX_AGE := 20.0

# Low-light back: seconds of perfect stillness for full gain (photo_capture.gd frame()).
const STILL_HOLD := 8.0
# Distance scan for the reach rings, metres.
const SCAN_STEP := 5.0
const SCAN_MIN := 20.0
# Readout cache: seconds between recomputes while time runs.
const CACHE_STEP := 0.5
const CACHE_POS := 8.0

# Feature reasons that a light price can answer. A soft row says SOFT_REASON; its tail is the "better frame" hint.
const LIGHT_REASONS := ["TOO DARK", "TOO SOFT"]
const SOFT_HINT := "move closer, add light or hold still"
const SOFT_REASON := "TOO SOFT · " + SOFT_HINT
# The camera panel's one plain next step (photo_grade/next_step.gd), by what the frame lacks. %d is metres or seconds.
const NEXT := {
	"hidden": "Go round the subject: its detail faces away",
	"cropped": "Turn so the subject is in the frame",
	"focus": "Press FOCUS to choose it",
	"tight": "Switch to a TIGHT frame",
	"cycle": "Wait for its cycle",
	"close": "Move within %d m",
	"hold": "Hold still for %d s",
	"light": "Light the subject: the flash is fitted",
	"dark": "Too dark: this camera has no flash or low-light back",
	"soft": "Too soft: no range here gives a sharp frame",
	"heat": "Move closer: the heat shimmer hides it from here",
}

# Short placeholder text.
const TEXT := {
	"film_out": "OUT OF FILM · this craft has no exposures left",
	"film_tag": "FILM %d/%d",
	"reach": "%s sharp inside %dm%s",
	"reach_flash": " (%dm with flash)",
	"reach_hidden": "%s hidden from here · go round the subject",
	"heard": "SHUTTER heard to %dm",
	"heard_eta": " · nearest Siren ~%ds",
	"heard_none": " · no known Siren in range",
	"light_flash": "Flash: %s · heard %dm · %d left",
	"light_flash_none": "Flash: not fitted",
	"light_wait": "Low light: hold still %ds %s · heard %dm",
	"light_wait_none": "Low light: needs the low-light back",
	"light_close": "Closer: within %dm %s",
	"ok": "resolves it",
	"short": "not enough",
	"window_open": "%s OPEN · %ds left",
	"window_wait": "%s OPENS IN %ds",
	"problems": "PHOTO PROBLEMS · %s",
	"optics": "OPTICS · %s",
}

# Briefing "photo problems", one or two placeholder lines per operation. These
# describe what the subject asks for; the fit line is appended from the fitting.
const PROBLEMS := {
	0: "the sheltered side of the hull faces away; fine detail needs a close, held frame.",
	1: "the west relay clock is dark; only the submarine can light it.",
	3: "vent lining needs a close frame; frame bays open in a cycle.",
	4: "rib count shows only in its cycle; film is short.",
	5: "warm fracture needs thermal or a close look; throat needs a held frame.",
}

# First-play prompts (ids carry the priced_ prefix so a saved list stays valid
# if this module is removed). Shown by the existing once-only hint system.
const HINTS := {
	"priced_reach": {"text": "Closer is clearer. The rings show how near a detail resolves; Sirens see you from 290m.", "ops": [0]},
	"priced_light": {"text": "Too dark to resolve. Flash is loud and limited, the low-light back needs 8 still seconds, or close in.", "ops": [1]},
	"priced_window": {"text": "Some details show only in a cycle. The viewfinder counts down to the next opening.", "ops": [3]},
	"priced_film": {"text": "Film is limited. Every exposure costs one, even a failed one. Make each count.", "ops": [4]},
}

# Data pass on the opening operations (applied after photo_ops.gd builds the
# subjects). "feature" rows patch one feature of objective `obj`; "subject" rows
# patch the subject itself. Required features are never touched, so bare
# Quietus still finishes every core job; these edits price the bonus intel.
const EDITS := [
	# Op 0 Shelf Signal: the sheltered side of the hull and drill string ask for a held, close frame.
	{"op": 0, "obj": 0, "feature": "drill", "set": {"detail": 0.5, "dwell": 3.0}},
	{"op": 0, "obj": 0, "feature": "scoring", "set": {"detail": 0.6, "dwell": 3.5}},
	# Op 1 Split Channel: the west relay is dark; Quietus must close in, flash or wait. A drone lamp cannot do it.
	{"op": 1, "obj": 0, "subject": {"glow": 0.1}},
	{"op": 1, "obj": 0, "feature": "clock", "set": {"detail": 0.5, "need": "light", "dwell": 2.5}},
	{"op": 1, "obj": 1, "feature": "clock", "set": {"detail": 0.55, "dwell": 2.5}},
	# Op 3 Cold Foundry: held lining, and the open frames show only in a cycle.
	{"op": 3, "obj": 0, "feature": "lining", "set": {"detail": 0.58, "dwell": 3.0}},
	{"op": 3, "obj": 1, "feature": "frames", "set": {"detail": 0.55, "window": [26.0, 10.0, 4.0], "dwell": 3.0}},
	# Op 4 Listening Well: the rib count shows only in its own cycle.
	{"op": 4, "obj": 0, "feature": "count", "set": {"detail": 0.55, "window": [20.0, 8.0, 0.0], "dwell": 2.5}},
	# Op 5 Siren's Song: held frames for the throat and the warm fracture.
	{"op": 5, "obj": 0, "feature": "throat", "set": {"detail": 0.6, "dwell": 2.5}},
	{"op": 5, "obj": 1, "feature": "fracture", "set": {"detail": 0.45, "dwell": 2.0}},
]
