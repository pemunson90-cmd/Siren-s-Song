extends RefCounted
const Courier=preload("res://src/simulation/blackwater_courier.gd")
static func draw(view,sim)->void:
 if sim.mission.get("courier_revision",0)!=1:return
 # Recovered route instructions are authored knowledge, never a live tracker.
 if sim.mission.objectives[0].captured and not sim.mission.objectives[1].captured:
  var tint=Color(0.73,0.64,0.40,0.30)
  for i in range(1,Courier.POINTS.size()):view._dash(Courier.POINTS[i-1],Courier.POINTS[i],tint,1.0/view.world_scale)
  view._label(Vector2(440,826),"ANNOUNCED ARCHIVE CORRIDOR",Color(0.73,0.64,0.40,0.75),14)
  view.draw_arc(Courier.POINTS[-1],12,0,TAU,16,tint,1.2/view.world_scale)
 var report=sim.courier_feedback()
 if report.is_empty():return
 var points=PackedVector2Array()
 for p in [Vector2(20,0),Vector2(-13,-15),Vector2(-7,0),Vector2(-13,15)]:points.append(report.pos+p.rotated(report.angle))
 view.draw_colored_polygon(points,Color("183d43"))
 view.draw_polyline(points,Color("a8c5b2"),1.5/view.world_scale)
 view.draw_line(points[-1],points[0],Color("a8c5b2"),1.5/view.world_scale)
 view.draw_circle(report.pos,3.0/view.world_scale,Color("dfc07e"))
 view._label(report.pos+Vector2(-54,-26),"REPLY CARRIER",Color("dfc07e"),15)
 if report.receivers.has(sim.selected) and not sim.mission.objectives[1].captured:
  view._label(report.pos+Vector2(-54,40),"LOCAL · SETTLE + SAMPLE",Color("a8c5b2"),14)
