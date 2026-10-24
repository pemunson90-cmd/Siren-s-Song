extends RefCounted
# ART1, draw-only. Set enabled=false to restore the exact preceding bodies and
# lamp presentation. No progress, profile, controls or simulation fields change.
static var enabled=true
const HULL=Color("263841")
const EDGE=Color("829398")
const CYAN=Color("72d9d3")
const AMBER=Color("c09860")
const HULL_SEAM=Color("65777b")
const SIREN_BODY=Color(.025,.045,.052)
const SIREN_EDGE=Color(.24,.30,.32)
const RAY_MATERIAL_UV=Rect2(.48,.40,.40,.20)
const SIREN_SEGMENT=Color(.42,.49,.49)
const SIREN_FILAMENT=Color(.31,.42,.43)
const NORMAL_UNDERLAY=["sweeper"]
const INDUSTRY_EDGE=Color("84918a")
const INDUSTRY_BODY=Color("1c343b")
const INDUSTRY_DARK=Color("10242d")
const INDUSTRY_PORT=Color("061920")
const INDUSTRY_RIBS=[-26,-8,10,28]
const INDUSTRY_CROSSBARS=[-48,-18,12]
const INDUSTRY_PORT_RADIUS=17.0
const INDUSTRY_RING_RADIUS=13.0
const INDUSTRY_ARC_SEGMENTS=32
const RIB_WIDTH=7.0
const FACTORY_STROKE=1.5
const DETAIL_MIN_SCALE=.65
const HUNTER_PITCH=14.0
const LAMP_GUIDE_START=18.0
const LAMP_GUIDE_STEP=.23
const LAMP_GUIDE_DUTY=.1
const LAMP=Color(.62,.83,.79)
const HULL_OUTLINE_WIDTH=1.2
const DRONE_OUTLINE_WIDTH=1.1
const SIREN_OUTLINE_WIDTH=1.25
const SEAM_WIDTH=2.0
const HUNTER_SEGMENTS=6
const FACTORY_BAYS=4
const FACTORY_INSET=.08
const LAMP_GUIDE_DASHES=3
const LAMP_REFERENCE=.36 # Artistic opacity reference, not a physical constant.
const LAMP_GUIDE_ALPHA=.45
const FILAMENT_ALPHA=.65
const LAMP_FADE_LENGTH=180.0 # Local artistic fade, never physical lamp reach.
const LAMP_ALPHA=.34
const MAX_GLOW_PASSES=1
const BOUNDS={"installation":Vector2(38,72),"quietus":Vector2(66,17),"drone_a":Vector2(22,12),"drone_b":Vector2(22,14),"patroller":Vector2(67,40),"sentinel":Vector2(58,53),"sweeper":Vector2(70,50),"hunter":Vector2(66,38)}
static var SHAPES={
 "installation":PackedVector2Array([Vector2(-38,36),Vector2(-38,-46),Vector2(-30,-56),Vector2(-30,-72),Vector2(-16,-72),Vector2(-12,-61),Vector2(12,-61),Vector2(18,-72),Vector2(30,-72),Vector2(30,-52),Vector2(38,-44),Vector2(38,36),Vector2(20,36),Vector2(14,28),Vector2(-14,28),Vector2(-20,36)]),
 "quietus":PackedVector2Array([Vector2(-66,-3),Vector2(-55,-12),Vector2(-22,-14),Vector2(-15,-17),Vector2(3,-17),Vector2(12,-13),Vector2(48,-11),Vector2(66,-2),Vector2(63,6),Vector2(43,13),Vector2(-53,13),Vector2(-66,5)]),
 "drone_a":PackedVector2Array([Vector2(-21,-10),Vector2(-9,-6),Vector2(12,-6),Vector2(22,-10),Vector2(19,-2),Vector2(12,0),Vector2(19,2),Vector2(22,10),Vector2(12,6),Vector2(-9,6),Vector2(-21,10),Vector2(-16,0)]),
 "drone_b":PackedVector2Array([Vector2(-19,-7),Vector2(-10,-7),Vector2(-5,-14),Vector2(4,-14),Vector2(8,-7),Vector2(18,-4),Vector2(22,2),Vector2(14,8),Vector2(-1,8),Vector2(-7,13),Vector2(-18,13),Vector2(-13,5),Vector2(-21,2)]),
 "patroller":PackedVector2Array([Vector2(67,0),Vector2(15,-13),Vector2(-48,-40),Vector2(-34,-13),Vector2(-61,-5),Vector2(-67,0),Vector2(-61,5),Vector2(-34,13),Vector2(-48,40),Vector2(15,13)]),
 "sentinel":PackedVector2Array([Vector2(58,0),Vector2(30,-34),Vector2(-5,-53),Vector2(-40,-39),Vector2(-58,-12),Vector2(-46,0),Vector2(-58,12),Vector2(-40,39),Vector2(-5,53),Vector2(30,34)]),
 "sweeper":PackedVector2Array([Vector2(70,-34),Vector2(29,-8),Vector2(19,0),Vector2(29,8),Vector2(70,34),Vector2(12,26),Vector2(-44,50),Vector2(-35,15),Vector2(-70,0),Vector2(-35,-15),Vector2(-44,-50),Vector2(12,-26)]),
 "hunter":PackedVector2Array([Vector2(66,0),Vector2(42,-8),Vector2(8,-12),Vector2(-29,-9),Vector2(-58,-2),Vector2(-54,3),Vector2(-23,10),Vector2(14,11),Vector2(43,7)])}
const ROLE_RECTS={"patroller":Rect2(-67,-40,134,80),"sentinel":Rect2(-58,-53,116,106),"sweeper":Rect2(-70,-50,140,100),"hunter":Rect2(-66,-38,132,76)}
