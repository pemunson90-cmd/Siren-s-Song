extends SceneTree
# R2 (Pat 2026-10-30): finishability is measured by hand piloting; "it still
# has to be a game". A deterministic careful-pilot policy flies each op with
# release controls only: straight legs it places itself from chart knowledge
# (the opening chart's public terrain, or only measured cells on an earned
# chart), depth, in-reach jobs, recall, select and hold. Quietus stays SILENT,
# racks are bare. After every leg order the installed route must equal the
# policy's own goals (no pathfinder corners). A red leg (crossing newly
# measured rock) is replotted, as a player would. Each run prints one
# HANDPILOT JSON row; dev rows fly the same plan through the test-only
# pathfinder for comparison and are not gated.
const Sim=preload("res://src/simulation/simulation.gd")
const Glass=preload("res://tests/glass_reach_journeys.gd")
const Calder=preload("res://tests/calder_trench_journey_tests.gd")
const HandPilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const ControlMix=preload("res://src/debug/control_mix.gd")
const CORE_OPS=[2,15,16,17,18,20,21,22,30]
const RELEASE_ORDERS=["route","queue","depth","frame","camera","glass_action","choir_action","recall","recall_all","select","hold"]

class HandRun extends "res://tests/glass_fleet_voyage.gd":
 var hand=true
 var release_only=true
 var refused=[]
 var legs=0
 var routes_match=true
 var collisions=0
 var stuck_holds=0
 var measured_reads=0
 var public_reads=0
 var hidden_reads=0
 func command(order:String,args:Dictionary={})->bool:
  if order not in RELEASE_ORDERS:release_only=false;refused.append(order);return false
  var ok=super.command(order,args)
  if ok and order=="route":
   legs+=1
   var u=units[selected]
   if hand and u.route.map(func(n):return n.pos)!=route_goals().map(func(g):return g.pos):routes_match=false
  return ok
 func advance(dt:float)->void:
  var count=events.size()
  var held=[0,1,2].map(func(i):return units[i].has("edge_hold"))
  super.advance(dt)
  if mission==null:return
  for e in events.slice(count):
   if e.get("type","")=="edge_contact":collisions+=1
  for i in 3:
   if units[i].has("edge_hold") and not held[i]:stuck_holds+=1

var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")

func tick(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):
  s.advance(Sim.STEP)
  if not s.outcome.is_empty():break
 s.paused=true

# The pilot's chart reading. Opening charts show their physical terrain to the
# player; an earned chart offers only the cells the fleet has measured.
func plan(s,a:Vector2,b:Vector2)->Array:
 var u=s.units[s.selected]
 s._use_band(u.band)
 var chart=s.depth_charts.get(u.band)
 var result=[]
 if chart==null:
  s.public_reads+=1
  if HandPilot.crosses_rock(s,a,b) or s.blocked(b,24):
   result=s.path(a,b,true).map(func(n):return n.pos)
  else:result=[b]
 else:
  s.measured_reads+=1
  if not HandPilot.crosses_rock(s,a,b):result=[b]
  elif chart.is_clear(a) and chart.is_clear(b):result=chart.known_path(a,b).map(func(n):return n.pos)
  if result.is_empty() and chart.is_clear(a):
   # Survey frontier: the measured cell nearest the goal that measured water reaches.
   var cells=chart.clear_cells.keys()
   cells.sort_custom(func(x,y):return (Vector2(x)*chart.TILE+Vector2.ONE*chart.TILE/2).distance_squared_to(b)<(Vector2(y)*chart.TILE+Vector2.ONE*chart.TILE/2).distance_squared_to(b))
   for cell in cells.slice(0,120):
    var c=Vector2(cell)*chart.TILE+Vector2.ONE*chart.TILE/2
    if c.distance_to(a)<30:break
    var way=chart.known_path(a,c)
    if not way.is_empty():result=way.map(func(n):return n.pos);break
 s._use_band(s.units[s.selected].band)
 return result

