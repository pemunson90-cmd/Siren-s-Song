extends SceneTree
# One rule (PROTECTED_CAPABILITIES row SIREN-022, PAT): no player tool permanently disables a Siren.
# Every tool that suppresses a Siren is applied to a real Siren in a real headless Simulation, the
# simulation is advanced past the tool's own duration, and the Siren must sense and act again.
# Suppressing tools: Disrupt (emp, stun EMP_STUN), Torpedo (knock, pin KNOCK_TIME), Decoy (decoy,
# distraction DECOY_TIME) and Silt screen (silt_screen, sight blocked for its table life).
# Sonobuoy, Survey, Hull patch and Relay buoy never act on a Siren and are not cases here.
# Disrupt is applied to every Siren role found in the campaign, including network and industrial roles.
# Durations are read from the game's own tables, so this suite follows a ruled change of a number;
# the numbers themselves are pinned by protected_rules_tests.
const Simulation=preload("res://src/simulation/simulation.gd")
const Tuning=preload("res://src/simulation/tuning.gd")
const FieldTools=preload("res://src/equipment/field_tools.gd")
const SIGHT_ROLES=["patroller","sentinel","hunter","sweeper"]
const NETWORK_ROLES=["buoy","relay"]
const INDUSTRY_ROLES=["interceptor","warden"]
const HELD=9999.0 # Test isolation only: other Sirens are held so they cannot end the dive.
var checks:=0
var failures:=0
func check(ok:bool,text:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",text)
func _initialize()->void:call_deferred("run")
func role(e:Dictionary)->String:
 var t=str(e.get("type",""))
 return "patroller" if t=="" else t
func tick(s,seconds:float)->void:
 for i in ceili(seconds/Simulation.STEP):s.advance(Simulation.STEP)
# First operation and Siren index for each role, scanning the campaign in order.
func find_roles()->Dictionary:
 var found={}
 var wanted=SIGHT_ROLES+NETWORK_ROLES+INDUSTRY_ROLES
 for op in range(0,42):
  var s=Simulation.new();s.start(op)
  for i in s.sirens.size():
   var r=role(s.sirens[i])
   if r in wanted and not found.has(r):found[r]={"op":op,"index":i}
  if found.size()==wanted.size():break
 return found
# A fresh dive with one subject Siren, Quietus placed in clear water at sight distance,
# drones parked far away and every other Siren held.
func setup(op:int,index:int,near:float=100.0)->Dictionary:
 var s=Simulation.new();s.start(op)
 var e=s.sirens[index];e.transition={}
 var band:int=int(e.band)
 for i in s.sirens.size():
  if i!=index:s.sirens[i].stun=HELD;s.sirens[i].lock=0.0;s.sirens[i].target=-1
 s._use_band(band)
 var spot=open_point(s,e.pos,band,near*0.8,near*1.2)
 var far=far_point(s,e.pos,band)
 s._use_band(1)
 if spot==null or far==null:return {}
 for i in s.units.size():
  var u=s.units[i];u.band=band;u.transition={};u.vel=Vector2.ZERO;u.route=[];u.silent=true
  u.pos=spot if i==0 else far+Vector2(0,i*20)
 # Quietus faces the Siren so a launched torpedo does not start by turning into rock.
 s.units[0].angle=s.units[0].pos.angle_to_point(e.pos)
 s.selected=0;s.paused=false;s._observe()
 return {"sim":s,"e":e,"band":band,"far":far}
func open_point(s,origin:Vector2,band:int,lo:float,hi:float):
 for step in 24:
  for r in [lo,(lo+hi)*0.5,hi]:
   var p=origin+Vector2.from_angle(step*TAU/24.0)*r
   if not s.blocked(p,16) and s.Depth.clear(s,origin,p,band,4):return p
 return null
func far_point(s,origin:Vector2,band:int):
 var best=null;var size=s.world_size()
 for x in range(60,int(size.x)-60,60):
  for y in range(60,int(size.y)-60,60):
   var p=Vector2(x,y)
   if p.distance_to(origin)<700 or s.blocked(p,20) or s.blocked(p+Vector2(0,40),20):continue
   if best==null or p.distance_to(origin)>best.distance_to(origin):best=p
 return best
func rehold(s,index:int)->void:
 for i in s.sirens.size():
  if i!=index:s.sirens[i].stun=HELD;s.sirens[i].lock=0.0;s.sirens[i].target=-1
func senses(e:Dictionary)->bool:return e.target>=0 and e.lock>0.0
# Moving Quietus out of sight must leave a recovered sight role acting: it moves or turns.
func acts_after(s,e:Dictionary,far:Vector2,label:String)->void:
 s.units[0].pos=far+Vector2(40,0)
 var pos:Vector2=e.pos;var angle:float=e.angle;var acted=false
 for i in 10:
  tick(s,1.0)
  if e.pos.distance_to(pos)>3.0 or absf(angle_difference(angle,e.angle))>0.05:acted=true;break
 check(acted,label+": recovered Siren moves or turns again once Quietus leaves sight")
func run()->void:
 var roles=find_roles()
 print("roles under test (operation, Siren index): ",roles)
 for r in SIGHT_ROLES+NETWORK_ROLES+INDUSTRY_ROLES:check(roles.has(r),"campaign contains a Siren of role "+r)
 for r in SIGHT_ROLES:
  if roles.has(r):disrupt_sight(r,roles[r].op,roles[r].index);torpedo(r,roles[r].op,roles[r].index)
 for r in NETWORK_ROLES+INDUSTRY_ROLES:
  if roles.has(r):disrupt_static(r,roles[r].op,roles[r].index)
 if roles.has("patroller"):
  decoy(roles.patroller.op,roles.patroller.index)
  silt(roles.patroller.op,roles.patroller.index)
 print("NEVER DISABLED CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
func disrupt_sight(r:String,op:int,index:int)->void:
 var label="Disrupt on %s (op %d S%d)"%[r,op,index+1]
 var f=setup(op,index);check(not f.is_empty(),label+": open water found beside the Siren")
 if f.is_empty():return
 var s=f.sim;var e=f.e
 check(s.command("emp") and e.stun==Tuning.EMP_STUN and e.mode=="DISRUPTED",label+": pulse stuns the Siren")
 rehold(s,index);var held:Vector2=e.pos
 tick(s,Tuning.EMP_STUN-0.5)
 check(e.stun>0 and e.target==-1 and e.lock==0.0 and e.pos==held,label+": stunned Siren neither senses Quietus in clear sight nor moves")
 tick(s,1.0)
 check(e.stun<=0 and e.mode!="DISRUPTED" and senses(e),label+": after the stun the Siren senses Quietus again")
 check(s.outcome=="",label+": dive still running")
 acts_after(s,e,f.far,label)
func torpedo(r:String,op:int,index:int)->void:
 var label="Torpedo on %s (op %d S%d)"%[r,op,index+1]
 var f=setup(op,index);check(not f.is_empty(),label+": open water found beside the Siren")
 if f.is_empty():return
 var s=f.sim;var e=f.e
 check(s.command("knock",{"target":index}),label+": torpedo launches at the observed Siren")
 var hit=false
 for i in 120:
  tick(s,Simulation.STEP*2)
  if e.mode=="PINNED":hit=true;break
 check(hit and e.get("pin_time",0)>Simulation.KNOCK_TIME-0.3,label+": impact pins the Siren (mode %s, %s)"%[e.mode,s.message])
 if not hit:return
 var held:Vector2=e.pos
 tick(s,Simulation.KNOCK_TIME-1.0)
 check(e.mode=="PINNED" and e.target==-1 and e.lock==0.0 and e.pos==held,label+": pinned Siren neither senses nor moves")
 tick(s,1.5)
 check(e.stun<=0 and e.get("pin_time",0)<=0 and e.mode!="PINNED" and senses(e),label+": after the pin the Siren senses Quietus again")
 acts_after(s,e,f.far,label)
func disrupt_static(r:String,op:int,index:int)->void:
 var label="Disrupt on %s (op %d S%d)"%[r,op,index+1]
 var f=setup(op,index);check(not f.is_empty(),label+": open water found beside the Siren")
 if f.is_empty():return
 var s=f.sim;var e=f.e
 check(s.command("emp") and e.stun==Tuning.EMP_STUN and e.mode=="DISRUPTED",label+": pulse stuns the Siren")
 rehold(s,index)
 tick(s,Tuning.EMP_STUN-0.5)
 check(e.stun>0 and e.mode=="DISRUPTED",label+": role stays suppressed during the stun")
 if r in NETWORK_ROLES:check(e.network.packet.is_empty(),label+": stunned network Siren carries no report")
 else:check(e.industry.phase=="idle",label+": stunned industrial Siren charges nothing")
 tick(s,1.0)
 check(e.stun<=0 and e.mode!="DISRUPTED",label+": role resumes after the stun (mode "+str(e.mode)+")")
 if r=="buoy":
  e.network.cooldown=0.0
  s._noise(e.pos+Vector2(60,0),650.0,"ACTIVE SONAR",2.0,f.band);tick(s,0.3)
  check(not e.network.packet.is_empty(),label+": recovered listener hears and reports again (mode "+str(e.mode)+")")
 elif r in INDUSTRY_ROLES:
  e.industry.cooldown=0.0;var acted=false
  for i in 30:
   tick(s,0.1)
   if e.industry.phase!="idle":acted=true;break
  check(acted,label+": recovered industrial Siren senses Quietus and winds up again (mode "+str(e.mode)+")")
func decoy(op:int,index:int)->void:
 var label="Decoy on patroller (op %d S%d)"%[op,index+1]
 var f=setup(op,index,140.0);check(not f.is_empty(),label+": open water found beside the Siren")
 if f.is_empty():return
 var s=f.sim;var e=f.e
 # Quietus is hidden far away; the decoy goes into clear water between where Quietus was and the Siren.
 var point:Vector2=s.units[0].pos.lerp(e.pos,0.5)
 check(s.command("decoy",{"point":point}),label+": decoy placed in clear water")
 s.units[0].pos=f.far+Vector2(40,0)
 var start:Vector2=e.pos;tick(s,2.0)
 check(e.mode in ["INVESTIGATE","SEARCH"] and e.pos.distance_to(point)<start.distance_to(point),label+": Siren is drawn toward the decoy")
 tick(s,Tuning.DECOY_TIME)
 check(not s.noises.any(func(n):return n.label=="DECOY"),label+": decoy transmission ends")
 check(e.stun<=0 and not e.mode in ["DISRUPTED","PINNED"],label+": Siren was never stunned by the decoy")
 s.units[0].pos=open_point(s,e.pos,f.band,80,120) if open_point(s,e.pos,f.band,80,120)!=null else s.units[0].pos
 s._observe();var sensed=false
 for i in 30:
  tick(s,0.1)
  if senses(e):sensed=true;break
 check(sensed,label+": after the decoy the Siren senses Quietus again")
func silt(op:int,index:int)->void:
 var label="Silt screen on patroller (op %d S%d)"%[op,index+1]
 var f=setup(op,index);check(not f.is_empty(),label+": open water found beside the Siren")
 if f.is_empty():return
 var s=f.sim;var e=f.e
 var life:float=FieldTools.spec("silt_screen").life
 var point:Vector2=s.units[0].pos.lerp(e.pos,0.5)
 check(s.command("silt_screen",{"point":point}),label+": silt screen released between Quietus and the Siren")
 var blind=true
 for i in int(life-1.0):
  tick(s,1.0)
  if e.target==0:blind=false
 check(blind,label+": Siren cannot see Quietus through the cloud")
 check(e.stun<=0 and not e.mode in ["DISRUPTED","PINNED"],label+": Siren keeps acting inside the cloud's lifetime")
 var sensed=false
 for i in 40:
  tick(s,0.1)
  if e.target==0 and e.lock>0:sensed=true;break
 check(sensed,label+": once the cloud clears the Siren sees Quietus again")
