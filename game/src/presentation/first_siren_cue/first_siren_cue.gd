extends Control
# D1 bearing-only presentation of the existing acquisition decision, never a sensor.
# Seam: install(host) in main; Simulation publishes its existing heard/seen decision.
# Revert: cue_table.enabled=false, or remove install() and this signal consumer.
const Palette=preload("res://src/presentation/accessibility/palette.gd")
const Table=preload("res://src/presentation/first_siren_cue/cue_table.gd")
const Tracker=preload("res://src/presentation/first_siren_cue/notice_tracker.gd")
const Sound=preload("res://src/audio/soundscape.gd")
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
 voice=AudioStreamPlayer.new();voice.bus=Sound.ALERTS_BUS if Sound.Depth.ENABLED else Sound.EFFECTS_BUS;voice.stream=Sound.stream(Table.AUDIO.id)
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
 var width=minf(size.x-layout.gap*2,h*layout.width_touch)
 chip_rect=Rect2(Vector2(size.x-width-layout.gap,h*layout.top_touch+layout.gap),Vector2(width,h*layout.height_touch))
 # The kind note sits directly under the chip (or alone) clear of the centred lock banner.
 note_rect=Rect2()
 if not note_frames.is_empty():
  var note_at=chip_rect.position if frames.is_empty() else chip_rect.end+Vector2(-chip_rect.size.x,layout.gap*.5)
  note_rect=Rect2(note_at,Vector2(width,h*layout.height_touch))
 # marker_rect is the chip (the note alone when no bearing); captions also avoid note_rect.
 marker_rect=chip_rect if not frames.is_empty() or note_frames.is_empty() else note_rect
 font_size=maxi(layout.font_min,roundi(h*layout.font_touch))
 var silent=not visible or not host.sound.cue_audible(Table.AUDIO.id)
 if silent or voice.get_playback_position()>=Table.AUDIO.seconds:voice.stop()
 voice.stream_paused=host.sim.paused or suspended or host.sound.system_suspended
 queue_redraw()
func _draw()->void:
 var panel=StyleBoxFlat.new();panel.bg_color=Color("102c39");panel.border_color=Palette.chart_color("evidence",Color("a9d9df"));panel.set_border_width_all(int(Palette.stroke(2)));panel.set_corner_radius_all(8)
 if not frames.is_empty():
  draw_style_box(panel,chip_rect)
  var center=chip_rect.position+Vector2(chip_rect.size.y*.5,chip_rect.size.y*.5)
  var direction:Vector2=frames.back().direction;var radius=chip_rect.size.y*.24
  Palette.marker(self,center,radius*1.35,"evidence")
  draw_line(center-direction*radius,center+direction*radius,Palette.chart_color("evidence",Color("a9d9df")),3.,true)
  var tip=center+direction*radius;var side=direction.orthogonal()*radius*.4
  draw_colored_polygon(PackedVector2Array([tip,center+side,center-side]),Palette.chart_color("evidence",Color("a9d9df")))
  draw_string(ThemeDB.fallback_font,chip_rect.position+Vector2(chip_rect.size.y,chip_rect.size.y*.62),label_text(),HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE)
 if not note_frames.is_empty():
  panel.border_color=Palette.chart_color("warning",Color("e6c46a"));draw_style_box(panel,note_rect)
  draw_string(ThemeDB.fallback_font,note_rect.position+Vector2(note_rect.size.y*.4,note_rect.size.y*.62),note_text(),HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE)
func note_text()->String:
 return "" if note_frames.is_empty() else note_frames.back().text
func label_text()->String:
 if frames.is_empty():return ""
 return "NOTICE · FROM %s · %03d°"%[["Q","A","B"][frames.back().unit],roundi(frames.back().bearing)%360]
func _notification(what:int)->void:
 if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
  suspended=true
  if voice!=null:voice.stream_paused=true
 elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:suspended=false
func _exit_tree()->void:
 tracker.unbind()
 if is_instance_valid(voice):voice.stop();voice.stream=null;voice.queue_free()