func place(s,points:Array)->bool:
 if points.is_empty():return false
 var before=s.queue_mode
 for n in points.size():
  s.queue_mode=n>0
  if not s.command("route",{"point":points[n]}):s.queue_mode=before;return false
 s.queue_mode=before
 return true

func go(s,point:Vector2,limit:float=400.)->bool:
 var u=s.units[s.selected]
 if not s.outcome.is_empty():return s.outcome=="won" and s.units[0].pos.distance_to(point)<65
 if not s.hand:
  if not s.command("route",{"point":point,"travel":"route_here"}):return false
  s.paused=false
  for n in roundi(limit*60):
   s.advance(Sim.STEP)
   if u.has("chart_stop") and n%30==0:s.command("route",{"point":point,"travel":"route_here"})
   if not s.outcome.is_empty() or (u.route.is_empty() and u.vel.length()<2):break
  s.paused=true
  return (s.outcome=="won" or u.pos.distance_to(point)<25) and u.alive
 var start=s.elapsed
 for attempt in 40:
  if u.hold=="HOLD":s.command("hold")
  if not place(s,plan(s,u.pos,point)):break
  s.paused=false
  var replot=false;var red=HandPilot.warnings(s,s.selected).size()
  for n in roundi(limit*60):
   s.advance(Sim.STEP)
   if not s.outcome.is_empty() or not u.alive:break
   if u.route.is_empty() and u.vel.length()<2:break
   if u.hold=="HOLD" and u.has("edge_hold"):replot=true;break
   # A leg turning red against newly measured rock is replotted by the pilot.
   if n%30==0 and HandPilot.warnings(s,s.selected).size()>red:replot=true;break
  s.paused=true
  if not s.outcome.is_empty():return s.outcome=="won"
  if u.pos.distance_to(point)<25 or not u.alive:break
  if s.elapsed-start>limit:break
  if not replot and u.route.is_empty() and plan(s,u.pos,point).is_empty():break
 return u.alive and u.pos.distance_to(point)<25

# Hold still until no contact has been received for `calm` seconds (bounded).
func quiet(s,calm:float,limit:float)->void:
 var still=0.;var waited=0.
 while still<calm and waited<limit and s.outcome.is_empty():
  tick(s,.25);waited+=.25
  still=0. if s.has_live_contact() else still+.25

func dive(s,band:int)->bool:
 var u=s.units[s.selected]
 if u.band==band and u.transition.is_empty():return true
 # A depth change is an exposed transition: wait for received contacts to go stale.
 quiet(s,2.,30.)
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2);return u.band==band and u.transition.is_empty()

# Before the last leg home, wait short of the mouth and RECALL ALL. Drones that
# come back are then flown into the mouth ahead of Quietus with placed legs.
func home(s,mouth:Vector2)->bool:
 if s.hand and s.outcome.is_empty():
  var q=s.units[0]
  var short=q.pos+(mouth-q.pos)*clampf(1.0-120.0/maxf(1.,q.pos.distance_to(mouth)),0.,1.)
  if q.pos.distance_to(mouth)<=130 or go(s,short):
   recall_drones(s)
   for i in [1,2]:
    var d=s.units[i]
    if not d.alive or d.pos.distance_to(q.pos)>90 or d.band!=1 or s.has_live_contact():continue
    s.command("select",{"unit":i})
    go(s,mouth+Vector2.from_angle(PI*i)*25,40.)
  s.command("select",{"unit":0})
 return go(s,mouth)

# Silt Archive: the authored course meets the camera site past (2470,400), 140m
# from a MIDDLE patrol near (2600,320); both hand and dev flights are beamed
# there. A player who has seen that patrol keeps west and comes down x=2250.
const HAND_COURSES={17:{"from":10,"steps":[["go",Vector2(2250,850)],["go",Vector2(2250,380)],["camera"],["go",Vector2(2250,140)],["exit",1]]}}

