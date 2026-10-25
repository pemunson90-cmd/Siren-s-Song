extends RefCounted
# Source-known launch-to-photo test support. Revert by removing the new row
# suites; production behavior is untouched. All live movement/work uses commands.
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Patient=preload("res://tests/patient_play.gd")
const GO_SECONDS=300.0
const WAITS=40
const WAIT_SECONDS=2.0
var s
var op:int
var key:String
var uid:int
var checks=0
var failures=0
var metres=0.0
var frames=0
var rehearsals=0
var initial_sirens=0
var initial_tools={}
var spawn=Vector2.ZERO
func _init(operation:int,row:String,craft:int=0):
 op=operation;key=row;uid=craft;s=Sim.new();s.start(op,"endurance")
 spawn=s.units[uid].pos;initial_sirens=s.sirens.size();initial_tools=s.tools.duplicate(true)
 check(initial_sirens>0,"authored live Sirens are present")
 check(s.units.all(func(u):return u.alive),"all authored craft begin alive at their real launch positions")
 check(Sim.valid_snapshot(s.snapshot()),"authored starting simulation validates")
func check(ok:bool,label:String)->bool:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",key," / ",label)
 return ok
func tick(seconds:float)->void:
 s.paused=false
 for n in ceili(seconds/Sim.STEP):
  if not s.outcome.is_empty() or not s.units[uid].alive:break
  var before:Vector2=s.units[uid].pos;s.advance(Sim.STEP);metres+=before.distance_to(s.units[uid].pos);frames+=1
 s.paused=true
func command(action:String,args:Dictionary={})->bool:
 return check(s.command(action,args),"real command accepted: "+action+" "+str(args))
func select()->void:s.command("select",{"unit":uid})
func go(point:Vector2,seconds:float=GO_SECONDS)->bool:
 select()
 if not check(s.command("route",{"point":point}),"route accepts authored waypoint "+str(point)):return false
 for n in ceili(seconds/Sim.STEP):
  if not s.outcome.is_empty() or not s.units[uid].alive:break
  tick(Sim.STEP)
  if s.units[uid].route.is_empty() and s.units[uid].vel.length()<2.0:break
 var reached=s.units[uid].alive and s.outcome!="lost" and s.units[uid].pos.distance_to(point)<25.0
 print("PHOTO_ROW_LEG key=",key," target=",point," reached=",reached," position=",s.units[uid].pos," band=",s.units[uid].band," elapsed=",s.elapsed," message=",s.message)
 return check(reached,"physical route reaches "+str(point))
func depth(band:int)->bool:
 select()
 while s.units[uid].band!=band:
  var next:int=s.units[uid].band+signi(band-s.units[uid].band)
  if not check(s.command("depth",{"band":next}),"adjacent depth command accepts band "+str(next)):return false
  tick(4.2)
  if not check(s.units[uid].alive and s.units[uid].band==next and s.units[uid].transition.is_empty(),"actual depth transition completes"):return false
 return true
func target()->int:
 for index in s.mission.objectives.size():
  if s.mission.objectives[index].get("optical","")==key:return index
 return -1
func focus()->bool:
 select()
 if not check(s.command("frame",{"mode":"tight","focus":key}),"ordinary frame selects the informative row feature"):return false
 tick(1.0)
 return check(target()>=0,"actual optical discovery creates the row objective")
func record_current()->bool:
 select();var context=s.camera_context();var index=int(context.get("target",-1))
 if not check(context.get("ready",false) and index>=0 and index<s.mission.objectives.size(),"real current mission job is available"):return false
 var job=s.mission.objectives[index]
 print("PHOTO_ROW_REQUIRED key=",key," target=",index," name=",job.get("name","")," elapsed=",s.elapsed)
 if not check(s.command("camera"),"ordinary control starts current required work"):return false
 tick(float(job.get("duration",4.0))+.5)
 return check(job.get("captured",false),"current required work actually completes before optional photography")
