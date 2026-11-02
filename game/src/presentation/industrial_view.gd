extends RefCounted
# ARCH2 activity-panel/world contract. Only the existing display refresh
# and drawing dispatch move; context, input and all industrial rules stay owned.
# Revert this PR to restore direct HUD/ocean calls at their original slots.
static func applies(sim)->bool:return sim!=null
static func build_panel(hud)->void:
 var sim=hud.host.sim
 var industry=sim.choir_context()
 if not industry.is_empty():
  for action in industry.actions:
   hud.extra["choir_"+action].disabled=not industry.actions[action].ready;hud.extra["choir_"+action].tooltip_text=industry.actions[action].reason
  hud.extra.choir_route.disabled=targets(sim).is_empty()
  if hud.page=="choir":hud.instrument_info.text=industry.detail+"\n"+sim.message
const CYAN=Color("9acdcc")
const AMBER=Color("dbbb82")
static func targets(sim)->Array:
 var info=sim.choir_context();var result=[]
 if info.is_empty():return result
 for site in info.sites:result.append({"kind":"objective","subkind":"choir","name":site.id.to_upper()+" / "+("OPEN" if site.done else "LOCAL WORK"),"target_id":"site:"+site.id,"pos":site.pos,"band":site.band})
 if not info.load.is_empty():result.append({"kind":"objective","subkind":"choir","name":info.load.name+" / "+info.load.state.to_upper(),"target_id":"load","pos":info.load.pos,"band":info.load.band})
 var a=info.artifact
 if not a.is_empty() and a.state in ["site","wreck"] and sim.visible(a.pos,a.band):result.append({"kind":"objective","subkind":"choir","name":a.id.replace("_"," ").to_upper(),"target_id":"artifact:"+a.id,"pos":a.pos,"band":a.band})
 return result
static func target_at(sim,pos:Vector2,owner:String="")->Dictionary:
 for target in targets(sim):
  if target.pos==pos and (owner.is_empty() or target.target_id==owner):return target
 return {}
static func pick(view,sim,point:Vector2,touch:float)->Dictionary:
 for target in targets(sim):
  if point.distance_to(view.screen_position(target.pos))<maxf(touch*.38,24.*view.world_scale):return target
 return {}
static func touch_rects(view,sim,touch:float)->Array:
 var result=[]
 for target in targets(sim):
  var radius=maxf(touch*.38,24.*view.world_scale);result.append(Rect2(view.screen_position(target.pos)-Vector2.ONE*radius,Vector2.ONE*radius*2))
 return result
static func draw(view,sim=null):
 if sim==null:sim=view.sim
 var info=sim.choir_context()
 if info.is_empty():return
 for site in info.sites:
  var color=CYAN if site.done else AMBER;var pos:Vector2=site.pos
  view.draw_rect(Rect2(pos-Vector2(24,18),Vector2(48,36)),Color("19353e"));view.draw_rect(Rect2(pos-Vector2(24,18),Vector2(48,36)),color,false,2.)
  for side in [-1,1]:view.draw_line(pos+Vector2(side*25,0),pos+Vector2(side*(50 if site.done else 32),-25),color,4.)
  view._label(pos+Vector2(35,-25),site.id.to_upper()+" / "+("OPEN" if site.done else "LOCAL"),color,13,target_at(sim,pos,"site:"+site.id))
 if not info.load.is_empty():
  var body=info.load;var pos:Vector2=body.pos;var color=CYAN if body.age<.3 else Color("687b7c")
  if "BALLAST" in body.name or "COUNTERWEIGHT" in body.name:
   view.draw_colored_polygon(PackedVector2Array([pos+Vector2(-32,-22),pos+Vector2(25,-22),pos+Vector2(38,0),pos+Vector2(25,22),pos+Vector2(-32,22)]),Color("50646b"))
  else:
   view.draw_rect(Rect2(pos-Vector2(48,20),Vector2(96,40)),Color("29454e"));view.draw_rect(Rect2(pos-Vector2(48,20),Vector2(96,40)),color,false,3.)
   for x in [-25,0,25]:view.draw_rect(Rect2(pos+Vector2(x,-10),Vector2(8,8)),color)
  view.draw_arc(pos,42,0,TAU,24,color,1.5)
  # 119: observed motion, escort hold, last fix or confirmed arrival at the load.
  var tag=preload("res://src/presentation/work_task/work_task.gd").load_tag(sim)
  view._label(pos+Vector2(50,35),body.name+" / "+(tag if not tag.is_empty() else body.state.to_upper() if body.age<.3 else "LAST FIX %ds"%int(body.age)),color,maxi(13,roundi(view.feedback_font_size/maxf(view.world_scale,.01))),target_at(sim,pos,"load"))
 for patch in sim.Industry.patches(sim):
  view.draw_circle(patch.pos,patch.radius,Color(.9,.35,.16,.10));view.draw_arc(patch.pos,patch.radius,0,TAU,40,Color("e79a60"),2.)
  view._label(patch.pos+Vector2(10,-15),"PRESSURE / %.1fs"%patch.remaining,AMBER,13)
