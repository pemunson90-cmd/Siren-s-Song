extends RefCounted
# Parallel read-only observer, called before Soundscape consumes events. Its
# ReceivedCues instance never consumes audio dedup. Own craft and public cached
# contacts only. Reset seeds current state and discards historical events.
const Table=preload("res://src/presentation/accessibility/cue_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Depth=preload("res://src/presentation/frontend/settings_depth.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
var received=preload("res://src/audio/received_cues.gd").new()
var received_factory=preload("res://src/audio/received_cues.gd").new()
var mission:Dictionary={}
var last_clock=-1.
var films:Array=[]
var transitions:Array=[]
var plate=1
var stopped=false
var lock_ids:Array=[]
var rows:Array=[]
var history:Array=[]
var emitted:Array=[]
var pulse_requests=0
var selected=-1
func _emit(cue:String,time:float,suffix:String="",caption_override:String="")->void:
 if not Table.TEXT.has(cue):return
 emitted.append(cue)
 if Depth.haptic_cue(cue) and Settings.vibrate(Table.PULSE_MS):pulse_requests+=1
 if not Settings.current.get("audio_captions",false):return
 var caption=str(Table.TEXT[cue]) if caption_override.is_empty() else caption_override
 rows.append({"text":caption+suffix,"until":time+Table.SECONDS})
 history.append({"text":caption+suffix,"at":time})
 while rows.size()>Table.MAX_ROWS:rows.pop_front()
 while history.size()>Table.HISTORY_ROWS:history.pop_front()
# Caption for an event audio cue raised after observe() this frame. Same gates as _emit.
func note(cue:String,time:float,suffix:String="")->void:
 if Table.ENABLED:_emit(cue,time,suffix)
func observe(sim,active:bool)->void:
 emitted=[]
 if not Table.ENABLED:rows.clear();history.clear();return
 var current_films=[];var current_transitions=[]
 for uid in sim.units.size():
  current_films.append(Pricing.film_left(sim,uid))
  current_transitions.append(sim.units[uid].get("transition",{}).get("to",-1))
 var next_plate=int(Photo.peek(sim).get("next",1))
 var now_stopped=sim.AllStop.stopped(sim.units[0])
 var ids=preload("res://src/presentation/lock_warning.gd").frames(sim).map(func(f):return f.id)
 var reset=not is_same(mission,sim.mission) or sim.elapsed<last_clock
 if reset or not active or selected!=sim.selected:
  rows.clear();history.clear();received=preload("res://src/audio/received_cues.gd").new();received_factory=preload("res://src/audio/received_cues.gd").new()
 var running=active and not sim.paused and sim.outcome.is_empty()
 if not reset and running:
  for raw_event in sim.events:
   var event=preload("res://src/simulation/contact_identity.gd").event(sim,raw_event)
   var cue=str(event.get("type",""))
   if cue in ["carrier_received","return_received","sweep_received"]:
    if not received.take(event,sim.selected,sim.elapsed,true).is_empty():_emit(cue,sim.elapsed,"",event.get("caption",""))
   elif cue=="factory" and event.has("receiver"):
    # Existing industrial receiver events have identical reception fields but
    # use a shared factory timbre. Apply the same gate on an independent cache.
    var reception=event.duplicate();reception.type="carrier_received"
    if not received_factory.take(reception,sim.selected,sim.elapsed,true).is_empty():_emit("factory",sim.elapsed,"",event.get("caption",""))
   elif cue=="factory" and event.get("industrial",false):_emit("factory",sim.elapsed)
   elif cue=="factory":continue # Scripted base response already has mandatory message text.
   elif Table.TEXT.has(cue):_emit(cue,sim.elapsed)
  for uid in current_films.size():
   var suffix=" · "+str(sim.units[uid].name)
   if current_films[uid]<films[uid]:
    if current_films[uid]==0:_emit("film_empty",sim.elapsed,suffix)
    elif current_films[uid]<=preload("res://src/audio/photo_audio/photo_cue_table.gd").LOW_FILM and films[uid]>preload("res://src/audio/photo_audio/photo_cue_table.gd").LOW_FILM:_emit("film_low",sim.elapsed,suffix)
   if current_transitions[uid]>=0 and current_transitions[uid]!=transitions[uid]:_emit("pressure_deep" if current_transitions[uid]>sim.units[uid].band else "pressure_shallow",sim.elapsed,suffix)
  if next_plate>plate:_emit("develop",sim.elapsed)
  if now_stopped and not stopped:_emit("engine_down",sim.elapsed)
  if ids.any(func(id):return id not in lock_ids):_emit("lock",sim.elapsed)
 mission=sim.mission;last_clock=sim.elapsed;films=current_films;transitions=current_transitions;plate=next_plate;stopped=now_stopped;lock_ids=ids;selected=sim.selected
 if not Settings.current.get("audio_captions",false):rows.clear();history.clear()
 rows=rows.filter(func(row):return row.until>sim.elapsed)
func text()->String:
 return "\n".join(rows.map(func(row):return row.text))
func history_text()->String:
 return "RECENT AUDIO LOG\nPast cues at mission clock, not current threat state.\n\n"+"\n".join(history.map(func(row):return "T+%.1fs · %s"%[row.at,row.text]))
