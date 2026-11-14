extends RefCounted
# Order tuning moved verbatim; physics and perception formulas stay with their owners.
# Revert by restoring these literals in the extracted order family.
const EMP_RADIUS = 340
const EMP_STUN = 12.0
# WP-125: Pat, 14 Nov 2026 ("Q4 that sounds fine ... a balanced lever for easy medium and hard difficulties"). Seconds after
# an EMP stun ends during which that Siren cannot start a new lock, by economy preset id (economy_table.gd ORDER:
# accessible = easy, standard = medium, survival = hard). A dive with no preset (Expedition, Career, Challenge) uses standard.
const EMP_LOCK_GRACE_BY_PRESET = {"accessible": 12.0, "standard": 8.0, "survival": 4.0}
const EMP_LOCK_GRACE_DEFAULT_PRESET = "standard"
const WEAPON_NOISE = 650
const WEAPON_NOISE_TIME = 2.0
const DECOY_NOISE = 1100
const DECOY_TIME = 15.0

# Sensor order values, unchanged.
const PING_FEEDBACK_TIME = 3.5
const RELAY_RANGE = 240
const RELAY_REPLAY_TIME = 3.0
const RECON_TIME = 8.0
const RECON_NOISE = 1100
const RECON_NOISE_TIME = 2.0

# Drive readout values, unchanged.
const DRONE_QUIET_SPEED = 42
const DRONE_TRANSIT_SPEED = 96

# Photo order values, unchanged.
const REPEAT_PHOTO_ACTION = 3.0
const PHOTO_FALLBACK_NOISE = 520
const PHOTO_NOISE_TIME = 2.0
