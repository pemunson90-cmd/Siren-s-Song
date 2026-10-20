extends RefCounted
const IDS=[6,7,8]
static func make(index:int)->Dictionary:
 var entry=index==6;var deep=index==7
 var m={"id":index,"title":["The Divergence","Deep Rendezvous","Shelf Return"][index-6],"depth":4200 if entry else (4860 if deep else 2900),"darkness":false,"region_revision":1,"world_size":Vector2(2200,2600 if entry else 2400),"acoustic_revision":1,"expedition_revision":1,"objectives":[],"sirens":[],"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.0,"chosen_route":"","recovered":false,"withdrawal_armed":false}
 if index in [7,8]:m["consequence_revision"]=1
 if index==7:m["measured_reference"]=[]
 if entry:
  m.start=Vector2(400,2300);m.extraction=Vector2(400,2360)
  m.rocks=[Rect2(-100,1800,800,200),Rect2(1000,1720,1400,200),Rect2(900,780,300,700),Rect2(100,1100,470,360),Rect2(680,300,160,300),Rect2(1400,1000,260,430),Rect2(1720,500,500,140),Rect2(950,-100,300,500)]
  m.signal_sources=[_source("deep","DEEP CARRIER",Vector2(1620,760),"The carrier repeats evacuation berths and a depth corridor. A rendezvous lies beyond the northeastern descent. It is a route to investigate, not proof of an ally."),_source("shelf","SHELFWARD ECHO",Vector2(520,800),"The shelfward echo repeats a verified fracture warning toward an old receiving station. A western shelf corridor may let Quietus carry the packet back toward inhabited water.")]
  m["corridors"]=[{"pos":Vector2(1920,220),"name":"DEEP DESCENT","route":"deep"},{"pos":Vector2(180,1560),"name":"SHELF PASSAGE","route":"shelf"}]
  m.brief="Beyond the tutorial warning, two carriers diverge through charted basalt. Their sources are not located. Listen in the western shelf water and northeastern trench; received direction may bend around rock. Separate drone listening positions can guide Quietus through the central lee. Close passive observation or a finite local RECON survey identifies a source immediately. Investigate either or both, then take Quietus through the corresponding DEEP DESCENT or SHELF PASSAGE. Your physical exit selects the next expedition; both facts remain if found. Returning to the southern recovery basin after departure is an incomplete withdrawal."
  m.record="The warning leads in two directions. Quietus recovered a physical route, not a target order."
  _patrol(m,Vector2(650,1150),[Vector2(650,1150),Vector2(620,760),Vector2(320,620),Vector2(640,1540)])
  _patrol(m,Vector2(1830,1230),[Vector2(1830,1230),Vector2(1830,1680),Vector2(1280,1580),Vector2(1280,800)])
 elif deep:
  m.start=Vector2(1800,2180);m.extraction=Vector2(420,180)
  m.rocks=[Rect2(1000,1600,1400,260),Rect2(840,680,320,720),Rect2(-100,1000,580,280),Rect2(1260,900,300,350),Rect2(120,300,260,340),Rect2(760,-100,300,500)]
  var source=_source("rendezvous","BERTHING CARRIER",Vector2(540,640),"Unarmed hulls exchange low berthing corrections. The rendezvous is assembling an evacuation line farther down the trench.")
  source["confirm"]=true;source["cadence"]=[0.8,1.6,0.8];m.signal_sources=[source]
  m["rendezvous_transport"]=preload("res://src/simulation/rendezvous_transport.gd").initial()
  m["structures"]=[Rect2(500,480,300,80)] # Sheltered mooring; western listening water stays open.
  m["corridors"]=[{"pos":m.extraction,"name":"NORTH TRENCH RECOVERY","route":"deep"}]
  m.brief="Enter from the lower trench. Locate the berthing carrier in the western basin, then bring Quietus within clear receiver reach and use CAMERA / LISTEN to confirm the evacuation rendezvous. Drones can find its carrier while Quietus crosses the covered central saddle. Recovery lies north, beyond the berth. The long southern wall separates the lower staging basin from the central saddle. A drone can watch its western tip while Quietus crosses."
  m.record="Deep rendezvous confirmed: the hulls are organizing an evacuation, but the destination remains unresolved. Quietus has a route farther down the trench."
  _patrol(m,Vector2(1280,1430),[Vector2(1280,1430),Vector2(1700,1430),Vector2(1780,1940),Vector2(1360,1940)])
  _patrol(m,Vector2(650,800),[Vector2(650,800),Vector2(460,800),Vector2(460,460),Vector2(680,560)])
  m.sirens[1].type="sentinel";m.sirens[1]["tether"]=190.0
  m.brief+=" A sentinel holds the berthing basin and returns to its post after an investigation."
  m.brief+=" The packet is aboard a physical unarmed tender. It stays at the berth unless you explicitly RELEASE BERTH from the locally discovered control. That one audible control transmission sends it along the announced western lane to the northern refuge, where it remains available. A drone can operate the control while Quietus stages elsewhere; Quietus can operate it alone. Quiet reception at the original berth also works. Survey locates nearby hulls and machinery; a measured vessel fix grows stale when no receiver can still sense it."
 else:
  m.start=Vector2(1920,600);m.extraction=Vector2(220,2180)
  m.rocks=[Rect2(1280,280,300,1000),Rect2(580,1000,420,300),Rect2(940,1600,1280,200),Rect2(100,460,620,200),Rect2(340,1600,300,240),Rect2(1680,920,600,220)]
  m.objectives=[{"pos":Vector2(1080,1480),"name":"SHELTERED WARNING RECEIVER","site_id":"warning_receiver","optical":"divergence_warning","captured":false,"kind":"receiver","required_unit":0,"duration":4.0,"evidence":"Quietus forwards the verified fracture warning through the sheltered shelf receiver. Acknowledgement returns from human water; this channel can carry a warning rather than a firing solution."}]
  m["corridors"]=[{"pos":m.extraction,"name":"WEST SHELF RECOVERY","route":"shelf"}]
  m.brief="Bring the verified warning along the outer shelf. The receiving station is charted in the central lee, south of the long eastern basalt wall. Only Quietus can transmit the packet: reach the SHELTERED WARNING RECEIVER and use CAMERA / LISTEN. Drones can scout either side while Quietus carries the packet toward the western recovery basin. The exposed outer return is direct; the lower western bend breaks sight. Return west with the acknowledgement."
  m.record="The shelf receiver acknowledges the fracture warning. Quietus has opened a channel toward human water without handing command a target list."
  _patrol(m,Vector2(1760,760),[Vector2(1760,760),Vector2(1940,780),Vector2(1940,1240),Vector2(1660,1420)])
  _patrol(m,Vector2(800,1510),[Vector2(800,1510),Vector2(1150,1510),Vector2(730,1900),Vector2(180,1940)])
  m.sirens[0].type="hunter"
  m.brief+=" A fast hunter listens along the eastern approach; cover breaks its visual pursuit."
 return m
static func _source(id:String,label:String,pos:Vector2,evidence:String)->Dictionary:
 return {"id":id,"label":label,"pos":pos,"evidence":evidence,"located":false}
static func _patrol(m:Dictionary,pos:Vector2,points:Array)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":"patroller","patrol_points":points,"patrol_index":0})
