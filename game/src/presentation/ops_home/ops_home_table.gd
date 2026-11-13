extends RefCounted
# Revert OPS HOME with enabled=false. Presentation only; no saved fields.
static var enabled=true
# WP-14: a TITLE control at the top of the panel (same callback as the bottom row). false = no top control.
const TOP_TITLE=false # the bottom navigation row keeps the one TITLE control
const FOLD_THRESHOLD=3
const GAP=12
const HEADING_SIZE=18
const NEXT_STRETCH=1.5
const TEXT={"next":"NEXT OPERATION", "complete":"ALL RECOVERED", "resume":"RESUME DIVE", "idle":"RESUME DIVE", "fold":"RECOVERED (%d)"}
