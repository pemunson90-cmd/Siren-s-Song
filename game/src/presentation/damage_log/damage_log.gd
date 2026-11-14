extends Node
const Names=preload("res://src/names.gd")
# Audit 091 F11: an after-the-moment hull damage record for the debrief. A presentation
# observer like DeathCauseLog: it reads sim.hull, sim.elapsed, sim.message, drone life and
# the field-tool collision ledger, and never writes the simulation, saves or any rule.
# Cause is stated only as far as the state shows it: a hull loss matched by the collision
# ledger is a collision (with the strike text the simulation printed); anything else is
# reported as not a collision, without inventing a source. Not persisted: after a reload
# the log starts empty and the debrief shows only what it actually observed.
# Revert: remove the install line in main.gd, the debrief() calls, and this folder.
const Effects=preload("res://src/simulation/field_tool_effects.gd")
const Economy=preload("res://src/campaign/economy.gd")
const LossSummary=preload("res://src/presentation/loss_summary.gd")
const MERGE_SECONDS=2.0
const MIN_LOSS=0.000001
const CAP=12
# Plain words for every hull loss the record can name. Collisions come from the strike text.
const START_LINE="The dive began at Hull %d%%, damage carried from an earlier dive."
const CAUSE_BEAM="a Siren beam"
const CAUSE_BURST="an Interceptor burst"
const CAUSE_FIELD="a Warden pressure field"
const CAUSE_UNKNOWN="a cause the game does not record"
const FLOOR_LINE="Quietus came home at %d%% and is recorded at %d%%, the lowest this difficulty records after a loss."
const REPAIR_LINE="Quietus hull is recorded at %d%%. It stays that way until repaired: open SUPPLIES and choose REPAIR QUIETUS HULL (%s) before the next dive."
const REPAIR_FREE="Quietus hull is recorded at %d%%. It stays that way until repaired in SUPPLIES (REPAIR QUIETUS HULL)."
var sim
var owner_ref
var mission_ref:Dictionary={}
var clock=-1.
var hull=-1.
var collision=0.
var alive:Array=[]
var rows:Array=[]
var total_loss=0.0
var start_hull=100.
var trimmed=false
static func install(owner)->void:
 var log=load("res://src/presentation/damage_log/damage_log.gd").new()
 log.name="DamageLog";log.owner_ref=owner;owner.hud.add_child(log);log.bind(owner.sim)
 log.process_mode=Node.PROCESS_MODE_ALWAYS
static func debrief(host)->void:
 var node=host.hud.get_node_or_null("DamageLog") if host.get("hud")!=null else null
 var text=node.summary() if node!=null else ""
 if not text.is_empty():host._menu_text(text,16)
 var floor_text=floor_line(host)
 if not floor_text.is_empty():host._menu_text(floor_text,16)
 var repair=repair_line(host)
 if not repair.is_empty():host._menu_text(repair,16)
# Why the recorded hull differs from the hull at the end of the dive: the difficulty's lowest recorded condition.
static func floor_line(host)->String:
 var e=host.get("economy")
 if not e is Dictionary or not Economy.Table.enabled or Economy.preset(e).replenish or host.get("sim")==null:return ""
 var cond:int=int(e.cond.get(Names.CRAFT_QUIETUS,100))
 var ended:int=roundi(host.sim.hull)
 return FLOOR_LINE%[ended,cond] if cond>ended and cond==int(Economy.preset(e).floor) else ""
# Where the Campaign and Career offer a hull repair; "" when the hull is whole or mends by itself.
static func repair_line(host)->String:
 var e=host.get("economy")
 if not e is Dictionary or not Economy.Table.enabled or Economy.preset(e).replenish:return ""
 var cond:int=int(e.cond.get(Names.CRAFT_QUIETUS,100))
 if cond>=100:return ""
 var cost:Dictionary=Economy.repair_cost(e,Names.CRAFT_QUIETUS)
 return REPAIR_LINE%[cond,Economy.fmt(cost).to_lower()] if not cost.is_empty() else REPAIR_FREE%cond
func bind(source)->void:
 sim=source;_reset()
func _collision_ledger()->float:
 return float(Effects.state(sim).get("repairable_collision_loss",0.0)) if sim!=null and sim.mission.has(Effects.KEY) else 0.0
