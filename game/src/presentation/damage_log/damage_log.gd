extends Node
# Audit 091 F11: an after-the-moment hull damage record for the debrief. A presentation
# observer like DeathCauseLog: it reads sim.hull, sim.elapsed, sim.message, drone life and
# the field-tool collision ledger, and never writes the simulation, saves or any rule.
# Cause is stated only as far as the state shows it: a hull loss matched by the collision
# ledger is a collision (with the strike text the simulation printed); anything else is
# reported as not a collision, without inventing a source. Not persisted: after a reload
# the log starts empty and the debrief shows only what it actually observed.
# Revert: remove the install line in main.gd, the debrief() calls, and this folder.
const Effects=preload("res://src/simulation/field_tool_effects.gd")
const MERGE_SECONDS=2.0
const MIN_LOSS=0.5
const CAP=12
var sim
var owner_ref
var mission_ref:Dictionary={}
var clock=-1.
var hull=-1.
var collision=0.
var alive:Array=[]
var rows:Array=[]
static func install(owner)->void:
 var log=load("res://src/presentation/damage_log/damage_log.gd").new()
 log.name="DamageLog";log.owner_ref=owner;owner.hud.add_child(log);log.bind(owner.sim)
 log.process_mode=Node.PROCESS_MODE_ALWAYS
static func debrief(host)->void:
 var node=host.hud.get_node_or_null("DamageLog") if host.get("hud")!=null else null
 var text=node.summary() if node!=null else ""
 if not text.is_empty():host._menu_text(text,16)
func bind(source)->void:
 sim=source;_reset()
func _collision_ledger()->float:
 return float(Effects.state(sim).get("repairable_collision_loss",0.0)) if sim!=null and sim.mission.has(Effects.KEY) else 0.0
func _reset()->void:
 rows.clear();mission_ref=sim.mission if sim!=null else {}
 clock=sim.elapsed if sim!=null else -1.;hull=float(sim.hull) if sim!=null else -1.
 collision=_collision_ledger();alive=sim.units.map(func(u):return u.get("alive",true)) if sim!=null else []
func _process(_dt:float)->void:
 sample()
static func _clock(t:float)->String:
 return "%02d:%02d"%[int(t)/60,int(t)%60]
# Safe to call from tests or the debrief; only observes.
func sample()->void:
 if owner_ref!=null and is_instance_valid(owner_ref) and owner_ref.get("sim")!=null and not is_same(owner_ref.sim,sim):bind(owner_ref.sim)
 if sim==null:return
 if not is_same(mission_ref,sim.mission) or sim.elapsed<clock:_reset();return
 var now:float=float(sim.hull);var ledger=_collision_ledger()
 # Launch condition and other set-up writes happen without time passing: rebase silently.
 if sim.elapsed<=clock:
  hull=now;collision=ledger;clock=sim.elapsed;return
 var loss:float=hull-now
 if loss>=MIN_LOSS:
  var by_collision:float=clampf(ledger-collision,0.0,loss)
  if by_collision>=MIN_LOSS:_record("COLLISION",by_collision,now+(loss-by_collision),_strike_text())
  if loss-by_collision>=MIN_LOSS:_record("NOT A COLLISION",loss-by_collision,now,"")
 for i in sim.units.size():
  var was=alive[i] if i<alive.size() else true
  if i>0 and was and not sim.units[i].get("alive",true):
   rows.append({"t0":sim.elapsed,"t1":sim.elapsed,"kind":"LOST","craft":str(sim.units[i].get("name","DRONE")),"loss":0.0,"after":0.0,"note":""})
 alive=sim.units.map(func(u):return u.get("alive",true))
 while rows.size()>CAP:rows.pop_front()
 hull=now;collision=ledger;clock=sim.elapsed
func _strike_text()->String:
 var text=str(sim.message)
 if text.begins_with("Hull strike against "):return text.trim_prefix("Hull strike against ").get_slice(" · hull",0).replace(" · "," at ")
 return ""
func _record(kind:String,amount:float,after:float,note:String)->void:
 var t:float=sim.elapsed
 if not rows.is_empty() and rows[-1].kind==kind and t-rows[-1].t1<=MERGE_SECONDS:
  rows[-1].t1=t;rows[-1].loss+=amount;rows[-1].after=after
  if rows[-1].note.is_empty():rows[-1].note=note
  return
 rows.append({"t0":t,"t1":t,"kind":kind,"craft":"QUIETUS","loss":amount,"after":after,"note":note})
func events()->Array:
 return rows.duplicate(true)
# Plain lines for the debrief, or "" when nothing was observed.
func summary()->String:
 if sim==null:return ""
 sample()
 if rows.is_empty():return ""
 var total=0.0
 for row in rows:total+=row.loss
 var lines=["DAMAGE RECORD · QUIETUS HULL -%d%% THIS DIVE"%roundi(total) if total>0 else "DAMAGE RECORD"]
 for row in rows:
  var when=_clock(row.t0) if row.t1-row.t0<1.0 else "%s to %s"%[_clock(row.t0),_clock(row.t1)]
  match row.kind:
   "LOST":lines.append("%s · %s LOST"%[when,row.craft])
   "COLLISION":lines.append("%s · QUIETUS HULL -%d%% to %d%% · COLLISION%s"%[when,roundi(row.loss),roundi(row.after)," against "+row.note if not row.note.is_empty() else ""])
   _:lines.append("%s · QUIETUS HULL -%d%% to %d%% · NOT A COLLISION · a strike or hazard field"%[when,roundi(row.loss),roundi(row.after)])
 return "\n".join(lines)
