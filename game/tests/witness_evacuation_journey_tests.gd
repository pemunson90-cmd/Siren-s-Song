extends SceneTree
# Source-known technical voyages from actual launch water. Guards, movement,
# tools and custody transitions run unchanged; no terminal flag is injected.
# Solo cases start without helper bodies; the rescue case loses its loaded A
# to ordinary four-second guard sight rather than a scripted death.
const Sim=preload("res://src/simulation/simulation.gd")
const Store=preload("res://src/persistence/save_store.gd")
const BERTH=Vector2(1840,800)
const HOME=Vector2(2260,2700)
const APPROACH=[Vector2(580,1900),Vector2(1380,1940),Vector2(1380,1100),BERTH]
var checks=0
var failures=0
var last_defense=-10.0
var distance=0.0
var reacted=false
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func local(s,id:int,pos:Vector2)->bool:
 return s.units[id].alive and s.units[id].pos.distance_to(pos)<55 and s.units[id].vel.length()<2 and s.line_clear(s.units[id].pos,pos)
func defend(s):
 if s.elapsed-last_defense<1:return
 for c in s.contacts.values():
  if s.elapsed-c.time<.3 and c.lock>=2 and c.target==0:
   s.command("select",{"unit":0});var targets=s.knockdown_targets()
   if not targets.is_empty() and s.tools.knock>0 and s.command("knock",{"target":targets[0].key}):last_defense=s.elapsed+1;return
   if s.command("emp"):last_defense=s.elapsed;return
func tick(s,protect:bool=true):
 if protect:defend(s)
 var before=s.units[0].pos;s.paused=false;s.advance(Sim.STEP);distance+=before.distance_to(s.units[0].pos)
 for noise in s.noises:
  if noise.label!="SERVICE SLUICE MOTOR":continue
  for guard in s.sirens:
   var arrival=s._heard_arrival(guard)
   if guard.mode=="INVESTIGATE" and arrival.get("pulse",false) and guard.goal.distance_to(arrival.goal)<5 and not s.acoustic_paths.arrivals(guard.pos,noise.pos,noise.radius).is_empty():reacted=true
func go(s,id:int,pos:Vector2,quiet:bool=true,protect:bool=true)->bool:
 s.command("select",{"unit":id})
 if id==0 and s.units[id].silent!=quiet:s.command("silent")
 elif id>0:s.command("drone_drive",{"mode":"quiet" if quiet else "transit"})
 if not s.command("route",{"point":pos}):check(false,"actual voyage route accepts legal water "+str(pos));return false
 for n in 18000:
  if not s.outcome.is_empty() or not s.units[id].alive:return false
  if local(s,id,pos):return true
  tick(s,protect)
 return false
func winch(s,id:int)->bool:
 s.command("select",{"unit":id})
 if not s.command("salvage",{"item":s.salvage_sites()[0].item}):return false
 for n in 300:
  tick(s)
  if s.witness_status().capsule.state=="carried":return s.witness_status().capsule.carrier==id
  if not s.outcome.is_empty():return false
 return false
func solve_local(s)->bool:
 # Additional actual Quietus voyage, not a staged completion flag.
 s.command("select",{"unit":0})
 if not go(s,0,Vector2(1380,850)) or not go(s,0,Vector2(1840,1010)):return false
 if not s.command("concealed_tow",{"action":"attach"}):return false
 if not go(s,0,Vector2(1840,850)):return false
 if not s.command("concealed_tow",{"action":"release"}):return false
 for n in 130:tick(s)
 return s.concealed_status().receipt
func setup():
 var s=Sim.new();s.start(12,"endurance");s.units[1].alive=false;s.units[2].alive=false
 last_defense=-10;distance=0;reacted=false;return s
