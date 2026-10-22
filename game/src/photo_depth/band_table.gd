extends RefCounted
# DEPTH-BAND PHOTOS: every number the module uses, in one table.
#
# A photograph may now be taken from SHALLOW, MIDDLE or DEEP water. Each band
# trades light, haze, steadiness, thermal and tele quality, how far our own
# shutter is heard, and what the exposure costs. Nothing here changes combat,
# beams, collision, damage, hull, or what a Siren sees or hears: a Siren still
# hears through the existing band transmission (x0.42 one band apart, x0.18
# two apart); only the radius of OUR shutter noise changes with the band.
#
# NEUTRAL VALUES (the game as it played before this module): SHOOT_BANDS=[1],
# every multiplier 1.0, VERTICAL=0.0, o2 and battery 0.0. Then every frame,
# noise ring, cost and hint is identical to the MIDDLE-only camera.
#
# Row fields (index = band, 0 SHALLOW, 1 MIDDLE, 2 DEEP):
#   light    x ambient light            haze   x water turbidity
#   swell    x steadiness               ring   x shutter noise radius
#   thermal  x thermal imager quality   blur   x tele-lens blur (tele only)
#   o2       oxygen per second drawn from Quietus while it exposes in this band
#   battery  battery per second drawn from a drone while it exposes in this band
const SHOOT_BANDS := [0, 1, 2]
# Mirrors photo_capture.gd's shutter radii before the band scale (520 m, 760 m with flash).
const BASE_RING := 520.0
const BASE_FLASH_RING := 760.0
# Metres of slant added for each band between the craft and a subject
# (distance becomes sqrt(d squared + VERTICAL squared)).
const VERTICAL := 40.0
const BANDS := [
	{"name": "SHALLOW", "light": 2.2, "haze": 1.6, "swell": 0.9, "ring": 1.3, "thermal": 0.9, "blur": 1.25, "o2": 0.0, "battery": 0.0},
	{"name": "MIDDLE", "light": 1.0, "haze": 1.0, "swell": 1.0, "ring": 1.0, "thermal": 1.0, "blur": 1.0, "o2": 0.0, "battery": 0.0},
	{"name": "DEEP", "light": 0.45, "haze": 0.7, "swell": 1.0, "ring": 0.8, "thermal": 1.1, "blur": 1.0, "o2": 0.075, "battery": 0.3},
]
# The hint line states a cost over this many seconds of exposure.
const HINT_SECONDS := 8.0
# Short placeholder text.
const TEXT := {
	"middle_only": "MIDDLE band and settled depth required",
	"settle": "Settle at depth to frame a photograph",
	"not_here": "%s · this band cannot frame it",
	"only_in": "%s · seen only from %s",
	"other_work": " · samples, links and listening need MIDDLE",
	"siren_band": "A Siren can only be studied from its own band",
	"line": "%s: %s, %s, heard %dm%s",
	"cost_o2": ", costs %.1f%% oxygen per %ds",
	"cost_battery": ", drains %.1f%% battery per %ds",
	"bright": "bright", "dark": "dark", "even": "even light",
	"hazy": "hazy", "clear": "clear", "plain": "plain water",
	"local_record": "Local record nearby · CAMERA works in this band · %s",
}