func glass(s,id:int)->bool:
 var steps:Array=Glass.COURSES[id]
 if HAND_COURSES.has(id):steps=steps.slice(0,HAND_COURSES[id].from)+HAND_COURSES[id].steps
 for step in steps:
  var ok=true
  match step[0]:
   "go":ok=go(s,step[1])
   "depth":ok=dive(s,step[1])
   "middle":ok=dive(s,1)
   "wait":tick(s,step[1]);quiet(s,3.,60.)
   "work":ok=s.command("glass_action",{"action":step[1]});tick(s,8.2)
   "camera":ok=s.command("camera");tick(s,s.mission.objectives[0].duration+.2);ok=ok and s.mission.objectives[0].captured
   "recover":ok=s.command("glass_action",{"action":"recover"});tick(s,4.2)
   "exit":ok=home(s,s.mission.corridors[step[1] if step.size()>1 else 0].pos)
  if not ok:print("HANDPILOT STOP op",id," step=",step," pos=",s.units[0].pos," msg=",s.message);return false
 return true

func blackwater(s)->bool:
 if not dive(s,2) or not go(s,Vector2(650,90)) or not dive(s,1) or not s.command("camera"):return false
 tick(s,2.5)
 if not s.mission.objectives[0].captured or not dive(s,2):return false
 if not go(s,Vector2(740,740)) or not dive(s,1):return false
 for n in 3600:
  if s.blackwater_context(1).ready:break
  tick(s,Sim.STEP)
 if not s.command("camera"):return false
 tick(s,2.5)
 if not s.mission.objectives[1].captured:return false
 return home(s,s.mission.extraction) and s.outcome=="won"

func work(s,action:String)->bool:
 if not s.command("choir_action",{"action":action}):print("HANDPILOT WORK REJECT ",action," ",s.message);return false
 tick(s,8.2);return true

func course(s,points:Array)->bool:
 for p in points:
  if not go(s,p):print("HANDPILOT STOP op",s.mission.id," goal=",p," pos=",s.units[0].pos," msg=",s.message);return false
 return true

func hammerwake(s)->bool:
 if not course(s,[Vector2(750,2050)]) or not s.command("choir_action",{"action":"west"}):return false
 if not course(s,[Vector2(750,600),Vector2(750,300),Vector2(1800,390)]) or not work(s,"lock_a"):return false
 if not course(s,[Vector2(2500,450)]):return false
 for n in 24000:
  if s.mission.iron_choir.receipt or not s.outcome.is_empty():break
  tick(s,Sim.STEP)
 if not s.mission.iron_choir.receipt:return false
 return course(s,[Vector2(350,300),Vector2(300,1200)]) and home(s,Vector2(300,2350))

func survey(s,id:int)->bool:
 for step in Calder.steps(id,s):
  var ok=false
  match step[0]:
   "go":ok=home(s,step[1]) if step[1]==s.mission.extraction else go(s,step[1])
   "dive":ok=dive(s,step[1])
   "shoot":
    var o=Calder.obj(s,step[1])
    ok=s.command("frame",{"mode":"wide","focus":o.get("optical",o.site_id)})
    tick(s,3.);ok=ok and s.command("camera");tick(s,float(o.get("duration",4.))+2.);ok=ok and o.captured
  if not ok:print("HANDPILOT STOP op",id," step=",step," pos=",s.units[0].pos," msg=",s.message);return false
 return true

# Before the last leg home, wait short of the mouth and RECALL ALL. A drone the
# straight recall refuses stays out; the pilot does not fly it home by proxy.
func recall_drones(s)->void:
 if s.oxygen<35. or s.has_live_contact():return
 s.command("select",{"unit":0})
 var ok=s.command("recall_all")
 print("HANDPILOT RECALL op",s.mission.id," ok=",ok," msg=",s.message)
 if not ok:return
 for n in 40*4:
  tick(s,.25)
  if s.has_live_contact() or not s.outcome.is_empty():break
  if [1,2].all(func(i):return not s.units[i].alive or not s.units[i].get("recall",false) or (s.units[i].route.is_empty() and s.units[i].vel.length()<2)):break

