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
 "header_gap":12,"back_width":2.,"current_width":2.,"header_font":.3,
 "legend_font":.22,"legend_margin":1.5,"legend_height":.6,
 "chart_top":1.9,"chart_reserve":3.2,"detail_font":.23,
 "stroke":3.,"line_dash":12.,"node_dash":9.,"padding":12.}
const COLORS={"RECOVERED":"75d7b0","AVAILABLE":"b8e7ed","LOCKED":"415862","KNOWN FROM PHOTOS":"e8c58b"}
const THEME={"background":"07151e","edge":"304953","recovered_fill":"193832","node_fill":"0c202b"}
