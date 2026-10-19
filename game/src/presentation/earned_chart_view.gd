extends RefCounted
# Shared world/planner chart. Cells describe measured water, never wall faces.
# Only exact physically received surface patches produce solid terrain strokes.
const CONFIRMED=Color("72d9d3")
const TENTATIVE=Color("d3b77c")
static func chart(sim)->Dictionary:
 return sim.public_chart() if sim!=null and sim.has_method("public_chart") else {}
static func segments(sim,unit:int)->Array:
 return sim.course_segments(unit) if sim!=null and sim.has_method("course_segments") else []
static func draw_terrain(view,data:Dictionary,scale:float)->void:
 var cell=float(data.get("cell_size",40.))
 for key in data.get("clear_cells",[]):
  view.draw_rect(Rect2(Vector2(key)*cell,Vector2.ONE*cell),Color(.065,.18,.205,.7))
 # No RETURN-cell squares, connected silhouettes, end caps or closure: a
 # measurement ending at a patch edge says nothing about the unseen rock.
 for face in data.get("surface_segments",[]):
  if face.size()!=2:continue
  view.draw_line(face[0],face[1],Color("132b32"),7./maxf(scale,.01))
  view.draw_line(face[0],face[1],Color("819c96"),2./maxf(scale,.01))
static func draw_course(view,parts:Array,scale:float,selected:bool)->void:
 for part in parts:
  var color=CONFIRMED if part.confirmed else TENTATIVE
  if not selected:color.a=.35
  var width=2./maxf(scale,.01)
  if part.confirmed:view.draw_line(part.from,part.to,color,width)
  else:
   var delta:Vector2=part.to-part.from;var length=delta.length();var step=18./maxf(scale,.01)
   var at=0.
   while at<length:
    view.draw_line(part.from+delta.normalized()*at,part.from+delta.normalized()*minf(at+step*.55,length),color,width)
    at+=step
static func status(sim,unit:int)->String:
 var course=sim.course_status(unit) if sim.has_method("course_status") else {}
 if course.is_empty():return ""
 match course.get("state",""):
  "blocked":return "NEW TERRAIN · REPLOT · queued intent retained"
  "frontier":return "SURVEY FRONTIER · extend chart or replot"
  "tentative":return "TENTATIVE COURSE · dashed amber is unsurveyed"
 return "CHARTED COURSE · solid cyan is confirmed water" if course.get("clear_distance",0.)>0 else "EARNED CHART · plot through measured water"
static func delivery(sim)->Dictionary:
 return sim.delivery_context() if sim!=null and sim.has_method("delivery_context") else {}
static func objective(sim)->String:
 var data=delivery(sim)
 if data.is_empty():return ""
 if data.get("recovered",false):return "HANDOFF RECOVERED · returned to withdrawal basin"
 if data.get("handoff_complete",false):return "HANDOFF COMPLETE · return Quietus to withdrawal basin"
 return "HANDOFF REQUIRED · Quietus to briefed coordinate · settle below 12m/s"
static func goal_context(sim,point:Vector2)->Dictionary:
 var data=delivery(sim)
 if data.is_empty():return {}
 return {"kind":"objective","subkind":"corridor","route":"charted_handoff","name":"BRIEFED HANDOFF","pos":data.handoff_pos,"available":not data.handoff_complete} if point.distance_to(data.handoff_pos)<.01 else {}
static func context_detail(sim,subject:Dictionary)->String:
 if subject.get("route","")!="charted_handoff":return ""
 return objective(sim)+"\nThe coordinate is briefed; surrounding terrain must be surveyed. Plot an approach, then physically return with the handoff."
static func draw_goal(view,sim)->void:
 var data=delivery(sim)
 if data.is_empty():return
 var area:Rect2=data.handoff_sector;var size=minf(area.size.x,area.size.y)*.18
 for corner in [area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]:
  var direction=(area.get_center()-corner).sign()
  view.draw_line(corner,corner+Vector2(direction.x*size,0),TENTATIVE,1.5/view.world_scale)
  view.draw_line(corner,corner+Vector2(0,direction.y*size),TENTATIVE,1.5/view.world_scale)
 view.draw_arc(data.handoff_pos,30,0,TAU,32,CONFIRMED if data.handoff_complete else TENTATIVE,2./view.world_scale)
 view._label(data.handoff_pos+Vector2(42,0),"HANDOFF COMPLETE" if data.handoff_complete else "BRIEFED HANDOFF",CONFIRMED if data.handoff_complete else TENTATIVE,maxi(4,roundi(view.feedback_font_size/view.world_scale)))
