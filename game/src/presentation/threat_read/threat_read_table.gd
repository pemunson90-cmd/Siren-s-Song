extends RefCounted
# THREAT READ settings: chart shutter reach, lock countdown beside the craft,
# drone loss cause and bearing, and the optional pause on a craft loss.
# Presentation only. Every figure below mirrors a rule the simulation already
# applies; nothing here changes sensing, lock, beam, damage or photography.
# Revert: set enabled=false. The chart, the status message and the pause
# behave as before this module, and the CRAFT LOSS settings row is hidden.
# For a full removal see the seam list in threat_read.gd.
# AI-DESIGNED wording, short factual labels only; Pat to adjust.
static var enabled=true

# Settings key of the optional pause aid (validated in settings_store.gd).
const SETTING="auto_pause_loss"
# The lock length is not kept here: read sim.lock_seconds() (simulation.gd, trial_rules.gd).
# Mirrors tactical_aids.gd / lock_warning.gd: a received contact older than this is not live.
const FRESH_AGE=0.3
# Mirrors photo_pricing_table.gd CONTACT_MAX_AGE: contacts older than this are not counted in shutter reach.
const CONTACT_MAX_AGE=20.0

# Drone loss presentation.
const LOSS_SECONDS=10.0   # sim seconds the wreck mark and loss label stay on the chart (frozen while paused)
const RAY_METRES=110.0    # fixed length of the bearing ray, so it gives a direction and never a range
const WRECK_METRES=14.0   # half size of the wreck cross
const EVENT_MATCH=1.0     # metres between a loss event and the craft's last position
const LOSS_CARD_SECONDS=6.0   # dive seconds the loss card stays where the lock card sits (frozen while paused)
const LOSS_CARD_LEFT=0.9      # text indent in touch heights: the same as the lock card's gauge column

# Shutter reach ring.
const RING_WIDTH=2.4      # screen pixels, before high contrast thickening
const RING_TICKS=12       # short radial ticks so the ring reads without colour
const TICK_PIXELS=9.0

# Screen chips (lock countdown and loss label).
const CHIP_PAD=6.0
const CHIP_GAP=10.0
const EDGE=12.0
# Candidate chip offsets, in chip heights, from the craft's screen point.
const OFFSETS=[Vector2(1.2,-1.6),Vector2(1.2,0.6),Vector2(-1.2,-1.6),Vector2(-1.2,0.6),Vector2(1.2,-2.9),Vector2(-1.2,-2.9),Vector2(1.2,1.9),Vector2(-1.2,1.9)]

# Same role words as the contact readout (contact_feedback.gd).
const Names=preload("res://src/names.gd")
const ROLE_WORDS={Names.ROLE_HUNTER:"HUNTER",Names.ROLE_SENTINEL:"GUARD",Names.ROLE_SWEEPER:"SWEEPER",Names.ROLE_BUOY:"LISTENER",Names.ROLE_RELAY:"RELAY",Names.ROLE_INTERCEPTOR:"INTERCEPTOR",Names.ROLE_WARDEN:"WARDEN",Names.ROLE_PATROLLER:"PATROL","unknown":"UNCLASSIFIED","STATIC":"STATIC","PATROLLER":"PATROLLER","UNCLASSIFIED":"UNCLASSIFIED"}

# Display classes that name no role: the card says SIREN for these instead of a type word.
const COARSE_KINDS=["unknown","STATIC","PATROLLER","UNCLASSIFIED"]
const SIREN_WORD="SIREN"
# Names of the tools on the lock card, the same words as their buttons (main.gd); the silent word is hud_words.gd's.
const MOVE_DECOY="DECOY"
const MOVE_EMP="EMP"

const TEXT={
	"shutter":"SHUTTER HEARD %dm",
	"in_reach":"IN SHUTTER REACH",
	"lock_one":"S%d LOCK · %.1fs",
	"lock_many":"%d LOCKS · %.1fs",
	# The one statement of a lock (lock_warning.gd): type word and direction, craft and seconds left, then the way out.
	"lock_sentence":"%s TO THE %s\nlocks %s in %.1f s",
	"lock_exit":"Put rock between you.",	# Quietus: a lock needs current sight of the craft, so cover breaks it
	"lock_exit_drone":"Move it behind rock, or let it go.",	# a drone: the same cover rule, else the beam takes it at 4 s
	"lost":"%s LOST",
	"beam":" · SIREN BEAM FROM %03d°",
	"battery":" · BATTERY EXHAUSTED",
	# The loss card (one line each): the cause with the direction in words, then what the loss costs.
	"loss_beam":"SIREN BEAM FROM %03d° · TO THE %s",
	"loss_battery":"BATTERY EXHAUSTED",
	"loss_run":"The run fails: every craft had to get home",
	# The counter-moves line on the lock card: the moves this craft can make now.
	"moves":"Or: %s",
	"move_count":"%s ×%d",
	"move_join":" · ",
	"source":" · S%d %s",
	"unseen":" · UNSEEN SIREN",
	"pause":"AUTO PAUSE: %s",
}
