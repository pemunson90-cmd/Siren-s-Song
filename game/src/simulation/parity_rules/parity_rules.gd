extends RefCounted
# WP-16: prototype rules Pat restored on 2026-11-12 after the parity audit
# (docs/V7_TO_GODOT_PARITY.md, audit of 12 November; rulings verbatim in
# docs/USER_DIRECTIVES.md). [PAT rulings; the build is AI-DESIGNED]
#
#  discovered_charts    "the whole point is it's a recon and survey mission. You
#                       have to discover through exploration, sonar, photographs,
#                       recon sweeps but are temporary until you map them." Known
#                       water only in "the first one to three missions as a
#                       tutorial".
#  site_search          objectives shown from the start "should be left as a
#                       debug option but not primary for gameplay release".
#  disrupt_needs_target Disrupt spending its charge with no Siren in range:
#                       "Yeah that's a failure".
#  factory_sensors      "It's an alien factory with sensors and protection. It
#                       should know you're there."
#  free_quietus_sonar   "I don't think it should cost oxygen. It's your primary
#                       maneuverability and recon ability. ... The biggest risk
#                       is getting caught. On the drones it costing battery
#                       makes sense."
#  The tool the code calls emp is named EMP wherever the player reads it
#  ("It should just say EMP"); it is an area pulse and never needs a target.
#
# The rules apply to a dive whose launch dictionary carries "parity_rules"
# (Main passes it for every player dive, ChallengeRun too). The flag is stored
# on the mission, so a saved dive keeps the rules it started with. A direct
# Simulation.start() without the flag keeps the older behavior, which the rule
# tests use as their fixture (the same arrangement as drone_bay/).
# Revert: set a row of RULES to false, or all of them.
const KEY="parity_rules"
const RULES={"discovered_charts":true,"site_search":true,"disrupt_needs_target":true,"factory_sensors":true,"free_quietus_sonar":true}
# Operations whose water and objectives are known from the start (tutorial).
const CHARTED_OPERATIONS=[0,1,2]
# Seconds a survey sweep's picture stays on the chart, and an objective it
# showed stays marked, unless a craft's own sensors map it first.
const SURVEY_MEMORY=30.0
# Developer console command "known": new dives start with charts and
# objectives known, and the current dive's objectives are all marked.
static var debug_known:=false
static func wanted(launch:Dictionary)->bool:
 return bool(launch.get(KEY,false))
static func on(m:Dictionary,rule:String)->bool:
 return bool(RULES.get(rule,false)) and bool(m.get(KEY,false))
static func tutorial(m:Dictionary)->bool:
 return int(m.get("id",-1)) in CHARTED_OPERATIONS
# Dive start. Returns true when this dive discovers its own chart.
static func discovers(m:Dictionary)->bool:
 return on(m,"discovered_charts") and not tutorial(m) and not debug_known
# Gives an operation that was authored with a full chart the same opening
# window an earned-chart operation has (encounters/terrain.gd seed_chart).
static func seed_chart(m:Dictionary,size:Vector2,start:Vector2)->void:
 if m.get("earned_terrain",false) or not discovers(m):return
 m["earned_terrain"]=true
 m["launch_seed"]=Rect2(start-Vector2(160,200),Vector2(480,480)).intersection(Rect2(Vector2.ONE*40,size-Vector2.ONE*80))
static func survey_memory(m:Dictionary)->float:
 return SURVEY_MEMORY if on(m,"discovered_charts") else -1.0
