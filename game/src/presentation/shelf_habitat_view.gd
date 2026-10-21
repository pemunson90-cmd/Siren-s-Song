extends RefCounted
const Habitat=preload("res://src/simulation/shelf_habitat.gd")
static func context(sim)->Dictionary:return sim.shelf_context() if sim!=null and sim.has_method("shelf_context") else {}
static func nearest(sim)->Dictionary:
 var report=context(sim)
 if report.is_empty():return {}
 var sites=[{"kind":"habitat","site":"alarm","name":"COMMUNAL RESONATOR","pos":report.alarm.pos}]
 for row in report.galleries:sites.append({"kind":"habitat","site":row.id,"name":row.name,"pos":row.pos})
 var pos:Vector2=sim.units[sim.selected].pos
 sites.sort_custom(func(a,b):return pos.distance_squared_to(a.pos)<pos.distance_squared_to(b.pos))
 return sites[0]
static func subject_rows(sim)->Array:
 var report=context(sim);var result=[]
 if report.is_empty():return result
 result.append({"kind":"habitat","site":"alarm","name":"COMMUNAL RESONATOR","pos":report.alarm.pos})
 for row in report.galleries:result.append({"kind":"habitat","site":row.id,"name":row.name,"pos":row.pos})
 return result
static func markers(view,sim,touch:float)->Array:
 var result=[];var bounds=Rect2(Vector2(12,view.instrument_top+12),view.size-Vector2(24,view.instrument_top+touch+30))
 var occupied=view.ui_blocked_rects+view.own_craft_rects()+view.ship_instrument_rects()+view.contact_readout_rects()
 var extent=Vector2(minf(touch*3.1,bounds.size.x),touch)
 for subject in subject_rows(sim):
  var anchor=view.screen_position(subject.pos)
  if not Rect2(Vector2.ZERO,view.size).has_point(anchor):continue
  for offset in [Vector2(.8,-1.6),Vector2(-3.8,-1.6),Vector2(.8,.8),Vector2(-3.8,.8),Vector2(-1.5,-2.8),Vector2(-1.5,1.8)]:
   var box=Rect2((anchor+offset*touch).clamp(bounds.position,bounds.end-extent),extent)
   if occupied.any(func(rect):return rect.intersects(box.grow(5))):continue
   result.append({"subject":subject,"rect":box,"anchor":anchor});occupied.append(box);break
 return result
static func pick(view,sim,point:Vector2,touch:float,bodies:bool=true)->Dictionary:
 for marker in markers(view,sim,touch):
  if marker.rect.has_point(point):return marker.subject
 if bodies:
  for subject in subject_rows(sim):
   if point.distance_to(view.screen_position(subject.pos))<=maxf(touch*.5,35*view.world_scale):return subject
 return {}
static func detail(sim,id:String)->String:
 var report=context(sim)
 if report.is_empty():return ""
 var result="WATCH REPLIES ·%d/2\n"%report.receipts.size()
 if id=="alarm":return result+"BUNKER ALARM\n"+report.alarm.reason+"\nOne1200m/8s audible common call. Actual water paths decide which sections receive it; listen for their returning replies. A shorter work route, with a hunter's real investigation risk. Local warnings remain available."
 for row in report.galleries:
  if row.id!=id:continue
  return result+row.name+"\n"+row.action.reason+"\nThe watch crew sits behind these pressure windows. Quietus can warn within100m, clear line, settled below2m/s. A small local140m pulse serves only this section; the second requires another close approach.\n"+(report.account if report.complete else "Watch the work-lights withdraw and listen for their watch account. The longer outer return keeps passive information; the short exhaust trench masks both sides.")
 return result+report.account
static func draw_ground(view,sim)->void:
 if context(sim).is_empty():return
 # Precharted pale shelf geology follows the actual collision outlines. Fine
 # occupied detail is drawn later from measured gallery state only.
 for rock in sim.mission.rocks:
  var poly=sim.rock_polygon(rock)
  var lower=PackedVector2Array();var uv=PackedVector2Array()
  for p in poly:lower.append(p+Vector2(10,25));uv.append(p/Vector2(400,400))
  view.draw_colored_polygon(lower,Color("07151b"))
  view.draw_colored_polygon(poly,Color("48524b"))
  view.draw_polygon(poly,PackedColorArray([Color(.88,.89,.73)]),uv,view.basalt)
  view.draw_colored_polygon(poly,Color(.60,.58,.40,.12))
  view.draw_polyline(poly,Color(.56,.61,.52,.72),2./maxf(.01,view.world_scale))
  var bounds=Geometry2D.convex_hull(poly)
  if bounds.size()<3:continue
  for n in poly.size():
   var edge:Vector2=poly[n];var next:Vector2=poly[(n+1)%poly.size()]
   view.draw_line(edge.lerp(next,.15),edge.lerp(next,.85),Color(.69,.65,.48,.45),6.)
   if next.x<edge.x:
    view.draw_colored_polygon(PackedVector2Array([edge,next,next+Vector2(10,25),edge+Vector2(10,25)]),Color("263a38"))
    for k in range(0,int(edge.distance_to(next)),18):
     var chip=edge.move_toward(next,k);view.draw_line(chip,chip+Vector2(7,21),Color(.55,.56,.39,.45),2.)
 # Mapped terrace depth, not an invented obstruction or discovered inhabitant.
 for n in 8:
  var line=PackedVector2Array([Vector2(180,1320+n*48),Vector2(440,1370+n*40),Vector2(590,1420+n*38)])
  view.draw_polyline(line,Color(.49,.56,.45,.12),4.)
