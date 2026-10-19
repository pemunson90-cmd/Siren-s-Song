extends RefCounted
# An analytical receiver display, not a photograph or a live view of hidden
# hulls. It uses the already known site and public received samples only.
static func applies(mission:int,objective:Dictionary)->bool:
 return mission>=6 and (objective.get("kind","") in ["receiver","uplink","transmitter"] or (mission==7 and objective.get("site_id","")=="rendezvous"))
static func title()->String:return "RECEIVER · ANALYTICAL"
static func draw(view,picture:Rect2,readings:Array,receiver:int)->void:
 var font=ThemeDB.fallback_font;var ink=Color("8cdcd3");var muted=Color("4d7c83")
 var fs=mini(view.receiver_font_size,16);var center=picture.position+picture.size*Vector2(.27,.55)
 var radius=minf(picture.size.y*.28,picture.size.x*.16)
 view.draw_arc(center,radius,0,TAU,48,muted,1.5)
 for n in 8:
  var direction=Vector2.from_angle(n*TAU/8.)
  view.draw_line(center+direction*(radius-7),center+direction*(radius+7),muted,1.)
 var own=readings.filter(func(r):return r.receiver==receiver)
 for reading in own:
  if reading.direction.length_squared()<.001:continue
  var angle:float=reading.direction.angle()
  view.draw_arc(center,radius*.85,angle-reading.uncertainty,angle+reading.uncertainty,16,ink,2.)
  view.draw_line(center,center+reading.direction*radius*.7,ink,1.5)
 var column=picture.position+Vector2(picture.size.x*.53,fs*2.5)
 view.draw_string(font,column,"RECEIVED ARRIVAL" if not own.is_empty() else "LISTENING",HORIZONTAL_ALIGNMENT_LEFT,-1,fs,ink)
 view.draw_string(font,column+Vector2(0,fs*1.6),"Uncertain direction",HORIZONTAL_ALIGNMENT_LEFT,-1,fs,muted)
 view.draw_string(font,column+Vector2(0,fs*3.2),"No hull image / range",HORIZONTAL_ALIGNMENT_LEFT,-1,fs,muted)

static func draw_transmitter(view,picture:Rect2,feedback:Dictionary)->void:
 var ink=Color("e0bf83");var fs=mini(view.receiver_font_size,16);var center=picture.position+picture.size*Vector2(.25,.55)
 var radius=minf(picture.size.y*.24,picture.size.x*.14)
 view.draw_circle(center,radius,Color("102630"))
 view.draw_arc(center,radius,-PI*.8,PI*.8,32,ink,2.)
 view.draw_circle(center,4.,ink)
 var column=picture.position+Vector2(picture.size.x*.47,fs*2.3)
 for line in ["OWN TRANSMITTER", "Hold %ds"%roundi(feedback.duration),"Pulse on completion", "Reception unknown"]:
  view.draw_string(ThemeDB.fallback_font,column,line,HORIZONTAL_ALIGNMENT_LEFT,-1,fs,ink);column.y+=fs*1.6
