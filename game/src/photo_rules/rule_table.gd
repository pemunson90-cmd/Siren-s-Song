extends RefCounted
# PHOTO RULES: every number and every line of placeholder text the module uses.
#
# What a studied subject teaches the player. These are display and planning aids
# worked out from the player's own findings and last contacts: nothing here moves
# a Siren, changes its senses, or touches damage, beams, lock, sight or hearing,
# and nothing reads a Siren's live position. Clocks are computed when drawn and
# are never saved.
#
# NEUTRAL VALUES (the game as it played before this module): ENABLED=false.
# Then no clock is drawn or hinted, no lane is certified and no optional subject
# is authored; findings still file and draw exactly as before.
const ENABLED := true

# --- LOOP CLOCK and POST RETURN CLOCK ------------------------------------------
# Speeds mirror simulation.gd: a patrolling Siren walks 25 m/s, an alerted one 48.
const PATROL_SPEED := 25.0
const ALERT_SPEED := 48.0
# A gait frame at this quality files the loop (photo_findings.gd uses the same 0.45).
const LOOP_MIN_Q := 0.45
# Only Sirens that walk a loop get a loop clock (sentinels hold a post).
const LOOP_TYPES := ["patroller"]
# Text key that marks an authored loop finding (an "OBSERVED PATH" is not one).
const LOOP_TEXT_KEY := "PATROL LOOP"
# A last sighting this close to the loop is placed on it, metres.
const LOOP_SNAP := 70.0
# The simulation drops a contact after 20 s unseen (simulation.gd), so no clock is
# ever older than that; it is drawn as aging after AGING_AFTER and gone after
# STALE_AFTER, when only the loop length is left, marked STALE.
const AGING_AFTER := 10.0
const STALE_AFTER := 20.0
# Modes of a Siren that has left its routine: its position no longer follows the loop.
const OFF_ROUTINE_MODES := ["INVESTIGATE", "SEARCH", "LOCKING", "DISRUPTED", "PINNED", "LISTENING", "DORMANT"]
# Post return: modes at which a sentinel moves fast (alerted) rather than at patrol pace.
const POST_ALERT_MODES := ["INVESTIGATE", "SEARCH", "LOCKING"]

# --- KNOWN LANE ---------------------------------------------------------------------
# Width of the strip of photographed water that counts as charted clear, and the
# spacing at which the lane is sampled, metres.
const LANE_STRIP := 45.0
const LANE_STEP := 10.0

# --- WINDOW CHECK ---------------------------------------------------------------------
# Speeds the check assumes for the selected craft (mirror simulation.gd: Quietus
# silent 42, cruise 78, drones 96).
const CRAFT_SPEED := {"silent": 42.0, "cruise": 78.0, "drone": 96.0}
# Seconds a window must still be open on arrival to count as GO.
const GO_MARGIN := 2.0
# A wait longer than this reads as TOO LATE (the window will have closed).
const WAIT_LIMIT := 20.0

# --- the optional deep subject (rule_data.gd) --------------------------------------------
# One hidden subject on operation 1, photographable only from DEEP. Its position,
# size and detail are authored in rule_data.gd; this switches it on.
const SUBJECT_ENABLED := true

# Short placeholder text.
const TEXT := {
	"loop": "S%d LOOP %ds",
	"loop_turn": "S%d LOOP %ds · TURN ~%ds",
	"loop_aging": "S%d LOOP %ds · TURN ~%ds · AGING",
	"loop_stale": "S%d LOOP %ds · STALE",
	"post_back": "S%d BACK ~%ds",
	"post_back_old": "S%d BACK ~%ds · AGING",
	"window_go": "%s · you arrive in %ds · GO",
	"window_wait": "%s · you arrive in %ds · WAIT %ds",
	"window_late": "%s · you arrive in %ds · TOO LATE, next in %ds",
	"window_open": "OPEN %ds",
	"window_opens": "OPENS IN %ds",
	"deep_name": "DEEP SEAM",
	"deep_alias": "UNKNOWN DEEP RETURN",
	"deep_seen": "UNIDENTIFIED SEAM",
	"deep_evidence": "A dark seam in the shelf wall, far below the lamp.",
	"deep_gloss": "A cable runs into the seam, laid by hands we do not know.",
	"deep_find": "DEEP SEAM · a cable runs into the shelf below the west bank",
	"deep_brief": " A faint return sits below the west shelf. Only the deep water will show it.",
}
