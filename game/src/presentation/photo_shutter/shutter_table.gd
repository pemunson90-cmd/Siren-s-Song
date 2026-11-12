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
const TEXT:={
	"label":"SHUTTER",
	"refused":"NO EXPOSURE · %s needs a TIGHT frame · tap WIDE to switch, or press again to expose anyway · no film spent",
}
const COLORS:={"ready":"e0bf83","refused":"4a6a6e","fill":"1d2a22"}
