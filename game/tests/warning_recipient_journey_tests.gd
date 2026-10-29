extends SceneTree
# Source-known technical voyages, not blind play. Original guards, real routes,
# actual acoustic delivery and own finite protection remain active throughout.
const Sim=preload("res://src/simulation/simulation.gd")
const BERTH=Vector2(1840,440)
const PANEL=Vector2(1840,380)
const HOME=Vector2(2420,240)
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func local(s,point:Vector2)->bool:return s.units[0].pos.distance_to(point)<30 and s.units[0].vel.length()<2
func route(s,point:Vector2):
 s.command("select",{"unit":0});check(s.command("route",{"point":point}),"actual Q route accepted")
func defend(s,last:float)->float:
 if s.elapsed-last<1:return last
 for contact in s.contacts.values():
  if s.elapsed-contact.time<.3 and contact.lock>=1.8:
   s.command("select",{"unit":0})
   var targets=s.knockdown_targets()
   if s.tools.knock>0 and not targets.is_empty() and s.command("knock",{"target":targets[0].key}):return s.elapsed
   if s.command("emp"):return s.elapsed
 return last
func voyage(course:String,proof:String,tools:bool,wait_seconds:float=0.,expect_win:bool=true):
 var s=Sim.new();s.start(13,"endurance",{"context":{"thread":"shelf","facts":{"warning_chain":proof}},"fleet":{"quietus":true,"drone_a":false,"drone_b":false}})
 # Optional bodies are left at launch; no special fitting or tool is required.
 if s.units[0].silent:s.command("silent")
 var path=[Vector2(900,1960),Vector2(940,1020),Vector2(940,600),Vector2(1540,440),Vector2(1740,440)]
 var initial_tools=s.tools.duplicate(true)
 var stage=0;var leg=0;var last=-10.;var transmission=false;var decoded=false;var manual=false;var departure_hull=-1.;var departure_tools={};var wait_until=-1.;var waited=false
 route(s,path[leg]);s.paused=false
 for frame in 24000:
  if not s.outcome.is_empty():break
  if tools:last=defend(s,last)
  s.advance(Sim.STEP)
  if stage==0 and local(s,path[leg]):
   if leg==1 and not transmission:
    check(s.command("camera"),"travelled Q transmits from its actual chosen origin");transmission=true;stage=1
   elif leg==4:
    if s.mission.objectives.any(func(o):return o.get("site_id","")=="warning_reply"):
     check(s.command("camera"),"actual local reply decoding starts");stage=2
   else:leg+=1;route(s,path[leg])
  elif stage==1 and s.captures[0].is_empty():
   check(s.mission.warning_recipient.delivered,"actual route origin delivers warning through real terrain");leg+=1;route(s,path[leg]);stage=0
  elif stage==2 and s.warning_recipient_status().informed:
   if not waited and wait_seconds>0:
    waited=true;wait_until=s.elapsed+wait_seconds
    if not s.units[0].silent:s.command("silent")
   if s.elapsed<wait_until:continue
   if wait_seconds>0:check(s.mission.warning_recipient.body.hull==100,"actual warned recipient safely waits for a deliberate release under original guards")
   decoded=true
   if course=="sheltered" and proof!="service_local_receipt":route(s,PANEL);stage=3
   else:check(s.command("warning_depart",{"course":course}),"deliberate local release chooses "+course);stage=4
  elif stage==3 and local(s,PANEL):
   check(s.command("warning_gate"),"solo no-proof manual release opens physical shelter passage");manual=true
   check(s.command("warning_depart",{"course":course}),"manual fallback releases sheltered hull");stage=4
  elif stage==4:
   departure_hull=s.hull;departure_tools=s.tools.duplicate(true)
   if not s.units[0].silent:s.command("silent")
   if course=="sheltered":route(s,Vector2(1840,160));stage=5
   elif tools:route(s,Vector2(2300,220));stage=7
   else:stage=10
  elif stage==5 and local(s,Vector2(1840,160)):route(s,Vector2(2280,160));stage=6
  elif stage==6 and (local(s,Vector2(2280,160)) or local(s,Vector2(2200,440))):route(s,HOME if course=="sheltered" else Vector2(2300,220));stage=7
  elif stage==7 and course=="exposed" and s.warning_recipient_status().receipt:route(s,HOME);stage=9
  if stage in [7,9] and local(s,HOME) and s.mission.objectives.any(func(o):return o.get("site_id","")=="warning_uplink" and not o.captured) and s.captures[0].is_empty():
   check(s.command("camera"),"actual pickup service account reception starts")
 if expect_win:check(s.outcome=="won" and decoded and s.warning_recipient_status().receipt and Sim.valid_snapshot(s.snapshot()),course+" real-guard voyage completes actual physical beneficiary and independent Q recovery")
 else:check(s.outcome=="lost" and not s.mission.warning_recipient.body.alive and not s.warning_recipient_status().receipt,"unprotected exposed crossing genuinely loses recipient to the authored watch")
 if not tools:check(s.tools==initial_tools,"bare fallback spends no finite protection")
 if proof.is_empty() and course=="sheltered":check(manual,"default no-proof journey pays real manual gate cost")
 print("RECIPIENT JOURNEY ",course," proof=",proof," protection=",tools," departure_hull=",departure_hull," departure_tools=",departure_tools," outcome=",s.outcome," stage=",stage," time=",s.elapsed," Q=",s.units[0].pos," hull=",s.hull," recipient=",s.mission.warning_recipient.body.pos," recipient_hull=",s.mission.warning_recipient.body.hull," oxygen=",s.oxygen," tools=",s.tools)
func _initialize():
 var waiting=Sim.new();waiting.start(13);waiting.paused=false
 for frame in 3600:waiting.advance(Sim.STEP)
 check(waiting.mission.warning_recipient.body.hull==100 and waiting.mission.warning_recipient.course.is_empty() and waiting.outcome.is_empty(),"ordinary unchanged guards impose no pre-warning departure deadline on covered berth")
 voyage("sheltered","",false,45.)
 voyage("sheltered","service_local_receipt",false,45.)
 voyage("exposed","",false,45.,false)
 voyage("exposed","",true,45.)
 print("WARNING RECIPIENT JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