static func draw_world(view,sim)->void:
 var report=context(sim)
 if report.is_empty():return
 var scale=maxf(.01,view.world_scale);var width=2./scale;var font=maxi(5,roundi(view.feedback_font_size/scale))
 if report.front.known:
  var area:Rect2=report.front.area
  view.draw_rect(area,Color(.48,.59,.40,.12));view.draw_rect(area,Color(.62,.67,.43,.5),false,width)
  for n in 7:
   var y=area.position.y+25+n*50
   view.draw_polyline(PackedVector2Array([Vector2(area.position.x,y),Vector2(area.get_center().x,y-15),Vector2(area.end.x,y)]),Color(.67,.68,.46,.25),width)
  view._label(area.position+Vector2(-90,-20),"EXHAUST FRONT · MUTUAL MASK",Color("b7b98e"),font)
 var a:Vector2=report.alarm.pos
 # Open resonating vanes are distinct from a receiver cross or factory marker.
 view.draw_rect(Rect2(a-Vector2(28,34),Vector2(56,68)),Color("293d3b"));view.draw_arc(a,40,0,TAU,40,Color("bec69c"),width)
 for n in 5:
  var p=a+Vector2((n-2)*12,-25)
  view.draw_line(p,p+Vector2(0,50),Color("c1bb87"),4.)
 if report.alarm.used:view.draw_arc(a,52,-PI*.8,PI*.8,32,Color("b99b65"),width)
 for row in report.galleries:
  var p:Vector2=row.pos;var direction=-1 if row.id=="west" else 1
  var color=Color("b4b68b");var box=Rect2(p+Vector2(-235 if direction<0 else 80,-135),Vector2(155,270))
  view.draw_rect(Rect2(box.position+Vector2(12,17),box.size),Color("07151b"))
  view.draw_rect(box,Color("273d3e"));view.draw_rect(box,color,false,width)
  # Recessed pressure bays, ribbed ducts and service decks explain an inhabited
  # bunker section rather than substituting another generic record-site installation.
  for rib in range(0,156,13):
   view.draw_line(box.position+Vector2(rib,0),box.position+Vector2(rib,270),Color("42615b"),2.)
  var spine=box.position.x+16 if direction<0 else box.end.x-16
  view.draw_line(Vector2(spine,box.position.y-25),Vector2(spine,box.end.y+25),Color("9fae91"),8.)
  for y in range(int(box.position.y)-15,int(box.end.y)+16,18):view.draw_line(Vector2(spine-6,y),Vector2(spine+6,y),Color("324f4b"),3.)
  for deck in 3:
   var y=p.y-88+deck*88
   view.draw_line(Vector2(box.position.x-12,y+33),Vector2(box.end.x+12,y+33),Color("6e8780"),5.)
   for rail in 7:
    var x=box.position.x-9+rail*28
    view.draw_line(Vector2(x,y+22),Vector2(x,y+33),Color("9ea98c"),2.)
   view.draw_line(Vector2(box.position.x-12,y+22),Vector2(box.end.x+12,y+22),Color("7f9583"),2.)
   for window in 4:
    var cell=Rect2(box.position.x+12+window*34,y-22,24,44)
    var c=cell.get_center();view.draw_circle(c,16,Color("0b2027"));view.draw_arc(c,16,0,TAU,20,Color("819e8c"),width)
    view.draw_line(c-Vector2(18,0),c+Vector2(18,0),Color("405d57"),width)
    var phase=float(row.closing)
    if phase<1:
     var clock=sim.elapsed if row.live else float(row.time)
     var lamp=cell.get_center()+Vector2(sin(clock*.7+window+deck)*7,6)-Vector2(0,20*phase)
     view.draw_circle(lamp,3.5,Color("e5c98b"))
     view.draw_line(lamp+Vector2(0,4),lamp+Vector2(0,13),Color("a9c9bd"),3.)
    if phase>0:
     view.draw_rect(Rect2(cell.position,Vector2(cell.size.x*phase,cell.size.y)),Color("637d73"))
     for slat in 5:
      var s=cell.position+Vector2(1,slat*9);view.draw_line(s,s+Vector2(cell.size.x*phase-2,0),Color("304e4b"),2.)
   # Vent blades visibly fold closed when the delivered warning is measured.
   var base=Vector2(p.x+direction*24,y)
   view.draw_line(base,base+Vector2(direction*24,(-20+40*float(row.closing))),color,4.)
  view.draw_line(p,Vector2(box.end.x if direction<0 else box.position.x,p.y),Color("728f80"),3.)
  view.draw_arc(p,32,-PI*.5,PI*.5,24,Color("e0bf83"),width)
  view._label(p+Vector2(-170,-165),("SECTION SEALED" if row.closing>=1 else "OCCUPIED SECTION")+(" · LAST OBSERVATION" if not row.live else ""),color,font)
 view.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 for marker in markers(view,sim,view.instrument_height):
  var box:Rect2=marker.rect;var color=Color("d9c28e");var label=marker.subject.name
  view.draw_line(marker.anchor,marker.anchor.clamp(box.position,box.end),Color(color,.5),1.5)
  view.draw_rect(box,Color(.025,.065,.075,.94));view.draw_rect(box,color,false,1)
  view.draw_string(ThemeDB.fallback_font,box.position+Vector2(8,view.feedback_font_size+6),label,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-16,view.feedback_font_size,color)
  view.draw_string(ThemeDB.fallback_font,box.position+Vector2(8,view.feedback_font_size*2+10),"ONE AUDIBLE ALARM" if marker.subject.site=="alarm" else "WARN / RECEIVE",HORIZONTAL_ALIGNMENT_LEFT,box.size.x-16,view.feedback_font_size,Color("92b1a4"))
 view.draw_set_transform(view.world_offset,0,Vector2.ONE*scale)
