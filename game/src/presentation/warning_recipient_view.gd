extends Control
# A measured recipient projection; announced routes never advance a hull fix.
const TEAL=Color("9acdbb")
const AMBER=Color("e3bd7c")
var arrival_data:Dictionary={}
static func status(sim)->Dictionary:
 return sim.warning_recipient_status() if sim!=null else {}
static func replaces_site(sim,site:Dictionary)->bool:
 return not status(sim).is_empty() and site.get("site_id","")=="warning_reply" and site.captured
static func subject(data:Dictionary,kind:String)->Dictionary:
 return {"kind":"objective","subkind":"warning_"+kind,"name":"WARNING RECIPIENT" if kind=="recipient" else "SERVICE GATE","pos":data.pos}
static func local_gate_subject(sim)->Dictionary:
 var info=status(sim)
 if info.is_empty() or not info.gate.known or info.gate.opened:return {}
 var craft=sim.units[sim.selected]
 if not craft.alive or craft.pos.distance_to(info.gate.pos)>60:return {}
 return subject(info.gate,"gate")
static func primary_subject(sim)->Dictionary:
 var local_gate=local_gate_subject(sim)
 if not local_gate.is_empty():return local_gate
 var info=status(sim)
 if info.is_empty() or not sim.units[sim.selected].alive or not info.informed or not info.recipient.known:return {}
 return subject(info.recipient,"recipient")
static func markers(view,sim,touch:float)->Array:
 var info=status(sim);var result=[]
 if info.is_empty():return result
 var occupied=view.ui_blocked_rects+view.own_craft_rects()+view.ship_instrument_rects()+view.contact_readout_rects()
 var bounds=Rect2(Vector2(12,view.instrument_top+12),view.size-Vector2(24,view.instrument_top+touch+30))
 var extent=Vector2(minf(touch*3.1,bounds.size.x),touch)
 for key in ["recipient","gate"]:
  var item=info[key]
  if not item.known:continue
  var anchor=view.screen_position(item.pos)
  if not Rect2(Vector2.ZERO,view.size).has_point(anchor):continue
  for offset in [Vector2(.9,-.5),Vector2(-4.,-.5),Vector2(-1.5,-1.7),Vector2(-1.5,.9),Vector2(.9,1.2),Vector2(-4.,1.2),Vector2(.9,-2.),Vector2(-5.,-.5),Vector2(2.,-.5)]:
   var box=Rect2((anchor+offset*touch).clamp(bounds.position,bounds.end-extent),extent)
   if occupied.any(func(rect):return rect.intersects(box.grow(5))):continue
   result.append({"rect":box,"anchor":anchor,"subject":subject(item,key),"text":("PASSAGE OPEN" if item.opened else "MANUAL RELEASE · AUDIBLE") if key=="gate" else (item.phase.to_upper()+" · %d%%"%roundi(item.hull)) if item.live else "LAST FIX · %ds"%floori(item.age)})
   occupied.append(box);break
 return result
static func pick(view,sim,point:Vector2,touch:float,bodies:bool=true)->Dictionary:
 for marker in markers(view,sim,touch):
  if marker.rect.has_point(point):return marker.subject
 if not bodies:return {}

 var info=status(sim)
 if info.is_empty():return {}
 # The gate control and hull are close: use their actual separate small bodies.
 for key in ["gate","recipient"]:
  var item=info[key]
  if item.known and point.distance_to(view.screen_position(item.pos))<=maxf(touch*.32,25*view.world_scale):return subject(item,key)
 return {}
static func touch_rects(view,sim,touch:float)->Array:
 var info=status(sim);var result=[]
 if info.is_empty():return result
 for marker in markers(view,sim,touch):result.append(marker.rect)
 for key in ["gate","recipient"]:
  var item=info[key]
  if item.known:
   var radius=maxf(touch*.32,25*view.world_scale)
   result.append(Rect2(view.screen_position(item.pos)-Vector2.ONE*radius,Vector2.ONE*radius*2))
 return result
static func refresh_subject(sim,current:Dictionary)->Dictionary:
 if current.get("subkind","")!="warning_recipient":return current
 var vessel=status(sim).get("recipient",{})
 return subject(vessel,"recipient") if vessel.get("known",false) else current
static func detail(sim,current:Dictionary)->String:
 var info=status(sim)
 if info.is_empty():return ""
 if current.get("subkind","")=="warning_gate":
  return "NORTH SERVICE GATE\n"+("PASSAGE OPEN" if info.gate.opened else "CLOSED · physical barrier")+"\n"+info.actions.gate.reason+"\nManual release: within 60m, clear line, below 2m/s. Audible 650m / 6s. A service credential carried by this received warning can operate the connected gate. No proof or kit is needed for the local release."
 var vessel=info.recipient;var lines=["WARNING RECIPIENT"]
 if vessel.known:lines.append("LOCAL HULL · %s · %d%%"%[vessel.phase.to_upper(),roundi(vessel.hull)] if vessel.live else "LAST FIX · %ds AGO · position and hull at last observation"%floori(vessel.age))
 lines.append(info.actions.depart.reason)
 lines.append("EXPOSED: no gate release, but a longer passage around the south breakwater into the eastern watch. SHELTERED: shorter north service passage behind cover; open its real gate first.")
 lines.append("Choose locally within 240m, clear link, below 12m/s. No automatic departure. Protect with terrain, distraction, EMP or torpedo as needed. Reacquire the actual arrival at the northeast pickup; Quietus recovery is separate.")
 return "\n".join(lines)
