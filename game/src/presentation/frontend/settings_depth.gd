extends RefCounted
# SETDEPTH (handoff 072): settings pages, mixer split, haptic strength and coverage, gesture timing.
# Seams: SettingsStore.sanitize (new keys), FrontendSettings.apply/vibrate, Frontend._settings_screen,
# Soundscape.play (bus category), CueObserver._emit (haptic coverage), MapGesture and ToolHelp (presets).
# Revert: ENABLED=false restores one settings column, fixed 45 ms pulses on the original four cues,
# the original gesture numbers, and routes every cue through the effects bus. New keys stay inert.
# AI-DESIGNED numbers below are tunable; the owner ratifies them.
const ENABLED := true
const PAGES := ["audio", "display", "controls"]
const PAGE_LABELS := {"audio": "AUDIO", "display": "DISPLAY", "controls": "CONTROLS"}
# Mixer rows: key, label, slider id suffix. "music" keeps its key (ambience and tension bed) so old files load.
const MIXER := [["master", "MASTER VOLUME"], ["music", "AMBIENCE VOLUME"], ["alerts", "ALERTS AND THREAT CUES VOLUME"],
	["effects", "EFFECTS AND EQUIPMENT VOLUME"], ["messages", "MESSAGES AND VOICE VOLUME"]]
const NIGHT_NOTE := "Night mode evens out loud and quiet sounds so nothing jumps out. Master keeps its peak guard."
# Cue categories for the bus split; anything not listed stays on the effects bus.
const ALERT_CUES := ["alert", "heartbeat", "hunt_stage", "sweep_received", "beam"]
const MESSAGE_CUES := ["carrier_received", "return_received"]
# Haptics: index 0 is off. Pulse length scales the base pulse; coverage adds cues beyond the original four.
const HAPTIC_LABELS := ["OFF", "LIGHT", "NORMAL", "STRONG"]
const HAPTIC_SCALE := [0.0, 0.55, 1.0, 1.8]
const HAPTIC_BASE_CUES := ["lock", "sweep_received", "film_empty", "loss"]
const HAPTIC_EXTRA_CUES := ["hull_light", "hull_medium", "hull_heavy", "snare", "knock", "extraction", "camera"]
# Gesture presets (index stored in settings; 1 is today's behavior).
const DRAG_LABELS := ["PRECISE", "NORMAL", "RELAXED"]
const DRAG_PX := [9.0, 14.0, 24.0]
const HOLD_LABELS := ["SHORT", "NORMAL", "LONG"]
const HOLD_SECONDS := [0.3, 0.5, 0.85]
static func haptic_cue(cue: String) -> bool:
	return cue in HAPTIC_BASE_CUES or (ENABLED and cue in HAPTIC_EXTRA_CUES)
static func pulse_ms(ms: int, values: Dictionary) -> int:
	if not ENABLED: return ms
	return roundi(float(ms) * HAPTIC_SCALE[clampi(int(values.get("haptic_strength", 2)), 1, 3)])
static func bus_category(cue: String) -> String:
	if not ENABLED: return "effects"
	return "alerts" if cue in ALERT_CUES else ("messages" if cue in MESSAGE_CUES else "effects")
static func drag_threshold(values: Dictionary) -> float:
	return DRAG_PX[clampi(int(values.get("drag_preset", 1)), 0, 2)] if ENABLED else DRAG_PX[1]
static func hold_seconds(values: Dictionary) -> float:
	return HOLD_SECONDS[clampi(int(values.get("hold_preset", 1)), 0, 2)] if ENABLED else HOLD_SECONDS[1]