func record()->bool:
 var index=target()
 if not check(index>=0,"row objective is reacquired by its optical key"):return false
 select();var context=s.camera_context()
 if not check(context.get("ready",false) and context.get("target",-1)==index,"camera context targets the exact optional row, not a mission job"):return false
 var before=Photo.shots_for(s.mission,key).size()
 if not check(s.command("camera"),"ordinary control begins target-specific exposure"):return false
 tick(float(s.mission.objectives[index].get("duration",4.0))+.5)
 var shots=Photo.shots_for(s.mission,key)
 var usable=shots.any(func(shot):return shot.get("usable",false) and key in shot.get("features",[]) and shot.get("intel",{}).has(key))
 check(shots.size()>before,"real held exposure files a new row-specific frame")
 check(usable and s.mission.objectives[index].get("captured",false),"usable informative film and the actual objective captured flag agree")
 return usable and s.mission.objectives[index].get("captured",false)
func study(at:Vector2=Vector2.INF,then:Vector2=Vector2.INF,refuge_band:int=-1)->bool:
 var index=target()
 if not check(index>=0,"discovered row is available before a patient rehearsal"):return false
 var band:int=int(s.mission.objectives[index].subject.band)
 var home=refuge_band if refuge_band>=0 else (2 if band==1 else 1)
 if not depth(home):return false
 select();s.command("frame",{"mode":"tight","focus":key})
 var copy=Sim.new()
 if not check(copy.restore(s.snapshot()),"patient rehearsal has a restorable real simulation"):return false
 if not check(absi(home-band)==1,"patient rehearsal uses a real adjacent depth crossing"):return false
 if not check(copy.command("select",{"unit":uid}) and copy.command("depth",{"band":band}),"patient rehearsal depth precondition is actually valid"):return false
 var safe=false
 for n in WAITS:
  var before=s.snapshot()
  rehearsals+=1
  var survives=Patient.rehearsal_survives(s,uid,band,index,then,at)
  if not check(s.snapshot()==before,"snapshot rehearsal does not change the live simulation"):return false
  if survives:safe=true;break
  tick(WAIT_SECONDS)
  if not s.units[uid].alive or not s.outcome.is_empty():break
 if not check(safe,"patient policy finds a survivable exposure and withdrawal"):return false
 if not depth(band):return false
 if at.is_finite() and not go(at):return false
 if not record():return false
 if not depth(home):return false
 if then.is_finite() and not go(then):return false
 tick(1.0)
 return check(s.units[uid].alive and s.hull>0 and s.outcome!="lost","photographer survives the real exposure and withdrawal")
func finish(tree:SceneTree,prefix:String)->void:
 var index=target();var shots=Photo.shots_for(s.mission,key)
 check(index>=0 and s.mission.objectives[index].get("captured",false),"journey actually captures its named row")
 check(shots.any(func(shot):return shot.get("usable",false) and key in shot.get("features",[]) and shot.get("intel",{}).has(key)),"journey retains usable film containing the row's feature and intel")
 check(metres>50.0 and frames>0,"journey moves from authored launch water rather than staging a viewpoint")
 check(s.sirens.size()>=initial_sirens and initial_sirens>0,"authored Sirens remain live throughout the journey")
 check(s.units[uid].alive and s.hull>0 and s.outcome!="lost","actual voyage remains alive")
 check(Sim.valid_snapshot(s.snapshot()),"real journey preserves current save validation")
 print("PHOTO_ROW_RESULT key=",key," op=",op," craft=",uid," outcome=",s.outcome," elapsed=",s.elapsed," metres=",metres," frames=",frames," hull=",s.hull," oxygen=",s.oxygen," sirens=",s.sirens.size()," tools_initial=",initial_tools," tools_remaining=",s.tools," rehearsals=",rehearsals," shots=",shots," final_position=",s.units[uid].pos," message=",s.message)
 print("%s CHECKS %d FAILURES %d"%[prefix,checks,failures]);tree.quit(1 if failures else 0)
