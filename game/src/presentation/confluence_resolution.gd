extends Control
# A recovery scene, composed from the operation's recovered public consequence.
# It never completes a mission, writes progression, or predicts the final ending.
const World=preload("res://src/presentation/confluence_world.gd")
const QUIETUS=preload("res://assets/craft/quietus.png")
var consequence:Dictionary={}
var phase=0.
var host
var heading:Label
var caption:Label
var actions:HBoxContainer
var art_rect=Rect2()
var touch_height=0.

static func recovery(data:Dictionary,units:Array,committed_route:String="")->Dictionary:
 var route=data.get("route","")
 if route not in ["concealed","overt"] or not data.get("facts",{}).has("confluence_packet"):return {}
 var result=data.duplicate(true)
 result["title"]="CONCEALED RECOVERY" if route=="concealed" else "WARNING PASSAGE"
 result["story"]="The living dispatch is aboard. Quietus chose the concealed passage; the witness store is now available." if route=="concealed" else "The living dispatch is aboard. Quietus chose the warning passage; the next operation will send it and listen for an answer."
 if committed_route in ["concealed","overt"] and committed_route!=route:
  result.story="The living dispatch is aboard. This replay used the %s passage; your campaign continues to %s."%["concealed" if route=="concealed" else "warning","The Concealed Record" if committed_route=="concealed" else "Open Warning"]
 result["service_known"]=data.get("service_opened",false) or data.get("facts",{}).has("confluence_repeater")
 result["service"]=("The cross-island sluice stands opened. Your motor run left a passage through the basalt." if data.get("service_opened",false) else "The cross-island sluice remains shut. Quietus returned around the island.") if result.service_known else ""
 if result.service_known:
  result.story=result.story.replace("The living dispatch is aboard.","The living dispatch is aboard; the service sluice stands open." if data.get("service_opened",false) else "The living dispatch is aboard; you left the service sluice shut.")
 result["drones"]=[]
 for id in range(1,units.size()):
  if units[id].get("alive",false):result.drones.append(id)
 return result

static func present(main)->bool:
 if not main.sim.has_method("confluence_resolution"):return false
 var data=recovery(main.sim.confluence_resolution(),main.sim.units,main.expedition.get("facts",{}).get("confluence_route",""))
 if data.is_empty():return false
 var scene=load("res://src/presentation/confluence_resolution.gd").new()
 scene.name="ConfluenceResolution";scene.consequence=data;scene.host=main
 main.add_child(scene);scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 main.menu.hide();main.hud.hide()
 return true

func _ready()->void:
 clip_contents=true;mouse_filter=Control.MOUSE_FILTER_STOP
 texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
 heading=Label.new();heading.text=consequence.get("title","");add_child(heading)
 caption=Label.new();caption.text=consequence.get("story","");caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;add_child(caption)
 actions=HBoxContainer.new();add_child(actions)
 if host!=null:
  for next in preload("res://src/campaign/expedition_campaign.gd").continuations(host.expedition,11):
   _action("CONTINUE",func():host._briefing(next),"next_expedition")
  if not host.recovered_evidence.is_empty():_action("FIELD RECORD",func():host._evidence_gallery(0),"evidence")
  _action("RETRY",func():host._briefing(11),"retry")
  _action("ARCHIVE",host._show_campaign,"back")
 resized.connect(_layout_scene);_layout_scene()
func _action(text:String,callback:Callable,action:String)->void:
 var button=host._button(actions,text,callback,action)
 button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
func _layout_scene()->void:
 if heading==null or caption==null or actions==null:return
 touch_height=host.ui_touch_height if host!=null else 48.
 var margin=maxf(24.,touch_height*.35);var gap=maxf(12.,touch_height*.14)
 heading.add_theme_font_size_override("font_size",roundi(touch_height*.36))
 heading.add_theme_color_override("font_color",Color("a2c6c4"))
 heading.position=Vector2(margin,margin);heading.size=Vector2(size.x-margin*2.,touch_height*.55)
 caption.add_theme_font_size_override("font_size",roundi(touch_height*.29))
 caption.size=Vector2(size.x-margin*2.,0)
 var text_height=caption.get_minimum_size().y
 var footer_height=text_height+touch_height+gap+margin
 caption.position=Vector2(margin,size.y-footer_height)
 actions.add_theme_constant_override("separation",roundi(gap))
 actions.position=Vector2(margin,size.y-margin-touch_height)
 actions.size=Vector2(size.x-margin*2.,touch_height)
 for button in actions.get_children():
  button.custom_minimum_size.y=touch_height;button.add_theme_font_size_override("font_size",roundi(touch_height*.28))
 art_rect=Rect2(0,heading.position.y+touch_height*.8,size.x,maxf(100.,caption.position.y-gap-heading.position.y-touch_height*.8))
 queue_redraw()
func _process(dt:float)->void:
 if host!=null and not is_equal_approx(touch_height,host.ui_touch_height):_layout_scene()
 phase+=dt;queue_redraw()
