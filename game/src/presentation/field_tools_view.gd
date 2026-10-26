extends RefCounted
# C2 field tools world drawing: sonobuoys with bearing ticks, silt clouds and relay buoys.
# AI-DESIGNED. Seam: presentation/feature_views.gd WORLD_VIEWS row. Draws placed items only; no input, no state.
# Revert by removing the WORLD_VIEWS entry; the simulation and orders are unaffected.
const Effects=preload("res://src/simulation/field_tool_effects.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const TICK_LENGTH=90.0

static func applies(sim)->bool:
 return sim!=null and not Effects.state(sim).get("placed",[]).is_empty()
static func draw(view)->void:
 var sim=view.sim;var scale=maxf(.01,view.world_scale)
 for item in Effects.state(sim).get("placed",[]):
  var left:float=item.until-sim.elapsed
  if left<=0.0 or item.band!=sim.units[sim.selected].band:continue
  match item.id:
   "silt_screen":
    var fade=clampf(left/Tools.spec("silt_screen").life,0.1,1.0)
    view.draw_circle(item.pos,Tools.spec("silt_screen").radius,Color(.55,.5,.38,.28*fade))
    view.draw_arc(item.pos,Tools.spec("silt_screen").radius,0,TAU,40,Color(.7,.63,.45,.5*fade),2./scale)
   "relay_buoy":
    view.draw_arc(item.pos,Tools.spec("relay_buoy").radius,0,TAU,48,Color(.45,.78,.7,.35),2./scale)
    view.draw_circle(item.pos,7,Color(.45,.78,.7))
   "sonobuoy":
    view.draw_circle(item.pos,6,Color(.85,.8,.5))
    view.draw_arc(item.pos,11,0,TAU,16,Color(.85,.8,.5,.7),2./scale)
 for bearing in Effects.bearings(sim):
  var dir=Vector2.from_angle(bearing.angle)
  view.draw_line(bearing.from+dir*18.0,bearing.from+dir*TICK_LENGTH,Color(.85,.8,.5,.8),3./scale)
