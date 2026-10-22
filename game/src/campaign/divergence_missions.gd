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
  m.signal_sources=[_source("deep","DEEP CARRIER",Vector2(1620,760),"A drillship's thrusters are still running somewhere past the northeastern descent, one steady beat. A sunken ship with a pressure bell may still have air. It is a place to investigate, not proof that anyone is alive."),_source("shelf","SHELFWARD ECHO",Vector2(520,800),"A shore station's active pings come in from the shelf, one every few seconds. Its seabed cable runs to a bunker on the coast. A western shelf corridor leads toward it.")]
  m["corridors"]=[{"pos":Vector2(1920,220),"name":"DEEP DESCENT","route":"deep"},{"pos":Vector2(180,1560),"name":"SHELF PASSAGE","route":"shelf"}]
  m.brief="The bearings from Corran Bank point two ways through charted basalt: a drillship's thrusters in the deep, a shore station's pings on the shelf. Neither source is located. Listen in the western shelf water and northeastern trench; received direction may bend around rock. Separate drone listening positions can guide Quietus through the central lee. Close passive observation or a finite local RECON survey identifies a source immediately. Investigate either or both, then take Quietus through the corresponding DEEP DESCENT or SHELF PASSAGE. Your physical exit selects the next expedition; both facts remain if found. Returning to the southern recovery basin after departure is an incomplete withdrawal."
  m.record="Two sites still make noise, one deep and one on the shelf. Quietus recovered a route to each. Where it dives first decides who it reaches first."
  _patrol(m,Vector2(650,1150),[Vector2(650,1150),Vector2(620,760),Vector2(320,620),Vector2(640,1540)])
  _patrol(m,Vector2(1830,1230),[Vector2(1830,1230),Vector2(1830,1680),Vector2(1280,1580),Vector2(1280,800)])
 elif deep:
  m.start=Vector2(1800,2180);m.extraction=Vector2(420,180)
  m.rocks=[Rect2(1000,1600,1400,260),Rect2(840,680,320,720),Rect2(-100,1000,580,280),Rect2(1260,900,300,350),Rect2(120,300,260,340),Rect2(760,-100,300,500)]
  var source=_source("rendezvous","BERTHING CARRIER",Vector2(540,640),"A support tender and the drillship Tessaly trade low position corrections to hold the ship over its own riser. Four saturation divers wait in a pressure bell below it and cannot be brought up fast.")
  source["confirm"]=true;source["cadence"]=[0.8,1.6,0.8];m.signal_sources=[source]
  m["rendezvous_transport"]=preload("res://src/simulation/rendezvous_transport.gd").initial()
  m["structures"]=[Rect2(500,480,300,80)] # Sheltered mooring; western listening water stays open.
  m["corridors"]=[{"pos":m.extraction,"name":"NORTH TRENCH RECOVERY","route":"deep"}]
  m.brief="Enter from the lower trench. Locate the berthing carrier in the western basin, then bring Quietus within clear receiver reach and use CAMERA / LISTEN to confirm the Tessaly's bell line. Drones can find its carrier while Quietus crosses the covered central saddle. Recovery lies north, beyond the berth. The long southern wall separates the lower staging basin from the central saddle. A drone can watch its western tip while Quietus crosses."
  m.record="Tessaly's bell line confirmed: four divers alive at depth, the thruster loop still running above them. Quietus has a route farther down the trench."
  _patrol(m,Vector2(1280,1430),[Vector2(1280,1430),Vector2(1700,1430),Vector2(1780,1940),Vector2(1360,1940)])
  _patrol(m,Vector2(650,800),[Vector2(650,800),Vector2(460,800),Vector2(460,460),Vector2(680,560)])
  m.sirens[1].type="sentinel";m.sirens[1]["tether"]=190.0
  m.brief+=" A Siren sentinel holds the berthing basin and returns to its post after an investigation."
  m.brief+=" The bell's lift packet is aboard a physical support tender. It stays at the berth unless you explicitly RELEASE BERTH from the locally discovered control. That one audible control transmission, the kind of sound that brought the Sirens down the first time, sends it along the announced western lane to the northern mooring, where it remains available. A drone can operate the control while Quietus stages elsewhere; Quietus can operate it alone. Quiet reception at the original berth also works. Survey locates nearby hulls and machinery; a measured vessel fix grows stale when no receiver can still sense it."
 else:
  preload("res://src/simulation/shelf_habitat.gd").build(m)
  _patrol(m,Vector2(1510,1510),[Vector2(1510,1510),Vector2(2010,1510),Vector2(2080,700),Vector2(1500,700)])
  _patrol(m,Vector2(660,920),[Vector2(660,920),Vector2(620,1280),Vector2(1000,1400),Vector2(620,1650)])
  m.sirens[0].type="hunter"
  m.brief+=" A fast Siren hunter listens along the eastern approach; cover breaks its visual pursuit."
 return m
static func _source(id:String,label:String,pos:Vector2,evidence:String)->Dictionary:
 return {"id":id,"label":label,"pos":pos,"evidence":evidence,"located":false}
static func _patrol(m:Dictionary,pos:Vector2,points:Array)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":"patroller","patrol_points":points,"patrol_index":0})

static func supports_config(config:Dictionary)->bool:
 var source=config.get("source_id",-1)
 return config.size()==2 and config.get("history")==false and source in IDS

# Identity-bound authored helpers remain on their original operation.
static func supports_identity(id:int,config:Dictionary)->bool:
 return id==config.source_id or config.source_id in [6,7]
