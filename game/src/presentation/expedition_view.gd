extends RefCounted
# Draw under the ordinary craft/route overlays. Consume earned observations
# only; never read signal_sources or acoustic path vertices in presentation.
static func draw(view,sim)->void:
 if not sim.mission.has("expedition_revision"):return
 var scale=maxf(0.01,view.world_scale)
 var font_size=int(view.feedback_font_size/scale)
 for reading in sim.signal_readings():
  var age:float=reading.age
  var alpha=clampf(1.0-age/30.0,0.15,0.8)
  var origin:Vector2=reading.origin
  var angle:float=reading.direction.angle()
  var radius=150.0
  view.draw_arc(origin,radius,angle-reading.uncertainty,angle+reading.uncertainty,20,Color(0.42,0.78,0.83,alpha),2.0/scale)
  var tip=origin+reading.direction*radius
  view.draw_line(origin+reading.direction*30,tip,Color(0.42,0.78,0.83,alpha*0.55),1.0/scale)
  var caption="%s · %s · %.0fs"%[sim.units[reading.receiver].name,reading.label,age]
  view.draw_string(ThemeDB.fallback_font,tip+Vector2(8,-8)/scale,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(0.62,0.83,0.84,alpha))
  view.draw_string(ThemeDB.fallback_font,tip+Vector2(8,12)/scale,"ARRIVAL ±%d° · may bend"%roundi(rad_to_deg(reading.uncertainty)),HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color(0.47,0.68,0.72,alpha))
 for corridor in sim.extraction_corridors():
  var c=Color("72d9d3") if corridor.available else Color("718387")
  view.draw_arc(corridor.pos,64,0,TAU,48,c,2.0/scale)
  view.draw_string(ThemeDB.fallback_font,corridor.pos+Vector2(-62,-78),corridor.name,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,c)
  view.draw_string(ThemeDB.fallback_font,corridor.pos+Vector2(-62,91),"RECOVERY AVAILABLE" if corridor.available else "INTERPRET CARRIER FIRST",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,c)
