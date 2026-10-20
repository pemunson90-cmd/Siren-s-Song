extends RefCounted
# V7 action/evidence pressure, adapted to local, earned hostile awareness.
# The own operational estimate never supplies a remote guard's knowledge.
static func state(m:Dictionary)->Dictionary:
 return m.get("reconnaissance",{"hunt":0.0,"floor":0.0,"delay":0.0,"secured":[]})
static func action(m:Dictionary,amount:float)->void:
 var p=state(m).duplicate(true);p.hunt=minf(100,p.hunt+amount);p.delay=6.0;m.reconnaissance=p
static func tick(m:Dictionary,dt:float)->void:
 var p=state(m).duplicate(true)
 p.hunt+=dt*.2
 if p.delay>0:p.delay=maxf(0,p.delay-dt)
 else:p.hunt-=dt
 p.hunt=clampf(p.hunt,p.floor,100);m.reconnaissance=p
static func heard(guard:Dictionary,arrival:Dictionary)->void:
 if not arrival.get("pulse",false):return
 guard["alert_floor"]=maxf(float(guard.get("alert_floor",0)),.12)
 if arrival.has("record"):
  if not guard.has("heard_records"):guard.heard_records=[]
  if arrival.record not in guard.heard_records:guard.heard_records.append(arrival.record)
static func seen(guard:Dictionary)->void:
 guard["alert_floor"]=maxf(float(guard.get("alert_floor",0)),.12)
static func readiness(guard:Dictionary)->float:
 var floor=float(guard.get("alert_floor",0))*100
 return 1.7 if floor>=90 else 1.5 if floor>=70 else 1.3 if floor>=45 else 1.15 if floor>=20 else 1.0
static func secured(sim,record:Dictionary,unit_id:int)->void:
 var index=sim.mission.objectives.find(record)
 var p=state(sim.mission).duplicate(true)
 if index not in p.secured:
  p.secured.append(index);p.floor=minf(100,p.secured.size()*8.0);p.hunt=maxf(p.floor,minf(100,p.hunt+8));p.delay=6.0
  for guard in sim.sirens:
   if index in guard.get("heard_records",[]) or (unit_id>=0 and guard.stun<=0 and guard.target==unit_id):
    guard["alert_floor"]=minf(.9,float(guard.get("alert_floor",0))+.12)
    guard.suspicion=maxf(guard.suspicion,guard.alert_floor)
 sim.mission.reconnaissance=p
 if unit_id<0 or record.get("kind","") not in ["","photo"]:return
 var distance=sim.units[unit_id].pos.distance_to(record.pos)
 var proximity=clampf(1.0-distance/240.0,0,1)
 record["photo_quality"]=(.55 if unit_id>0 else .25)+.45*proximity
 record["photo_craft"]=sim.units[unit_id].name
 record["photo_distance"]=distance
static func grade(records:Array)->Dictionary:
 var total=0.0;var count=0
 for record in records:
  if record.has("photo_quality"):
   total+=float(record.photo_quality);count+=1
 if count==0:return {"photos":0,"quality":0.0,"grade":""}
 var quality=total/count
 return {"photos":count,"quality":quality,"grade":"A" if quality>=.95 else "B" if quality>=.7 else "C"}
static func feedback(sim)->Dictionary:
 var intensity=0.0
 # Fresh received contacts only: hidden locks or unseen guards cannot drive cues.
 for c in sim.contacts.values():
  if sim.elapsed-c.time>.4:continue
  intensity=maxf(intensity,clampf(float(c.get("lock",0))/4.0,0,1))
 var p=state(sim.mission)
 var stage=4 if p.hunt>=90 else 3 if p.hunt>=70 else 2 if p.hunt>=45 else 1 if p.hunt>=20 else 0
 return {"hunt":p.hunt,"floor":p.floor,"stage":["DORMANT","STIRRING","SEARCHING","HUNTING","LOCKDOWN"][stage],"threat":intensity,"hostile":intensity>=.75,"grade":grade(sim.mission.objectives)}
