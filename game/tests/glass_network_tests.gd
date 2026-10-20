extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func tick(s,seconds):
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func fixture():
 var s=Sim.new();s.start(14);s.mission.rocks=[];s.mission.structures=[];s.mission.depth_geometry={};s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 for id in [1,2]:s.units[id].alive=false
 s.units[0].pos=Vector2(400,600)
 s.sirens[0].pos=Vector2(1350,600);s.sirens[0].home=s.sirens[0].pos;s.sirens[0].goal=s.sirens[0].pos
 s.sirens[1].pos=Vector2(600,600);s.sirens[1].home=s.sirens[1].pos
 s.sirens[2].pos=Vector2(1000,600);s.sirens[2].home=s.sirens[2].pos
 return s
func _initialize():
 var s=fixture();check(s.has_method("network_feedback"),"buoy/relay network runtime interface exists")
 if not s.has_method("network_feedback"):finish();return
 tick(s,1.)
 check(s.sirens[1].network.packet.is_empty(),"stationary quiet craft grants buoy no invented contact")
 s._noise(s.units[0].pos,400.,"ACTIVE SONAR",.2,1);tick(s,.1)
 var packet=s.sirens[1].network.packet.duplicate(true)
 check(not packet.is_empty() and packet.point!=s.units[0].pos,"received noise latches uncertain grid point rather than a live target")
 var original=packet.point;s.units[0].pos=Vector2(250,1800);tick(s,1.)
 check(s.sirens[1].network.packet.point==original and s.sirens[2].network.packet.is_empty(),"charging report cannot track moved craft or forward instantly")
 var snapshot=s.snapshot();var copy=Sim.new();check(Sim.valid_snapshot(snapshot) and copy.restore(snapshot),"charged network packet roundtrips current snapshot")
 s.advance(30);check(s.snapshot()==snapshot,"pause freezes network delay and packet lifetime")
 tick(s,2.)
 check(not s.sirens[2].network.packet.is_empty() and s.sirens[2].network.packet.point==original,"relay receives actual delayed stale physical report")
 tick(s,3.)
 check(s.sirens[0].get("last_known",Vector2.ZERO)==original and s.sirens[0].get("known_band",-1)==1,"relay recruits existing armed investigator to received old area")
 check(s.hull==120 or s.hull==100,"network itself inflicts no omniscient damage")
 tick(s,20.)
 check(s.sirens.filter(func(e):return e.get("type","") in ["buoy","relay"]).all(func(e):return e.network.packet.is_empty()),"expired packets cannot loop through relays forever")
 s=fixture();s.units[0].band=2;s._noise(s.units[0].pos,900.,"ACTIVE SONAR",1.,2);tick(s,3.)
 check(s.sirens[1].network.packet.is_empty(),"leaving buoy water volume defeats layer-specific hearing")
 s=fixture();s._noise(s.units[0].pos,400.,"ACTIVE SONAR",1.,1);tick(s,.2);s.command("emp");tick(s,3.)
 check(s.sirens[1].network.packet.is_empty() and s.sirens[2].network.packet.is_empty(),"physical disruption interrupts charge before any onward report")
 s=fixture();s.mission.structures=[Rect2(480,0,40,2400)];s._build_navigation();s._noise(s.units[0].pos,400.,"ACTIVE SONAR",1.,1);tick(s,3.)
 check(s.sirens[1].network.packet.is_empty(),"real separating terrain blocks listening evidence")
 var before=s.network_feedback();var truth=s.sirens;s.sirens=[]
 check(s.network_feedback()==before,"public network feedback reads acquired contacts rather than hidden roster");s.sirens=truth
 finish()
func finish():print("GLASS NETWORK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
