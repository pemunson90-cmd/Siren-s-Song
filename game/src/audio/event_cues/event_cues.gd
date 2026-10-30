extends Node
# EVENT AUDIO: own-craft hull strain, survivor, artifact, research and field-tool cues.
# Seam: Soundscape.update calls sync() once per frame; Soundscape.event_cue(id) stays the entry point for
# callers that own an event (research). Observes simulation state and the public event list read-only, incl.
# a drop in mission field_tools counts (a successful tool use; refused uses spend nothing). No hook in simulation.
# Unknown ids are ignored, so a tool nobody fires yet is safe.
const Table=preload("res://src/audio/event_cues/event_cue_table.gd")
const Wave=preload("res://src/audio/photo_audio/photo_wave.gd")
# Immutable PCM is shared across soundscapes, as in PhotoWave.stream(). Keep players,
# repeat clocks and observation state local; freeing a scene only releases its references.
static var stream_cache:Dictionary={}
var voices:Array=[]
var next_voice:=0
var last_play:Dictionary={}
var queued:Array=[]
var played:Array=[]
var streams:Dictionary={}
var mission_ref:Dictionary={}
var last_clock:=-1.
var hull:=-1.
var materials:Dictionary={}
var tool_counts:Dictionary={}
var reporting:Dictionary={}
var lifecycle_suspended:=false
var host_ref
static func sync(host,sim,dt:float,active:bool)->void:
 if not host.is_inside_tree():return
 var layer=host.get_node_or_null("EventAudio")
 if layer==null:
  layer=load("res://src/audio/event_cues/event_cues.gd").new();layer.name="EventAudio"
  host.add_child(layer);layer.setup(host)
 layer.advance(sim,dt,active)
func setup(host)->void:
 host_ref=host
 for id in Table.CUES:
  if not Table.CUES[id].has("recording"):
   if not stream_cache.has(id):stream_cache[id]=Wave.render(Table.CUES[id])
   streams[id]=stream_cache[id]
 for n in Table.VOICES:
  var voice=AudioStreamPlayer.new();voice.bus=host.EFFECTS_BUS;add_child(voice);voices.append(voice)
# Entry point for callers that own an event (field tools, research): sound.event_cue("sonobuoy").
# Plays at once when audible, honouring the id's repeat interval. Unknown ids are ignored.
func fire(id:String)->bool:
 if not Table.CUES.has(id):return false
 if host_ref.muted or host_ref.effects_volume<=0 or host_ref.system_suspended or lifecycle_suspended:return false
 return _play(id,false)
func request(id:String)->bool:
 if not Table.CUES.has(id):return false
 queued.append(id)
 return true
func _now()->float:
 return float(Time.get_ticks_msec())/1000.
func _play(id:String,frozen:bool)->bool:
 var row=Table.CUES[id];var now=_now()
 if now-float(last_play.get(id,-100.))<float(row.interval):return false
 last_play[id]=now;played.append(id)
 if row.has("recording"):host_ref.play(str(row.recording));return true
 var voice=voices[next_voice];next_voice=(next_voice+1)%voices.size()
 voice.stop();voice.stream=streams[id];voice.volume_db=row.gain_db
 voice.play();voice.stream_paused=frozen
 return true
func _flush(allowed:bool,frozen:bool)->void:
 played=[]
 var batch=queued;queued=[]
 if not allowed:return
 batch.sort_custom(func(a,b):return Table.CUES[a].priority>Table.CUES[b].priority)
 for id in batch:
  if played.size()>=Table.MAX_PER_FRAME:break
  if id not in played:_play(id,frozen)
func _materials(sim)->Dictionary:
 var found={}
 var m=sim.mission
 if m.has("module_recovery"):
  for item in m.module_recovery.modules:found["m:"+str(item)]=str(m.module_recovery.modules[item].get("state",""))
 for key in ["glass_reach","iron_choir"]:
  if m.has(key) and not m[key].get("artifact",{}).is_empty():found["a:"+key]=str(m[key].artifact.get("state",""))
 return found
# Field tool stock from mission["field_tools"]; a successful use spends one, a refused use spends none.
func _tools(sim)->Dictionary:
 var found={}
 var counts=sim.mission.get("field_tools",{}).get("counts",{})
 for id in Table.TOOLS:found[id]=int(counts.get(id,0))
 return found
func _raise(id:String,sim)->void:
 if request(id):host_ref.accessibility.note(id,sim.elapsed)
# Observed from state only: the hull percent a strike removed, a physical module or artifact
# reaching cargo, and the public survivor and handoff events. Held in the freeze, never replayed.
func advance(sim,_dt:float,active:bool)->void:
 var audible=not host_ref.muted and host_ref.effects_volume>0
 var allowed=audible and active and not host_ref.system_suspended and not lifecycle_suspended
 var frozen=sim.paused or not active or host_ref.system_suspended or lifecycle_suspended
 var found=_materials(sim);var tools=_tools(sim)
 var reports={}
 for id in sim.contacts:
  var contact=sim.contacts[id]
  if sim.elapsed-float(contact.time)<0.25 and contact.get("report_remaining",0)>0:reports[id]=true
 if not is_same(mission_ref,sim.mission) or sim.elapsed<last_clock:
  mission_ref=sim.mission;hull=sim.hull;materials=found;tool_counts=tools;reporting=reports;queued=[]
 elif active and not sim.paused and sim.outcome.is_empty():
  for id in reports:
   if not reporting.has(id):_raise("siren_report",sim)
  var hit=Table.hull_cue(hull-sim.hull)
  if not hit.is_empty():_raise(hit,sim)
  for key in found:
   if found[key]=="cargo" and materials.get(key,"cargo")!="cargo":_raise("artifact_secured",sim)
  for event in sim.events:
   var id={"witness_boarded":"survivor_aboard","witness_landed":"survivor_landed","data_handoff":"cargo_handoff"}.get(str(event.get("type","")),"")
   if not id.is_empty():_raise(id,sim)
 if active:
  for id in Table.TOOLS:
   if tools[id]<int(tool_counts.get(id,tools[id])):_raise(id,sim)
 last_clock=sim.elapsed;hull=sim.hull;materials=found;tool_counts=tools;reporting=reports
 _flush(allowed,frozen)
 if not audible or not active:
  for voice in voices:voice.stop()
 for voice in voices:voice.stream_paused=frozen
func _notification(what:int)->void:
 if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
  lifecycle_suspended=true
  for voice in voices:voice.stream_paused=true
 elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_WM_WINDOW_FOCUS_IN]:
  lifecycle_suspended=false
func _exit_tree()->void:
 for voice in voices:voice.stop();voice.stream=null
 streams.clear()
