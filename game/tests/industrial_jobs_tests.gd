extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,t):
 s.paused=false
 for i in roundi(t*60):s.advance(Sim.STEP)
 s.paused=true
func fixture(id):
 var s=Sim.new();s.start(id);s.sirens=[];return s
func _initialize():
 check(ResourceLoader.exists("res://src/simulation/industrial_jobs.gd"),"physical industrial job runtime exists")
 if not ResourceLoader.exists("res://src/simulation/industrial_jobs.gd"):finish();return
 var s=fixture(23);s.units[1].pos=s.mission.iron_choir.sites[0].pos+Vector2(0,35);s.command("select",{"unit":1})
 check(s.command("choir_action",{"action":"lock_a"}),"actual local drone starts equalizer")
 tick(s,1.);s.units[2].band=2;s.command("select",{"unit":2});var copy=Sim.new()
 var restored=copy.restore(s.snapshot());check(restored,"partial unselected equalizer restores")
 if not restored:finish();return
 var before=s.snapshot();s.advance(2.);check(before==s.snapshot(),"pause freezes machinery work")
 tick(s,7.2);tick(copy,7.2)
 check(s.mission.iron_choir.sites[0].done and copy.mission.iron_choir.sites[0].done and s.mission.structures.size()==8,"unselected local worker opens actual shutter after restore")
 s=fixture(24);s.units[0].pos=s.mission.iron_choir.load.pos+Vector2(0,40)
 check(s.command("choir_action",{"action":"attach"}),"bare Quietus attaches actual ballast locally")
 var load_start=s.mission.iron_choir.load.pos
 check(s.mission.iron_choir.load.pos==load_start,"attach does not teleport load")
 s.command("route",{"point":s.units[0].pos+Vector2(0,150)});tick(s,6.)
 check(s.mission.iron_choir.load.pos.distance_to(load_start)>50 and s.mission.iron_choir.load.pos.distance_to(s.units[0].pos)<100,"physical tow moves through travelled water")
 s.units[0].alive=false;tick(s,.1)
 check(s.mission.iron_choir.load.carrier==-1 and s.mission.iron_choir.load.state=="free","lost tow craft leaves actual physical load")
 s=fixture(22)
 check(s.Choir.status(s).load.is_empty(),"hidden industrial vessel has no live tracker")
 s.units[0].pos=s.mission.iron_choir.sites[0].pos+Vector2(0,30)
 check(s.command("choir_action",{"action":"east"}),"deliberate actual freight course starts locally")
 tick(s,1.);s.Choir.observe(s);var seen=s.Choir.status(s).load
 s.units[0].pos=Vector2(300,300);tick(s,3.)
 check(not seen.is_empty() and s.Choir.status(s).load.pos==seen.pos and s.Choir.status(s).load.age>0,"lost vessel observation freezes position rather than tracking")
 s=fixture(26);var a=s.mission.iron_choir.artifact;s.units[1].pos=a.pos+Vector2(0,-35);s.units[1].band=2;s.command("select",{"unit":1})
 check(s.command("choir_action",{"action":"recover"}),"same-depth physical alien material winch")
 tick(s,4.2);s.units[1].alive=false;tick(s,.1)
 check(a.state=="wreck" and a.band==2 and a.carrier==-1,"artifact loss retains actual deep wreck")
 var malformed=s.snapshot();malformed.mission.erase("iron_choir")
 check(not Sim.valid_snapshot(malformed),"new current save requires physical industrial state")
 s=fixture(23);malformed=s.snapshot();malformed.mission.iron_choir.sites=[]
 check(not Sim.valid_snapshot(malformed),"industrial current save cannot omit authored locks")
 s=fixture(22);malformed=s.snapshot();malformed.mission.iron_choir.load.trail=[7]
 check(not Sim.valid_snapshot(malformed),"physical tow trail rejects non-point current save")
 malformed=s.snapshot();malformed.mission.iron_choir.load.state="transit"
 check(not Sim.valid_snapshot(malformed),"moving freight requires an actual bounded destination")
 var active=Sim.new();active.start(23,"endurance",{"fitted":{"quietus":"","drone_a":"drone_survey_array","drone_b":""}});active.sirens=[]
 active.units[0].pos=active.mission.iron_choir.sites[0].pos+Vector2(0,35);active.units[1].pos=active.units[0].pos+Vector2(30,0);active.units[1].alive=false;tick(active,.1)
 check(active.command("choir_action",{"action":"lock_a"}),"local equalizer claims worker before other salvage")
 check(not active.command("salvage",{"item":"drone_survey_array"}),"industrial worker cannot simultaneously recover another physical module")
 rules()
 bell_cooperation()
 finish()
