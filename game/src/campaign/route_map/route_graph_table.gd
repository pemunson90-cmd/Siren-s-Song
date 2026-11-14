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
 "font_touch":.23,"font_min":16,"zoom_start":1.,"zoom_max":2.,"zoom_step":.25,
 "header_gap":12,"height_tagged":2.1,"region_font":.26,"region_pad":6,"back_width":2.,"current_width":2.,"header_font":.3,
 "legend_font":.22,"legend_margin":1.5,"legend_height":.6,
 "wide_ratio":1.5,"column_share":.34,"chart_top":1.9,"chart_reserve":3.2,"detail_font":.23,
 "stroke":3.,"line_dash":12.,"node_dash":9.,"padding":12.}
# Overview: the player may zoom out until the whole board fits the chart (never below zoom_floor, fit_slack leaves a small margin).
# Below compact_below a node shows its number (and its title while the box is title_min_width wide); text never drops under font_floor.
# A node that would be under min_target in either direction is look-only: a tap zooms in on it (to look_zoom) instead of selecting it.
const OVERVIEW={"zoom_floor":.05,"fit_slack":.98,"compact_below":.7,"title_min_width":96.,"font_floor":14,"padding":2,"look_zoom":.5,"min_target":48.,"stroke_share":.1,"pad_share":.25}
const COLORS={"RECOVERED":"75d7b0","AVAILABLE":"b8e7ed","LOCKED":"415862","KNOWN FROM PHOTOS":"e8c58b"}
# An operation not yet charted is a small dim mark, not a box; the key lists it last.
const NOT_CHARTED="NOT YET CHARTED"
const MARK_COLOR="5d7a86"
const MARK_GLYPH="?"
const KEY_ORDER=["RECOVERED","AVAILABLE","KNOWN FROM PHOTOS","LOCKED","NOT YET CHARTED"]
const KEY_SWATCH={"mark_size":.9,"gap":8,"item_gap":16,"font":.22,"line_pad":4}
# Available and recovered operations open their briefing on a tap (replay for recovered); the others explain themselves here.
const DETAIL={"look":"Whole chart. Tap a region to zoom in, then tap an operation. + zooms in; CURRENT finds the next available branch.","hint":"Drag to pan. + / − changes chart size. CURRENT finds the next available branch. Tap an available or recovered operation for its briefing; tap any other to see what opens it.",
 "photos":"%s: known from recovered film. Its route is not available yet.","locked":"%s: locked. %s.","not_charted":"%s: not yet charted: recover the operations next to it.","not_charted_plain":"Not yet charted: recover the operations next to it."}
# Region names: drawn once above each arc's group, only when the player knows at least one of its operations by name.
const REGION_COLOR="7fa6b3"
# Every region is a soft rounded area behind its operations, one tint per arc (arc_table.gd "region" key), with its name above it.
# Alpha stays low so the node boxes and lines remain the strongest marks; a region with nothing available or recovered is dimmer.
const REGION_TINTS={"shelf":"4aa3c4","divergence":"8a7fd6","confluence":"4cc0a0","glass":"6fb4d8","iron":"d68a5e","calder":"c4607a"}
const REGION_AREA={"pad":.2,"corner":14,"fill":.12,"fill_dim":.05,"line":.3,"line_dim":.12,"name_dim":.55,"name_gap":4}
# Work and reward tag on an operation the player can open: short lines under the title, from facts its briefing shows
# (required photo subjects and other required tasks, then the routes recovering it opens). Entries are [one, many]; zero counts are left out.
const TAG={"photo":["%d photo","%d photos"],"task":["%d task","%d tasks"],"opens":["opens %d route","opens %d routes"],"join":" · "}
const THEME={"background":"07151e","edge":"304953","recovered_fill":"193832","node_fill":"0c202b"}
