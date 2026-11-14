extends RefCounted
# WP-16 (parity_rules.gd, rule "factory_sensors"): a Siren factory senses craft
# near it. [PAT, 2026-11-12] "It's an alien factory with sensors and
# protection. It should know you're there."
#
# The v7 prototype raised suspicion while the submarine was within 340 m of the
# factory, by up to 8 per second at the wall, falling to nothing at the edge
# (prototype lines 334 to 335). The game has no suspicion meter; its global
# pressure value is Hunt (hunt_pressure/), which widens Siren sight in stages.
# So a craft in the water inside a factory's sensor radius raises Hunt by the
# same curve, and the Hunt meter names the cause. [AI-DESIGNED mapping; RADIUS
# and GAIN are the prototype's numbers and are Pat's to tune]
#
# Sites come from the operation: mission["factory_sensors"] is a list of
# {"pos":Vector2,"r":float}. Only operations whose data names a factory carry
# it today (3 Cold Foundry, 11 Confluence). Which other Siren works should
# sense craft is a question for Pat.
const Rules=preload("res://src/simulation/parity_rules/parity_rules.gd")
const RADIUS=340.0
const GAIN=8.0
const CAUSE="FACTORY"
static func sites(m:Dictionary)->Array:
 return m.get("factory_sensors",[]) if Rules.on(m,"factory_sensors") else []
# Strongest reading over all craft in the water and all sites, 0 to 1.
static func reading(sim)->float:
 var best=0.0
 for site in sites(sim.mission):
  var reach=float(site.get("r",RADIUS))
  for u in sim.units:
   if not u.get("alive",false):continue
   var d:float=u.pos.distance_to(site.pos)
   if d<reach:best=maxf(best,1.0-d/reach)
 return best
static func tick(sim,dt:float)->void:
 var level=reading(sim)
 var state:Dictionary=sim.mission.get("factory_state",{})
 if level<=0.0:
  if state.get("sensed",false):state["sensed"]=false;sim.mission["factory_state"]=state
  return
 sim.Recon.action(sim.mission,GAIN*level*dt,CAUSE)
 if not state.get("sensed",false):
  state["sensed"]=true;sim.mission["factory_state"]=state
  sim.message="Factory sensors have a craft · Hunt rises while it stays inside %d m"%roundi(RADIUS)
  sim.events.append({"type":"factory_sensed","pos":sim.units[0].pos})
