extends RefCounted
const Equipment=preload("res://src/presentation/equipment_context.gd")
# Public received measurements only. Fans have no hit region: water along a
# bearing remains available for routes. The HUD supplies an explicit badge.
static func active(sim)->bool:return sim!=null and sim.mission.get("expedition_revision",0) in [1,2]
static func entry(sim)->bool:return active(sim) and sim.mission.id==6
static func measurements(sim,receiver:int=-1)->Array:
 if not active(sim):return []
 return sim.signal_readings().filter(func(r):return receiver<0 or r.receiver==receiver)
static func detail(sim,receiver:int=-1)->String:
 var rows=["RECEIVED ARRIVALS · %s"%(sim.units[receiver].name if receiver>=0 else "OWN FLEET")]
 for reading in measurements(sim,receiver):
  rows.append("%s · %s · %.1fs ago"%[sim.units[reading.receiver].name,reading.label,reading.age])
  if reading.has("cadence"):rows.append(Equipment.cadence_text(reading.cadence))
  rows.append("ARRIVAL ±%d° · may bend around rock; no source fix"%roundi(rad_to_deg(reading.uncertainty)) if reading.direction.length_squared()>.001 else "Arrival direction unresolved; no source fix")
 if rows.size()==1:rows.append("No current carrier measurements. Listen from another position or use local SURVEY.")
 if receiver in [-1,0]:
  var correlation=Equipment.correlation_detail(sim)
  if not correlation.is_empty():rows.append(correlation)
 return "\n\n".join(rows)
static func badge_rect(view,sim,touch:float,blocked:Array)->Rect2:
 if measurements(sim,sim.selected).is_empty():return Rect2()
 var p:Vector2=view.screen_position(sim.units[sim.selected].pos)
 if not Rect2(Vector2.ZERO,view.size).has_point(p):return Rect2()
 var size=Vector2(touch*1.55,touch);var radius=maxf(touch*1.1,72*view.world_scale if sim.selected==0 else 24*view.world_scale)
 var avoid=blocked.duplicate();avoid.append_array(view.own_craft_rects());avoid.append_array(view.ship_instrument_rects());avoid.append_array(view.contact_readout_rects())
 for site in sim.observable_sites():avoid.append(Rect2(view.screen_position(site.pos)-Vector2.ONE*40*view.world_scale,Vector2.ONE*80*view.world_scale))
 if view.optical_feed!=null and view.optical_feed.visible:avoid.append(view.optical_feed.get_rect())
 for offset in [Vector2(radius+12,-touch*.5),Vector2(-radius-size.x-12,-touch*.5),Vector2(radius+12,touch*.6),Vector2(-radius-size.x-12,touch*.6),Vector2(-size.x*.5,-radius-touch-12),Vector2(-size.x*.5,radius+12)]:
  var at=(p+offset).clamp(Vector2(12,view.instrument_top+8),view.size-size-Vector2(12,12));var area=Rect2(at,size)
  if Rect2(Vector2.ZERO,view.size).encloses(area) and not avoid.any(func(r):return r.intersects(area.grow(5))):return area
 return Rect2()
static func pick(view,sim,point:Vector2,touch:float)->Dictionary:
 if not active(sim):return {}
 # Only charted physical corridors are targets, never received fan directions.
 for corridor in sim.extraction_corridors():
  if point.distance_to(view.screen_position(corridor.pos))<=maxf(touch*.5,64*view.world_scale):
   return {"kind":"objective","subkind":"corridor","name":corridor.name,"pos":corridor.pos,"route":corridor.route,"available":corridor.available}
 if entry(sim) and point.distance_to(view.screen_position(sim.mission.extraction))<=maxf(touch*.5,64*view.world_scale):
  return {"kind":"objective","subkind":"withdrawal","name":"INCOMPLETE WITHDRAWAL","pos":sim.mission.extraction}
 return {}
static func context_detail(sim,subject:Dictionary)->String:
 if subject.get("subkind","")=="withdrawal":return "INCOMPLETE WITHDRAWAL\nReturn Quietus to the southern basin. Field observations remain; this does not recover an expedition route."
 for corridor in sim.extraction_corridors():
  if corridor.route==subject.get("route",""):
   return "%s\n%s\nPlot the selected craft’s approach. Only Quietus’s settled arrival commits this recovery corridor."%[corridor.name,"RECOVERY AVAILABLE" if corridor.available else "RECOVERY NOT READY · approach only" if sim.mission.get("expedition_revision",0)==2 else "INTERPRET CARRIER FIRST · approach only"]
 return ""
static func draw(view,sim)->void:
 if not active(sim):return
 var scale=maxf(.01,view.world_scale)
 for reading in measurements(sim,sim.selected):
  if reading.direction.length_squared()<.001:continue
  var alpha=clampf(1.0-reading.age/30.,.15,.8);var origin:Vector2=reading.origin;var angle:float=reading.direction.angle();var radius=150.
  # Direction and fan are arrival information at the historical receiver,
  # not a line to a source, a measured range or a corridor through terrain.
  var color=Color(.42,.78,.83,alpha)
  view.draw_arc(origin,radius,angle-reading.uncertainty,angle+reading.uncertainty,20,color,2./scale)
  for side in [-1,1]:
   var direction=Vector2.from_angle(angle+reading.uncertainty*side)
   view.draw_line(origin+direction*(radius-12),origin+direction*(radius+12),color,1.5/scale)
  view.draw_line(origin+reading.direction*(radius-8),origin+reading.direction*(radius+8),color,1.5/scale)
  view.draw_circle(origin,4./scale,Color(color,.5*alpha),false,1./scale)
 for corridor in sim.extraction_corridors():
  var color=Color("72d9d3") if corridor.available else Color("718387")
  view.draw_arc(corridor.pos,64,0,TAU,48,color,2./scale)
  view._label(corridor.pos+Vector2(-62,-78),corridor.name,color,maxi(4,roundi(view.feedback_font_size/scale)))
  view._label(corridor.pos+Vector2(-62,91),"RECOVERY" if corridor.available else ("FIELD TASK" if sim.mission.get("expedition_revision",0)==2 else "INTERPRET CARRIER"),color,maxi(4,roundi(view.feedback_font_size/scale)))