func run_solo(service:bool):
 var s=setup();var reached=true
 for point in APPROACH:
  if not go(s,0,point,point==Vector2(1380,1100) or point==BERTH):reached=false;break
 check(reached and s.witness_status().known,"solo route physically discovers the occupied berth under original guards")
 if not reached:return
 check(winch(s,0),"solo Quietus loads the living witness with an actual local four-second winch")
 check(solve_local(s),"rescued witness guides actual local trace hauling and received station reply")
 var loaded_at=s.elapsed;var start_distance=distance
 if service:
  check(go(s,0,Vector2(1380,1940)) and go(s,0,Vector2(1780,2040)),"loaded craft physically approaches the authored optional actuator")
  s.command("select",{"unit":0});check(s.command("camera"),"local Quietus actuates the optional sluice through ordinary receiver work")
  for n in 260:tick(s)
  check(s.mission.physical_gates[0].opened and s.noises.any(func(n):return n.label=="SERVICE SLUICE MOTOR"),"one completed actuator really opens the hull path and emits the existing finite motor")
  check(go(s,0,HOME,false),"occupied carrier traverses the physically open service return")
 else:
  check(go(s,0,Vector2(1380,1100)) and go(s,0,Vector2(1380,1940)) and go(s,0,Vector2(580,1900),false) and go(s,0,HOME,false),"occupied carrier physically returns through the long quiet detour")
 s.command("select",{"unit":0});check(s.command("witness_land"),"local arrived Quietus explicitly lands its living passenger")
 tick(s)
 check(s.outcome=="won" and s.hull>0 and Sim.valid_snapshot(s.snapshot()),"real solo voyage physically lands the witness and recovers a valid Quietus")
 check(s.mission.physical_gates[0].opened==service,"return preserves the selected actual sluice choice")
 if service:check(reacted,"an original guard reacts during the real finite sluice motor run")
 else:check(not s.noises.any(func(n):return n.label=="SERVICE SLUICE MOTOR"),"quiet voyage never borrows a hidden gate opening or motor")
 print("WITNESS JOURNEY ","solo-sluice" if service else "solo-detour"," outcome=",s.outcome," time=",s.elapsed," loaded_return=",s.elapsed-loaded_at," loaded_metres=",distance-start_distance," hull=",s.hull," oxygen=",s.oxygen," EMP=",s.tools.emp," torpedoes=",s.tools.knock," guard_reacted=",reacted)
func run_rescue():
 var s=Sim.new();s.start(12,"endurance",{"fitted":{"quietus":"","drone_a":"drone_deep_cells","drone_b":""}});s.units[2].alive=false
 last_defense=-10;distance=0;reacted=false;var reached=true
 for point in APPROACH:
  if not go(s,1,point,true,false):reached=false;break
 check(reached and s.units[1].alive,"real drone reaches the berth alive through unchanged guards")
 if not reached:return
 check(winch(s,1),"real drone boards the same occupied capsule before its exposed return")
 # A carried snapshot is real current binary data before any loss.
 var archive={"version":2,"unlocked":5,"completed":[0,1,2,3,4,5],"upgrade":"endurance","settings":{},"expedition":{"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch","confluence_route":"concealed"},"completed":[6,7,9,11],"notes":{},"references":{},"entitlements":["drone_deep_cells"],"history":[],"selected_thread":"deep"},"active":s.snapshot()}
 var store=Store.new();store.path="user://occupied-witness-journey.save"
 check(store.save(archive) and store.load_game()==archive,"actual loaded drone voyage survives a current binary archive roundtrip")
 var restored=Sim.new();check(restored.restore(store.load_game().active) and restored.witness_status()==s.witness_status(),"actual transit restore retains its exact carrier, occupied cargo and live guards")
 s=restored
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(store.path+suffix)
 # A deliberately enters the authored southern patrol basin and waits. This
 # uses a fixed known map point, never the guard's changing private position.
 go(s,1,Vector2(1780,1780),false,false)
 for n in 2400:
  if not s.units[1].alive:break
  tick(s,false)
 check(not s.units[1].alive and s.events.any(func(e):return e.type=="beam") and s.witness_status().capsule.state=="salvage","an actual guard beam destroys the loaded carrier and ejects its same occupied pod")
 if s.units[1].alive:return
 var wreck=s.witness_status().capsule.pos
 check(s.witness_status().capsule.losses==[1] and s.salvage_sites().size()==1,"actual known loss preserves one shared kit-and-witness wreck")
 check(go(s,0,wreck),"bare Quietus physically reaches the known lost carrier site under the remaining guard")
 check(winch(s,0),"bare Quietus rescues the actual witness and colocated inert kit with one exposed winch")
 check(s.witness_status().capsule.rescues==1 and s.module_recovery_status().cargo[0]==["drone_deep_cells"] and not s.units[1].alive,"actual rescue retains its real carrier loss and unique equipment custody")
 check(solve_local(s),"rescued occupant guides a real bare-Q trace disconnection after carrier loss")
 check(go(s,0,Vector2(1380,1940)) and go(s,0,Vector2(580,1900),false) and go(s,0,HOME,false),"loaded fallback Quietus physically takes the closed-sluice western return")
 s.command("select",{"unit":0});check(s.command("witness_land"),"rescued living witness is explicitly landed at actual local harbour")
 tick(s)
 check(s.outcome=="won" and s.hull>0 and Sim.valid_snapshot(s.snapshot()),"real beam loss of every helper still permits a valid physical rescue and Quietus recovery")
 print("WITNESS JOURNEY beam-loss-rescue outcome=",s.outcome," time=",s.elapsed," hull=",s.hull," oxygen=",s.oxygen," EMP=",s.tools.emp," torpedoes=",s.tools.knock," wreck=",wreck," losses=",s.witness_status().capsule.losses)
func _initialize():
 run_solo(false);run_solo(true);run_rescue()
 print("WITNESS EVACUATION JOURNEY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
