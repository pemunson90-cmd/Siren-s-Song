extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const FIELD="res://src/simulation/current_field.gd"
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func world(flow:Vector2):
 var s=Sim.new();s.start(0);s.mission.rocks=[];s.mission["structures"]=[]
 s.mission["currents"]=[{"center":Vector2(700,800),"radius":1000.0,"velocity":flow}]
 s._build_navigation();s.units[0].pos=Vector2(400,800);s.units[0].angle=0;s.units[0].vel=Vector2.ZERO;s.units[0]["water_velocity"]=Vector2.ZERO
 return s
func move(s,holding:bool=false):s._move(s.units[0],1.0/60,42,holding,true,true)
func _initialize():
 check(ResourceLoader.exists(FIELD),"radially faded current field exists")
 if failures:finish();return
 var field=load(FIELD)
 var fields=[{"center":Vector2(700,800),"radius":200.0,"velocity":Vector2(34,-10)}]
 check(field.sample(fields,Vector2(700,800))==Vector2(34,-10),"V7 center has full authored flow")
 check(field.sample(fields,Vector2(800,800))==Vector2(17,-5),"V7 radial fade halves flow halfway out")
 check(field.sample(fields,Vector2(900,800))==Vector2.ZERO,"field edge has no displacement")
 var plain=world(Vector2.ZERO);var assist=world(Vector2(24,0));var oppose=world(Vector2(-24,0))
 for s in [plain,assist,oppose]:s.command("route",{"point":Vector2(1200,800)})
 for tick in 480:
  for s in [plain,assist,oppose]:move(s)
 check(assist.units[0].pos.x>plain.units[0].pos.x+50 and oppose.units[0].pos.x<plain.units[0].pos.x-50,"same propulsion gains or loses ground progress with the water")
 check(assist.propulsion_speed(assist.units[0])<=42.01 and assist.units[0].vel.length()>42,"flow assistance does not become fictional engine thrust")
 var hold=world(Vector2(24,0));hold.units[0].pos=Vector2(700,800);hold.units[0].angle=PI/2;hold.units[0].vel=Vector2(24,0)
 var anchor:Vector2=hold.units[0].pos;var maximum=0.0
 for tick in 1800:
  move(hold,true);maximum=maxf(maximum,anchor.distance_to(hold.units[0].pos))
 check(maximum<20 and anchor.distance_to(hold.units[0].pos)<1,"bounded vector HOLD avoids rejected62m heading excursion and regains its station")
 check(hold.units[0].vel.length()<.1 and hold.propulsion_speed(hold.units[0])>20,"ground-settled HOLD retains counterthrust effort")
 var stop=world(Vector2(24,0));stop.command("route",{"point":Vector2(800,800)})
 for tick in 1800:move(stop)
 check(stop.units[0].route.is_empty() and stop.units[0].pos.distance_to(Vector2(800,800))<2 and stop.units[0].vel.length()<.1,"final STOP reaches and holds a ground station in flowing water")
 var cross=world(Vector2(0,24));cross.command("route",{"point":Vector2(1200,800)})
 for tick in 480:move(cross)
 check(absf(cross.units[0].pos.y-800)<20,"course thrust compensates lateral flow instead of sweeping the route into cover")
 var wall=world(Vector2(1000,0));wall.mission.rocks=[Rect2(720,700,20,200)];wall._build_navigation();wall.units[0].pos=Vector2(700,800);wall.units[0].water_velocity=Vector2.ZERO
 wall._move(wall.units[0],.2,42,true,true,true)
 check(wall.units[0].pos.x<708 and not wall.blocked(wall.units[0].pos,12),"swept current displacement cannot tunnel through a thin obstacle")
 var paused=world(Vector2(24,0));var before=paused.snapshot();paused.advance(20)
 check(paused.snapshot()==before,"pause freezes current movement and station state")
 var saved=hold.snapshot();var restored=Sim.new()
 check(Sim.valid_snapshot(saved) and restored.restore(saved) and restored.units[0].get("water_velocity")==hold.units[0].water_velocity,"current effort and station survive current-save restore")
 var readings=hold.current_feedback()
 check(not readings.is_empty() and readings[0].flow.x>20 and readings[0].effort>20,"own craft publishes its local flow and counterthrust effort")
 check(not readings[0].has("center") and not readings[0].has("radius") and not readings[0].has("fields"),"local current instrument does not disclose the hidden field map")
 var operation=Sim.new();operation.start(11);operation.sirens=[]
 var receiver:Vector2=operation.mission.signal_sources.filter(func(source):return source.id=="confluence_packet")[0].pos
 operation.mission["currents"]=[{"center":receiver,"radius":400.0,"velocity":Vector2(0,24)}]
 operation.units[0].pos=receiver;operation.units[0].vel=Vector2.ZERO;operation.units[0]["water_velocity"]=Vector2(0,-24)
 operation.paused=false;operation.advance(.2)
 check(operation.camera_context().ready and operation.command("camera"),"ground-stationary counterthrust allows the real receiver action")
 for tick in 300:operation.advance(1.0/60)
 check(operation.mission.objectives.any(func(o):return o.get("site_id","")=="confluence_packet" and o.captured),"settled current-aware receiver completes without drift interruption")
 print("CURRENT MOTION DIAGNOSTIC hold_max=",maximum," assist_x=",assist.units[0].pos.x," plain_x=",plain.units[0].pos.x," oppose_x=",oppose.units[0].pos.x)
 finish()
func finish():
 print("CURRENT MOTION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
