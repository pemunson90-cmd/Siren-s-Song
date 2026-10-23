extends Control
# D1 bearing-only presentation of the existing acquisition decision, never a sensor.
# Seam: install(host) in main; Simulation publishes its existing heard/seen decision.
# Revert: cue_table.enabled=false, or remove install() and this signal consumer.
const Table=preload("res://src/presentation/first_siren_cue/cue_table.gd")
const Tracker=preload("res://src/presentation/first_siren_cue/notice_tracker.gd")
const Sound=preload("res://src/audio/soundscape.gd")
var host
var tracker=Tracker.new()
var frames:Array=[]
var audio_events:Array=[]
var voice:AudioStreamPlayer
var marker_rect=Rect2()
var font_size=18
var suspended=false
static func install(owner)->void:
 var cue=load("res://src/presentation/first_siren_cue/first_siren_cue.gd").new()
 cue.name="FirstSirenCue";owner.hud.add_child(cue);cue.setup(owner)
func setup(owner)->void:
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 voice=AudioStreamPlayer.new();voice.bus=Sound.EFFECTS_BUS;voice.stream=Sound.stream(Table.AUDIO.id)
 voice.volume_db=Table.AUDIO.gain_db;voice.pitch_scale=Table.AUDIO.pitch;host.sound.add_child(voice)
 tracker.noticed.connect(_notice);tracker.bind(host.sim);hide()
func _notice(row:Dictionary)->void:
 refresh()
 if host.screen!="mission" or host.sound.muted or host.sound.effects_volume<=0 or host.sound.system_suspended or suspended:return
 voice.play();voice.stream_paused=host.sim.paused
 audio_events.append({"cue":Table.AUDIO.id,"type":"first_siren_notice","id":row.id,"time":row.time})
func _process(_dt:float)->void:
 if host!=null:refresh()
func refresh()->void:
 frames=tracker.frames();position=Vector2.ZERO;size=host.size
 visible=host.screen=="mission" and not frames.is_empty() and host.sim.outcome.is_empty()
 var h=host.ui_touch_height;var layout=Table.LAYOUT
 var width=minf(size.x-layout.gap*2,h*layout.width_touch)
 marker_rect=Rect2(Vector2(size.x-width-layout.gap,h*layout.top_touch+layout.gap),Vector2(width,h*layout.height_touch))
 font_size=maxi(layout.font_min,roundi(h*layout.font_touch))
 var silent=not visible or host.sound.muted or host.sound.effects_volume<=0
 if silent or voice.get_playback_position()>=Table.AUDIO.seconds:voice.stop()
 voice.stream_paused=host.sim.paused or suspended or host.sound.system_suspended
 queue_redraw()
func _draw()->void:
 if frames.is_empty():return
 var panel=StyleBoxFlat.new();panel.bg_color=Color("102c39");panel.border_color=Color("a9d9df");panel.set_border_width_all(2);panel.set_corner_radius_all(8)
 draw_style_box(panel,marker_rect)
 var center=marker_rect.position+Vector2(marker_rect.size.y*.5,marker_rect.size.y*.5)
 var direction:Vector2=frames.back().direction;var radius=marker_rect.size.y*.24
 draw_line(center-direction*radius,center+direction*radius,Color("a9d9df"),3.,true)
 var tip=center+direction*radius;var side=direction.orthogonal()*radius*.4
 draw_colored_polygon(PackedVector2Array([tip,center+side,center-side]),Color("a9d9df"))
 var text=label_text()
 draw_string(ThemeDB.fallback_font,marker_rect.position+Vector2(marker_rect.size.y,marker_rect.size.y*.62),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE)
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
