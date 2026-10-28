extends "res://src/simulation/simulation.gd"
# Source-known voyage telemetry. Decisions use received contacts and own state.
var equipped=false
var escaped=false
var locking={}
var hunt_peak=0.0
var warnings=0
var silent_throughout=true
var initial_tools={}
var defended={}
func start(index:int,upgrade:String="endurance",launch:Dictionary={})->void:
 var config=launch.duplicate(true)
 var racks=preload("res://src/equipment/tool_racks.gd").empty()
 if equipped:
  racks.drone_a={"emp":2};racks.drone_b={"emp":1}
  if index not in [17,20,21]:racks.quietus={"emp":1}
  if index==19:racks.quietus["hull_patch"]=1
 config["tool_racks"]=racks
 super.start(index,upgrade,config)
 initial_tools=tools.duplicate(true)
func advance(dt:float)->void:
 silent_throughout=silent_throughout and units[0].silent
 var prior_locking=locking.duplicate()
 var had_lock=not locking.is_empty()
 super.advance(dt)
 if mission==null:return
 hunt_peak=maxf(hunt_peak,float(mission.get("reconnaissance",{}).get("hunt",0.0)))
 var now={}
 var received_clear=false
 for id in contacts:
  var c=contacts[id]
  # Target clears immediately; displayed lock charge may still be decaying.
  if prior_locking.has(id) and elapsed-float(c.time)<0.15 and (int(c.target)==-1 or (int(c.target)==0 and float(c.lock)<=0.0)):received_clear=true
  if int(c.target)!=0:continue
  if elapsed-float(c.time)<=0.4 and float(c.lock)>0.0:
   now[id]=true
   if not locking.has(id):warnings+=1
 locking=now
 # Strait: react to the first freshly received clear by crossing beneath cover.
 var q=units[0]
 if mission.id==15 and not escaped and outcome.is_empty() and had_lock and locking.is_empty() and received_clear and q.band==1 and q.transition.is_empty() and captures[0].is_empty():
  var old=selected;command("select",{"unit":0})
  if command("depth",{"band":0}):escaped=true;print("GLASS RECEIVED ESCAPE ",elapsed)
  command("select",{"unit":old})
 if not equipped or not outcome.is_empty():return
 for id in contacts:
  var c=contacts[id]
  if elapsed-float(c.time)<0.3 and float(c.lock)<=0.0:defended.erase(id)
  if not defended.has(id) and elapsed-float(c.time)<0.3 and float(c.lock)>2.8 and tools.emp>0:
   var old=selected
   command("select",{"unit":maxi(0,int(c.target))})
   if command("emp"):defended[id]=true
   command("select",{"unit":old})
   break
func measured()->Dictionary:
 return {"id":mission.id,"outcome":outcome,"seconds":elapsed,"hull":hull,"oxygen":oxygen,"hunt_peak":hunt_peak,"received_locks":warnings,"silent_throughout":silent_throughout,"tools":tools,"equipment":mission.launch_equipment,"records":mission.objectives,"recovery":mission.get("module_recovery",{}).get("result",{}),"alive":units.map(func(u):return u.alive)}
