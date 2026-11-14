extends RefCounted
# Route-map presentation data only. Revert with enabled=false; saves are untouched.
static var enabled=true
const MIN_QUALITY=.3
const REVEALS={"silt_scour":[19],"exhaust_stack":[25]}
const SOURCES={"silt_scour":17,"exhaust_stack":16}
# Opening operations form one visual group, retaining six distinct states.
# Positions are authored per operation in operation_meta.gd ROWS; this is a read-only view.
static var POSITIONS:Dictionary=preload("res://src/campaign/operation_meta.gd").positions()
const VIEW={
 "min_target":64.,"margin":16.,"gap_touch":.5,"width_touch":3.,"height_touch":1.3,
 "font_touch":.23,"font_min":16,"zoom_min":1.,"zoom_max":2.,"zoom_step":.25,
 "header_gap":12,"height_tagged":2.1,"region_font":.26,"region_pad":6,"back_width":2.,"current_width":2.,"header_font":.3,
 "legend_font":.22,"legend_margin":1.5,"legend_height":.6,
 "chart_top":1.9,"chart_reserve":3.2,"detail_font":.23,
 "stroke":3.,"line_dash":12.,"node_dash":9.,"padding":12.}
const COLORS={"RECOVERED":"75d7b0","AVAILABLE":"b8e7ed","LOCKED":"415862","KNOWN FROM PHOTOS":"e8c58b"}
# An operation not yet charted is a small dim mark, not a box; the key lists it last.
const NOT_CHARTED="NOT YET CHARTED"
const MARK_COLOR="5d7a86"
const MARK_GLYPH="?"
const KEY_ORDER=["RECOVERED","AVAILABLE","KNOWN FROM PHOTOS","LOCKED","NOT YET CHARTED"]
const KEY_SWATCH={"mark_size":.9,"gap":8,"item_gap":16,"font":.22,"line_pad":4}
# Available and recovered operations open their briefing on a tap (replay for recovered); the others explain themselves here.
const DETAIL={"hint":"Drag to pan. + / − changes chart size. CURRENT finds the next available branch. Tap an available or recovered operation for its briefing; tap any other to see what opens it.",
 "photos":"%s: known from recovered film. Its route is not available yet.","locked":"%s: locked. %s.","not_charted":"Not yet charted: recover the operations next to it."}
# Region names: drawn once above each arc's group, only when the player knows at least one of its operations by name.
const REGION_COLOR="7fa6b3"
# Reward and risk tag on an operation the player can open: two short lines under the title, from facts its briefing shows
# (required photo subjects and other required tasks, Sirens on the chart, routes recovering it opens). Entries are [one, many]; zero counts are left out.
const TAG={"photo":["%d photo","%d photos"],"task":["%d task","%d tasks"],"siren":["%d Siren","%d Sirens"],"opens":["opens %d route","opens %d routes"],"join":" · "}
const THEME={"background":"07151e","edge":"304953","recovered_fill":"193832","node_fill":"0c202b"}