func _draw()->void:
 if consequence.is_empty() or size.x<1 or size.y<1:return
 draw_rect(Rect2(Vector2.ZERO,size),Color("06151e"))
 # This authored aftermath looks back from the actual recovered passage. It is
 # deliberately a scene, with no unearned tactical chart, contacts or new facts.
 var area=art_rect if art_rect.has_area() else Rect2(Vector2.ZERO,size)
 var scale=minf(area.size.x/800.,area.size.y/300.)
 var offset=area.position
 var width=area.size.x/scale;var height=area.size.y/scale
 var proportions=Vector2(width/800.,height/300.)
 draw_set_transform(offset,0,Vector2.ONE*scale)
 for n in ceili(height/22.)+1:
  var y=20.+n*22.
  draw_line(Vector2(0,y),Vector2(width,y-32),Color(.12,.29,.33,.10),1.)
 var concealed=consequence.route=="concealed"
 # The factory is a remembered acquired landmark. Its core remains distant;
 # no departing hull or alien response is invented by the recovery animation.
 draw_set_transform(offset+Vector2(width*.65,14)*scale,-.12,Vector2.ONE*scale*.42)
 World._factory(self,Rect2(-340,-90,680,260),1.)
 draw_set_transform(offset,0,Vector2.ONE*scale)
 _cliff(_scaled(PackedVector2Array([Vector2(-30,-20),Vector2(360,-20),Vector2(325,25),Vector2(225,60),Vector2(215,108),Vector2(120,144),Vector2(80,226),Vector2(-30,330)]),proportions),true)
 _cliff(_scaled(PackedVector2Array([Vector2(700,-20),Vector2(830,-20),Vector2(830,330),Vector2(645,330),Vector2(610,255),Vector2(651,204),Vector2(633,137),Vector2(715,93)]),proportions),false)
 # Concealed recovery carries one small amber memory. Overt recovery has an
 # amber channel architecture ahead; it has not yet transmitted a warning.
 if not concealed:
  for x in [width*.23,width*.75]:
   draw_colored_polygon(PackedVector2Array([Vector2(x,height*.69),Vector2(x+25,height*.66),Vector2(x+33,height*.97),Vector2(x+5,height)]),Color("21363b"))
   draw_line(Vector2(x+18,height*.72),Vector2(x+23,height*.93),Color("c59a61"),3.)
 var departure=minf(1.,phase/8.)*25.
 var ship=Vector2(width*.49,height*.56+departure)
 draw_set_transform(offset+ship*scale,PI*.56,Vector2.ONE*scale*1.42)
 draw_texture_rect_region(QUIETUS,Rect2(-66,-17,132,34),Rect2(60,145,1940,390))
 draw_set_transform(offset,0,Vector2.ONE*scale)
 for n in 4:
  var y=ship.y-60.-n*11.
  draw_line(Vector2(ship.x+7-n*2,y),Vector2(ship.x+14+n*2,y-13),Color(.28,.57,.59,.10-float(n)*.018),1.8)
 # Actual surviving drone identities accompany the recovery, never replacements.
 for id in consequence.get("drones",[]):
  var p=ship+Vector2(-70. if id==1 else 79.,23. if id==1 else -12.)
  draw_set_transform(offset+p*scale,PI*.56,Vector2.ONE*scale)
  draw_style_box(_drone(),Rect2(-18,-5,36,10))
  draw_line(Vector2(-7,-5),Vector2(-7,5),Color("c39a5e"),2.)
  draw_circle(Vector2(18,0),2.5,Color("79cdd1"))
 draw_set_transform(offset,0,Vector2.ONE*scale)
 var memory=ship+Vector2(37,64)
 draw_line(ship+Vector2(26,19),memory,Color(.72,.59,.37,.33),1.)
 draw_rect(Rect2(memory,Vector2(24,14)),Color("253e43"))
 for x in [5.,10.,15.]:draw_line(memory+Vector2(x,3),memory+Vector2(x,11),Color("d2ac69"),1.3)
 var fs=13
 draw_string(ThemeDB.fallback_font,Vector2(24,28),"CONFLUENCE / RECOVERY",HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("719c9f"))
 draw_string(ThemeDB.fallback_font,memory+Vector2(44,17),"LIVING DISPATCH ABOARD",HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("c6ac76"))
 var thread=consequence.get("thread","")
 if thread in ["deep","shelf"]:
  draw_string(ThemeDB.fallback_font,Vector2(24,height-19),"DEEP-WATER HISTORY" if thread=="deep" else "SHELTER HISTORY",HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("719c9f"))
 # A little physical threshold distinguishes the passage actually used, while
 # the optional motor consequence is embodied by separated/closed gate leaves.
 var gate=Vector2(width*.95,height*.55)
 var opened=consequence.get("service_opened",false)
 if consequence.get("service_known",false):
  for sign_x in [-1,1]:
   var p=gate+Vector2(sign_x*(13. if opened else 5.),0)
   draw_rect(Rect2(p-Vector2(4,29),Vector2(8,58)),Color("3a5151"))
   draw_line(p-Vector2(0,24),p+Vector2(0,24),Color("78aaa5") if opened else Color("b7975d"),1.4)
 draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _scaled(points:PackedVector2Array,proportions:Vector2)->PackedVector2Array:
 var result=PackedVector2Array()
 for point in points:result.append(point*proportions)
 return result

func _cliff(points:PackedVector2Array,left:bool)->void:
 draw_colored_polygon(points,Color("0b1d25"))
 var uv=PackedVector2Array()
 for point in points:uv.append(point/200.)
 draw_polygon(points,PackedColorArray([Color(.26,.39,.4)]),uv,World.BASALT)
 var start=2 if left else 3
 var end=points.size()-1
 for n in range(start,end):
  var a=points[n];var b=points[n+1]
  draw_line(a,b,Color("4a6768"),2.)
  for k in maxi(1,int(a.distance_to(b)/12.)):
   var p=a.lerp(b,float(k)/maxi(1,int(a.distance_to(b)/12.)))
   draw_line(p,p+Vector2(-7 if left else 7,17),Color("0a1820"),3.)
func _drone()->StyleBoxFlat:
 var style=StyleBoxFlat.new();style.bg_color=Color("293c43");style.border_color=Color("6d8585");style.set_border_width_all(1);style.set_corner_radius_all(6);return style
