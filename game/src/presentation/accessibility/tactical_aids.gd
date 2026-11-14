extends RefCounted
# Optional player pause hooks. Uses the existing any-craft acquisition signal and
# fresh received contacts; never changes sensing, lock accumulation or damage.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Stun=preload("res://src/simulation/observed_stun.gd")
const TrialRules=preload("res://src/trial_rules.gd")
const AutoPause=preload("res://src/presentation/auto_pause.gd")
# THREAT READ seam: drone loss cause line and the optional craft-loss pause (threat_read/).
const ThreatRead=preload("res://src/presentation/threat_read/threat_read.gd")
# AI-DESIGNED UI episode rearm: brief contact/cover gaps must not demand
# repeated resume taps. This never changes an actual lock or warning display.
const LOCK_CLEAR_SECONDS=2.0
var host
var mission:Dictionary={}
var clock=-1.
var noticed:Dictionary={}
var lock_seen:Dictionary={}
# The lock progress last received for each pair. A lock whose received progress has risen since it was last seen
# is the same lock, however long the gap between fresh reports: a Siren's report can go quiet for longer than
# LOCK_CLEAR_SECONDS while it keeps locking, and treating each report as a new lock paused the dive again and again
# (critic 13 Nov: about eight resumes for one lock). Not saved: after a restore the time rule alone applies.
var lock_level:Dictionary={}
var pending_notice=false
# Every automatic pause goes through this one object (presentation/auto_pause.gd).
var auto_pause=AutoPause.new()
static func _pair_key(id:int,target:int)->String:return "%d:%d"%[id,target]
func bind(owner)->void:
 host=owner
 host.sim.siren_notice.connect(_notice)
func _reset()->void:
 var sim=host.sim
 if not is_same(mission,sim.mission) or sim.elapsed<clock:
  mission=sim.mission;noticed.clear();lock_seen.clear();lock_level.clear();pending_notice=false
 clock=sim.elapsed
func _notice(id:int,_source:Vector2)->void:
 _reset()
 if host.screen!="mission" or not host.sim.outcome.is_empty():return
 if noticed.has(id):return
 noticed[id]=true
 if Settings.current.get("auto_pause_notice",false):pending_notice=true
func saved_history()->Dictionary:
 _reset()
 var locks=[]
 for key in lock_seen:
  if host.sim.elapsed-float(lock_seen[key])>=LOCK_CLEAR_SECONDS:continue
  var pair=key.split(":")
  locks.append([int(pair[0]),int(pair[1]),lock_seen[key]])
 return {"noticed":noticed.keys(),"locks":locks}
func restore_history(value=null)->void:
 # Optional presentation history never changes or invalidates a simulation save.
 mission=host.sim.mission;clock=host.sim.elapsed
 noticed.clear();lock_seen.clear();lock_level.clear();pending_notice=false
 var sim=host.sim
 if value is Dictionary:
  var ids=value.get("noticed",[])
  if ids is Array and ids.size()<=sim.sirens.size():
   for id in ids:
    if id is int and id>=0 and id<sim.sirens.size():noticed[id]=true
  var locks=value.get("locks",[])
  if locks is Array and locks.size()<=sim.sirens.size()*sim.units.size():
   for row in locks:
    if not row is Array or row.size()!=3:continue
    var id=row[0];var target=row[1];var time=row[2]
    if not id is int or id<0 or id>=sim.sirens.size() or not target is int or target<0 or target>=sim.units.size():continue
    if not (time is int or time is float) or not is_finite(time) or time<0 or time>sim.elapsed or sim.elapsed-time>=LOCK_CLEAR_SECONDS:continue
    lock_seen[_pair_key(id,target)]=float(time)
 # Older archives have no history. Prime their live craft acquisition and
 # received warnings so resuming the already paused dive does not replay them.
 for id in sim.sirens.size():
  var siren=sim.sirens[id];var target=int(siren.get("target",-1))
  if target>=0 and target<sim.units.size() and sim.units[target].alive and not siren.get("recipient_target",false):noticed[id]=true
 for pair in warnings():
  noticed[pair[0]]=true;lock_seen[_pair_key(pair[0],pair[1])]=sim.elapsed
func warnings()->Array:
 var sim=host.sim;var ids=[];var seconds:float=sim.lock_seconds()
 for id in sim.contacts:
  var c=sim.contacts[id];var target=int(c.get("target",-1));var age=sim.elapsed-float(c.time)
  if age<0 or age>=.3 or target<0 or target>=sim.units.size() or c.get("recipient_target",false):continue
  if not sim.units[target].alive or c.get("mode","")!="LOCKING" or c.get("lock",0)<=0 or c.lock>=seconds:continue
  if Stun.remaining(c,sim.elapsed)>0 or not sim.Depth.sight(sim,c,sim.units[target]):continue
  ids.append([id,target])
 return ids
func observe()->void:
 _reset()
 var sim=host.sim
 if host.screen!="mission" or not sim.outcome.is_empty():pending_notice=false;return
 var ids=warnings()
 var new_lock=false
 for id in ids:
  var key=_pair_key(id[0],id[1])
  var level:float=float(sim.contacts[id[0]].get("lock",0.0))
  var continuing:bool=lock_level.has(key) and level>float(lock_level[key])
  if not lock_seen.has(key) or (sim.elapsed-float(lock_seen[key])>=LOCK_CLEAR_SECONDS and not continuing):new_lock=true
  lock_seen[key]=sim.elapsed;lock_level[key]=level
 var losses=ThreatRead.observe(sim);var lost=not losses.is_empty() and ThreatRead.pause_wanted()
 # Trial rule 4 (trial_rules.gd): a new lock pauses the dive whatever the accessibility setting says.
 var pause_for_lock=new_lock and (Settings.current.get("auto_pause_lock",false) or TrialRules.pause_on_every_lock())
 if pending_notice or pause_for_lock or lost:
  var reason="FIRST NOTICE" if pending_notice else "LOCK WARNING" if pause_for_lock else ""
  # A loss in the same step keeps its cause line first (THREAT READ); otherwise the original text.
  var message=ThreatRead.pause_message(sim,reason) if not losses.is_empty() else "AUTO PAUSE: "+reason
  auto_pause.request(host,"notice" if pending_notice else "lock" if pause_for_lock else "",-1,message)
 pending_notice=false
 # Trial rule 5: a craft held by rock pauses the dive once for that hold.
 auto_pause.observe_blocked(host)
# A8 step 1: the dive's clock lives in src/dive_clock.gd. The aids only say
# whether they need to look after every fixed step, and look.
func begin_frame()->void:_reset()
func slices_steps()->bool:
 return Settings.current.get("auto_pause_notice",false) or Settings.current.get("auto_pause_lock",false) or ThreatRead.pause_wanted() or TrialRules.pause_on_every_lock()
# Kept for callers that still advance a dive through the aids (tests).
func advance(dt:float)->void:
 preload("res://src/dive_clock.gd").advance(host,self,dt)
