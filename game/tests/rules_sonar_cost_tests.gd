extends SceneTree
# Displayed SONAR reserve cost must equal what the simulation spends, for every
# hull, drone chassis, pulse power and sector.
const Hulls=preload("res://src/equipment/hulls.gd")
const Chassis=preload("res://src/equipment/chassis.gd")
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func frames():
 for n in 4:await process_frame
func spent(sim,unit:int)->float:
 sim.paused=false;sim.ping_time=0.0;sim.units[unit].transition={}
 var before=sim.oxygen if unit==0 else sim.units[unit].battery
 sim.command("select",{"unit":unit})
 var ok=sim.command("ping")
 var after=sim.oxygen if unit==0 else sim.units[unit].battery
 return before-after if ok else -1.0
func displayed(text:String)->float:
 return float(text.replace("EMIT\n","").replace(" RESERVE",""))
func run():
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.store.path="user://rules-r1-cost.save"
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(g.store.path+suffix)
 root.size=Vector2i(2520,1080);await frames()
 root.add_child(g);await frames();g.set_process(false)
 var cases=[]
 for hull in Hulls.HULLS:cases.append([0,{"quietus":"","drone_a":"","drone_b":"","hull":hull},hull])
 for chassis in Chassis.CHASSIS:cases.append([1,{"quietus":"","drone_a":"","drone_b":"","chassis_a":chassis},chassis])
 check(cases.size()>=7,"every hull and chassis in the fitting data is exercised")
 for row in cases:
  for power in ["low","high"]:
   for sector in ["all","forward"]:
    g._start_mission(0);g._enter_water();var sim=g.sim
    sim.sirens=[];sim.mission.launch_equipment=row[1].duplicate(true)
    sim.sonar.power=power;sim.sonar.sector=sector
    sim.oxygen=100.0;sim.units[1].battery=100.0
    sim.command("select",{"unit":row[0]});g._refresh();g.mission_hud.open("acoustics");await frames()
    var shown=displayed(g.mission_hud.extra.sonar_emit.text)
    var cost=sim.Sonar.pulse_cost(sim,row[0])
    var paid=spent(sim,row[0])
    var label="%s %s %s"%[row[2],power,sector]
    check(paid>0.0 and absf(shown-paid)<0.006,label+" label "+str(shown)+" equals spent "+str(paid))
    check(absf(cost-paid)<0.0001,label+" single cost function equals spent")
 # The reported bug: low noise hull, low power, all-around pulse.
 g._start_mission(0);g._enter_water();g.sim.sirens=[];g.sim.mission.launch_equipment={"quietus":"","drone_a":"","drone_b":"","hull":"quiet"}
 g.sim.sonar.power="low";g.sim.sonar.sector="all";g.sim.command("select",{"unit":0});g._refresh();g.mission_hud.open("acoustics");await frames()
 check("0.5 RESERVE" in g.mission_hud.extra.sonar_emit.text,"low noise hull shows 0.5 reserve, not 0.4")
 g.queue_free();await frames()
 print("RULES SONAR COST CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