func rules():
 # 22 freight intercept: the sled jams at its shut lane gate and is lost unless the gate is worked.
 var s=fixture(22);s.units[0].pos=Vector2(750,2030);s.units[0].vel=Vector2.ZERO
 check(s.command("choir_action",{"action":"west"}),"22 sled released on the west lane");s.units[0].pos=Vector2(300,2350)
 tick(s,150.)
 check(s.outcome=="lost","22 an unattended sled jams at the shut lane gate and is lost")
 s=fixture(22);s.units[0].pos=Vector2(750,2030);s.command("choir_action",{"action":"west"});s.units[0].pos=Vector2(300,2350);s.mission.iron_choir.sites[1].done=true
 tick(s,150.)
 check(s.outcome.is_empty() and s.mission.iron_choir.load.state=="arrived" and s.mission.iron_choir.load.hull>=100.,"22 an opened gate lets the sled arrive undamaged")
 s=fixture(22);s.units[0].pos=Vector2(750,2030);s.command("choir_action",{"action":"west"});s.units[0].pos=Vector2(300,2350);s.mission.iron_choir.sites[2].done=true
 tick(s,150.)
 check(s.outcome=="lost","22 opening the other lane's gate does not save the sled")
 # 23 lock sequence
 s=fixture(23);var st=s.mission.iron_choir.sites;s.units[0].band=0;s.units[0].pos=st[1].pos+Vector2(0,35);s.units[0].vel=Vector2.ZERO
 check(s.Choir.context(s,"lock_b").reason=="Finish LOCK_A first" and not s.command("choir_action",{"action":"lock_b"}),"23 second equalizer waits for the first")
 st[0].done=true;check(s.Choir.context(s,"lock_b").ready,"23 second equalizer ready after the first")
 s.units[0].band=2;s.units[0].pos=st[2].pos+Vector2(0,-35)
 check(s.Choir.context(s,"lock_c").reason=="Finish LOCK_B first","23 third equalizer waits for the second")
 # 25 escort: the sled only advances while a craft is near
 s=fixture(25);s.mission.iron_choir.sites[1].done=true;s.units[0].pos=Vector2(750,2030);s.units[0].vel=Vector2.ZERO
 check(s.command("choir_action",{"action":"west"}),"25 escorted sled released")
 var start=s.mission.iron_choir.load.pos;s.units[0].pos=Vector2(2000,2400);tick(s,10.)
 check(s.mission.iron_choir.load.pos.distance_to(start)<5.,"25 sled holds with no escort in range")
 s.units[0].pos=s.mission.iron_choir.load.pos+Vector2(60,0);tick(s,5.)
 check(s.mission.iron_choir.load.pos.distance_to(start)>30.,"25 sled advances once a craft escorts it")
 # 26 the hammer restart seals the west mouth; the cooling release is the other way out
 s=fixture(26);var a=s.mission.iron_choir.artifact;s.units[0].band=2;s.units[0].pos=a.pos+Vector2(0,-35);s.units[0].vel=Vector2.ZERO
 check(s.command("choir_action",{"action":"recover"}),"26 deep winch starts");tick(s,4.2)
 check(s.mission.iron_choir.stamp>=0. and not s.mission.iron_choir.sealed,"26 lifting the spindle starts the hammer clock")
 tick(s,101.)
 check(s.mission.iron_choir.sealed and Rect2(1100,350,150,150) in s.mission.structures and Sim.valid_snapshot(s.snapshot()),"26 west mouth seals with the carrier still inside, save stays valid")
 var copy=Sim.new();check(copy.restore(s.snapshot()) and copy.mission.iron_choir.sealed,"26 sealed mouth restores")
 s._use_band(2);check(s.path(s.units[0].pos,Vector2(700,425)).is_empty(),"26 the sealed mouth cannot be crossed")
 s.units[0].pos=s.mission.iron_choir.sites[0].pos+Vector2(0,-20)
 check(s.command("choir_action",{"action":"cooling"}),"26 cooling release works from inside");tick(s,8.2)
 s._use_band(2);check(not s.path(s.units[0].pos,Vector2(1450,1000)).is_empty(),"26 cooling release opens the south return")
 # 27 a loose counterweight slides back unless chocked
 s=fixture(27);var load=s.mission.iron_choir.load;s.units[0].pos=load.pos+Vector2(0,40);s.units[0].vel=Vector2.ZERO
 check(s.command("choir_action",{"action":"attach"}),"27 counterweight attached")
 load.state="free";load.carrier=-1;load.pos=Vector2(750,1500);tick(s,10.)
 check(load.pos.y>1540.,"27 an unchocked counterweight slides back downhill")
 s.mission.iron_choir.sites[0].done=true;load.pos=Vector2(750,1200);tick(s,10.)
 check(abs(load.pos.y-1200.)<1.,"27 a chocked counterweight above the ledge stays put")
 load.pos=Vector2(750,1500);tick(s,5.)
 check(load.pos.y>1500.,"27 the chock does not hold the weight below the ledge")
 s=fixture(27);s.units[0].pos=s.mission.iron_choir.sites[0].pos;s.units[0].vel=Vector2.ZERO
 check(s.Choir.context(s,"lock_a").reason=="Bring the real load to this station","27 chock needs the load beside it")
 # 28 decompression stops need the towed bell
 s=fixture(28);s.units[0].pos=s.mission.iron_choir.sites[0].pos;s.units[0].vel=Vector2.ZERO
 check(s.Choir.context(s,"lock_a").reason=="Bring the real load to this station" and s.Choir.context(s,"land").reason!="","28 stop work needs the bell towed to the station")
 # 29 the far breaker drops out when the reconnect window lapses
 s=fixture(29);s.units[0].pos=s.mission.iron_choir.sites[0].pos+Vector2(0,30);s.units[0].vel=Vector2.ZERO
 check(s.command("choir_action",{"action":"lock_c"}),"29 far breaker work starts");tick(s,8.2)
 check(s.mission.iron_choir.sites[0].done and s.mission.iron_choir.stamp>=0.,"29 far breaker thrown")
 tick(s,151.)
 check(not s.mission.iron_choir.sites[0].done and s.mission.iron_choir.stamp==-1.,"29 breaker drops out after the window")
 s.units[0].pos=s.mission.iron_choir.sites[1].pos+Vector2(0,30)
 check(s.Choir.context(s,"reconnect").reason=="Finish LOCK_C first","29 reconnect refused without the held breaker")

