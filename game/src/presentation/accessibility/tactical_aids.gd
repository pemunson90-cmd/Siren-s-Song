extends RefCounted
# Optional player pause hooks. Uses the existing any-craft acquisition signal and
# fresh received contacts; never changes sensing, lock accumulation or damage.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
# AI-DESIGNED UI episode rearm: brief contact/cover gaps must not demand
# repeated resume taps. This never changes an actual lock or warning display.
const LOCK_CLEAR_SECONDS=2.0
const Stun=preload("res://src/simulation/observed_stun.gd")
var host
var mission:Dictionary={}
var clock=-1.
var noticed:Dictionary={}
var lock_seen:Dictionary={}
var pending_notice=false
func bind(owner)->void:
 host=owner
 host.sim.siren_notice.connect(_notice)
func _reset()->void:
 var sim=host.sim
 if not is_same(mission,sim.mission) or sim.elapsed<clock:
  mission=sim.mission;noticed.clear();lock_seen.clear();pending_notice=false
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
 noticed.clear();lock_seen.clear();pending_notice=false
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
    lock_seen["%d:%d"%[id,target]]=float(time)
 # Older archives have no history. Prime their live craft acquisition and
 # received warnings so resuming the already paused dive does not replay them.
 for id in sim.sirens.size():
  var siren=sim.sirens[id];var target=int(siren.get("target",-1))
  if target>=0 and target<sim.units.size() and sim.units[target].alive and not siren.get("recipient_target",false):noticed[id]=true
 for pair in warnings():
  noticed[pair[0]]=true;lock_seen["%d:%d"%[pair[0],pair[1]]]=sim.elapsed
func warnings()->Array:
 var sim=host.sim;var ids=[]
 for id in sim.contacts:
  var c=sim.contacts[id];var target=int(c.get("target",-1));var age=sim.elapsed-float(c.time)
  if age<0 or age>=.3 or target<0 or target>=sim.units.size() or c.get("recipient_target",false):continue
  if not sim.units[target].alive or c.get("mode","")!="LOCKING" or c.get("lock",0)<=0 or c.lock>=4:continue
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
  var key="%d:%d"%[id[0],id[1]]
  if not lock_seen.has(key) or sim.elapsed-float(lock_seen[key])>=LOCK_CLEAR_SECONDS:new_lock=true
  lock_seen[key]=sim.elapsed
 if pending_notice or (new_lock and Settings.current.get("auto_pause_lock",false)):
  sim.paused=true
  sim.message="AUTO PAUSE: FIRST NOTICE" if pending_notice else "AUTO PAUSE: LOCK WARNING"
 pending_notice=false
func advance(dt:float)->void:
 # Observe between fixed steps so a long rendered frame cannot consume the
 # warning after the aid pauses. Keep the ordinary frame cap and accumulator.
 _reset()
 var enabled=Settings.current.get("auto_pause_notice",false) or Settings.current.get("auto_pause_lock",false)
 if not enabled:
  _advance(dt);observe();return
 var remaining=minf(dt,.25)
 while remaining>0.0000001 and not host.sim.paused and host.sim.outcome.is_empty():
  var amount=minf(remaining,host.sim.STEP)
  _advance(amount);observe();remaining-=amount
func _advance(dt:float)->void:
 if host.get("debug_console")!=null:host.debug_console.advance(dt)
 else:host.sim.advance(dt)
