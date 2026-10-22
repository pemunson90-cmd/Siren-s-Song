extends RefCounted
# Only this public measured projection crosses the simulation/presentation seam.
# The announced course is authored knowledge; it never advances a hull fix.
static func context(sim)->Dictionary:
 return sim.rendezvous_context() if sim!=null and sim.has_method("rendezvous_context") else {}
static func projection(sim)->Dictionary:
 var report=context(sim);var result={"hull":{},"control":{},"course":[]}
 if report.is_empty():return result
 result.course=report.course.duplicate()
 if report.control.known:result.control=report.control.duplicate(true)
 if report.vessel.known:
  result.hull=report.vessel.duplicate(true)
  result.hull["label"]="BERTHING HULL · "+str(report.vessel.phase).to_upper() if report.vessel.live else "LAST HULL FIX · STALE %ds"%floori(report.vessel.age)
 return result
static func replaces_site(sim,site:Dictionary)->bool:
 return site.get("site_id","")=="rendezvous" and not context(sim).is_empty()
static func markers(view,sim,touch:float)->Array:
 var known=projection(sim);var result=[]
 var occupied=view.ui_blocked_rects+view.own_craft_rects()+view.ship_instrument_rects()+view.contact_readout_rects()
 var bounds=Rect2(Vector2(12,view.instrument_top+12),view.size-Vector2(24,view.instrument_top+touch+30))
 var extent=Vector2(minf(touch*3.2,bounds.size.x),touch)
 for kind in ["control","hull"]:
  var data=known[kind]
  if data.is_empty():continue
  var anchor=view.screen_position(data.pos)
  if not Rect2(Vector2.ZERO,view.size).has_point(anchor):continue
  for offset in [Vector2(.9,-.5),Vector2(-4.1,-.5),Vector2(-1.6,-1.7),Vector2(-1.6,.9),Vector2(.9,1.2),Vector2(-4.1,1.2),Vector2(.9,-2.),Vector2(-5.1,-.5),Vector2(2.,-.5),Vector2(-5.1,.9),Vector2(2.,.9),Vector2(-1.6,2.)]:
   var box=Rect2((anchor+offset*touch).clamp(bounds.position,bounds.end-extent),extent)
   if occupied.any(func(rect):return rect.intersects(box.grow(5))):continue
   var subject={"kind":"objective","subkind":"berth_control" if kind=="control" else "rendezvous_hull","name":"BERTH CONTROL" if kind=="control" else "BERTHING HULL" if data.live else "LAST HULL FIX","pos":data.pos}
   var text="RELEASED · MOORING COURSE" if kind=="control" and data.used else "RELEASE · AUDIBLE 950m / 6s" if kind=="control" else str(data.phase).to_upper()+" · LOCAL FIX" if data.live else "STALE · %ds AGO"%floori(data.age)
   result.append({"rect":box,"anchor":anchor,"subject":subject,"text":text});occupied.append(box);break
 return result
static func pick(view,sim,point:Vector2,touch:float,bodies:bool=true)->Dictionary:
 for marker in markers(view,sim,touch):
  if marker.rect.has_point(point):return marker.subject
 if not bodies:return {}
 var known=projection(sim)
 if not known.control.is_empty() and point.distance_to(view.screen_position(known.control.pos))<=maxf(touch*.5,28*view.world_scale):
  return {"kind":"objective","subkind":"berth_control","name":"BERTH CONTROL","pos":known.control.pos}
 if not known.hull.is_empty() and point.distance_to(view.screen_position(known.hull.pos))<=maxf(touch*.5,44*view.world_scale):
  return {"kind":"objective","subkind":"rendezvous_hull","name":"BERTHING HULL" if known.hull.live else "LAST HULL FIX","pos":known.hull.pos}
 return {}
static func refresh_subject(sim,subject:Dictionary)->Dictionary:
 if subject.get("subkind","")!="rendezvous_hull":return subject
 var hull=projection(sim).hull
 if hull.is_empty():return subject
 var copy=subject.duplicate();copy.pos=hull.pos;copy.name="BERTHING HULL" if hull.live else "LAST HULL FIX";return copy
static func detail(sim,subject:Dictionary)->String:
 var report=context(sim)
 if report.is_empty():return ""
 if subject.get("subkind","")=="berth_control":
  var control=report.control
  if not control.known:return "Locate the berth control locally or with Survey."
  return "BERTH CONTROL\n"+control.reason+"\nRELEASE BERTH · AUDIBLE %dm / %ds\nWithin %dm · clear link · settled below 12m/s.\nOne release starts the tender's announced course to the permanent northern mooring. The course is not a live tracker. Quiet berth decode also remains available."%[roundi(control.noise_radius),roundi(control.noise_duration),roundi(control.range)]
 var lines=receiver_lines(sim,sim.selected)
 if report.vessel.known:
  lines.push_front("CURRENT HULL · "+str(report.vessel.phase).to_upper() if report.vessel.live else "LAST HULL FIX · STALE %ds · position at last measurement"%floori(report.vessel.age))
 lines.append("Quietus decodes in 4s within 240m of the actual hull, with clear local reception and speed below 12m/s. A last fix is an approach reference; reacquire to decode.")
 return "\n".join(lines)
