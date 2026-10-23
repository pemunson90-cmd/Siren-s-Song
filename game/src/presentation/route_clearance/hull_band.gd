extends RefCounted
# Own accepted-course footprint only. No terrain/listener query or input ownership.
# Values describe the existing 12 m hull, not a change to collision or damage rules.
# Revert: remove the OceanView/RouteProgramPreview draw calls and this folder.
const STYLE={"hull_radius":12.0,"tint":Color(0.35,0.85,0.82,0.10),"legend":"BAND = HULL WIDTH"}
static func segments(sim,unit:int)->Array:
 var result=[]
 if unit<0 or unit>=sim.units.size() or not sim.units[unit].alive:return result
 var previous:Vector2=sim.units[unit].pos
 for node in sim.units[unit].route:
  result.append({"from":previous,"to":node.pos,"radius":STYLE.hull_radius});previous=node.pos
 return result
# Caller supplies its existing world-to-screen canvas transform, including zoom.
static func draw_world(view,sim,unit:int)->void:
 for leg in segments(sim,unit):
  view.draw_line(leg.from,leg.to,STYLE.tint,leg.radius*2.,true)
  view.draw_circle(leg.from,leg.radius,STYLE.tint)
  view.draw_circle(leg.to,leg.radius,STYLE.tint)
