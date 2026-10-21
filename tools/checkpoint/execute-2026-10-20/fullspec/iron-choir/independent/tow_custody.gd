extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
func tick(s,t):
 s.paused=false
 for i in roundi(t*60):s.advance(Sim.STEP)
 s.paused=true
func _initialize():
 var s=Sim.new();s.start(26);s.sirens=[];var a=s.mission.iron_choir.artifact
 s.units[1].pos=a.pos+Vector2(0,-35);s.units[1].band=2;s.command("select",{"unit":1})
 check(s.command("choir_action",{"action":"recover"}),"DEEP drone starts actual material winch")
 tick(s,.8);s.command("select",{"unit":2});var copy=Sim.new()
 check(copy.restore(s.snapshot()),"DEEP material work saves with MIDDLE peer selected")
 tick(s,3.4);tick(copy,3.4)
 check(a.state=="cargo" and a.carrier==1 and copy.mission.iron_choir.artifact.carrier==1,"deep winch finishes independently of selection/restoration")
 s.units[1].alive=false;tick(s,.1)
 check(a.state=="wreck" and a.carrier==-1 and a.band==2 and Sim.valid_snapshot(s.snapshot()),"lost deep carrier leaves valid physical material wreck")
 s.units[0].pos=a.pos+Vector2(0,-35);s.command("select",{"unit":0})
 check(not s.command("choir_action",{"action":"recover"}),"wrong-depth Quietus cannot collect deep wreck")
 s.units[0].band=2;s.command("select",{"unit":0});check(s.command("choir_action",{"action":"recover"}),"same-band Quietus can recover lost real material")
 tick(s,4.2);check(a.state=="cargo" and a.carrier==0 and Sim.valid_snapshot(s.snapshot()),"recovered material changes custody without duplicate reward or bad snapshot")
 s=Sim.new();s.start(24,"endurance",{"fitted":{"quietus":"","drone_a":"drone_traction_yoke","drone_b":""}});s.sirens=[]
 s.units[0].pos=Vector2(300,2350);s.units[1].pos=s.mission.iron_choir.load.pos+Vector2(0,35);s.units[2].pos=s.units[1].pos;s.command("select",{"unit":2})
 check(not s.command("choir_action",{"action":"attach"}),"remote yoke on peer cannot let bare B attach")
 s.command("select",{"unit":1});check(s.command("choir_action",{"action":"attach"}),"actual fitted A attaches physical ballast")
 check(not s.command("depth",{"band":2}),"physical tow cannot be depth-teleported")
 var origin=s.mission.iron_choir.load.pos
 check(s.command("route",{"point":s.units[1].pos+Vector2(0,180)}),"tow worker receives ordinary physical route")
 tick(s,2.);s.units[0].band=2;s.command("select",{"unit":0});copy=Sim.new()
 check(copy.restore(s.snapshot()),"active unselected trail-followed tow restores")
 var frozen=s.snapshot();s.advance(30.)
 check(s.snapshot()==frozen,"pause freezes real load and travelled trail")
 tick(s,5.);tick(copy,5.)
 var load=s.mission.iron_choir.load;var restored=copy.mission.iron_choir.load
 check(load.pos.distance_to(origin)>40 and load.carrier==1 and load.pos.distance_to(restored.pos)<.001 and load.trail==restored.trail,"real fitted tow follows identical travelled water after selection/restore")
 check(load.pos.distance_to(s.units[1].pos)<100 and s.Depth.clear(s,load.pos,load.pos,1,16) and Sim.valid_snapshot(s.snapshot()),"physical load stays bounded in actual water with valid current state")
 s.units[1].alive=false;tick(s,.1)
 check(load.state=="free" and load.carrier==-1 and Sim.valid_snapshot(s.snapshot()),"actual tow-craft loss leaves unteleported free load and valid save")
 print("INDEPENDENT IRON TOW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
