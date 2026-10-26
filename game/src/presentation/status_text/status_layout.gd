extends RefCounted
# Reversible viewport fit for existing HUD controls; never shrinks fonts/targets.
# Disable enabled (or status_table.enabled) to restore the preceding geometry.
static var enabled=true
const MARGIN=12.0
const HEADER_OFFSET=24.0
const SEARCH_STEP=.1
const DISC_STEPS=64
const ARC_STEPS=96
