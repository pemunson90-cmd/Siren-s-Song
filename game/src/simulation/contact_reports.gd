extends RefCounted
# Revision 2 shares bounded stale evidence between patrollers. Revision 1 keeps
# its original one-investigator behavior for interrupted dives. A report never supplies a live target,
# global alert or queue of interests (Klei's bounded-awareness pattern).
# Report timing and range tuning is centralized here; sight and beam are unchanged.
const CHARGE=2.0 # Legacy revision 1 saves.
const RADIO_CHARGE=3.0 # AI-DESIGNED: completes before the protected four-second beam.
const ROLES=["patroller","hunter","sentinel"]
static func eligible(s)->bool:return s is Dictionary and s.get("type","patroller") in ROLES
static func configure(m:Dictionary)->void:
 if m.sirens.filter(eligible).size()>=2:m["contact_report_revision"]=2
static func charge(m:Dictionary)->float:return RADIO_CHARGE if m.get("contact_report_revision",0)==2 else CHARGE
const RANGE=430.0
const WAKE_RANGE=650.0
const SENT_CUE=1.0
const INTEREST=10.0
const MEMORY=12.0
const GRID=80.0
static func advance(sim,observations:Array,fresh:Array,dt:float,distractions:Array=[])->void:
 var revision=sim.mission.get("contact_report_revision",0)
 if revision not in [1,2]:return
 var duration=charge(sim.mission)
 var completed=[]
 for id in sim.sirens.size():
  var s=sim.sirens[id];var seen=int(observations[id])
  if revision==2 and not eligible(s):continue
  if s.has("report_interest"):
   s.report_interest=maxf(0,s.report_interest-dt)
   if fresh[id]:s.erase("report_interest")
   elif s.report_interest<=0:
    s.erase("report_interest");s["attention_time"]=0.0;s.goal=s.home;s.route.clear();s.path_time=0.0
    if s.stun<=0 and s.get("pin_time",0)<=0:s.mode="PATROL" if s.get("type","patroller")=="patroller" else "RETURN"
  if not s.has("report"):
   if seen<0 or sim.sirens.size()<2:continue
   s["report"]={"target":-1,"point":Vector2.ZERO,"charge":0.0,"cooldown":0.0,"sent":0.0,"band":sim.units[seen].transition.get("to",sim.units[seen].band)}
  var r=s.report;r.cooldown=maxf(0,r.cooldown-dt)
  r.sent=maxf(0,r.sent-dt)
  if s.stun>0 or s.get("pin_time",0)>0 or seen<0 or r.cooldown>0 or (revision==2 and (not distractions.is_empty() and distractions[id])):
   r.charge=0.0;r.target=-1;continue
  if revision==2 and r.target>=0 and r.target!=seen:
   r.charge=0.0;r.target=-1;continue
  if r.target!=seen:
   r.target=seen;r.charge=0.0;r.band=sim.units[seen].transition.get("to",sim.units[seen].band);r.point=(sim.units[seen].pos/GRID).round()*GRID
  if revision==2:
   r.point=((sim.units[seen].pos/GRID).round()*GRID).clamp(Vector2.ZERO,sim.world_size());r.band=sim.units[seen].transition.get("to",sim.units[seen].band)
  r.charge=minf(duration,r.charge+dt)
  if r.charge+0.000001>=duration:
   completed.append({"sender":id,"point":r.point,"band":r.band})
   r.charge=0.0;r.target=-1;r.cooldown=MEMORY;r.sent=SENT_CUE
 # Resolve only after every Siren has had its own sensing/beam turn. Array order
 # cannot make a report override a receiver's current local evidence.
 var assigned=[]
 for report in completed:
  var source=sim.sirens[report.sender];var recipients=[];var strength=0.0
  for id in sim.sirens.size():
   var peer=sim.sirens[id]
   if id==report.sender or id in assigned or fresh[id] or peer.stun>0 or peer.get("pin_time",0)>0:continue
   if revision==2 and not eligible(peer):continue
   var arrivals=sim.band_acoustics[peer.band].arrivals(peer.pos,source.pos,(WAKE_RANGE if sim.mission.id==9 else RANGE)*sim.Depth.transmission(peer,source))
   for arrival in arrivals:
    if revision==2:
     recipients.append(id);break
    elif arrival.strength>strength:strength=arrival.strength;recipients=[id]
  for recipient in recipients:
   assigned.append(recipient)
   var peer=sim.sirens[recipient]
   peer["known_band"]=report.band;peer.goal=report.point;peer["last_known"]=report.point;peer["attention_time"]=INTEREST;peer["search_index"]=0
   peer["report_interest"]=INTEREST
   peer.suspicion=maxf(peer.suspicion,0.3);peer.mode="INVESTIGATE";peer.path_time=0.0;peer.route.clear()
static func valid(data:Dictionary)->bool:
 var enabled=data.mission.has("contact_report_revision")
 var revision=data.mission.get("contact_report_revision",0)
 if enabled and (not revision is int or revision not in [1,2]):return false
 if revision==1 and (data.mission.get("id",-1) not in [5,9] or data.mission.get("acoustic_revision",0)!=1):return false
 if revision==2:
  if not data.mission.get("sirens") is Array:return false
  if data.mission.sirens.filter(eligible).size()<2:return false
 for s in data.sirens:
  if s is Dictionary and s.has("report_interest"):
   var interest=s.report_interest
   if not enabled or not (interest is int or interest is float) or not is_finite(float(interest)) or interest<=0 or interest>INTEREST:return false
  if not s is Dictionary or not s.has("report"):continue
  if not enabled or not s.report is Dictionary or s.report.size()!=6 or not s.report.has_all(["target","point","charge","cooldown","sent","band"]):return false
  var r=s.report
  if not r.band is int or r.band not in [0,1,2]:return false
  if not r.target is int or r.target< -1 or r.target>=3 or not r.point is Vector2 or not r.point.is_finite():return false
  var bounds=data.mission.get("world_size",Vector2(1600,960))
  if r.point.x<0 or r.point.x>bounds.x or r.point.y<0 or r.point.y>bounds.y:return false
  for key in ["charge","cooldown","sent"]:
   if not (r[key] is int or r[key] is float) or not is_finite(float(r[key])) or r[key]<0:return false
  if r.charge>charge(data.mission) or r.cooldown>MEMORY or r.sent>SENT_CUE or (r.charge>0 and (r.target<0 or r.cooldown>0)):return false
 return true
