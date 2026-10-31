extends RefCounted
# 127 (Pat 2026-10-30): scripted journeys here fly the dev/test pathfinder route; hand_pilot_journeys covers release play.
#116 source-known ordinary SILENT voyages. The off switch is a controlled report-only
# counterfactual, never a player policy. Phase B also measures the fetched source base.
const P=preload("res://tests/thermal_operation_plan.gd")
const C=preload("res://tests/calder_trench_journey_tests.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
class Voyage:
 extends "res://tests/thermal_operation_plan.gd".Voyage
 var sent=0
 var received=0
 var lock_by={}
 var max_lock={}
 var interrupted=false
 var reacted=false
 func advance(dt:float)->void:
  var before=elapsed
  var cooldown=sirens.map(func(e):return e.get("report",{}).get("cooldown",0.))
  super.advance(dt)
  if elapsed<=before:return
  for i in sirens.size():
   var e=sirens[i]
   if cooldown[i]<=0 and e.get("report",{}).get("cooldown",0.)>0:sent+=1
   if e.has("report_interest"):received+=1
   if e.target==0 and e.lock>0:
    lock_by[i]=float(lock_by.get(i,0.))+elapsed-before
    max_lock[i]=maxf(float(max_lock.get(i,0.)),e.lock)
 func radio_metrics()->Dictionary:
  var row=metrics();row.sent=sent;row.received_frames=received;row.lock_by=lock_by;row.max_lock=max_lock
  row.quietus_lock_total=lock_by.values().reduce(func(a,b):return a+b,0.)
  row.interrupted=interrupted;row.reacted=reacted;row.position=[units[0].pos.x,units[0].pos.y]
  return row
static func approach(s,point:Vector2,equipped:bool)->bool:
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(1./60)
  if not s.outcome.is_empty():break
  for id in s.contacts:
   var c=s.contacts[id]
   if s.elapsed-c.time>=.25 or c.get("report_remaining",0.)<=0:continue
   s.paused=true;s.reacted=true
   var ok=true
   if equipped:
    ok=s.command("emp");P.tick(s,.1)
   elif s.mission.id==31:ok=P.go(s,0,Vector2(1700,1100))
   else:ok=P.go(s,0,Vector2(1760,1700))
   var report=s.sirens[id].get("report",{})
   s.interrupted=report.get("charge",0.)==0 and report.get("cooldown",0.)==0
   return ok and s.interrupted
 s.paused=true
 return false
static func play(id:int,policy:String,preset="standard",reports_off=false):
 var s=Voyage.new();s.use_flash=false
 var racks=Racks.empty()
 if policy=="equipped":racks.quietus={"emp":2}
 s.start(id,"endurance",{"tool_racks":racks});s.mission["dev"]=true
 var economy=preload("res://src/campaign/economy.gd")
 economy.apply_launch(economy.new_state(preset),s)
 # Park the unfitted drones in a different band through ordinary orders. They do
 # no work and cannot bait a peer away from Quietus during this causal comparison.
 for u in [1,2]:
  s.command("select",{"unit":u});s.command("depth",{"band":2 if id==31 else 0})
 s.command("select",{"unit":0})
 if reports_off:s.mission.erase("contact_report_revision")
 var ok=true
 if id==31:
  ok=P.shift(s,0,0) and P.go(s,0,Vector2(400,1300)) and P.shift(s,0,1) and P.go(s,0,Vector2(880,1000)) and P.record(s,0,0,true)
  for point in [Vector2(880,1300),Vector2(1700,1300),Vector2(1700,950)]:ok=P.go(s,0,point) and ok
  if policy in ["interrupt","equipped"]:
   ok=approach(s,s.mission.extraction,policy=="equipped") and ok
   if policy=="interrupt":ok=P.go(s,0,Vector2(2100,1100)) and P.go(s,0,Vector2(2100,300)) and ok
 else:
  # Shared job prefix ends after cargo pickup and the return to the deep lip.
  # The radio policies choose their own exposed or covered return from there.
  for step in C.steps(id,s).slice(0,8):
   var accepted=false
   match step[0]:
    "go":accepted=P.go(s,0,step[1])
    "dive":accepted=P.shift(s,0,step[1])
    "shoot":accepted=C.expose(s,C.obj(s,step[1]))
    "cargo":accepted=C.recover_cargo(s)
   ok=accepted and ok
  ok=P.shift(s,0,1) and P.go(s,0,Vector2(1910,1700)) and ok
  if policy in ["interrupt","equipped"]:
   ok=approach(s,Vector2(2380,1700),policy=="equipped") and ok
   if policy=="interrupt":ok=P.shift(s,0,2) and ok
  var exit_points=[Vector2(1760,1950),Vector2(2800,1950),Vector2(2800,1900)] if policy=="interrupt" else [Vector2(2420,1700),Vector2(2420,1900),Vector2(2800,1900)]
  for point in exit_points:ok=P.go(s,0,point) and ok
  if policy=="interrupt":ok=P.shift(s,0,1) and ok
 var returned=P.go(s,0,s.mission.extraction)
 ok=(returned or s.outcome=="won") and ok;P.tick(s,1.)
 var row=s.radio_metrics();row.accepted=ok;row.policy=policy;row.preset=preset;row.reports_off=reports_off
 return {"sim":s,"metrics":row}
