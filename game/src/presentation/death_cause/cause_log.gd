extends Node
# Why the Siren came: a presentation-side observer with a bounded ring buffer of the last
# WINDOW seconds of own-craft emissions and loud motion. Read-only: it never writes the
# simulation, saves or any detection rule; it copies labels from sim.noises and reads
# sim.motion_radius()/contacts/elapsed. Mirrors NoticeTracker (clear on mission change).
# The sim stores no cause, so this log is not persisted: after a reload there is no record
# and the debrief shows no cause line (never an invented one).
# Revert: remove the install line in main.gd, the debrief() calls in loss debriefs, and this folder.
const Table=preload("res://src/presentation/death_cause/cause_table.gd")
const NoticeSources=preload("res://src/presentation/first_siren_cue/cue_table.gd")
var sim
var mission_ref:Dictionary={}
var clock=-1.
var ring:Array=[]
var seen_noises:Array=[]
var lock_start:Dictionary={}
var noticed:Dictionary={}  # siren index -> recent sim.elapsed times of siren_notice (bounded by WINDOW and NOTICE_CAP)
static func install(owner)->void:
 var log=load("res://src/presentation/death_cause/cause_log.gd").new()
 log.name="DeathCauseLog";owner.hud.add_child(log);log.bind(owner.sim)
 log.process_mode=Node.PROCESS_MODE_ALWAYS
static func debrief(host)->void:
 var node=host.hud.get_node_or_null("DeathCauseLog") if host.get("hud")!=null else null
 var text=node.line() if node!=null else ""
 if not text.is_empty():host._menu_text(text,17)
func bind(source)->void:
 sim=source;_reset()
 if sim!=null and sim.has_signal("siren_notice") and not sim.siren_notice.is_connected(_on_notice):sim.siren_notice.connect(_on_notice)
func _on_notice(id:int,_at:Vector2)->void:
 # siren_notice fires on many ticks while a Siren hears or sees the craft; keep a bounded recent list per Siren.
 var list:Array=noticed.get(id,[])
 if not list.is_empty() and sim.elapsed-float(list[-1])<Table.NOTICE_STEP:return  # thin the per-tick stream
 list.append(sim.elapsed)
 while list.size()>Table.NOTICE_CAP or (not list.is_empty() and sim.elapsed-list[0]>Table.WINDOW+Table.NOTICE_LEAD):list.pop_front()
 noticed[id]=list
func _reset()->void:
 ring.clear();seen_noises.clear();lock_start.clear();noticed.clear()
 mission_ref=sim.mission if sim!=null else {};clock=sim.elapsed if sim!=null else -1.
func _process(_dt:float)->void:
 sample()
# Safe to call from tests or the debrief; only observes.
func sample()->void:
 if sim==null or not Table.enabled:return
 if not is_same(mission_ref,sim.mission) or sim.elapsed<clock:_reset()
 clock=sim.elapsed
 var t:float=sim.elapsed
 var live:Array=[]
 for n in sim.noises:
  live.append(n)
  var label=str(n.get("label",""))
  if label not in NoticeSources.CRAFT_EMISSIONS or _was_seen(n):continue
  seen_noises.append(n);_push({"t":t,"kind":"emission","label":label,"unit":-1})
 seen_noises=seen_noises.filter(func(n):return live.any(func(l):return is_same(l,n)))
 for i in sim.units.size():
  var u=sim.units[i]
  if not u.get("alive",true) or u.get("name","")=="":continue
  var radius:float=sim.motion_radius(i)
  if radius<Table.MOTION_RADIUS:continue
  if not ring.is_empty() and ring[-1].kind=="motion" and ring[-1].unit==i and t-ring[-1].t<Table.MOTION_MERGE:ring[-1].t=t
  else:_push({"t":t,"t0":t,"kind":"motion","label":"","unit":i})
 var current:Array=[]
 for id in sim.contacts:
  var c=sim.contacts[id]
  if c.get("mode","") in Table.LOCKISH and c.get("target",-1)==0:
   current.append(id)
   if not lock_start.has(id):lock_start[id]=float(c.get("time",t))
 for id in lock_start.keys():
  if id not in current:lock_start.erase(id)
func _was_seen(n)->bool:
 for s in seen_noises:
  if is_same(s,n):return true
 return false
func _push(row:Dictionary)->void:
 ring.append(row)
 ring=ring.filter(func(r):return sim.elapsed-r.t<=Table.WINDOW)
 while ring.size()>Table.CAP:ring.pop_front()
# One plain line, or "" when no cause can be shown.
func line()->String:
 if sim==null or not Table.enabled or sim.outcome!="lost" or sim.units.is_empty():return ""
 sample()
 var oxygen=sim.get("oxygen")
 if (oxygen is float or oxygen is int) and oxygen<=0:return ""
 if not "Siren beam" in sim.message:return ""
 var elapsed:float=sim.elapsed;var pick=-1;var pick_t=-1.
 for id in sim.contacts:
  var c=sim.contacts[id]
  if elapsed-float(c.get("time",-100.))>1. or c.get("target",-1)!=0 or c.get("mode","") not in Table.LOCKISH:continue
  var start:float=lock_start.get(id,float(c.get("time",elapsed)))
  if pick<0 or start<pick_t:pick=id;pick_t=start
 if pick<0:return ""
 # Only blame an own emission or loud motion that this Siren reacted to: a siren_notice from it must follow within
 # NOTICE_LEAD seconds. An old shutter or engine burst is not blamed for a plain sight-line lock.
 var best={}
 for row in ring:
  if row.kind=="emission" and row.t<=pick_t+0.001 and pick_t-row.t<=Table.WINDOW and _reacted(pick,row.t,row.t) and (best.is_empty() or row.t>best.t):best=row
 if not best.is_empty():return Table.DRAWN%[Table.EMISSION_PHRASE.get(best.label,best.label),maxi(0,roundi(pick_t-best.t))]
 for row in ring:
  if row.kind=="motion" and pick_t-row.t<=Table.WINDOW and _reacted(pick,float(row.get("t0",row.t)),row.t):return Table.MOVING%_name(row.unit)
 if str(sim.contacts[pick].get("source",""))=="optical":return Table.SIGHT%_name(0)
 return ""
func _name(i:int)->String:
 return str(sim.units[i].get("name","Quietus")).capitalize()
func _reacted(id:int,t0:float,t1:float)->bool:
 # True when this Siren sent a siren_notice during the emission or motion, or within NOTICE_LEAD seconds after it.
 for nt in noticed.get(id,[]):
  if nt>=t0-0.001 and nt-t1<=Table.NOTICE_LEAD:return true
 return false
