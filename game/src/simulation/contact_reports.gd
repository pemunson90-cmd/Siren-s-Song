extends RefCounted
# One cached interest, one investigator. A report never supplies a live target,
# global alert or queue of interests (Klei's bounded-awareness pattern).
# Scales reuse the four-second beam, cruise acoustics and twelve-second search.
const CHARGE=2.0
const RANGE=430.0
const MEMORY=12.0
const GRID=80.0
static func advance(sim,observations:Array,fresh:Array,dt:float)->void:
 if sim.mission.get("contact_report_revision",0)!=1:return
 var completed=[]
 for id in sim.sirens.size():
  var s=sim.sirens[id];var seen=int(observations[id])
  if s.has("report_interest"):
   s.report_interest=maxf(0,s.report_interest-dt)
   if fresh[id]:s.erase("report_interest")
   elif s.report_interest<=0:
    s.erase("report_interest");s["attention_time"]=0.0;s.goal=s.home;s.route.clear();s.path_time=0.0
    if s.stun<=0 and s.get("pin_time",0)<=0:s.mode="PATROL" if s.get("type","patroller")=="patroller" else "RETURN"
  if not s.has("report"):
   if seen<0 or sim.sirens.size()<2:continue
   s["report"]={"target":-1,"point":Vector2.ZERO,"charge":0.0,"cooldown":0.0,"sent":0.0}
  var r=s.report;r.cooldown=maxf(0,r.cooldown-dt)
  r.sent=maxf(0,r.sent-dt)
  if s.stun>0 or s.get("pin_time",0)>0 or seen<0 or r.cooldown>0:
   r.charge=0.0;r.target=-1;continue
  if r.target!=seen:
   r.target=seen;r.charge=0.0;r.point=(sim.units[seen].pos/GRID).round()*GRID
  r.charge=minf(CHARGE,r.charge+dt)
  if r.charge+0.000001>=CHARGE:
   completed.append({"sender":id,"point":r.point})
   r.charge=0.0;r.target=-1;r.cooldown=MEMORY;r.sent=1.0
 # Resolve only after every Siren has had its own sensing/beam turn. Array order
 # cannot make a report override a receiver's current local evidence.
 var assigned=[]
 for report in completed:
  var source=sim.sirens[report.sender];var recipient=-1;var strength=0.0
  for id in sim.sirens.size():
   var peer=sim.sirens[id]
   if id==report.sender or id in assigned or fresh[id] or peer.stun>0 or peer.get("pin_time",0)>0:continue
   var arrivals=sim.acoustic_paths.arrivals(peer.pos,source.pos,650.0 if sim.mission.id==9 else RANGE)
   for arrival in arrivals:
    if arrival.strength>strength:strength=arrival.strength;recipient=id
  if recipient<0:continue
  assigned.append(recipient)
  var peer=sim.sirens[recipient]
  peer.goal=report.point;peer["last_known"]=report.point;peer["attention_time"]=MEMORY-CHARGE;peer["search_index"]=0
  peer["report_interest"]=MEMORY-CHARGE
  peer.suspicion=maxf(peer.suspicion,0.3);peer.mode="INVESTIGATE";peer.path_time=0.0;peer.route.clear()
static func valid(data:Dictionary)->bool:
 var enabled=data.mission.has("contact_report_revision")
 if enabled and (data.mission.get("id",-1) not in [5,9] or not data.mission.contact_report_revision is int or data.mission.contact_report_revision!=1 or data.mission.get("acoustic_revision",0)!=1):return false
 for s in data.sirens:
  if s is Dictionary and s.has("report_interest"):
   var interest=s.report_interest
   if not enabled or not (interest is int or interest is float) or not is_finite(float(interest)) or interest<=0 or interest>MEMORY-CHARGE:return false
  if not s is Dictionary or not s.has("report"):continue
  if not enabled or not s.report is Dictionary or s.report.size()!=5 or not s.report.has_all(["target","point","charge","cooldown","sent"]):return false
  var r=s.report
  if not r.target is int or r.target< -1 or r.target>=3 or not r.point is Vector2 or not r.point.is_finite():return false
  var bounds=data.mission.get("world_size",Vector2(1600,960))
  if r.point.x<0 or r.point.x>bounds.x or r.point.y<0 or r.point.y>bounds.y:return false
  for key in ["charge","cooldown","sent"]:
   if not (r[key] is int or r[key] is float) or not is_finite(float(r[key])) or r[key]<0:return false
  if r.charge>CHARGE or r.cooldown>MEMORY or r.sent>1.0 or (r.charge>0 and (r.target<0 or r.cooldown>0)):return false
 return true
