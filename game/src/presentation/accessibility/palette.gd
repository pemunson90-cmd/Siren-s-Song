extends RefCounted
# Narrow consumers: lock warning and photographic price/range cues. Standard
# colors remain supplied by their original renderer; no global art recoloring.
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
