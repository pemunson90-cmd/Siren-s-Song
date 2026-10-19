extends RefCounted
# World-space manufactured scenery and chart marks. The caller supplies only
# operation_context(): charted gate geometry/phase and the pilot's own history.
# No simulator, contacts, source positions, clocks or hidden response state.
const METAL=Color("263f44")
const PLATE=Color("152c33")
const EDGE=Color("6e9293")
const AMBER=Color("d5a15e")
const TEAL=Color("72c9c3")

static func draw(view,public_context:Dictionary)->void:
 var scale=maxf(.01,float(view.world_scale))
 for gate in public_context.get("gates",[]):
  if not gate is Dictionary or not gate.get("rect") is Rect2 or not gate.get("opened") is bool:continue
  var rect:Rect2=gate.rect
  if not rect.position.is_finite() or not rect.size.is_finite() or rect.size.x<=0 or rect.size.y<=0:continue
  if gate.opened:_open(view,rect,scale)
  else:_closed(view,rect,scale)
 var sector=public_context.get("transmission_region")
 if sector is Rect2 and sector.size.x>0 and sector.size.y>0:
  _sector(view,sector,scale)
  var origin=public_context.get("transmission_origin")
  if origin is Vector2 and origin.is_finite() and sector.has_point(origin):_origin(view,origin,scale)

static func _closed(view,r:Rect2,s:float)->void:
 # Full caisson footprint is solid. All relief, locks and edges stay inside it;
 # the two leaves withdraw sideways beneath the existing basalt when opened.
 view.draw_rect(r,METAL)
 var inset=minf(r.size.x,r.size.y)*.045
 var face=r.grow(-inset)
 view.draw_rect(face,Color("0c1e26"))
 var seam=r.get_center().x;var gap=r.size.x*.016
 var leaf_w=(face.size.x-gap)*.5
 for side in 2:
  var leaf=Rect2(face.position+Vector2(side*(leaf_w+gap),0),Vector2(leaf_w,face.size.y))
  view.draw_rect(leaf,PLATE if side==0 else Color("1c353c"))
  # Inset bevels make a pressure housing rather than another outlined UI card.
  view.draw_colored_polygon(PackedVector2Array([leaf.position,leaf.position+Vector2(leaf.size.x,0),leaf.position+Vector2(leaf.size.x-inset,inset),leaf.position+Vector2(inset,inset)]),Color("476267"))
  view.draw_line(leaf.position+Vector2(inset,inset),Vector2(leaf.position.x+inset,leaf.end.y-inset),Color("35535b"),minf(inset*.4,2./s))
 view.draw_line(Vector2(seam,r.position.y+inset*2),Vector2(seam,r.end.y-inset*2),Color("071820"),maxf(1.,r.size.x*.012))
 var detail=minf(r.size.x,r.size.y)*s>=72
 if detail:
  for row in 4:
   var y=r.position.y+r.size.y*(.22+row*.18)
   for side in [-1,1]:
    view.draw_line(Vector2(seam+side*r.size.x*.09,y),Vector2(seam+side*r.size.x*.39,y),Color("4b6466"),1.2/s)
  # Opposed short hydraulic stays visibly lock the leaves together.
  for side in [-1,1]:
   var a=r.get_center()+Vector2(side*r.size.x*.34,-r.size.y*.25)
   var b=r.get_center()+Vector2(side*r.size.x*.07,r.size.y*.18)
   view.draw_line(a,b,Color("0b1b21"),7./s)
   view.draw_line(a,b,Color("8e8971"),3./s)
   view.draw_circle(a,minf(inset*.65,5./s),EDGE)
   view.draw_circle(b,minf(inset*.65,5./s),AMBER)
 # Small amber locking lamps remain readable at chart scale, never a halo.
 for x in [.16,.84]:
  for y in [.09,.91]:
   var lamp=r.position+r.size*Vector2(x,y)
   view.draw_rect(Rect2(lamp-Vector2.ONE*inset*.3,Vector2.ONE*inset*.6),AMBER)
 _label(view,r.position+Vector2(0,-18./s),"SLUICE CLOSED",AMBER,s)

static func _open(view,r:Rect2,s:float)->void:
 # The leaves are below/beside the charted passage, not new solid jambs.
 # Thin floor guides and broken threshold marks are traversable seabed detail.
 var tint=Color(.35,.65,.65,.48)
 for side in [.08,.92]:
  var x=r.position.x+r.size.x*side
  view.draw_line(Vector2(x,r.position.y+r.size.y*.16),Vector2(x,r.end.y-r.size.y*.16),tint,1./s)
 for end in [r.position.y,r.end.y]:
  for side in [.08,.78]:
   var x=r.position.x+r.size.x*side
   view.draw_line(Vector2(x,end),Vector2(x+r.size.x*.14,end),tint,1./s)
 # Open chevrons indicate through-water without drawing a fictitious corridor.
 var center=r.get_center();var h=minf(r.size.x,r.size.y)*.09
 for sign_y in [-1,1]:
  var tip=center+Vector2(0,sign_y*r.size.y*.23)
  view.draw_line(tip+Vector2(-h,-sign_y*h),tip,tint,1.2/s)
  view.draw_line(tip+Vector2(h,-sign_y*h),tip,tint,1.2/s)
 _label(view,r.position+Vector2(0,-18./s),"SLUICE OPEN",TEAL,s)

static func _sector(view,r:Rect2,s:float)->void:
 # Cartographic corner brackets are not walls, a sensor range or safe water.
 var length=minf(64.,minf(r.size.x,r.size.y)*.12)
 var tint=Color(.43,.68,.69,.36)
 for corner in [r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]:
  var direction=Vector2(1 if corner.x==r.position.x else -1,1 if corner.y==r.position.y else -1)
  view.draw_line(corner,corner+Vector2(length*direction.x,0),tint,1./s)
  view.draw_line(corner,corner+Vector2(0,length*direction.y),tint,1./s)
 _label(view,r.position+Vector2(0,-18./s),"TRANSMISSION SECTOR",Color(.43,.68,.69,.7),s)

static func _origin(view,p:Vector2,s:float)->void:
 # A historical stencil at the actual attempted origin, never a live beacon,
 # successful-delivery certificate, response marker or invented range ring.
 var radius=7./s
 for side in [-1,1]:
  view.draw_line(p+Vector2(side*radius,-radius*.55),p+Vector2(side*radius,radius*.55),AMBER,1.4/s)
  view.draw_line(p+Vector2(-radius*.55,side*radius),p+Vector2(radius*.55,side*radius),AMBER,1.4/s)
 _label(view,p+Vector2(14./s,-14./s),"OWN SEND ORIGIN",AMBER,s)

static func _label(view,p:Vector2,text:String,color:Color,s:float)->void:
 view._label(p,text,color,maxi(1,roundi(float(view.feedback_font_size)/s)))
