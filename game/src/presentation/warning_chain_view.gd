extends RefCounted
# Known fixed plant hardware and own-body power only. No private machinery,
# hostile coordinates or inferred remote reception cross this seam.
static func context(sim)->Dictionary:
 return sim.warning_chain_context().duplicate(true) if sim!=null and sim.has_method("warning_chain_context") else {}
static func station_subject(sim,subject:Dictionary)->Dictionary:
 var info=context(sim)
 if info.is_empty() or subject.get("kind","") not in ["objective","plant"]:return {}
 if subject.get("kind","")=="plant":return subject.duplicate(true)
 var index=int(subject.get("index",-1));var sites=sim.observable_sites()
 if index<0 or index>=sites.size():return {}
 for station in info.stations:
  if sites[index].get("site_id","")==station.site_id:return {"kind":"plant","station":station.id,"name":station.name,"pos":station.pos}
 return {}
static func nearest_station(sim)->Dictionary:
 var info=context(sim)
 if info.is_empty():return {}
 var ordered=info.stations.duplicate();var pos:Vector2=sim.units[sim.selected].pos
 ordered.sort_custom(func(a,b):return pos.distance_squared_to(a.pos)<pos.distance_squared_to(b.pos))
 return {"kind":"plant","station":ordered[0].id,"name":ordered[0].name,"pos":ordered[0].pos}
static func action(sim,id:String)->Dictionary:
 for row in context(sim).get("actions",[]):
  if row.id==id:return row
 return {"id":id,"ready":false,"reason":"Plant unavailable"}
static func power_label(sim,info:Dictionary)->String:
 if info.power.source=="umbilical":return "POWER "+sim.units[info.power.unit].name.replace("DRONE ","")
 return "BACKUP" if info.power.source=="backup" else "POWER OFF"
static func proof(info:Dictionary)->String:
 var result=info.get("result",{})
 if result.get("proof","")=="local_receipt":return "LOCAL RECEIPT · WEST"
 if result.get("proof","")=="mast_transmission":return "MAST SENT · EXTERNAL UNKNOWN"
 return ("SERVICE" if info.output=="service" else "NORTH MAST")+" · NOT SENT" if not info.output.is_empty() else "OUTPUT UNSELECTED"
static func summary(sim)->String:
 var info=context(sim)
 return "PLANT "+power_label(sim,info)+" · "+proof(info) if not info.is_empty() else ""
static func connected(sim,unit:int)->bool:
 var info=context(sim)
 return not info.is_empty() and info.power.source=="umbilical" and info.power.unit==unit
static func task(sim,unit:int)->String:return "SHORE POWER · CONNECTED" if connected(sim,unit) else ""
static func detail(sim,station:String)->String:
 var info=context(sim)
 if info.is_empty():return ""
 var lines=[summary(sim),info.text,"LOCAL CONTROL · within 60m · clear line · settled below 2m/s"]
 if station=="inlet":lines.append("CONNECT supplies quiet shore power while this craft holds its retained course. DISCONNECT or an accepted movement order releases it. START BACKUP runs independently: one audible 900m / 6s start.")
 else:lines.append("Quietus or a fitted field sampler operates this panel. OPEN SERVICE opens the physical crosslink once; NORTH MAST preserves its current opening. Selecting an output does not send. Use SEND WARNING separately.")
 for id in (["connect","disconnect","backup"] if station=="inlet" else ["service","mast","send"]):
  var row=action(sim,id);lines.append({"connect":"CONNECT","disconnect":"DISCONNECT","backup":"START BACKUP","service":"OPEN SERVICE","mast":"NORTH MAST","send":"SEND WARNING"}[id]+" · "+row.reason)
 lines.append("CROSSLINK · "+("OPEN" if info.crosslink.opened else "CLOSED"))
 for output in info.outputs:
  lines.append(("SERVICE / EAST PANEL" if output.id=="service" else "NORTH MAST")+" · %dm / %ds · "%[roundi(output.radius),roundi(output.duration)]+("local receipt required" if output.proof=="local_receipt" else "transmission only; external reception unknown"))
 if not info.result.is_empty():lines.append("COMMISSIONED · "+proof(info)+". Power may be released; recover Quietus by either mouth.")
 return "\n".join(lines)
