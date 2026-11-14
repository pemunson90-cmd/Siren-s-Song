extends Control
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
# Read-only, receiver-earned lock cues. Never inspect the live enemy roster.
# Visual revert: remove Main construction/refresh only; retain frames() and tests
# because Soundscape and accessibility consume the same received-lock data.
static func frames(sim)->Array:
 var result:Array=[]
 if sim.units.is_empty() or not sim.units[0].alive or not sim.outcome.is_empty():return result
 var seconds:float=sim.lock_seconds()
 for id in sim.contacts:
  var c=sim.contacts[id];var age=sim.elapsed-float(c.time)
  if age<0 or age>=.3 or c.get("target",-1)!=0 or c.get("recipient_target",false):continue
  if preload("res://src/simulation/observed_stun.gd").remaining(c,sim.elapsed)>0:continue
  if c.get("mode","")!="LOCKING" or c.get("lock",0)<=0 or c.lock>=seconds:continue
  if not preload("res://src/simulation/depth_bands.gd").sight(sim,c,sim.units[0]):continue
  result.append({"id":id,"pos":c.pos,"progress":c.lock/seconds,"remaining":seconds-c.lock})
 result.sort_custom(func(a,b):return a.progress>b.progress)
 return result
var host
var locks:Array=[]
var episodes=0
var previous_clock=-1.
var previous_ids:Array=[]
var banner=Rect2():
 set(value):
  banner=value;_place_buttons()
# One tap per counter-move the card lists (ThreatRead.move_list), shown only while the game is paused or held.
# They send the wheel's own orders through Main._order; the card owns their taps (blocks(), mission_hud.blocks).
const MOVE_BUTTONS=3
const BUTTON_GAP=6.
const BUTTON_PAD=8.
var buttons:Array=[]
var button_top=0.
# The ONE statement of a lock. The card names the Siren's type and direction, the threatened craft (any of
# ours, not only Quietus), the seconds left and the way out, from the same received-lock rows the chart's
# threat line uses. Nothing else says it: the contact readout, the craft tag and the notice chip stand down
# while it shows (ocean_view.lock_card_source). A "NEW SIREN TYPE" note joins it as its last line.
var rows:Array=[]
var card_text=""
var note=""
func _init():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 for i in MOVE_BUTTONS:
  var button=Button.new();button.visible=false;button.mouse_filter=Control.MOUSE_FILTER_STOP;button.focus_mode=Control.FOCUS_NONE
  button.pressed.connect(_press.bind(button));add_child(button);buttons.append(button)
func update_state(sim,active:bool):
 if sim.elapsed<previous_clock:previous_ids.clear()
 previous_clock=sim.elapsed
 locks=frames(sim) if active else []
 rows=ThreatRead.lock_rows(sim) if active else []
 var ids=locks.map(func(frame):return frame.id)
 if ids.any(func(id):return id not in previous_ids):episodes+=1
 previous_ids=ids
 card_text=_card_text()
 visible=not locks.is_empty() or not rows.is_empty();queue_redraw()
func _card_text()->String:
 if rows.is_empty():
  return "S%d LOCK · %.1fs"%[int(locks[0].id)+1,locks[0].remaining] if not locks.is_empty() else ""
 var aim=ThreatRead.Table.TEXT.decoy_aim if host!=null and host.get("decoy_armed")==true and int(host.decoy_unit)==int(rows[0].craft) else ""
 return rows[0].sentence+"\n"+rows[0].advice+("\n"+aim if not aim.is_empty() else "")+("\n"+note if not note.is_empty() else "")
func refresh(owner):
 host=owner;position=Vector2.ZERO;size=host.size
 var cue=host.hud.get_node_or_null("FirstSirenCue") if host.get("hud")!=null else null
 note=cue.note_text() if cue!=null and host.screen=="mission" else ""
 update_state(host.sim,host.screen=="mission")
 host.ocean.lock_card_source=int(rows[0].source) if not rows.is_empty() else -1
 var h=host.ui_touch_height
 var width=minf(size.x-32,h*UiStyle.LOCK_CARD_WIDTH)
 var tall=h*.85
 if not rows.is_empty():
  var text_h=ThemeDB.fallback_font.get_multiline_string_size(card_text,HORIZONTAL_ALIGNMENT_LEFT,maxf(1.,width-h*.9-12.),_font_size(h)).y
  tall=maxf(tall,text_h+h*.25)
 button_top=tall
 tall+=_fit_buttons(h,width)
 banner=Rect2(Vector2((size.x-width)/2,h+24),Vector2(width,tall))