static func draw_world(view,sim)->void:
 var info=status(sim)
 if info.is_empty():return
 var scale=maxf(.01,view.world_scale);var font=maxi(4,roundi(view.feedback_font_size/scale))
 for course in info.courses:
  var previous=Vector2(1840,440);var color=Color(.75,.65,.4,.32) if course=="exposed" else Color(.4,.75,.65,.4)
  for point in info.courses[course]:view._dash(previous,point,color,1.2/scale);previous=point
 if info.gate.known:
  var point:Vector2=info.gate.pos
  view.draw_circle(point,18,Color("132e36"));view.draw_arc(point,18,0,TAU,24,TEAL if info.gate.opened else AMBER,2/scale)
  view.draw_line(point+Vector2(-10,-8),point+Vector2(10,8),TEAL if info.gate.opened else AMBER,2/scale)
  view._label(point+Vector2(-215,-35),"SERVICE OPEN" if info.gate.opened else "SERVICE GATE",TEAL if info.gate.opened else AMBER,font)
 var vessel=info.recipient
 if vessel.known:
  _hull(view,vessel.pos,vessel.angle,scale,not vessel.live,vessel.alive)
  view._label(vessel.pos+Vector2(-60,70),("RECIPIENT · %d%%"%roundi(vessel.hull)) if vessel.live else "LAST RECIPIENT FIX · %ds"%floori(vessel.age),TEAL if vessel.alive else Color("df896c"),font)
 view.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
 for marker in markers(view,sim,view.instrument_height):
  var box:Rect2=marker.rect;var fs=view.feedback_font_size
  view.draw_line(marker.anchor,marker.anchor.clamp(box.position,box.end),Color(TEAL,.5),1.5)
  view.draw_rect(box,Color(.025,.065,.075,.94));view.draw_rect(box,TEAL,false,1)
  view.draw_string(ThemeDB.fallback_font,box.position+Vector2(10,fs+8),marker.subject.name,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-20,fs,TEAL)
  view.draw_string(ThemeDB.fallback_font,box.position+Vector2(10,fs*2+14),marker.text,HORIZONTAL_ALIGNMENT_LEFT,box.size.x-20,fs,TEAL)
 view.draw_set_transform(view.world_offset,0,Vector2.ONE*scale)
static func _hull(view,at:Vector2,angle:float,scale:float,stale:bool=false,alive:bool=true):
 var points=PackedVector2Array()
 for p in [Vector2(38,0),Vector2(18,-17),Vector2(-28,-17),Vector2(-38,-8),Vector2(-38,8),Vector2(-28,17),Vector2(18,17),Vector2(38,0)]:points.append(at+p.rotated(angle))
 if not stale:view.draw_colored_polygon(points,Color("26484a") if alive else Color("3b2927"))
 view.draw_polyline(points,Color(TEAL,.48) if stale else TEAL if alive else Color("df896c"),2/scale)
 if alive:
  for x in [-15,3,18]:view.draw_circle(at+Vector2(x,0).rotated(angle),3.5,AMBER)
static func arrival(main):
 var info=status(main.sim)
 if info.is_empty() or not info.receipt:return
 var scene=load("res://src/presentation/warning_recipient_view.gd").new();scene.name="WarningArrival";scene.arrival_data=info
 scene.custom_minimum_size=Vector2(0,main.ui_touch_height*1.65);scene.mouse_filter=Control.MOUSE_FILTER_IGNORE;main.panel_box.add_child(scene)
 var deceased=not info.recipient.get("alive",true);var failed=main.sim.outcome!="won"
 var heading=("RECIPIENT LOST AFTER ARRIVAL" if deceased else "RECIPIENT ARRIVAL PREVIOUSLY RECEIVED") if failed else "RECIPIENT AT PICKUP"
 main._menu_text(heading+" · "+info.course.to_upper()+" COURSE\n"+("HISTORICAL ARRIVAL RECEIPT" if failed else "THIS CROSSING · ARRIVAL RECEIVED"),20)
 if failed:main._menu_text("The recipient was destroyed after its arrival was received. This dive grants no campaign outcome." if deceased else "The recipient reached the pickup. Quietus did not recover; this dive grants no campaign outcome.",17)
func _ready():resized.connect(queue_redraw)
func _draw():
 if arrival_data.is_empty():return
 draw_rect(Rect2(Vector2.ZERO,size),Color("081d27"))
 var scale=minf(size.x/560.,size.y/130.);draw_set_transform(size*.5,0,Vector2.ONE*scale)
 for side in [-1,1]:
  draw_colored_polygon(PackedVector2Array([Vector2(side*275,-70),Vector2(side*180,-70),Vector2(side*155,-25),Vector2(side*175,65),Vector2(side*275,70)]),Color("18363e"))
  draw_line(Vector2(-65,side*30),Vector2(65,side*30),TEAL,4)
 _hull(self,Vector2.ZERO,0,1,false,arrival_data.recipient.get("alive",true))
 draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
