extends RefCounted
# Phase G read-only AI state trace for tests and debugging. Mirrors NoticeTracker:
# observes a Simulation, never writes to it, never touches saves or detection.
# Flag: AITraceTable.enabled (default false). Callers drive it: attach once, then call
# sample() (or step()) after each advance; nothing runs when not attached.
# Revert by deleting diagnostics/ai_trace*.gd and the test row; no other file refers to them.
const Table=preload("res://src/diagnostics/ai_trace_table.gd")
# Returns a recorder, or {} when the flag is off. per_tick also keeps one row per Siren per sample.
static func attach(sim,per_tick:bool=false,caps:Dictionary={})->Dictionary:
 if not Table.enabled or sim==null:return {}
 var rec={"t0":sim.elapsed,"per_tick":per_tick,"event_cap":int(caps.get("event_cap",Table.EVENT_CAP)),"tick_cap":int(caps.get("tick_cap",Table.TICK_CAP)),"events":[],"ticks":[],"dropped":0,"dropped_ticks":0,"last":{},"sirens":{},"pending":{},"samples":0}
 sim.siren_notice.connect(_on_notice.bind(rec))
 sample(rec,sim,true)
 return rec
static func detach(rec:Dictionary,sim)->void:
 if rec.is_empty() or sim==null:return
 var cb=_on_notice.bind(rec)
 if sim.siren_notice.is_connected(cb):sim.siren_notice.disconnect(cb)
static func _on_notice(id:int,_source:Vector2,rec:Dictionary)->void:
 rec.pending[id]=true
# Advance the simulation, then sample. Only for scripted runs; the game loop calls sample() itself.
static func step(rec:Dictionary,sim,dt:float)->void:
 sim.advance(dt)
 sample(rec,sim)
# baseline records each Siren's starting mode as the init row without counting a tick.
static func sample(rec:Dictionary,sim,baseline:bool=false)->void:
 if rec.is_empty():return
 if not baseline:rec.samples+=1
 var t:float=sim.elapsed
 for i in sim.sirens.size():
  var s=sim.sirens[i]
  var mode:String=str(s.get("mode",""))
  if not rec.sirens.has(i):rec.sirens[i]={"role":str(s.get("type",Table.DEFAULT_ROLE)),"notice":-1.,"lock":-1.,"detect":-1.,"beam":-1.,"transitions":0}
  var m=rec.sirens[i]
  var noticed:bool=rec.pending.has(i)
  if noticed:
   rec.pending.erase(i)
   if m.notice<0.:m.notice=t-rec.t0
  if (float(s.get("lock",0.))>0. or mode=="LOCKING") and m.lock<0.:m.lock=t-rec.t0
  if int(s.get("target",-1))>=0 and m.detect<0.:m.detect=t-rec.t0
  if mode=="BEAM" and m.beam<0.:m.beam=t-rec.t0
  var row={"t":t,"id":i,"role":m.role,"from":"","to":mode,"cause":"init","suspicion":float(s.get("suspicion",0.)),"alert_floor":float(s.get("alert_floor",0.)),"lock":float(s.get("lock",0.)),"target":int(s.get("target",-1)),"pos":s.pos,"band":int(s.get("band",1))}
  if not rec.last.has(i):
   rec.dropped+=_push(rec.events,row,rec.event_cap)
  elif rec.last[i]!=mode:
   m.transitions+=1
   row.from=rec.last[i];row.cause=_cause(rec.last[i],mode,s,sim,noticed)
   rec.dropped+=_push(rec.events,row,rec.event_cap)
  rec.last[i]=mode
  if rec.per_tick and not baseline:
   var tick=row.duplicate();tick.erase("from");tick.erase("cause")
   rec.dropped_ticks+=_push(rec.ticks,tick,rec.tick_cap)
static func _push(ring:Array,row:Dictionary,cap:int)->int:
 ring.append(row)
 if ring.size()>cap:
  ring.pop_front()
  return 1
 return 0
# Best-effort reason derived from fields the simulation already exposes.
static func _cause(from:String,to:String,s:Dictionary,sim,noticed:bool)->String:
 if to in Table.STUNNED:return "stun"
 if to=="LOCKING":return "sight"
 if to=="BEAM":return "timer"
 if to=="INVESTIGATE":
  if s.has("report_interest"):return "report"
  var label:String=_noise_label(s,sim)
  if label.contains("DECOY"):return "decoy"
  return "sound:"+label if label!="" else ("sound" if noticed else "heard")
 if from in Table.STUNNED:return "stun_end"
 if from in Table.LOCKISH:return "lost_target"
 return "timer"
static func _noise_label(s:Dictionary,sim)->String:
 var goal=s.get("last_known",s.get("goal",null))
 if not goal is Vector2:return ""
 var best=Table.NOISE_MATCH
 var label=""
 for n in sim.noises:
  var d=n.pos.distance_to(goal)
  if d<best:best=d;label=str(n.get("label",""))
 return label
# Derived metrics. Times are seconds since attach; -1 means it never happened.
static func metrics(rec:Dictionary)->Dictionary:
 var per={}
 var total=0
 var first_notice=-1.
 var first_lock=-1.
 var noticed=0
 for i in rec.get("sirens",{}):
  var m=rec.sirens[i]
  per[i]={"role":m.role,"time_to_first_notice":m.notice,"time_to_lock_start":m.lock,"time_to_detection":m.detect,"time_to_beam":m.beam,"transitions":m.transitions}
  total+=m.transitions
  if m.notice>=0.:
   noticed+=1
   if first_notice<0. or m.notice<first_notice:first_notice=m.notice
  if m.lock>=0. and (first_lock<0. or m.lock<first_lock):first_lock=m.lock
 return {"sirens":per,"transitions":total,"noticed":noticed,"first_notice":first_notice,"first_lock":first_lock,"samples":rec.get("samples",0),"dropped":rec.get("dropped",0),"dropped_ticks":rec.get("dropped_ticks",0)}
# Full deterministic dump: same seed and script give an identical dictionary.
static func export(rec:Dictionary)->Dictionary:
 if rec.is_empty():return {}
 return {"events":rec.events.duplicate(true),"ticks":rec.ticks.duplicate(true),"metrics":metrics(rec)}