static func receiver_lines(sim,unit:int)->Array:
 if context(sim).is_empty():return []
 var receiver=sim.rendezvous_receiver(unit)
 var lines=["LOCAL HULL RECEPTION" if receiver.distance>=0 else "HULL RECEPTION UNAVAILABLE",receiver.text]
 if receiver.distance>=0:lines.append("LOCAL RANGE · %dm"%roundi(receiver.distance))
 lines.append("PASSIVE DECODE · 4s" if unit==0 else "QUIETUS HYDROPHONES REQUIRED")
 return lines
static func draw(view,sim)->void:
 var known=projection(sim);var scale=maxf(.01,view.world_scale);var font=maxi(4,roundi(view.feedback_font_size/scale))
 var course: Array=known.course
 if not course.is_empty():
  var ink=Color(.60,.70,.65,.4)
  for n in range(1,course.size()):view._dash(course[n-1],course[n],ink,1.3/scale)
  view.draw_arc(course.back(),32,0,TAU,32,ink,1.5/scale)
  view._label(course.back()+Vector2(45,30),"PERMANENT NORTH MOORING",Color("8faeaa"),font)
  view._label(course[1]+Vector2(32,-60),"ANNOUNCED TENDER COURSE",Color("8faeaa"),font)
  # This fixed mooring belongs to the announced course, not a hull observation.
  var berth=course[0]
  for side in [-1,1]:
   var edge=berth+Vector2(-48,side*37)
   view.draw_line(edge,edge+Vector2(110,0),Color("507677"),4/scale)
   view.draw_circle(edge,5/scale,Color("87aaa3"))
 if not known.control.is_empty():
  var pos:Vector2=known.control.pos;var color=Color("8faeaa") if known.control.used else Color("dfbd7c")
  view.draw_circle(pos,24,Color("102a32"));view.draw_arc(pos,24,0,TAU,24,color,2/scale)
  view.draw_line(pos+Vector2(-13,-8),pos+Vector2(13,8),color,3/scale)
  view.draw_line(pos+Vector2(-13,8),pos+Vector2(13,-8),color,3/scale)
  view._label(pos+Vector2(42,-12),"BERTH RELEASED" if known.control.used else "BERTH CONTROL",color,font)
 if not known.hull.is_empty():
  var hull=known.hull;var points=PackedVector2Array()
  for p in [Vector2(48,0),Vector2(27,-24),Vector2(-36,-24),Vector2(-48,-10),Vector2(-48,10),Vector2(-36,24),Vector2(27,24),Vector2(48,0)]:points.append(hull.pos+p.rotated(hull.angle))
  if not hull.live:
   view.draw_polyline(points,Color(.59,.65,.62,.55),1.5/scale)
   view.draw_arc(hull.pos,56,0,TAU,16,Color(.59,.65,.62,.4),1/scale)
  else:
   view.draw_colored_polygon(points,Color("24474b"));view.draw_polyline(points,Color("bdd0bc"),2/scale)
   for offset in [-24,0,24]:
    var a=hull.pos+Vector2(offset,-16).rotated(hull.angle);var b=hull.pos+Vector2(offset,16).rotated(hull.angle)
    view.draw_line(a,b,Color("729c97"),3/scale)
   view.draw_circle(hull.pos+Vector2(19,0).rotated(hull.angle),6,Color("d9c18a"))
 # Object-owned badges move away from craft instruments; their measured anchor
 # stays unchanged. A visible badge and its hit region are the same rectangle.
 view.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 for marker in markers(view,sim,view.instrument_height):
  var color=Color("dfbd7c") if marker.subject.subkind=="berth_control" else Color("bdd0bc")
  var box:Rect2=marker.rect;var fs=view.feedback_font_size
  view.draw_line(marker.anchor,marker.anchor.clamp(box.position,box.end),Color(color,.5),1.5)
  view.draw_rect(box,Color(.025,.065,.075,.94));view.draw_rect(box,color,false,1)
  view.draw_string(ThemeDB.fallback_font,box.position+Vector2(10,fs+8),marker.subject.name,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-20,fs,color)
  view.draw_string(ThemeDB.fallback_font,box.position+Vector2(10,fs*2+14),marker.text,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-20,fs,color)
 view.draw_set_transform(view.world_offset,0,Vector2.ONE*scale)
