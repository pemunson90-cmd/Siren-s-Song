extends RefCounted
# ARCH2 panel/world contract. The later world group retains the original
# order before Recipient and after Witness. Revert this PR to restore direct
# seams; legacy projections/drawing/input and all text/numbers stay unchanged.
static func applies(sim)->bool:return sim!=null
static func build_panel(hud)->void:
 var sim=hud.host.sim
 var concealed=status(sim)
 if concealed.get("known",false):
  hud.intent.text=summary(sim)+" · "+hud.intent.text
  hud.extra.concealed_attach.disabled=not concealed.actions.tow
  hud.extra.concealed_release.disabled=not concealed.actions.release
  hud.extra.concealed_seat.disabled=not concealed.actions.seats.any(func(p):return p.id==hud.subject.get("seat","") and p.ready)
  if hud.subject.get("subkind","")=="concealed" or hud.page=="inspect":hud.instrument_info.text=detail(sim,hud.subject)+"\n\n"+hud.instrument_info.text
static func draw(view)->void:draw_world(view,view.sim)
const TEAL=Color("8ad6c9")
const AMBER=Color("e3bd7c")
static func status(sim)->Dictionary:return sim.concealed_status() if sim!=null and sim.has_method("concealed_status") else {}
static func subjects(sim)->Array:
 var s=status(sim)
 if not s.get("known",false):return []
 var result=[{"kind":"objective","subkind":"concealed","name":"LISTENING FLOAT" if s.thread=="deep" else "COLLAPSED BUNKER SCREEN","pos":s.pos,"seat":""}]
 for seat in s.seats:result.append({"kind":"objective","subkind":"concealed","name":seat.name,"pos":seat.pos,"seat":seat.id})
 return result
static func pick(view,sim,point:Vector2,touch:float)->Dictionary:
 var candidates=subjects(sim);candidates.sort_custom(func(a,b):return point.distance_squared_to(view.screen_position(a.pos))<point.distance_squared_to(view.screen_position(b.pos)))
 for subject in candidates:
  if point.distance_to(view.screen_position(subject.pos))<=maxf(touch*.5,32*view.world_scale):return subject
 return {}
static func touch_rects(view,sim,touch:float)->Array:
 var result=[];var r=maxf(touch*.5,32*view.world_scale)
 for subject in subjects(sim):result.append(Rect2(view.screen_position(subject.pos)-Vector2.ONE*r,Vector2.ONE*r*2))
 return result
static func summary(sim)->String:
 var s=status(sim)
 if not s.get("known",false):return ""
 if s.receipt:return "SURVIVORS ACK RECEIVED" if s.thread=="deep" else "BUNKER ACK RECEIVED"
 if s.phase=="towing":return "QUIETUS TOW · 40 CRUISE / 26 SILENT · MOVING CABLE AUDIBLE"
 if s.phase=="seated":return "SEATED · RECEIVE THE LOCAL STATION ACK"
 if s.thread=="deep" and not s.connected:return "TRACE SEVERED · RECEIVE THE SURVIVORS ACK"
 return s.text+" · WITNESS ACCOUNT / ATTACH LOCAL TOW"
static func detail(sim,subject:Dictionary={})->String:
 var s=status(sim)
 if not s.get("known",false):return "Rescue the witness first."
 var lines=[s.account,"",s.text,s.actions.reason]
 for seat in s.seats:
  if subject.get("seat","").is_empty() or subject.seat==seat.id:lines.append(seat.name+" · "+seat.description)
 for seat in s.actions.seats:
  if seat.id==subject.get("seat",""):lines.append(seat.reason)
 lines.append("TOW ·40m/s CRUISE /26m/s SILENT · moving cable audible. The station’s first reply is audible1200m for2s through actual water paths. If missed, approach within local passive reach for quiet reception.")
 lines.append("Quietus tows. Drones can scout each approach, receive the station reply, protect the tow or carry the occupied witness independently. Release leaves the equipment in actual water for local reattachment. No finite tool is required.")
 if s.receipt:lines.append("RECEIVED LOCAL ACCOUNT · "+("The crew below reports trace current zero and opens its own shutter." if s.thread=="deep" else "The bunker watch comes out through the cleared mouth."))
 return "\n".join(lines)
