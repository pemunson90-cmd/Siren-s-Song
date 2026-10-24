extends RefCounted
# AI-DESIGNED PLACEHOLDER (handoff 039, COLD_REVIEW_3 F4). Flagged for Pat to
# rewrite: every line below is a stand-in, not authored story. One short
# consequence line per operation id 14 to 29, shown above the existing debrief
# record text on a recovered expedition. The only recorded fact used is the
# recovery mouth the run actually left by (mission.chosen_route matched to its
# named corridor); everything else is the fixed table keyed by operation id.
# Revert note: set enabled=false (or delete the single call in
# expedition_operations.gd debrief) and the debrief is exactly today's text.
# No saved fields, no rules, no ending logic. Ops 1 to 14 and 30/31 never match.
static var enabled=true
const LINES={
 14:"The fence crossing is on record.",
 15:"The strait is quieter than you found it.",
 16:"The atlas rides home with Quietus.",
 17:"The spindle is out of the silt and aboard.",
 18:"The lock's choice is made and stays made.",
 19:"The register is carried out of the Reach.",
 20:"The crystal is cut and counted.",
 21:"The locker is empty and the wafer is yours.",
 22:"The sled is free and the lane is working.",
 23:"The stair has cycled to its last shutter.",
 24:"The ballast sits where you left it.",
 25:"The sled reached its dock.",
 26:"The spindle is up and the hammer has restarted.",
 27:"The core is off the grave and in hand.",
 28:"The bell is down and landed.",
 29:"The plant is switched and the account is kept."
}
static func line(mission:Dictionary)->String:
 var id=int(mission.get("id",-1))
 if not enabled or not LINES.has(id):return ""
 var text=LINES[id]
 var route=str(mission.get("chosen_route",""))
 if not route.is_empty():
  for corridor in mission.get("corridors",[]):
   if str(corridor.get("route",""))==route and not str(corridor.get("name","")).is_empty():
    return text+" Out by "+str(corridor.name).capitalize()+"."
 return text
