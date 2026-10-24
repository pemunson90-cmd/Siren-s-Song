extends Control
# Read-only, receiver-earned lock cues. Never inspect the live enemy roster.
static func frames(sim)->Array:
 var result:Array=[]
 if sim.units.is_empty() or not sim.units[0].alive or not sim.outcome.is_empty():return result
 for id in sim.contacts:
  var c=sim.contacts[id];var age=sim.elapsed-float(c.time)
  if age<0 or age>=.3 or c.get("target",-1)!=0 or c.get("recipient_target",false):continue
  if preload("res://src/simulation/observed_stun.gd").remaining(c,sim.elapsed)>0:continue
  if c.get("mode","")!="LOCKING" or c.get("lock",0)<=0 or c.lock>=4:continue
  if not preload("res://src/simulation/depth_bands.gd").sight(sim,c,sim.units[0]):continue
  result.append({"id":id,"pos":c.pos,"progress":c.lock/4.,"remaining":4.-c.lock})
 result.sort_custom(func(a,b):return a.progress>b.progress)
 return result
var host
var locks:Array=[]
var episodes=0
var show_hint=false
var previous_clock=-1.
var previous_ids:Array=[]
var banner=Rect2()
func _init():mouse_filter=Control.MOUSE_FILTER_IGNORE
func update_state(sim,active:bool):
 if sim.elapsed<previous_clock:previous_ids.clear()
 previous_clock=sim.elapsed
 locks=frames(sim) if active else []
 var ids=locks.map(func(frame):return frame.id)
 if ids.any(func(id):return id not in previous_ids):
  episodes+=1;show_hint=episodes<=3
 if locks.is_empty():show_hint=false
 previous_ids=ids
 visible=not locks.is_empty();queue_redraw()
func refresh(owner):
 host=owner;position=Vector2.ZERO;size=host.size
 update_state(host.sim,host.screen=="mission")
 var h=host.ui_touch_height
 var width=minf(size.x-32,h*5.)
 banner=Rect2(Vector2((size.x-width)/2,h+24),Vector2(width,h*(1.55 if show_hint else .85)))
func marker(point:Vector2)->Vector2:
 return point.clamp(Vector2.ONE*26,size-Vector2.ONE*26)
func _draw():
 if host==null or locks.is_empty():return
 var h=host.ui_touch_height;var font=ThemeDB.fallback_font
 var warning=preload("res://src/presentation/accessibility/palette.gd").color("warning",Color("ffb18b"));var ink=Color("160b13")
 for frame in locks:
  var source=marker(host.ocean.screen_position(frame.pos))
  var target=marker(host.ocean.screen_position(host.sim.units[0].pos))
  draw_line(source,target,Color(.04,.02,.03,.95),7,true)
  draw_dashed_line(source,target,warning,3,12,true)
  draw_circle(source,25,ink)
  draw_arc(source,25,-PI/2,-PI/2+TAU*frame.progress,40,warning,5,true)
  draw_string(font,source+Vector2(-15,6),"S%d"%(int(frame.id)+1),HORIZONTAL_ALIGNMENT_LEFT,-1,18,warning)
 draw_style_box(_panel(),banner)
 var radius=h*.26;var at=banner.position+Vector2(h*.45,h*.42)
 draw_arc(at,radius,0,TAU,40,Color(.4,.25,.24),5,true)
 draw_arc(at,radius,-PI/2,-PI/2+TAU*(1.-locks[0].progress),40,warning,7,true)
 var font_size=maxi(18,roundi(h*.25))
 draw_string(font,banner.position+Vector2(h*.9,h*.5),"S%d LOCK · %.1fs"%[int(locks[0].id)+1,locks[0].remaining],HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,warning)
 if show_hint:
  draw_string(font,banner.position+Vector2(12,h),"Break sight with cover.",HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE)
  draw_string(font,banner.position+Vector2(12,h*1.35),"DISRUPT or torpedo impact interrupts.",HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(16,roundi(h*.21)),Color.WHITE)
func _panel()->StyleBoxFlat:
 var panel=StyleBoxFlat.new();panel.bg_color=Color(.06,.015,.025,.97);panel.border_color=preload("res://src/presentation/accessibility/palette.gd").color("warning",Color("ffb18b"));panel.set_border_width_all(2);panel.set_corner_radius_all(10)
 return panel
