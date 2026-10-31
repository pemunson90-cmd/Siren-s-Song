extends "res://src/simulation/simulation.gd"
# Source-known fleet policy. All actions use ordinary orders and finite launch stock.
# The first optional optical subject may have an empty kind; subject is authoritative.
var fleet_policy=false
var scout_goal=-1
var scout_return=false
var handling=false
var scout_frame_at=-1.
var scout_shot=false
var scout_started=false
var breaker_staged=false
var replan_at=[0.,0.,0.]
var disrupt_after=0.
# Park across Quietus' final approach, keeping the recovery convoy out of its lane.
const APPROACH={30:Vector2(1180,300),31:Vector2(880,1000),32:Vector2(1100,2900),33:Vector2(1900,1150),34:Vector2(1050,2150),35:Vector2(2900,1450),36:Vector2(1000,1300)}
func parking(unit:int)->Vector2:
 return mission.extraction+(mission.extraction-APPROACH[mission.id]).normalized().orthogonal()*(50. if unit==1 else -50.)
func stage_breaker()->void:
 super.command("route",{"point":Vector2(350,1900)});breaker_staged=true
func start(index:int,upgrade:String="endurance",launch:Dictionary={})->void:
 var config=launch.duplicate(true)
 if fleet_policy:
  config["fitted"]={"quietus":"quietus_wellhead_seal" if index==35 else "quietus_baffles","drone_a":"drone_deep_cells","drone_b":"drone_choir_tuner" if index==36 else "drone_survey_array"}
 super.start(index,upgrade,config)
 mission["dev"]=true # 127: authored pathfinder journeys run on the dev/test route path (Pat 2026-10-30).
 if not fleet_policy:return
 for i in mission.objectives.size():
  var o=mission.objectives[i]
  if o.get("optional",false) and o.has("subject"):
   scout_goal=i;break
 if scout_goal<0:return
 super.command("select",{"unit":1});super.command("drone_drive",{"mode":"quiet"})
 var o=mission.objectives[scout_goal]
 if o.get("band",1)!=1:super.command("depth",{"band":o.band})
 if index!=36:
  # The spare receiver takes its module to the recovery mouth in parallel.
  super.command("select",{"unit":2})
  if index in [31,33]:super.command("depth",{"band":2 if index==31 else 0})
  super.command("route",{"point":parking(2)})
 super.command("select",{"unit":0})
func advance(dt:float)->void:
 super.advance(dt)
 if not fleet_policy or handling or not outcome.is_empty():return
 handling=true
 var old=selected
 # Do not leave the tuner parked alone under the recovery post's listening line.
 if breaker_staged and units[0].pos.distance_to(mission.extraction)<220:
  super.command("select",{"unit":2});super.command("route",{"point":parking(2)});breaker_staged=false
 # A depth order takes time. Plot only after settling in the requested band.
 if scout_goal>=0 and not scout_started and units[1].transition.is_empty():
  super.command("select",{"unit":1})
  scout_started=super.command("route",{"point":mission.objectives[scout_goal].pos+Vector2(-100,0)})
 # Replot a stopped leg from the drone's newly received terrain, never clear it.
 for id in [1,2]:
  var body=units[id]
  if body.alive and body.has("chart_stop") and not body.route.is_empty() and elapsed>=replan_at[id]:
   super.command("select",{"unit":id})
   super.command("route",{"point":body.route.back().pos});replan_at[id]=elapsed+1.
 # Spend finite Disrupt on received live radio charge-ups as well as lock warnings.
 # Waiting for lock lets the new recovery pair finish its report and surround a drone.
 for c in contacts.values():
  if elapsed>=disrupt_after and elapsed-float(c.time)<.3 and (float(c.lock)>1.2 or float(c.get("report_remaining",0.))>0.) and tools.emp>0:
   super.command("select",{"unit":maxi(0,int(c.target))})
   if super.command("emp"):disrupt_after=elapsed+5.
   break
 if scout_goal>=0 and units[1].alive:
  var o=mission.objectives[scout_goal];var u=units[1]
  super.command("select",{"unit":1})
  if not o.captured and u.route.is_empty() and u.vel.length()<2 and captures[1].is_empty() and u.transition.is_empty():
   if scout_frame_at<0:
    super.command("frame",{"mode":"wide","focus":o.optical});scout_frame_at=elapsed
   elif elapsed-scout_frame_at>=3. and not scout_shot:
    scout_shot=super.command("camera")
  if o.captured and not scout_return:
   # Bring the film back outside the new MIDDLE recovery watch, then rendezvous.
   var return_band=(2 if mission.id==31 else 0) if mission.id in [31,33] else 1
   if u.band!=return_band:super.command("depth",{"band":return_band})
   super.command("route",{"point":parking(1)});scout_return=true
 super.command("select",{"unit":old});handling=false
