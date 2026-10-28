extends SceneTree
const Recon=preload("res://src/simulation/recon_consequences.gd")
class PublicSim:
 extends RefCounted
 const Recon=preload("res://src/simulation/recon_consequences.gd")
 var mission={"id":14}
 var sirens=[]
 var units=[{"alive":true}]
 var elapsed=0.0
 var events=[]
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize()->void:
 var Hunt=load("res://src/simulation/hunt_pressure/hunt_pressure.gd")
 check(Hunt!=null,"Hunt module loads")
 if Hunt==null:finish();return
 var Table=load("res://src/simulation/hunt_pressure/hunt_table.gd")
 Table.enabled=true
 var legacy={"id":14};check(not Hunt.active(legacy),"legacy mission is inactive")
 var before=legacy.duplicate(true);check(Hunt.sight(legacy,{"type":"hunter"},1.15)==1.15 and legacy==before,"legacy sight and mission unchanged")
 var m={"id":14};Hunt.initialize(m)
 check(Hunt.active(m) and Hunt.valid(m,0.),"fresh optional state validates")
 var expected=[1.,1.,1.,1.15,1.15,1.15,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.7,1.7,1.7,1.7,1.7,1.7,1.7,1.7,1.,1.]
 for id in expected.size():
  m.id=id;m.reconnaissance={"hunt":95.,"floor":0.,"delay":0.,"secured":[]}
  check(is_equal_approx(Hunt.view_mission(m).scale,expected[id]),"operation %d global cap"%id)
 m.id=22
 for pair in [[0.,0,1.],[19.99,0,1.],[20.,1,1.15],[44.99,1,1.15],[45.,2,1.3],[69.99,2,1.3],[70.,3,1.5],[89.99,3,1.5],[90.,4,1.7],[100.,4,1.7]]:
  m.reconnaissance.hunt=pair[0];var view=Hunt.view_mission(m)
  check(view.index==pair[1] and is_equal_approx(view.scale,pair[2]),"stage boundary %.2f"%pair[0])
 for role in ["patroller","sentinel","hunter","sweeper",""]:
  check(Hunt.sight(m,{"type":role},1.15)==1.7,"eligible role "+role)
 for role in ["buoy","relay","interceptor","warden","unknown"]:
  check(Hunt.sight(m,{"type":role},1.15)==1.15,"excluded role "+role)
 check(Hunt.sight(m,{"type":"hunter"},1.7)==1.7,"local and global combine by max, not multiplication")
 for pair in [["ACTIVE SONAR",5.],["DISRUPTION",4.],["KNOCKDOWN",4.],["DECOY",0.],["RECON UPLINK",0.]]:
  check(Hunt.action_amount(m,pair[0],4.)==pair[1],"action amount "+pair[0])
 check(Hunt.action_amount(legacy,"DECOY",4.)==4.,"legacy action amount unchanged")
 var s=PublicSim.new();Hunt.initialize(s.mission)
 s.sirens=[{"type":"hunter","target":0,"lock":.1,"stun":0.,"mode":"LOCKING"}]
 Hunt.observe(s,.05)
 check(is_equal_approx(Recon.state(s.mission).hunt,6.),"new visual craft edge adds six")
 Hunt.observe(s,.05);check(is_equal_approx(Recon.state(s.mission).hunt,6.),"continuous sight adds nothing")
 s.sirens[0].target=-1;s.sirens[0].lock=0.;Hunt.observe(s,.05)
 s.sirens[0].target=0;s.sirens[0].lock=.1;Hunt.observe(s,.05)
 check(is_equal_approx(Recon.state(s.mission).hunt,12.),"second none-to-some edge adds six")
 s.mission.reconnaissance.hunt=25.;Hunt.observe(s,.05)
 check(s.events.filter(func(e):return e.type=="hunt_stage").size()==1,"stage rise emits one public cue")
 s.mission.reconnaissance.hunt=75.;Hunt.observe(s,.05)
 check(s.events.filter(func(e):return e.type=="hunt_stage").size()==1,"three-second cue limit")
 s.elapsed=3.1;s.mission.reconnaissance.hunt=95.;Hunt.observe(s,.05)
 check(s.events.filter(func(e):return e.type=="hunt_stage").size()==2,"later stage rise can cue")
 var copy=s.mission.duplicate(true);check(Hunt.valid(copy,s.elapsed),"owned state roundtrip validates")
 for bad in [null,[],{"revision":2,"stage":0,"seen":false}]:
  var broken=copy.duplicate(true);broken.hunt_pressure=bad
  check(not Hunt.valid(broken,s.elapsed),"malformed owned field rejected")
 for pair in [["stage",1.5],["stage",5],["seen",1],["cause",123],["cue_at",NAN],["cue_at",99.]]:
  var broken=copy.duplicate(true);broken.hunt_pressure[pair[0]]=pair[1]
  check(not Hunt.valid(broken,s.elapsed),"invalid owned member "+pair[0])
 for pair in [["hunt",NAN],["hunt",101.],["floor",-1.],["delay",INF]]:
  var broken=copy.duplicate(true);broken.reconnaissance[pair[0]]=pair[1]
  check(not Hunt.valid(broken,s.elapsed),"invalid pressure member "+pair[0])
 Table.enabled=false
 var inactive={"id":14};Hunt.initialize(inactive)
 check(not inactive.has("hunt_pressure"),"flag off writes no new field")
 var frozen=s.mission.duplicate(true);Hunt.observe(s,.05)
 check(s.mission==frozen and Hunt.sight(m,{"type":"hunter"},1.)==1. and Hunt.action_amount(m,"DECOY",4.)==4.,"off flag restores rules without owned writes")
 check(Hunt.ambience_offset(m)==0. and not Hunt.view_mission(m).active,"flag off restores presentation/audio")
 Table.enabled=true
 check(Hunt.ambience_offset(m)==5.1,"late ambience table")
 m.id=3;check(Hunt.ambience_offset(m)==3.,"early ambience capped independently of sight cap")
 Table.enabled=true;finish()
func finish()->void:
 print("HUNT PRESSURE CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
