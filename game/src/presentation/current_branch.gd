extends RefCounted
# Audit 091 F9: the operation that continues the branch the player most recently advanced.
# Presentation only: it reads completion order and catalog prerequisites, never unlocks,
# reorders or hides anything. Older optional operations stay listed and launchable.
const Catalog=preload("res://src/campaign/operation_catalog.gd")
# candidates: available, not yet recovered operation ids in the caller's display order.
# Returns the first candidate whose prerequisites name the most recent recovery that has
# any open continuation, or -1 when no recovery leads to a listed candidate.
static func pick(completed:Array,candidates:Array)->int:
 for n in range(completed.size()-1,-1,-1):
  var recent=completed[n]
  for id in candidates:
   if recent in Catalog.definition(int(id)).get("prerequisites",[]):return int(id)
 return -1