static func debrief_text(sim)->String:
 var info=context(sim)
 if info.is_empty():return ""
 return "PLANT RESULT / "+proof(info) if info.commissioned else "PLANT NOT COMMISSIONED / no warning result recovered"
static func replaces_site(sim,site:Dictionary)->bool:
 for station in context(sim).get("stations",[]):
  if station.site_id==site.get("site_id",""):return true
 return false
# Caller owns the world transform. This also accepts a plain planner Control.
static func draw_crosslink(canvas:CanvasItem,info:Dictionary,world_scale:float=1.)->void:
 if info.is_empty():return
 var gate:Rect2=info.crosslink.rect;var ink=Color("85bbae") if info.crosslink.opened else Color("d5a56b");var width=2./maxf(.01,world_scale)
 if info.crosslink.opened:
  for y in [gate.position.y,gate.end.y-12]:
   var leaf=Rect2(Vector2(gate.position.x,y),Vector2(gate.size.x,12));canvas.draw_rect(leaf,Color("213d40"));canvas.draw_rect(leaf,ink,false,width)
 else:
  canvas.draw_rect(gate,Color("243538"));canvas.draw_rect(gate,ink,false,width)
  for n in 6:
   var x=gate.position.x+(n+.5)*gate.size.x/6;canvas.draw_line(Vector2(x,gate.position.y+8),Vector2(x,gate.end.y-8),ink,width)
static func draw_world(view,sim)->void:
 var info=context(sim)
 if info.is_empty():return
 var scale=maxf(.01,view.world_scale);var width=2./scale;var powered=info.power.source!="off";var ink=Color("85bbae") if powered else Color("b29b7b")
 draw_crosslink(view,info,scale)
 view._label(info.crosslink.rect.get_center()+Vector2(-72,-90),"CROSSLINK "+("OPEN" if info.crosslink.opened else "CLOSED"),ink,14)
 for station in info.stations:
  var pos:Vector2=station.pos
  view.draw_rect(Rect2(pos-Vector2(25,21),Vector2(50,42)),Color("102630"));view.draw_rect(Rect2(pos-Vector2(25,21),Vector2(50,42)),ink,false,width)
  if station.id=="inlet":
   view.draw_arc(pos,13,0,TAU,24,ink,width);view.draw_line(pos-Vector2(0,19),pos+Vector2(0,19),ink,width)
   if info.power.source=="umbilical":view.draw_line(pos,sim.units[info.power.unit].pos,ink,width)
  else:
   for y in [-10,0,10]:view.draw_line(pos+Vector2(-15,y),pos+Vector2(15,y),ink,width)
  view._label(pos+Vector2(50,-5),station.name,ink,17)
 var mast={}
 for output in info.outputs:
  if output.id=="mast":mast=output
 if not mast.is_empty():
  var pos:Vector2=mast.origin;var mast_ink=Color("85bbae") if info.output=="mast" else Color("688a8c")
  view.draw_line(pos-Vector2(0,28),pos+Vector2(0,26),mast_ink,3./scale)
  for y in [-20,-8,4]:view.draw_line(pos+Vector2(-18,y),pos+Vector2(18,y),mast_ink,width)
  view.draw_arc(pos,34,-PI*.8,-PI*.2,20,mast_ink,width)
  view._label(pos+Vector2(45,-12),"NORTH MAST · TRANSMITTED / EXTERNAL UNKNOWN" if info.result.get("proof","")=="mast_transmission" else "NORTH MAST · SELECTED" if info.output=="mast" else "NORTH MAST",mast_ink,14)
 for pulse in sim.acoustic_feedback().pulses:
  if pulse.label not in ["BACKUP GENERATOR START","SERVICE SHUTTER","SERVICE WARNING","NORTH MAST WARNING"]:continue
  var radius=float(pulse.radius);var remaining=float(pulse.time);var duration=2. if pulse.label=="SERVICE SHUTTER" else 6.
  view.draw_arc(pulse.pos,34+(1-clampf(remaining/duration,0,1))*90,0,TAU,48,Color(.9,.68,.36,.6),1.5/scale)
  view._label(pulse.pos+Vector2(40,55),"%s · %dm · %ds"%[pulse.label,roundi(radius),ceili(remaining)],Color("dfbd7c"),14)
