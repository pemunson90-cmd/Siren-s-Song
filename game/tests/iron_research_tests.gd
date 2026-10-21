extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,t):
 s.paused=false
 for i in roundi(t*60):s.advance(Sim.STEP)
 s.paused=true
func _initialize():
 check("quietus_pressure_sleeve" in Equipment.ITEMS and "drone_traction_yoke" in Equipment.ITEMS,"two material-funded practical Iron fittings exist")
 var p={"completed":[22,23,26,27],"facts":{"choir_22":"actual dock receipt","choir_23":"actual pressure locks"},"entitlements":[]}
 var m={"recovered":true,"iron_choir":{"retrieved":true,"artifact":{"id":"pressure_spindle","state":"recovered"}}}
 p=Research.recovered(p,m)
 check("quietus_pressure_sleeve" in p.entitlements,"physical pressure spindle and returned hammer proof fund sleeve")
 m.iron_choir.artifact.id="traction_core";p=Research.recovered(p,m)
 check("drone_traction_yoke" in p.entitlements and Research.valid(p),"second real material funds fitting without fake cadence refs")
 var before=p.duplicate(true);p=Research.recovered(p,m);check(p==before,"replay cannot farm industrial recovered material")
 if "quietus_pressure_sleeve" in Equipment.ITEMS:
  var bare=Sim.new();bare.start(23);bare.sirens=[];var fitted=Sim.new();fitted.start(23,"endurance",{"fitted":{"quietus":"quietus_pressure_sleeve","drone_a":"","drone_b":""}});fitted.sirens=[]
  check(bare.command("depth",{"band":0}) and fitted.command("depth",{"band":0}),"bare and fitted Quietus begin real adjacent transitions")
  check(fitted.units[0].transition.remaining<bare.units[0].transition.remaining and fitted.oxygen<bare.oxygen and fitted.noises.any(func(n):return n.label=="PRESSURE SLEEVE"),"shortened transition pays actual reserve and acoustic cost")
  tick(fitted,1.);fitted.command("select",{"unit":1});check(Sim.valid_snapshot(fitted.snapshot()) and fitted.Depth.occupied(fitted.units[0])==[1,0],"shorter transition remains exposed in both bands and saveable after peer selection")
  tick(fitted,1.6);tick(bare,2.6);check(fitted.units[0].band==0 and not bare.units[0].transition.is_empty(),"fitted sleeve changes actual later pressure-lock timing")
  fitted.command("depth",{"band":0});check(fitted.units[1].transition.remaining==4.,"Quietus sleeve never remotely upgrades drone transition")
 if "drone_traction_yoke" in Equipment.ITEMS:
  var s=Sim.new();s.start(24,"endurance",{"fitted":{"quietus":"","drone_a":"drone_traction_yoke","drone_b":""}});s.sirens=[]
  s.units[1].pos=s.mission.iron_choir.load.pos+Vector2(0,35);s.command("select",{"unit":1})
  check(s.command("choir_action",{"action":"attach"}),"actual fitted drone yoke attaches regional ballast")
  s.command("select",{"unit":2});check(s.Choir.towing(s,1) and not s.Choir.yoke(s,2),"yoke remains on working craft across peer selection")
  var a=Vector2(1675,2050);var b=Vector2(1675,1350)
  check(s.Depth.clear(s,a,b,1,16) and not s.Depth.clear(s,a,b,1,32),"authored service water accepts stabilized yoke envelope but not bare broad load")
  s.units[1].vel=Vector2(20,0)
  check(s.Choir.speed(s,1,96.)==22. and s.Choir.noise(s,1)>0,"yoke tow pays real speed and propulsion noise cost")
 print("IRON RESEARCH CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