# Sets up the move buttons from the card's moves (only while paused) and flows them into rows that fit the card's
# width; returns the height they add under the text. Rows' offsets are kept in each button's "offset" meta.
func _fit_buttons(h:float,width:float)->float:
 var moves:Array=rows[0].moves if not rows.is_empty() and host.sim.paused else []
 var font_size=_font_size(h)
 var inner=width-BUTTON_PAD*2
 var x=0.;var y=0.;var used=0.
 for i in buttons.size():
  var button:Button=buttons[i]
  button.visible=i<moves.size()
  if not button.visible:continue
  var move=moves[i]
  button.text=move.label;button.set_meta("order",move.order);button.set_meta("craft",int(rows[0].craft))
  button.add_theme_font_size_override("font_size",font_size)
  button.disabled=move.order=="decoy" and host.get("decoy_armed")==true and int(host.decoy_unit)==int(rows[0].craft)
  var w=minf(inner,maxf(h*1.2,ThemeDB.fallback_font.get_string_size(move.label,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x+h*.5))
  if x>0 and x+w>inner:x=0.;y+=h+BUTTON_GAP
  button.size=Vector2(w,h);button.set_meta("offset",Vector2(x,y));x+=w+BUTTON_GAP;used=y+h
 return 0. if moves.is_empty() else used+BUTTON_PAD*2
func _place_buttons()->void:
 for button in buttons:
  if button.visible:button.position=banner.position+Vector2(BUTTON_PAD,button_top+BUTTON_PAD)+button.get_meta("offset",Vector2.ZERO)
# True when a tap at this screen point belongs to the card (its whole rectangle while buttons show).
func blocks(point:Vector2)->bool:
 return visible and buttons.any(func(b):return b.visible) and Rect2(global_position+banner.position,banner.size).has_point(point)
# One tap: select the locked craft, then send the wheel's own order. DECOY arms placement and the chart waits for a point.
func _press(button:Button)->void:
 if host==null:return
 var craft=int(button.get_meta("craft"))
 if host.sim.selected!=craft:host._order("select",{"unit":craft})
 host._order(str(button.get_meta("order")))
func _font_size(h:float)->int:
 return maxi(18,roundi(h*.25))
func marker(point:Vector2)->Vector2:
 return point.clamp(Vector2.ONE*26,size-Vector2.ONE*26)
func _draw():
 if host==null or (locks.is_empty() and rows.is_empty()):return
 var h=host.ui_touch_height;var font=ThemeDB.fallback_font
 var warning=preload("res://src/presentation/accessibility/palette.gd").color("warning",Color("ffb18b"));var ink=Color("160b13")
 for frame in locks:
  var source=marker(host.ocean.screen_position(frame.pos))
  var target=marker(host.ocean.screen_position(host.sim.units[0].pos))
  draw_line(source,target,Color(.04,.02,.03,.95),7,true)
  draw_dashed_line(source,target,warning,Palette.stroke(3),12,true)
  Palette.marker(self,source,29.,"warning")
  draw_circle(source,25,ink)
  draw_arc(source,25,-PI/2,-PI/2+TAU*frame.progress,40,warning,5,true)
  draw_string(font,source+Vector2(-15,6),"S%d"%(int(frame.id)+1),HORIZONTAL_ALIGNMENT_LEFT,-1,18,warning)
 draw_style_box(_panel(),banner)
 var progress=rows[0].progress if not rows.is_empty() else locks[0].progress
 var radius=h*.26;var at=banner.position+Vector2(h*.45,h*.42)
 draw_arc(at,radius,0,TAU,40,Color(.4,.25,.24),5,true)
 draw_arc(at,radius,-PI/2,-PI/2+TAU*(1.-progress),40,warning,7,true)
 var font_size=_font_size(h)
 if rows.is_empty():
  draw_string(font,banner.position+Vector2(h*.9,h*.5),card_text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,warning)
  return
 draw_multiline_string(font,banner.position+Vector2(h*.9,h*.2+font.get_ascent(font_size)),card_text,HORIZONTAL_ALIGNMENT_LEFT,maxf(1.,banner.size.x-h*.9-12.),font_size,-1,Color.WHITE)
func _panel()->StyleBoxFlat:
 var panel=StyleBoxFlat.new();panel.bg_color=Color(.06,.015,.025,.97);panel.border_color=preload("res://src/presentation/accessibility/palette.gd").color("warning",Color("ffb18b"));panel.set_border_width_all(int(Palette.stroke(2)));panel.set_corner_radius_all(10)
 return panel