func finish():print("INDUSTRIAL JOBS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

func bell_cooperation():
 var s=fixture(28);var state=s.mission.iron_choir;var station=state.sites[0].pos
 s.units[0].pos=station+Vector2(0,35);s.units[0].vel=Vector2.ZERO
 state.load.pos=station+Vector2(0,70);state.load.state="towed";state.load.carrier=0
 s.units[1].pos=station+Vector2(20,0);s.units[1].vel=Vector2.ZERO;s.command("select",{"unit":1})
 check(s.command("choir_action",{"action":"lock_a"}),"28 a second local craft operates the stop beside the actual towed bell")
 tick(s,1.);var snapshot=s.snapshot();var restored=Sim.new()
 check(Sim.valid_snapshot(snapshot) and restored.restore(snapshot),"28 simultaneous tow and partial drone stop roundtrip current save")
 s.command("select",{"unit":0});check(s.command("emp"),"28 carrier can defend while the second craft works")
 tick(s,7.2);tick(restored,7.2)
 check(state.sites[0].done and restored.mission.iron_choir.sites[0].done and Sim.valid_snapshot(restored.snapshot()),"28 unselected local helper completes after carrier defense and saved restore")
 for interruption in ["bell_departure","bell_depth","helper_depth","helper_loss","tow_release"]:
  var interrupted=Sim.new();check(interrupted.restore(snapshot),"28 interruption fixture restores "+interruption)
  match interruption:
   "bell_departure":interrupted.units[0].pos+=Vector2(400,0)
   "bell_depth":interrupted.mission.iron_choir.load.band=0
   "helper_depth":interrupted.units[1].band=0
   "helper_loss":interrupted.units[1].alive=false
   "tow_release":interrupted.mission.iron_choir.load.state="free";interrupted.mission.iron_choir.load.carrier=-1
  tick(interrupted,8.)
  check(not interrupted.mission.iron_choir.sites[0].done and interrupted.mission.iron_choir.jobs[1].is_empty(),"28 no ghost completion after "+interruption)
 var remote=Sim.new();check(remote.restore(snapshot),"28 remote worker fixture restores")
 remote.mission.iron_choir.jobs[1]={};remote.units[1].hold="";remote.units[1].pos+=Vector2(200,0)
 check(not remote.command("choir_action",{"action":"lock_a"}),"28 remote second craft cannot start stop work")
