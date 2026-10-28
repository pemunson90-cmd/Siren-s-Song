extends RefCounted
# Presentation-only chart, warning and photographic cues. Revert by disabling
# the existing settings. Standard calls retain their original arguments/output.
const Table=preload("res://src/presentation/accessibility/cue_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
static func color(role:String,standard:Color)->Color:
 return Table.SAFE.get(role,standard) if Table.ENABLED and Settings.current.get("safe_palette",false) else standard
static func film_tag(left:int,cap:int)->String:
 var tag="FILM %d/%d"%[left,cap]
 if left==0:return tag+" EMPTY"
 if left<=preload("res://src/audio/photo_audio/photo_cue_table.gd").LOW_FILM:return tag+" LOW"
 return tag
static func ring(ci,center:Vector2,radius:float,color_value:Color,width:float,role:String)->void:
 var pattern=Table.PATTERNS[role]
 for k in 96:
  if k%int(pattern[1])<int(pattern[0]):ci.draw_arc(center,radius,TAU*k/96.,TAU*(k+1)/96.,4,color_value,width)

static func safe()->bool:
 return Table.ENABLED and Settings.current.get("safe_palette",false)
static func high_contrast()->bool:
 return Settings.current.get("high_contrast",false)
static func motion_phase(value:float)->float:
 return 0. if Settings.reduced_motion() else value
static func pulse(standard:float,steady:float)->float:
 return steady if Settings.reduced_motion() else standard
static func stroke(width:float)->float:
 return width*1.5 if high_contrast() else width
static func chart_color(role:String,standard:Color)->Color:
 var result=color(role,standard)
 if high_contrast():result=result.lightened(.25);result.a=maxf(result.a,.85)
 return result
static func marker(ci,at:Vector2,radius:float,role:String,width:float=2.)->void:
 if not safe():return
 # Opaque dark backing keeps semantic strokes readable over regional water.
 ci.draw_arc(at,radius,0.,TAU,96,Color("07131b"),stroke(width)+3.)
 ring(ci,at,radius,chart_color(role,Color.WHITE),stroke(width),role)
static func course(ci,parts:Array,scale:float,selected:bool)->void:
 # Preserve confirmed/unsurveyed geometry and solid/dashed distinction.
 var legacy=preload("res://src/presentation/earned_chart_view.gd")
 if not safe() and not high_contrast():legacy.draw_course(ci,parts,scale,selected);return
 for part in parts:
  var role="route" if part.confirmed else "warning"
  var tint=chart_color(role,legacy.CONFIRMED if part.confirmed else legacy.TENTATIVE)
  if not selected:tint.a=.65
  var width=stroke(2.)/maxf(scale,.01)
  ci.draw_line(part.from,part.to,Color("07131b"),width+3./maxf(scale,.01))
  if part.confirmed:ci.draw_line(part.from,part.to,tint,width)
  else:ci.draw_dashed_line(part.from,part.to,tint,width,18./maxf(scale,.01)*.55)
static func legend()->String:
 return "\nChart: threat long dashes; received dots; route lines (dashed = unsurveyed); warning short dashes." if safe() else ""
