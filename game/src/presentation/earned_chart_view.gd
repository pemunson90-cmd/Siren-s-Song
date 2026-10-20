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