func fly(id:int,preset:String,hand:bool)->Dictionary:
 var history={"version":2,"history":[],"notes":{},"references":{},"entitlements":[],"route":"deep","routes":["deep"],"selected_thread":"deep","facts":{"deep":"Recovered branch account","confluence_route":"concealed","resolution":"concealed_recovery"},"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25]}
 var s=HandRun.new();s.hand=hand
 seed(127)
 s.start(id,"endurance",{"context":history,"tool_racks":Racks.empty()})
 Economy.apply_launch(Economy.new_state(preset),s)
 s.mission["dev"]=not hand
 var bare=s.mission.launch_equipment.values().all(func(item):return str(item).is_empty() or str(item)=="standard")
 var empty=s.tools.values().all(func(n):return n==0) and s.mission.tool_racks==Racks.empty()
 var ok=false
 if id==2:ok=blackwater(s)
 elif id in [15,16,17,18,20,21]:ok=glass(s,id)
 elif id==22:ok=hammerwake(s)
 else:ok=survey(s,id)
 var recovered=s.outcome=="won" and s.events.any(func(e):return e.type=="extraction")
 if id==2:recovered=recovered and s.mission.blackwater_delivery.aboard.has(0) and s.mission.blackwater_delivery.aboard.has(1)
 var drones=s.mission.get("module_recovery",{}).get("result",{}).get("recovered_drones",[]).size()
 if drones==0 and s.outcome=="won":drones=[1,2].filter(func(i):return s.units[i].alive and s.units[i].band==1 and (s.units[i].pos.distance_to(s.units[0].pos)<HandPilot.RECALL_REACH or HandPilot.recalled(s,i))).size()
 var row={"id":id,"title":s.mission.title,"preset":preset,"controls":"hand" if hand else "dev","recovered":recovered,"time":snappedf(s.elapsed,.1),"hunt_peak":snappedf(s.hunt_peak,.1),"locks":s.warnings,"hull":snappedf(s.hull,.1),"oxygen":snappedf(s.oxygen,.1),"legs":s.legs,"collisions":s.collisions,"stuck_holds":s.stuck_holds,"drones_recovered":drones,"silent":s.silent_throughout,"bare":bare and empty,"release_only":s.release_only,"routes_match":s.routes_match,"measured_reads":s.measured_reads,"public_reads":s.public_reads,"one_press_share":snappedf(ControlMix.one_press_share(s),.001),"message":s.message}
 print("HANDPILOT ",JSON.stringify(row))
 if hand:
  var tag="op%d %s"%[id,preset]
  check(recovered,tag+" finishes by hand")
  check(s.silent_throughout,tag+" Quietus SILENT throughout")
  check(bare and empty,tag+" bare racks and fittings")
  check(s.release_only,tag+" release orders only "+str(s.refused))
  check(s.routes_match,tag+" installed routes equal the pilot's own goals")
  # Earned charts: the policy never consulted the public physical chart.
  if s.mission.get("earned_terrain",false):check(s.public_reads==0,tag+" earned chart planning reads measured cells only")
 return row

func run():
 var scope=OS.get_environment("HANDPILOT_SCOPE")
 var ops=CORE_OPS
 if not OS.get_environment("HANDPILOT_OPS").is_empty():ops=Array(OS.get_environment("HANDPILOT_OPS").split(",")).map(func(x):return int(x))
 var presets=["standard"] if scope=="quick" else ["standard","accessible"]
 var rows=[]
 for preset in presets:
  for id in ops:rows.append(fly(id,preset,true))
 if scope in ["all","compare","quick"]:
  for id in ops:rows.append(fly(id,"standard",false))
 var hand_rows=rows.filter(func(r):return r.controls=="hand")
 var met=hand_rows.filter(func(r):return r.hunt_peak>=20 or r.locks>0).size()
 print("HANDPILOT SUMMARY rows=",hand_rows.size()," finished=",hand_rows.filter(func(r):return r.recovered).size()," met_sirens=",met," collisions=",hand_rows.reduce(func(a,r):return a+r.collisions,0)," stuck_holds=",hand_rows.reduce(func(a,r):return a+r.stuck_holds,0))
 print("HANDPILOT CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
