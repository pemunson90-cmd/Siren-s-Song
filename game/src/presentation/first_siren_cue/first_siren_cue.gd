extends Control
const Names=preload("res://src/names.gd")
# D1 bearing-only presentation of the existing acquisition decision, never a sensor.
# Seam: install(host) in main; Simulation publishes its existing heard/seen decision.
# Revert: cue_table.enabled=false, or remove install() and this signal consumer.
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Table=preload("res://src/presentation/first_siren_cue/cue_table.gd")
const Tracker=preload("res://src/presentation/first_siren_cue/notice_tracker.gd")
const Sound=preload("res://src/audio/soundscape.gd")
const Compass=preload("res://src/presentation/compass.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
const ThreatLine=preload("res://src/presentation/threat_read/threat_line.gd")
var host
var tracker=Tracker.new()
var frames:Array=[]
var audio_events:Array=[]
var voice:AudioStreamPlayer
var note_frames:Array=[]
var chip_rect=Rect2()
var note_rect=Rect2()
var marker_rect=Rect2()
var font_size=18
var suspended=false
static func install(owner)->void:
 var cue=load("res://src/presentation/first_siren_cue/first_siren_cue.gd").new()
 cue.name="FirstSirenCue";owner.hud.add_child(cue);cue.setup(owner)
func setup(owner)->void:
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 voice=AudioStreamPlayer.new();voice.bus=Sound.ALERTS_BUS;voice.stream=Sound.stream(Table.AUDIO.id)
 voice.volume_db=Table.AUDIO.gain_db;voice.pitch_scale=Table.AUDIO.pitch;host.sound.add_child(voice)
 tracker.noticed.connect(_notice);tracker.bind(host.sim);hide()
func _notice(row:Dictionary)->void:
 refresh()
 if host.screen!="mission" or not host.sound.cue_audible(Table.AUDIO.id) or host.sound.system_suspended or suspended:return
 voice.play();voice.stream_paused=host.sim.paused
 audio_events.append({"cue":Table.AUDIO.id,"type":"first_siren_notice","id":row.id,"time":row.time})
func _process(_dt:float)->void:
 if host!=null:refresh()
func refresh()->void:
 frames=tracker.frames();note_frames=tracker.notes();position=Vector2.ZERO;size=host.size
 visible=host.screen=="mission" and not (frames.is_empty() and note_frames.is_empty()) and host.sim.outcome.is_empty()
 var h=host.ui_touch_height;var layout=Table.LAYOUT
 font_size=maxi(layout.font_min,roundi(h*layout.font_touch))
 # WP-11 (I2): grow to the measured text, never past the content edge; wrap when even that is short.
 # The camera panel owns the right lane: the notice sits left of it, never over WIDE, SHUTTER or FOLD.
 var feed=host.ocean.optical_feed;var right=size.x
 if feed!=null and feed.is_visible_in_tree():right=minf(right,feed.global_position.x-global_position.x)
 var tall=h*layout.height_touch;var widest=maxf(1.,right-layout.gap*2)
 var need=maxf(_text_width(label_text())+tall+12.,_text_width(note_text())+tall*.4+12.)
 var width=clampf(need,minf(widest,h*layout.width_touch),widest)
 chip_rect=Rect2(Vector2(right-width-layout.gap,h*layout.top_touch+layout.gap),Vector2(width,_box_height(label_text(),width-tall-8.,tall)))
 # WP-51: a received lock is stated once, by the lock card, which also carries the new-type note as its last line.
 # While it shows, this chip and note draw nothing; only the bearing wedge (when no lock line already points) remains.
 var lock=host.get("lock_warning")
 var folded=lock!=null and lock.visible and not lock.rows.is_empty()
 host.ocean.first_notice_showing=not frames.is_empty() and host.screen=="mission"
 note_rect=Rect2()
 if folded:
  chip_rect=Rect2();marker_rect=Rect2()
 else:
  # The kind note sits directly under the chip (or alone).
  if not note_frames.is_empty():
   var note_at=chip_rect.position if frames.is_empty() else chip_rect.end+Vector2(-chip_rect.size.x,layout.gap*.5)
   note_rect=Rect2(note_at,Vector2(width,_box_height(note_text(),width-tall*.4-8.,tall)))
  # marker_rect is the chip (the note alone when no bearing); captions also avoid note_rect.
  marker_rect=chip_rect if not frames.is_empty() or note_frames.is_empty() else note_rect
 var silent=not visible or not host.sound.cue_audible(Table.AUDIO.id)
 if silent or voice.get_playback_position()>=Table.AUDIO.seconds:voice.stop()
 voice.stream_paused=host.sim.paused or suspended or host.sound.system_suspended
 queue_redraw()
func _draw()->void:
 # Bearing wedge from the craft that was noticed, unless a lock line already points at the Siren.
 if not frames.is_empty():
  var row=frames.back()
  var locked=ThreatRead.lock_rows(host.sim).any(func(lock):return lock.craft==row.unit)
  if not locked:ThreatLine.wedge(self,host.ocean.screen_position(host.sim.units[row.unit].pos),row.bearing,minf(size.x,size.y)*UiStyle.THREAT_WEDGE_LENGTH)
 var panel=StyleBoxFlat.new();panel.bg_color=Color("102c39");panel.border_color=Palette.chart_color("evidence",Color("a9d9df"));panel.set_border_width_all(int(Palette.stroke(2)));panel.set_corner_radius_all(8)
 if not frames.is_empty() and chip_rect.has_area():
  draw_style_box(panel,chip_rect)
  var center=chip_rect.position+Vector2(chip_rect.size.y*.5,chip_rect.size.y*.5)
  var direction:Vector2=frames.back().direction;var radius=chip_rect.size.y*.24
  Palette.marker(self,center,radius*1.35,"evidence")
  draw_line(center-direction*radius,center+direction*radius,Palette.chart_color("evidence",Color("a9d9df")),3.,true)
  var tip=center+direction*radius;var side=direction.orthogonal()*radius*.4
  draw_colored_polygon(PackedVector2Array([tip,center+side,center-side]),Palette.chart_color("evidence",Color("a9d9df")))
  var tall=minf(chip_rect.size.y,host.ui_touch_height*Table.LAYOUT.height_touch)
  _text(chip_rect.position+Vector2(tall,0),label_text(),chip_rect.size.x-tall-8.,chip_rect.size.y)
 if note_rect.has_area():
  panel.border_color=Palette.chart_color("warning",Color("e6c46a"));draw_style_box(panel,note_rect)
  var inset=minf(note_rect.size.y,host.ui_touch_height*Table.LAYOUT.height_touch)*.4
  _text(note_rect.position+Vector2(inset,0),note_text(),note_rect.size.x-inset-8.,note_rect.size.y)
func _text_width(text:String)->float:
 return ThemeDB.fallback_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
# One line keeps the original box height; wrapped text grows the box downward.
func _box_height(text:String,room:float,tall:float)->float:
 if text.is_empty() or _text_width(text)<=room:return tall
 return maxf(tall,ThemeDB.fallback_font.get_multiline_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,maxf(1.,room),font_size).y+tall*.4)
func _text(at:Vector2,text:String,room:float,box_height:float)->void:
 var font=ThemeDB.fallback_font
 if _text_width(text)<=room:
  draw_string(font,at+Vector2(0,box_height*.62),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE);return
 draw_multiline_string(font,at+Vector2(0,box_height*.2+font.get_ascent(font_size)),text,HORIZONTAL_ALIGNMENT_LEFT,maxf(1.,room),font_size,-1,Color.WHITE)
func note_text()->String:
 return "" if note_frames.is_empty() else note_frames.back().text
func label_text()->String:
 if frames.is_empty():return ""
 var row=frames.back()
 return Table.NOTICE_LABEL%[Compass.point(row.bearing),Names.UNIT_LETTERS[row.unit],roundi(row.bearing)%360]
func _notification(what:int)->void:
 if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
  suspended=true
  if voice!=null:voice.stream_paused=true
 elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:suspended=false
func _exit_tree()->void:
 tracker.unbind()
 if is_instance_valid(voice):voice.stop();voice.stream=null;voice.queue_free()
