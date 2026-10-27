extends RefCounted
# Hunt meter presentation configuration only. Tune these values or restore
# prior values to revert. Retain files, tests and evidence. HuntTable.enabled
# remains the single module flag; this file contains no independent switch.
const MARGIN=12.0
const TONES=[Color("91d3d5"),Color("91d3d5"),Color("e5c282"),Color("e5a66d"),Color("e78477")]
# Set PULSE_HZ=0 to disable only the LOCKDOWN alpha pulse.
const PULSE_HZ=1.0
const PULSE_MIN_ALPHA=0.85
const COMPACT_TOUCH_HEIGHT=180.0
const COMPACT_FONT_FACTOR=0.17
const STANDARD_FONT_FACTOR=0.22
const MIN_FONT_SIZE=14
const MIN_READABLE_DP=14.0
const TOUCH_TARGET_DP=48.0
const BASE_DPI=160.0
const WIDTH_PADDING=24.0
const HEIGHT_PADDING=16.0
const HELP_PAUSE_GAP=8.0
const HELP_WIDTH_MARGIN_COUNT=3.0
const SCAN_MIN_STEP=12.0
const SCAN_TOUCH_FACTOR=0.5
const PIP_COUNT=5
const COMPACT_PIP_SPLIT=3
const TEXT={
	"compact":"HUNT\n%s\n%s\n×%.2f\n%s\n%s",
	"tight":"HUNT ×%.2f\n%s\n%s",
	"standard":"HUNT · %s ×%.2f\n%s",
	"help":"HUNT · %s · ×%.2f\nLast rise: %s · floor %.0f / 100.\nSight notice range for eligible Sirens, capped at ×%.2f.\nLocal alert may be higher. Hearing, speed and 4 s lock stay unchanged.",
	"no_rise":"no rise recorded"
}
