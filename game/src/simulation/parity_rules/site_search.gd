extends RefCounted
# WP-16 (parity_rules.gd, rule "site_search"): an objective is a search area on
# the chart until the player finds it. It reuses the discovery stage the game
# already has for hidden photo subjects (PhotoCapture.stage "lead": an area,
# never the exact position), so the chart, the ring caption and the camera
# context already know how to show it.
#
# Found for good by the player's own sensors: a craft's passive reach with a
# clear path, or a sonar pulse that reaches it inside the pulse's sector.
# Shown for a while by a survey sweep (ParityRules.SURVEY_MEMORY), then a
# search area again unless a craft found it meanwhile. [AI-DESIGNED from Pat's
# ruling of 2026-11-12]
const Rules=preload("res://src/simulation/parity_rules/parity_rules.gd")
const Region=preload("res://src/simulation/world_region.gd")
const RADIUS=220.0
const SIGHT=170.0
static func applies(m:Dictionary)->bool:
 return Rules.on(m,"site_search") and not Rules.tutorial(m) and not Rules.debug_known
# Dive start: every plainly charted objective becomes a search area. Subjects
# that already have their own discovery (unknown, lead) or that are not places
# (a Siren, the launch point) are left alone.
static func prepare(m:Dictionary)->void:
 if not applies(m):return
 var objectives:Array=m.get("objectives",[])
 for index in objectives.size():
  var o:Dictionary=objectives[index]
  if o.get("unknown",false) or o.has("lead") or o.has("siren") or o.get("own_origin",false) or not o.get("pos") is Vector2:continue
  # A fixed offset per operation and objective: the area holds the site, off centre.
  var turn=fposmod(float(int(m.get("id",0))*37+index*101),360.0)
  o["search"]=true
  o["lead"]={"r":RADIUS,"off":Vector2.from_angle(deg_to_rad(turn))*RADIUS*.55,"sight":SIGHT}
static func hidden(o:Dictionary)->bool:
 return bool(o.get("search",false)) and not bool(o.get("found",false)) and not bool(o.get("glimpsed",false))
static func _find(sim,o:Dictionary,by:String)->void:
 o["found"]=true;o.erase("glimpsed");o.erase("glimpse_until")
 sim.message="%s located by %s · marked on the chart"%[str(o.get("name","Site")),by]
 sim.events.append({"type":"site_found","pos":o.pos})
# Called with the other sensor observations.
static func tick(sim)->void:
 if not Rules.on(sim.mission,"site_search"):return
 for o in sim.mission.get("objectives",[]):
  if not o.get("search",false) or o.get("found",false):continue
  var band=int(o.get("band",1))
  var receivers:Array=sim.passive_receivers(o.pos,band)
  if not receivers.is_empty():
   _find(sim,o,str(sim.units[receivers[0]].name));continue
  if Region.survey_visible(sim,o.pos):
   if not o.get("glimpsed",false):sim.message="Survey shows %s · on the chart for %d s unless a craft maps it"%[str(o.get("name","a site")),roundi(Rules.SURVEY_MEMORY)]
   o["glimpsed"]=true;o["glimpse_until"]=sim.elapsed+Rules.SURVEY_MEMORY
  elif o.get("glimpsed",false) and sim.elapsed>=float(o.get("glimpse_until",0.)):
   o.erase("glimpsed");o.erase("glimpse_until")
# A sonar pulse from this craft.
static func pinged(sim,station:int,radius:float)->void:
 if not Rules.on(sim.mission,"site_search"):return
 var u=sim.units[station]
 for o in sim.mission.get("objectives",[]):
  if not o.get("search",false) or o.get("found",false):continue
  if u.pos.distance_to(o.pos)<radius and sim.Sonar.in_sector(u.pos,o.pos,u.angle,sim.sonar.sector) and sim.Depth.clear(sim,u.pos,o.pos,u.band):
   _find(sim,o,"%s's sonar"%str(u.name))
# Developer option.
static func reveal_all(sim)->void:
 for o in sim.mission.get("objectives",[]):
  if o.get("search",false):o["found"]=true
