extends RefCounted
# WP-10 [AI-DESIGNED] SHUTTER: a shutter control on the camera panel, and a warning
# before an exposure that the viewfinder already shows cannot be used.
# REVERT: set `enabled` to false. The panel then draws no shutter, the ring's PHOTO
# gives no warning, and both behave exactly as before.
# Rules are untouched: film, exposure, grading and shutter noise stay in
# simulation/photo_pricing and photo_capture. This table holds text, sizes and timing only.
static var enabled:=true
# Smallest shutter side in pixels at the 48 dp touch height; the panel scales it up.
const MIN_SIDE:=48.0
# The shutter is wider than square so its label reads at large text sizes.
const WIDTH_PER_TOUCH:=1.6
const CHARS_WIDE:=7.0
# A viewfinder row reason that cannot change during a WIDE exposure of a still subject.
const FIXED_WIDE_REASON:="FINE DETAIL"
# A second press on the same warned subject within this many seconds exposes anyway.
const REPEAT_SECONDS:=4.0
# WP-108: a SHUTTER that has only just appeared ignores taps for this long, so a tap meant for the OPEN or FOLD
# button (or the chart) as the panel unfolds can never spend film. Tests set the panel's shutter_since to 0.
const ARM_MS:=450
const TEXT:={
	"label":"SHUTTER",
	"refused":"NO EXPOSURE · %s needs a TIGHT frame · tap WIDE to switch, or press again to expose anyway · no film spent",
	# Beside the button, before the tap: the frame it would file now, and the shutter's reach.
	"forecast":"FRAME ~%d%% · grade %s",
	"forecast_none":"NO USABLE FRAME",
	"heard":" · HEARD TO %dm",
	# The exposure the game will ask for is longer than the time left on a Siren's lock on this craft.
	"lock_outlasts":"HOLD %d s · LOCK IN %d s",
	# While an exposure runs: ends it where the craft is, with the film already spent.
	"stop":"STOP EXPOSURE",
	"stopped":"EXPOSURE STOPPED · the film is spent",
	"more":"MORE v · drag the text",
	# WP-113: why a frame is or would be unusable (photo_grade/unusable_reason.gd), and what a second frame of a filed subject adds.
	"unusable_now":"NO USABLE FRAME · %s",
	"unusable_filed":"UNUSABLE · NOT FILED · %s",
	"unusable_review":" · UNUSABLE · %s",
	"unusable_old":"the frame did not resolve the subject",
	"frame_word":"UNUSABLE FRAME",
	"filed_before":"FILED %d%% · a new frame only helps if it is sharper or shows a new detail",
	"why":{"HEAT SHIMMER":"lost in heat shimmer","TOO DARK":"too dark","CROPPED":"out of frame","HIDDEN":"hidden from this side","FINE DETAIL":"needs a TIGHT frame","OUT OF FOCUS":"out of focus","WAITING":"not showing yet","TOO SOFT":"too soft","SHORT":"not held long enough","NONE":"nothing resolved"},
}
# The result lines under the viewfinder stay this many seconds after a frame is filed.
const RESULT_SECONDS:=30.0
# The viewfinder picture keeps at least this height (px) while the panel can hold it and a line and a half of
# text: the photograph is the point; the text scrolls (audit_readability_ui_tests pins it).
const PICTURE_KEEP:=120.0
const COLORS:={"ready":"e0bf83","refused":"4a6a6e","fill":"1d2a22","weak":"e0a46a","refused_text":"e08a73"}
