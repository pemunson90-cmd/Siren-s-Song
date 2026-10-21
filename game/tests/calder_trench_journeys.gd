extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):
  s.advance(Sim.STEP)
  if not s.outcome.is_empty():break
 s.paused=true
func go(s,point)->bool:
 if s.outcome=="won":return s.units[0].pos.distance_to(point)<65
 if not s.command("route",{"point":point}):return false
 s.paused=false
 for n in 18000:
  s.advance(Sim.STEP)
  if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
 s.paused=true
 return (s.outcome=="won" or s.units[0].pos.distance_to(point)<25) and s.units[0].alive
func dive(s,band)->bool:
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2);return s.units[0].band==band and s.units[0].transition.is_empty()
# One authored bare-Quietus course per core operation. "camera" takes the nearest
# unfinished local task (record or valve) and holds still for its full duration.
const COURSES={
 30:[["go",Vector2(1900,2200)],["camera"],["go",Vector2(2500,2000)],["go",Vector2(2500,1450)],["go",Vector2(2450,1150)],["camera"],["go",Vector2(1900,900)],["go",Vector2(1450,800)],["go",Vector2(950,820)],["camera"],["go",Vector2(900,640)],["camera"],["go",Vector2(1450,800)],["go",Vector2(2500,1450)],["go",Vector2(2500,2000)],["exit"]],
 31:[["go",Vector2(1200,2800)],["depth",2],["go",Vector2(1200,2300)],["depth",1],["depth",0],["go",Vector2(1200,1500)],["depth",1],["depth",2],["go",Vector2(1200,800)],["depth",1],["go",Vector2(1200,700)],["camera"],["go",Vector2(300,300)],["exit",1]],
 32:[["go",Vector2(800,4400)],["go",Vector2(800,3600)],["go",Vector2(750,3300)],["go",Vector2(750,3000)],["go",Vector2(650,2400)],["go",Vector2(800,1900)],["go",Vector2(900,1700)],["camera"],["go",Vector2(750,1100)],["go",Vector2(700,500)],["go",Vector2(900,420)],["exit",1]],
 34:[["go",Vector2(1200,1750)],["go",Vector2(1700,1750)],["go",Vector2(2000,1600)],["go",Vector2(2000,1000)],["depth",2],["go",Vector2(2000,450)],["depth",1],["go",Vector2(1850,450)],["camera"],["depth",2],["go",Vector2(2000,1000)],["depth",1],["go",Vector2(2000,1600)],["go",Vector2(1700,1750)],["exit"]],
 35:[["go",Vector2(900,1500)],["camera"],["go",Vector2(1300,1150)],["go",Vector2(2000,1150)],["go",Vector2(2400,1050)],["camera"],["go",Vector2(2000,1150)],["go",Vector2(1300,1150)],["go",Vector2(900,1500)],["exit"]],
 36:[["go",Vector2(1000,1500)],["go",Vector2(1220,1240)],["go",Vector2(1330,1100)],["camera"],["go",Vector2(1220,1240)],["go",Vector2(1000,1500)],["exit"]],
 37:[["depth",0],["go",Vector2(300,1500)],["go",Vector2(300,300)],["depth",1],["go",Vector2(1300,350)],["camera"],["go",Vector2(300,300)],["depth",0],["go",Vector2(300,1500)],["go",Vector2(300,2300)],["depth",1],["exit"]],
 38:[["go",Vector2(1325,2250)],["go",Vector2(1325,1930)],["go",Vector2(1125,1740)],["go",Vector2(1125,1450)],["go",Vector2(1300,1380)],["camera"],["go",Vector2(1125,1450)],["go",Vector2(1125,1740)],["go",Vector2(1325,1930)],["exit"]],
 39:[["go",Vector2(1000,1850)],["go",Vector2(1250,1500)],["go",Vector2(1400,1200)],["camera"],["go",Vector2(1700,900)],["go",Vector2(1850,900)],["camera"],["go",Vector2(1700,900)],["go",Vector2(1400,1200)],["go",Vector2(1250,1500)],["go",Vector2(1000,1850)],["exit"]],
 33:[["go",Vector2(700,1300)],["camera"],["go",Vector2(1900,1200)],["go",Vector2(2300,1200)],["go",Vector2(3500,1350)],["camera"],["go",Vector2(3600,700)],["camera"],["go",Vector2(3900,2150)],["exit",1]]}
func course(s,id)->bool:
 for step in COURSES[id]:
  if OS.get_environment("CALDER_DEBUG")!="":print("  step ",step," q=",s.units[0].pos," hull=",s.hull," t=",roundi(s.elapsed)," modes=",s.sirens.map(func(e):return e.type.left(3)+":"+e.mode.left(4)))
  match step[0]:
   "go":
    if not go(s,step[1]):check(false,"bare course reaches "+str(step[1])+" "+str(id)+" at "+str(s.units[0].pos)+" "+s.message);return false
   "depth":
    if not dive(s,step[1]):check(false,"bare depth crossing to band "+str(step[1])+" "+str(id)+" "+s.message);return false
   "camera":
    var done=s.mission.objectives.filter(func(o):return o.captured).size()
    if not s.command("camera"):check(false,"local task starts "+str(id)+" "+s.message+" at "+str(s.units[0].pos));return false
    tick(s,8.3)
    if s.mission.objectives.filter(func(o):return o.captured).size()!=done+1:check(false,"local task finishes "+str(id)+" "+s.message);return false
   "exit":
    if not go(s,s.mission.corridors[step[1] if step.size()>1 else 0].pos):check(false,"bare return reaches named recovery mouth "+str(id)+" "+str(s.units[0].pos));return false
 return true
func progress():
 return {"version":2,"route":"deep","routes":["deep"],"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25],"facts":{"deep":"received carrier","confluence_route":"concealed","resolution":"concealed_recovery"},"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
func journey(id:int,p:Dictionary):
 var s=Sim.new();s.start(id,"endurance",{"context":Sim.Consequences.context(p)})
 s.units[1].alive=false;s.units[2].alive=false;var tools=s.tools.duplicate()
 course(s,id)
 check(s.outcome=="won" and s.hull>99.9 and s.tools==tools and s.mission.launch_equipment.values().all(func(v):return v==""),"baseline Quietus finishes unhurt without finite tools or advanced fitting "+str(id)+" outcome "+s.outcome)
 check(Sim.valid_snapshot(s.snapshot()),"finished well dive restores current state "+str(id))
 print("CALDER JOURNEY id=",id," outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," message=",s.message)
 return s
func _initialize():
 var p=progress();check(Campaign.valid(p),"staged recovered history is a valid campaign")
 check(30 in Campaign.available([0,1,2,3,4,5],p),"ordinary campaign progress offers the trench after Last Shift")
 for id in [30,31,32,33,34,35,36,37,38,39]:
  check(id in Campaign.available([0,1,2,3,4,5],p),"ordinary recovered prerequisites offer "+str(id))
  var s=journey(id,p);p=Campaign.recover(p,s.mission)
  check(id in p.completed and Campaign.valid(p),"real recovered result advances valid trench campaign "+str(id))
  if failures>0:break
 print("CALDER JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
