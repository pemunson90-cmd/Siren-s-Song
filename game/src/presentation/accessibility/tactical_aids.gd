extends RefCounted
# Optional player pause hooks. Uses the existing any-craft acquisition signal and
# fresh received contacts; never changes sensing, lock accumulation or damage.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Stun=preload("res://src/simulation/observed_stun.gd")
var host
var mission:Dictionary={}
var clock=-1.
var noticed:Dictionary={}
var lock_ids:Array=[]
var pending_notice=false
func bind(owner)->void:
 host=owner
 host.sim.siren_notice.connect(_notice)
func _reset()->void:
 var sim=host.sim
 if not is_same(mission,sim.mission) or sim.elapsed<clock:
  mission=sim.mission;noticed.clear();lock_ids.clear();pending_notice=false
 clock=sim.elapsed
func _notice(id:int,_source:Vector2)->void:
 _reset()
 if host.screen!="mission" or not host.sim.outcome.is_empty():return
 if noticed.has(id):return
 noticed[id]=true
 if Settings.current.get("auto_pause_notice",false):pending_notice=true
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
 var new_lock=ids.any(func(id):return id not in lock_ids)
 lock_ids=ids
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