func _reset()->void:
 rows.clear();total_loss=0.0;trimmed=false;mission_ref=sim.mission if sim!=null else {}
 clock=sim.elapsed if sim!=null else -1.;hull=float(sim.hull) if sim!=null else -1.
 start_hull=hull
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
  hull=now;start_hull=now;collision=ledger;clock=sim.elapsed;return
 var loss:float=hull-now
 if loss>=MIN_LOSS:
  total_loss+=loss
  var by_collision:float=clampf(ledger-collision,0.0,loss)
  if by_collision>=MIN_LOSS:_record("COLLISION",by_collision,now+(loss-by_collision),_strike_text())
  if loss-by_collision>=MIN_LOSS:_record("NOT A COLLISION",loss-by_collision,now,_cause_text())
 for i in sim.units.size():
  var was=alive[i] if i<alive.size() else true
  if i>0 and was and not sim.units[i].get("alive",true):
   rows.append({"t0":sim.elapsed,"t1":sim.elapsed,"kind":"LOST","craft":str(sim.units[i].get("name","DRONE")),"loss":0.0,"after":0.0,"note":""})
 alive=sim.units.map(func(u):return u.get("alive",true))
 while rows.size()>CAP:rows.pop_front();trimmed=true
 hull=now;collision=ledger;clock=sim.elapsed
func _strike_text()->String:
 var text=str(sim.message)
 if text.begins_with("Hull strike against "):return text.trim_prefix("Hull strike against ").get_slice(" · hull",0).replace(" · "," at ")
 return ""
# The cause of a hull loss that was not a collision, read from state the simulation already keeps.
func _cause_text()->String:
 if LossSummary.beam_struck(sim):return CAUSE_BEAM
 var quietus=sim.units[0]
 for siren in sim.sirens:
  var state=siren.get("industry")
  if not state is Dictionary:continue
  if siren.get("type","")==Names.ROLE_INTERCEPTOR and state.get("phase","")=="burst" and 0 in state.get("hit",[]):return CAUSE_BURST
  if siren.get("type","")==Names.ROLE_WARDEN:
   for patch in state.get("patches",[]):
    if quietus.pos.distance_to(patch.pos)<float(patch.radius):return CAUSE_FIELD
 return CAUSE_UNKNOWN
func _record(kind:String,amount:float,after:float,note:String)->void:
 var t:float=sim.elapsed
 if not rows.is_empty() and rows[-1].kind==kind and t-rows[-1].t1<=MERGE_SECONDS:
  rows[-1].t1=t;rows[-1].loss+=amount;rows[-1].after=after
  if rows[-1].note.is_empty():rows[-1].note=note
  return
 rows.append({"t0":t,"t1":t,"kind":kind,"craft":Names.UNIT_QUIETUS,"loss":amount,"after":after,"note":note})
func events()->Array:
 return rows.duplicate(true)
# Plain lines for the debrief, or "" when nothing was observed.
func summary()->String:
 if sim==null:return ""
 sample()
 if rows.is_empty() and start_hull>=100.:return ""
 var lines=["DAMAGE RECORD · QUIETUS HULL -%d%% OBSERVED"%roundi(total_loss) if total_loss>0 else "DAMAGE RECORD"]
 if start_hull<100.:lines.append(START_LINE%roundi(start_hull))
 if trimmed:lines.append("Most recent %d events shown."%CAP)
 for row in rows:
  var when=_clock(row.t0) if row.t1-row.t0<1.0 else "%s to %s"%[_clock(row.t0),_clock(row.t1)]
  match row.kind:
   "LOST":lines.append("%s · %s LOST"%[when,row.craft])
   "COLLISION":lines.append("%s · QUIETUS HULL -%d%% to %d%% · COLLISION%s"%[when,roundi(row.loss),roundi(row.after)," against "+row.note if not row.note.is_empty() else ""])
   _:
    var note:String=row.note if not row.note.is_empty() else CAUSE_UNKNOWN
    # The final row may have been written a moment before the lock showed in the contacts.
    if note==CAUSE_UNKNOWN and is_same(row,rows[-1]) and LossSummary.beam_struck(sim):note=CAUSE_BEAM
    lines.append("%s · QUIETUS HULL -%d%% to %d%% · %s"%[when,roundi(row.loss),roundi(row.after),note])
 return "\n".join(lines)
