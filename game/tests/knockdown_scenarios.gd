extends SceneTree
const Simulation=preload("res://src/simulation/simulation.gd")
const SaveStore=preload("res://src/persistence/save_store.gd")
var checks:=0
var failures:=0
func check(ok: bool,text: String) -> void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",text)
func fixture():
 var s=Simulation.new();s.start(4);s.units[0].band=1;s.units[0].pos=Vector2(600,750);s.units[0].angle=0.0
 for i in [0,1]:
  s.sirens[i].band=1;s.sirens[i].transition={};s.sirens[i].pos=Vector2(700+i*30,750);s.sirens[i].vel=Vector2(8,3);s.sirens[i].route=[];s.sirens[i].home=s.sirens[i].pos;s.sirens[i].goal=s.sirens[i].pos
 s._observe();return s
func tick(s,seconds: float) -> void:
 for i in ceili(seconds/Simulation.STEP):s.advance(Simulation.STEP)
func _initialize() -> void:
 var s=fixture();check(s.tools.get("knock",0)==2,"new dives carry exactly two knockdown torpedoes")
 var accepted=s.command("knock",{"target":0})
 check(accepted,"ordinary knock command launches at a current observed Siren in clear close range")
 if not accepted:finish();return
 check(s.tools.knock==1 and s.sirens[0].stun==0.0,"valid launch spends one charge without an instant pin")
 check(s.get("projectiles") is Array and s.get("projectiles").size()==1,"launch creates an independent physical projectile")
 if not s.get("projectiles") is Array:finish();return
 var in_flight=s.snapshot();var flight_restore=Simulation.new()
 check(flight_restore.restore(in_flight) and flight_restore.projectiles.size()==1 and flight_restore.tools.knock==1,"active flight serializes and restores paused")
 tick(flight_restore,10);check(flight_restore.projectiles[0].pos==s.projectiles[0].pos,"pause freezes projectile travel")
 s.paused=false;tick(s,0.1)
 check(s.sirens[0].stun==0.0 and s.projectiles.size()==1 and s.projectiles[0].pos.distance_to(s.units[0].pos)>5,"torpedo has visible travel time before impact")
 tick(s,0.5)
 check(s.projectiles.is_empty() and s.sirens[0].stun>7.7 and s.sirens[0].mode=="PINNED","only physical impact begins eight-second snare")
 s.paused=true
 check(s.sirens[0].get("pin_time",0)>7.7,"snare carries its own eight-second depth clock independent of disruption")
 check(s.sirens[1].stun==0.0,"a second Siren inside EMP radius is unaffected by the targeted pin")
 check(s.sirens[0].lock==0 and s.sirens[0].target==-1 and s.sirens[0].vel==Vector2.ZERO,"pin interrupts beam and immediately immobilizes its single target")
 check(s.noises.any(func(n):return n.label=="KNOCKDOWN" and n.radius==650.0) and s.sirens[0].suspicion>=0.45,"shot has explicit local acoustic and struck-target pressure costs")
 var held=s.sirens[0].pos;tick(s,20)
 check(s.sirens[0].stun>7.7 and s.sirens[0].pos==held,"tactical pause freezes pin and motion")
 s.paused=false;tick(s,3)
 check(s.sirens[0].pos==held and s.sirens[0].stun>4.7 and s.sirens[0].stun<5.1,"pinned Siren stays physically fixed while eight-second clock runs")
 var saved=s.snapshot();var restored=Simulation.new();check(restored.restore(saved) and restored.tools.knock==1 and restored.sirens[0].mode=="PINNED","partial pin and finite stock restore paused without a schema migration")
 tick(restored,20);check(restored.sirens[0].stun==s.sirens[0].stun,"restored pause consumes no pin time")
 restored.paused=false;tick(restored,5.1)
 check(restored.sirens[0].stun<=0 and restored.sirens[0].mode!="PINNED","pin expires after eight simulation seconds and ordinary AI resumes")
 check(Simulation.valid_snapshot(restored.snapshot()),"ordinary post-pin expiry remains saveable")
 for args in [{},{"target":-1},{"target":0.0},{"target":true},{"target":99}]:
  var invalid=fixture();check(not invalid.command("knock",args) and invalid.tools.knock==2,"invalid target rejects without spending: "+str(args))
 var old=fixture();old.contacts[0].time=-1.0
 check(not old.command("knock",{"target":0}) and old.tools.knock==2,"remembered echo cannot be shot")
 old.contacts.erase(0);check(not old.command("knock",{"target":0}) and old.tools.knock==2,"hidden unobserved Siren cannot be shot by index")
 var far=fixture();far.sirens[0].pos=far.units[0].pos+Vector2(150.1,0);far._observe()
 check(not far.command("knock",{"target":0}) and far.tools.knock==2,"currently observed target beyond 150m rejects without spend")
 far.sirens[0].pos=far.units[0].pos+Vector2(150,0);far._observe()
 check(far.command("knock",{"target":0}),"exact 150m boundary remains valid")
 var cover=fixture();var pair=[]
 for x in range(400,1200,20):
  if not pair.is_empty():break
  for y in range(140,760,20):
   var a=Vector2(x,y)
   if cover.blocked(a,12):continue
   for offset in [Vector2(100,80),Vector2(100,-80),Vector2(-100,80),Vector2(-100,-80)]:
    var b=a+offset
    if not cover.blocked(b,12) and not cover.line_clear(a,b):pair=[a,b];break
   if not pair.is_empty():break
 check(pair.size()==2,"cover counterexample uses two physically open positions under 150m")
 if pair.size()==2:
  cover.units[0].pos=pair[0];cover.units[1].pos=pair[1];cover.sirens[0].pos=pair[1];cover._observe()
  check(cover.contacts.has(0) and not cover.command("knock",{"target":0}) and cover.tools.knock==2,"drone observation does not let Quietus fire through rock")
 var drone=fixture();drone.command("select",{"unit":1})
 check(not drone.command("knock",{"target":0}) and drone.tools.knock==2,"Quietus torpedo cannot silently launch from a drone")
 var pinned=fixture();pinned.command("knock",{"target":0});pinned.paused=false;tick(pinned,0.6);pinned.paused=true
 check(not pinned.command("knock",{"target":0}) and pinned.tools.knock==1,"already immobilized target rejects without wasting another charge")
 check(pinned.command("knock",{"target":1}) and pinned.tools.knock==0 and not pinned.command("knock",{"target":1}),"two launches exhaust stock; no negative charges")
 var miss=fixture();miss.command("knock",{"target":0});var aim=miss.projectiles[0].aim
 miss.sirens[0].pos=Vector2(1500,900);miss.sirens[1].pos=Vector2(1400,900);miss.paused=false;tick(miss,0.1)
 check(miss.projectiles[0].aim==aim,"projectile never acquires a new target position beyond Quietus sensors")
 tick(miss,3.1);check(miss.projectiles.is_empty() and miss.tools.knock==1 and miss.sirens[0].stun==0,"a physical miss expires without refund or remote pin")
 check(miss.message=="Torpedo run ended · shot spent","own projectile expiry replaces launch history with spent-shot feedback")
 var wall=fixture();wall.sirens[0].pos=Vector2(600,650);wall.sirens[1].pos=Vector2(1400,900);wall.mission.rocks.append(Rect2(650,710,20,30));wall._build_navigation();wall._observe()
 check(wall.line_clear(wall.units[0].pos,wall.sirens[0].pos) and wall.command("knock",{"target":0}),"a clear target can be valid despite terrain in the initial bow direction")
 wall.paused=false;tick(wall,1.0)
 check(wall.projectiles.is_empty() and wall.sirens[0].stun==0 and wall.tools.knock==1,"turning physical torpedo can hit basalt instead of teleporting to target")
 var malformed_flight=in_flight.duplicate(true);malformed_flight.projectiles[0].pos=Vector2(NAN,0)
 check(not Simulation.valid_snapshot(malformed_flight),"nonfinite projectile position rejects before restore")
 malformed_flight=in_flight.duplicate(true);malformed_flight.projectiles[0].target=99
 check(not Simulation.valid_snapshot(malformed_flight),"invalid projectile target rejects before restore")
 malformed_flight=in_flight.duplicate(true);malformed_flight.projectiles[0].life=-1
 check(not Simulation.valid_snapshot(malformed_flight),"expired invalid projectile rejects before restore")
 var shadow=fixture();shadow.units[0].pos=Vector2(600,690);shadow.sirens[0].pos=Vector2(704,680);shadow.sirens[1].pos=Vector2(1400,900);shadow.mission.rocks.append(Rect2(650,700,40,100));shadow._build_navigation();shadow._observe()
 check(shadow.command("knock",{"target":0}),"near-corner target launches with valid Quietus sight")
 var acquired=shadow.projectiles[0].aim;shadow.sirens[0].pos=Vector2(704,730);shadow.paused=false;tick(shadow,0.1)
 check(not shadow.line_clear(shadow.units[0].pos,shadow.sirens[0].pos) and shadow.projectiles[0].aim==acquired,"target behind rock within range cannot update projectile aim")
 var overstock=in_flight.duplicate(true);overstock.tools.knock=2
 check(not Simulation.valid_snapshot(overstock),"in-flight entity plus remaining stock cannot exceed two original rounds")
 var bad_pin=saved.duplicate(true);bad_pin.sirens[0].stun=0.0
 check(not Simulation.valid_snapshot(bad_pin),"active depth pin cannot restore with an inconsistent zero immobilization clock")
 var stacked=fixture();stacked.command("knock",{"target":0});stacked.paused=false;tick(stacked,0.6)
 var remaining=stacked.sirens[0].get("pin_time",0);stacked.command("emp");tick(stacked,1.0)
 check(remaining>7.7 and absf(stacked.sirens[0].get("pin_time",0)-(remaining-1))<0.02 and stacked.sirens[0].stun>10.9,"EMP keeps twelve-second disruption without resetting the physical snare interval")
 tick(stacked,7.1);check(stacked.sirens[0].get("pin_time",0)==0 and stacked.sirens[0].stun>3.8,"snare resurfaces on its clock while any longer EMP recovery remains")
 var emp=fixture();emp.command("emp")
 check(emp.sirens[0].stun==12.0 and emp.sirens[1].stun==12.0 and emp.tools.emp==1,"existing radial EMP still disrupts both for twelve seconds")
 var legacy=fixture().snapshot();legacy.tools.erase("knock");var legacy_tools=legacy.tools.duplicate();var resumed=Simulation.new()
 check(resumed.restore(legacy) and resumed.tools==legacy_tools and not resumed.command("knock",{"target":0}),"missing legacy stock remains absent and unavailable without a free grant")
 for value in [-1,3,2.0,true,NAN,"2"]:
  var malformed=fixture().snapshot();malformed.tools.knock=value
  check(not Simulation.valid_snapshot(malformed),"new optional stock rejects malformed value "+str(value))
 var store=SaveStore.new();store.path="user://knockdown-test.save"
 var archive={"version":1,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","active":saved}
 check(store.save(archive) and store.load_game().active.tools.knock==1,"actual binary archive retains spent stock and partial pin")
 archive.active=in_flight
 check(store.save(archive) and store.load_game().active.projectiles.size()==1,"actual binary archive retains an in-flight torpedo")
 var audio=preload("res://src/audio/soundscape.gd").samples("knock");var loudest=0.0
 for value in audio:loudest=maxf(loudest,absf(value))
 check(audio.size()>1000 and loudest>0.01 and loudest<=0.31,"original torpedo launch cue has nonzero bounded PCM")
 for path in ["accepted-blackwater.archive","accepted-finale.archive"]:
  store.path="res://tests/fixtures/"+path;var archive_old=store.load_game();var active=Simulation.new()
  check(archive_old.is_empty() and not store.warning.is_empty(),"Pass0 rejects incompatible old archive: "+path)
 finish()
func finish() -> void:
 print("KNOCKDOWN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