static func draw_world(view,sim)->void:
 var s=status(sim)
 if not s.get("known",false):return
 var scale=maxf(.01,view.world_scale);var p:Vector2=s.pos
 # The spoken account supplies charted work sites. Remote machinery changes
 # are drawn only from local sensing, never the simulation's private phase.
 for seat in s.seats:
  view.draw_arc(seat.pos,32,0,TAU,24,Color("527e7d"),1.5/scale)
  view._label(seat.pos+Vector2(0,-48),seat.name,TEAL,13)
 if s.thread=="deep":
  if s.connected:view.draw_polyline(PackedVector2Array([p,p+Vector2(60,-45),Vector2(2180,800)]),Color("a38d63"),1.5/scale)
  else:
   view.draw_line(Vector2(1840,1040),Vector2(1880,1010),Color("746857"),1.5/scale)
   view.draw_circle(Vector2(1840,1040),7,AMBER)
  if sim.mission.structures.has(preload("res://src/simulation/concealed_harbour.gd").TRACE_BLOCK):
   view.draw_rect(preload("res://src/simulation/concealed_harbour.gd").TRACE_BLOCK,Color("354c50"))
   view.draw_line(Vector2(1760,1080),Vector2(1920,1080),AMBER,3/scale)
  view.draw_circle(p,19,Color("26424a"));view.draw_arc(p,19,0,TAU,24,AMBER,2/scale)
  view.draw_line(p+Vector2(0,-30),p+Vector2(0,30),TEAL,2/scale)
 else:
  if sim.mission.structures.has(preload("res://src/simulation/concealed_harbour.gd").SCREEN):
   view.draw_rect(preload("res://src/simulation/concealed_harbour.gd").SCREEN,Color("4b5451"))
   for y in range(950,1200,25):view.draw_line(Vector2(1980,y),Vector2(2040,y+18),AMBER,2/scale)
  else:
   view.draw_rect(Rect2(p-Vector2(22,12),Vector2(44,24)),Color("314951"));view.draw_rect(Rect2(p-Vector2(22,12),Vector2(44,24)),AMBER,false,2/scale)
  if s.placement=="baffle":
   view.draw_rect(Rect2(2040,940,200,60),Color("365455"))
   for x in range(2050,2240,24):view.draw_line(Vector2(x,944),Vector2(x+14,994),TEAL,2/scale)
 if s.phase=="towing":
  view.draw_polyline(PackedVector2Array([p]+sim.mission.concealed_harbour.trail+[sim.units[0].pos]),AMBER,1.5/scale)
 view._label(p+Vector2(0,46),"TOW · "+("LISTENING FLOAT" if s.thread=="deep" else "BUNKER SCREEN"),AMBER,14)
 # Received acknowledgement establishes the station response; close samples
 # additionally show its local open/closed machinery and occupied bays.
 var seen=s.station_seen
 if seen.is_empty():return
 var station:Vector2=s.reply_pos
 if s.thread=="shelf":
  for x in [2260,2310,2360]:
   var bay=Vector2(x,916)
   view.draw_rect(Rect2(bay-Vector2(22,18),Vector2(44,36)),Color("1e4b4e"))
   view.draw_rect(Rect2(bay-Vector2(17,12),Vector2(34,24)),Color("76aaa0"),false,2/scale)
   # Small occupants remain deliberately ambiguous pressure-world silhouettes.
   for offset in [-7,7]:
    view.draw_circle(bay+Vector2(offset,-3),3,Color("c5d6b5"))
    view.draw_line(bay+Vector2(offset,0),bay+Vector2(offset,9),Color("c5d6b5"),2/scale)
   view.draw_line(bay+Vector2(0,18),Vector2(x,947),TEAL,2/scale)
 view.draw_rect(Rect2(station+Vector2(-45,-23),Vector2(90,46)),Color("18363e"))
 for x in [-28,0,28]:
  view.draw_circle(station+Vector2(x,0),6,TEAL if seen.open else Color("66736b"))
 if seen.open:
  for side in [-1,1]:view.draw_line(station+Vector2(side*50,-25),station+Vector2(side*65,-42),TEAL,3/scale)
 else:view.draw_line(station+Vector2(-45,-25),station+Vector2(45,-25),AMBER,3/scale)
 view._label(station+Vector2(0,-65),("SEALED SHUTTER" if s.thread=="deep" else "BUNKER MOUTH")+(" · OPEN" if seen.open else " · LOCAL FIX"),TEAL,13)
static func debrief(main)->void:
 var s=status(main.sim)
 if not s.get("known",false):return
 main._menu_text(summary(main.sim),20)
 if main.sim.outcome=="won" and s.receipt:main._menu_text("THIS DIVE · "+("Surface trace physically disconnected; the crew below replied." if s.thread=="deep" else "Bunker mouth cleared · "+("SHORT SERVICE APPROACH" if s.placement=="service" else "SHELTERED LOWER APPROACH"))+"\nThe ending preserves the first committed campaign consequence.",17)

static func refresh_subject(sim,subject:Dictionary)->Dictionary:
 if subject.get("subkind","")!="concealed" or not subject.get("seat","").is_empty():return subject
 var s=status(sim)
 if not s.get("known",false):return subject
 var result=subject.duplicate(true);result.pos=s.pos;return result
