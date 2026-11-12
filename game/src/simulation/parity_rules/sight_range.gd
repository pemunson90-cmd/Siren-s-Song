extends RefCounted
# WP-16 (parity_rules.gd, rule "sight_range"): the chart draws how far a Siren
# sees, as the v7 prototype did (line 504), once that Siren type's sensor array
# has been photographed. [PAT, 2026-11-12] chose this option: "A is fine for now
# even though it doesn't make a ton of sense we can figure out a way to explain
# it later."
#
# [AI-DESIGNED] Public knowledge only: the ring is drawn at a contact's last
# known position, for a contact whose type the player has identified, when the
# campaign's photo intel holds "siren_<type>" (the SENSOR ARRAY feature of a
# Siren photograph) or a usable photograph of that type was taken this dive.
# The radius is the published sight rule for the selected craft's present state
# (180 m silent, 290 m otherwise) times the Hunt stage shown on the Hunt meter.
# It never reads a Siren's hidden readiness, so it is an estimate ("~").
const Rules=preload("res://src/simulation/parity_rules/parity_rules.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Identity=preload("res://src/simulation/contact_identity.gd")
const PREFIX="siren_"
const SILENT=180.0
const MOVING=290.0
# Roles that acquire craft by sight.
const SIGHTED=["patroller","sentinel","hunter","sweeper"]
# Dive start: remember which Siren types earlier photographs resolved.
static func prepare(m:Dictionary,intel:Dictionary)->void:
 var types=[]
 for key in intel:
  if str(key).begins_with(PREFIX):types.append(str(key).substr(PREFIX.length()))
 m["sight_intel"]=types
static func known_types(sim)->Array:
 var types:Array=sim.mission.get("sight_intel",[]).duplicate()
 for shot in sim.mission.get("photo",{}).get("shots",[]):
  if shot.get("usable",false) and shot.has("siren") and int(shot.siren)>=0 and int(shot.siren)<sim.sirens.size():
   var type=str(sim.sirens[int(shot.siren)].get("type","patroller"))
   if type not in types:types.append(type)
 return types
# [{id,pos,radius,label}] for the chart.
static func rows(sim)->Array:
 var result=[]
 if not Rules.on(sim.mission,"sight_range") or sim.units.is_empty():return result
 var types=known_types(sim)
 if types.is_empty():return result
 var craft=sim.units[clampi(sim.selected,0,sim.units.size()-1)]
 var base=SILENT if craft.get("silent",false) else MOVING
 var scale=float(Hunt.view(sim).scale)
 for id in sim.contacts:
  if not id is int or id<0 or id>=sim.sirens.size() or not Identity.known(sim,id):continue
  var type=str(sim.sonar.identified[id])
  if type not in types or type not in SIGHTED:continue
  var radius=base*scale
  result.append({"id":id,"pos":sim.contacts[id].pos,"radius":radius,"label":"S%d SIGHT ~%dm"%[id+1,roundi(radius)]})
 return result
