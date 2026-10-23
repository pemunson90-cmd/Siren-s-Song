extends Node
# Own-craft photographic and propulsion feedback, with no enemy queries or save fields.
# Seam: Soundscape.update calls sync() once and applies its returned engine multiplier.
# Lifecycle notifications freeze these players immediately; normal updates own resume.
# Revert: remove that soundscape call/multiplier and this folder. Music/warnings stay owned there.
const Table=preload("res://src/audio/photo_audio/photo_cue_table.gd")
const Wave=preload("res://src/audio/photo_audio/photo_wave.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
var hold:AudioStreamPlayer
var voices:Array=[]
var next_voice=0
var last_cues:Array=[]
var mission_ref:Dictionary={}
var films:Array=[]
var transitions:Array=[]
var next_plate=1
var was_stopped=false
var spin_at=-100.
var lifecycle_suspended=false
static func sync(host,sim,dt:float,active:bool)->float:
 if not host.is_inside_tree():return 1.
 var layer=host.get_node_or_null("PhotoAudio")
 if layer==null:
  layer=load("res://src/audio/photo_audio/photo_audio.gd").new();layer.name="PhotoAudio"
  host.add_child(layer);layer.setup(host.EFFECTS_BUS)
 return layer.advance(host,sim,dt,active)
func setup(bus:String)->void:
 for cue in Table.CUES:Wave.stream(cue)
 hold=AudioStreamPlayer.new();hold.bus=bus;hold.stream=Wave.stream("hold");add_child(hold)
 for n in Table.VOICES:
  var voice=AudioStreamPlayer.new();voice.bus=bus;add_child(voice);voices.append(voice)
func _emit(cue:String,allowed:bool,frozen:bool)->void:
 if not allowed:return
 var voice=voices[next_voice];next_voice=(next_voice+1)%voices.size()
 voice.stop();voice.stream=Wave.stream(cue);voice.volume_db=Table.CUES[cue].gain_db
 voice.play();voice.stream_paused=frozen;last_cues.append(cue)
func advance(host,sim,_dt:float,active:bool)->float:
 last_cues=[]
 var stopped=sim.AllStop.stopped(sim.units[0])
 var current_films=[];var current_transitions=[];var jobs=[]
 for uid in sim.units.size():
  current_films.append(Pricing.film_left(sim,uid))
  var shift=sim.units[uid].get("transition",{})
  current_transitions.append(shift.get("to",-1))
  var work=sim.capture_feedback(uid)
  if work.unit>=0 and Photo.applies(Photo.obj(sim,work.target)):jobs.append(work)
 var plate=int(Photo.peek(sim).get("next",1))
 var reset=not is_same(mission_ref,sim.mission)
 if reset:
  mission_ref=sim.mission;films=current_films.duplicate();transitions=current_transitions.duplicate()
  next_plate=plate;was_stopped=stopped;spin_at=-100.
  hold.stop()
  for voice in voices:voice.stop()
 var audible=not host.muted and host.effects_volume>0
 var allowed=audible and active and not host.system_suspended and not lifecycle_suspended
 var frozen=sim.paused or not active or host.system_suspended or lifecycle_suspended
 for event in sim.events:
  if event.get("type","")!="camera":continue
  if jobs.any(func(work):return event.get("pos",Vector2.INF).distance_to(sim.units[work.unit].pos)<1.):
   _emit("shutter",allowed,frozen)
 for uid in sim.units.size():
  if current_films[uid]<films[uid]:
   if current_films[uid]==0:_emit("film_empty",allowed,frozen)
   elif current_films[uid]<=Table.LOW_FILM and films[uid]>Table.LOW_FILM:_emit("film_low",allowed,frozen)
  if current_transitions[uid]>=0 and current_transitions[uid]!=transitions[uid]:
   _emit("pressure_deep" if current_transitions[uid]>sim.units[uid].band else "pressure_shallow",allowed,frozen)
 if plate>next_plate:_emit("develop",allowed,frozen)
 if stopped and not was_stopped:
  spin_at=sim.elapsed;_emit("engine_down",allowed,frozen)
 if not audible or not active:
  hold.stop()
  for voice in voices:voice.stop()
 elif jobs.is_empty():hold.stop()
 else:
  var progress=0.
  for work in jobs:progress=maxf(progress,clampf(work.elapsed/maxf(.001,work.duration),0,1))
  var row=Table.CUES.hold;var curve=pow(progress,row.build_curve)
  hold.volume_db=lerpf(row.gain_db,row.max_db,curve);hold.pitch_scale=lerpf(row.pitch[0],row.pitch[1],curve)
  if not hold.playing:hold.play()
 hold.stream_paused=frozen
 for voice in voices:voice.stream_paused=frozen
 films=current_films;transitions=current_transitions;next_plate=plate;was_stopped=stopped
 return clampf(1.-(sim.elapsed-spin_at)/Table.SPIN_DOWN,0,1) if stopped else 1.
func _notification(what:int)->void:
 if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
  lifecycle_suspended=true
  if hold!=null:hold.stream_paused=true
  for voice in voices:voice.stream_paused=true
 elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:
  lifecycle_suspended=false
func _exit_tree()->void:
 if hold!=null:hold.stop();hold.stream=null
 for voice in voices:voice.stop();voice.stream=null
