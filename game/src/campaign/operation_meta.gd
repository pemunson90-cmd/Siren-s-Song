extends RefCounted
# [AI-DESIGNED] One row of per-operation metadata per registered operation ID.
# Readers: region_table.key (style and audio bed), endurance_budgets.for_mission,
# route_graph and route_graph_table.POSITIONS. The Hunt cap stays in the protected
# hunt_table.CAPS; hunt_cap() is its bounds-safe lookup. Static data, no saved state.
# Row keys: region (a region_table.STYLES key), position (route-map cell), optional
# route_regions (chosen_route -> region), oxygen_seconds/drone_seconds (authored
# endurance), arc "tutorial" (opening sequence) and after (gate on a whole arc).
# Unknown IDs get the DEFAULT_* values below. operation_meta_parity_tests pins rows.
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const DEFAULT_REGION="shelf"
const DEFAULT_HUNT_CAP=1.
const DEFAULT_ENDURANCE={"oxygen_seconds":300.0,"drone_seconds":240.0}
const TUTORIAL="tutorial"
const ROWS={
 0:{"region":"shelf","position":Vector2(0,0),"arc":"tutorial","oxygen_seconds":180.0,"drone_seconds":180.0},
 1:{"region":"shelf","position":Vector2(0,1),"arc":"tutorial","oxygen_seconds":300.0,"drone_seconds":240.0},
 2:{"region":"shelf","position":Vector2(0,2),"arc":"tutorial","oxygen_seconds":180.0,"drone_seconds":150.0},
 3:{"region":"shelf","position":Vector2(0,3),"arc":"tutorial","oxygen_seconds":180.0,"drone_seconds":180.0},
 4:{"region":"shelf","position":Vector2(0,4),"arc":"tutorial","oxygen_seconds":240.0,"drone_seconds":180.0},
 5:{"region":"shelf","position":Vector2(0,5),"arc":"tutorial","oxygen_seconds":300.0,"drone_seconds":240.0},
 6:{"region":"divergence_deep","route_regions":{"shelf":"divergence_shelf"},"position":Vector2(1,5),"after":"tutorial","oxygen_seconds":300.0,"drone_seconds":240.0},
 7:{"region":"divergence_deep","position":Vector2(2,4),"oxygen_seconds":300.0,"drone_seconds":240.0},
 8:{"region":"divergence_shelf","position":Vector2(2,6),"oxygen_seconds":300.0,"drone_seconds":240.0},
 9:{"region":"divergence_deep","position":Vector2(3,4),"oxygen_seconds":300.0,"drone_seconds":240.0},
 10:{"region":"divergence_shelf","position":Vector2(3,6),"oxygen_seconds":300.0,"drone_seconds":240.0},
 11:{"region":"confluence","position":Vector2(4,5),"oxygen_seconds":840.0,"drone_seconds":600.0},
 12:{"region":"confluence","position":Vector2(5,4),"oxygen_seconds":420.0,"drone_seconds":300.0},
 13:{"region":"confluence","position":Vector2(5,6),"oxygen_seconds":360.0,"drone_seconds":300.0},
 14:{"region":"glass","position":Vector2(6,5)},15:{"region":"glass","position":Vector2(7,5)},
 16:{"region":"glass","position":Vector2(8,5)},17:{"region":"glass","position":Vector2(9,5)},
 18:{"region":"glass","position":Vector2(10,5)},19:{"region":"glass","position":Vector2(11,5)},
 20:{"region":"glass","position":Vector2(8,3)},21:{"region":"glass","position":Vector2(9,7)},
 22:{"region":"iron","position":Vector2(12,5)},23:{"region":"iron","position":Vector2(13,5)},
 24:{"region":"iron","position":Vector2(14,5)},25:{"region":"iron","position":Vector2(15,5)},
 26:{"region":"iron","position":Vector2(12,7)},27:{"region":"iron","position":Vector2(13,3)},
 28:{"region":"iron","position":Vector2(13,7)},29:{"region":"iron","position":Vector2(14,7)},
 # Final pair 30/31 keep the Iron style; Sorley 41 keeps the shelf style.
 30:{"region":"iron","position":Vector2(16,5)},31:{"region":"iron","position":Vector2(17,5)},
 32:{"region":"calder","position":Vector2(18,5)},33:{"region":"calder","position":Vector2(19,5)},
 34:{"region":"calder","position":Vector2(20,5)},35:{"region":"calder","position":Vector2(19,7)},
 36:{"region":"calder","position":Vector2(19,3)},37:{"region":"glass","position":Vector2(7,7)},
 38:{"region":"divergence_deep","position":Vector2(2,2)},39:{"region":"divergence_shelf","position":Vector2(2,8)},
 40:{"region":"confluence","position":Vector2(4,8)},41:{"region":"shelf","position":Vector2(8,8)}
}
static func has_row(id:int)->bool:return ROWS.has(id)
static func ids()->Array:
 var result=ROWS.keys();result.sort();return result
static func row(id:int)->Dictionary:return ROWS.get(id,{}).duplicate(true)
# Region style key; route is the mission's chosen_route (only rows with route_regions use it).
static func region(id:int,route:String="deep")->String:
 var r:Dictionary=ROWS.get(id,{})
 return r.get("route_regions",{}).get(route,r.get("region",DEFAULT_REGION))
static func hunt_cap(id:int)->float:return Hunt.CAPS[id] if id>=0 and id<Hunt.CAPS.size() else DEFAULT_HUNT_CAP
static func endurance(id:int)->Dictionary:
 var r:Dictionary=ROWS.get(id,{})
 if not r.has("oxygen_seconds"):return DEFAULT_ENDURANCE.duplicate()
 return {"oxygen_seconds":r.oxygen_seconds,"drone_seconds":r.drone_seconds}
static func position(id:int)->Vector2:return ROWS.get(id,{}).get("position",Vector2(id,5))
static func positions()->Dictionary:
 var result={}
 for id in ids():result[id]=ROWS[id].position
 return result
static func in_arc(id:int,arc:String)->bool:return ROWS.get(id,{}).get("arc","")==arc
static func arc_ids(arc:String)->Array:return ids().filter(func(id):return in_arc(id,arc))
static func tutorial(id:int)->bool:return in_arc(id,TUTORIAL)
# Route-map gating for the opening sequence. A tutorial operation needs the previous
# tutorial operation; a row with "after" needs every operation of that arc and draws
# its map edge from the arc's last one. Returns null for catalog-gated operations.
static func map_requires(id:int):
 if tutorial(id):
  var chain=arc_ids(TUTORIAL);var index=chain.find(id)
  return [] if index==0 else [chain[index-1]]
 var after:String=ROWS.get(id,{}).get("after","")
 return null if after.is_empty() else arc_ids(after)
static func map_sources(id:int,prerequisites:Array)->Array:
 var required=map_requires(id)
 if required==null:return prerequisites
 return [required.back()] if ROWS[id].has("after") and not required.is_empty() else required
