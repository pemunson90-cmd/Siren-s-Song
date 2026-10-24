extends RefCounted
# Revert OPS HOME with enabled=false. Presentation only; no saved fields.
static var enabled=true
const FOLD_THRESHOLD=3
const GAP=12
const HEADING_SIZE=18
const TEXT={"next":"NEXT OPERATION", "complete":"ALL RECOVERED", "resume":"RESUME DIVE", "idle":"RESUME DIVE", "fold":"RECOVERED (%d)"}
