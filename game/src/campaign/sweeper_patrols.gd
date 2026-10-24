extends RefCounted
# Authored walking circuits for sweeper Sirens. DATA ONLY (Pat approved 24 Oct).
#
# A sweeper walks an authored patrol lane only when its operation supplies
# patrol_points (sweeper_senses.gd PROFILES.sweeper lane_needs_points); with none
# it holds its post. Every circuit here is 3 or 4 points of clear water inside the
# sweeper's own band, a loop of roughly 500 to 800 m, started near its post.
#
# REVERT: set ENABLED=false (every sweeper stands at home again, byte for byte the
# previous behaviour), or delete one OPS entry to restore a single sweeper.
#
# Keyed by operation id, then by the sweeper's order within that operation.
# Not listed on purpose: ops 18 (Lantern Lock) and 19 (Last Boat Out), whose sweepers
# belong to campaign photo-row operations (keel_mark, boat_keel) and are left to
# handoff 040.
const ENABLED:=true
const OPS:={
 0:[[Vector2(760,200),Vector2(760,400),Vector2(850,400)]],
 2:[[Vector2(1180,500),Vector2(1320,500),Vector2(1320,600),Vector2(1200,610)]],
 4:[[Vector2(1260,720),Vector2(1460,720),Vector2(1460,860)]],
 5:[[Vector2(1240,720),Vector2(1240,860),Vector2(1100,860)]],
 16:[[Vector2(1850,2150),Vector2(2100,2150),Vector2(2100,2330),Vector2(1850,2330)]]
}
static func circuit(op_id:int,index:int=0)->Array:
 if not ENABLED or not OPS.has(op_id) or index>=OPS[op_id].size():return []
 return OPS[op_id][index].duplicate()
