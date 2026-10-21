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
 check(s.mission.iron_choir.sites[0].done and copy.mission.iron_choir.sites[0].done and s.mission.structures.size()==2,"unselected local worker opens actual shutter after restore")
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
 finish()
func finish():print("INDUSTRIAL JOBS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
