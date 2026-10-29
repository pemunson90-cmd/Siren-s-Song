extends RefCounted
# Authored 38/39 geography only. Revert with their factory calls; no rule changes.
const T=preload("res://src/campaign/encounters/terrain.gd")
const DEEP_GATE=Rect2(650,1800,300,160)
static func deep(m:Dictionary)->void:
 m.world_size=Vector2(2000,2800);m.start=Vector2(350,2480)
 # Three physical landmarks: split launch tooth, low roof, western mooring ribs.
 T.apply(m,[[T.shard(Vector2(1050,2390),190,7,74,.3,Vector2(.6,1.4)),T.ALL],[Rect2(650,1300,1200,300),[0,1]],[Rect2(950,1800,900,160),T.ALL],[T.ridge([Vector2(660,500),Vector2(640,650),Vector2(700,760)],140,74),T.ALL]])
 m.structures=[DEEP_GATE]
 m.currents=[]
 m.sirens=[]
 _patrol(m,[Vector2(1000,450),Vector2(1550,450),Vector2(1750,700),Vector2(1100,650)])
 _patrol(m,[Vector2(1750,1650),Vector2(1750,1740),Vector2(1200,1740),Vector2(1200,1650)])
static func shelf(m:Dictionary)->void:
 m.world_size=Vector2(3000,1920);m.start=Vector2(350,1520)
 T.apply(m,[[T.ridge([Vector2(850,950),Vector2(1050,1150),Vector2(1150,1500),Vector2(1150,1900)],170,75),T.ALL],[T.wall([Vector2(1050,450),Vector2(2200,450),Vector2(2200,800),Vector2(1950,800),Vector2(1950,650),Vector2(1050,650)]),T.ALL],[T.shard(Vector2(1650,150),130,7,76,.2,Vector2(1.8,.6)),T.ALL],[Rect2(170,440,230,120),T.ALL],[Rect2(170,640,230,120),T.ALL]])
 m.structures=[];m.currents=[];m.sirens=[]
 # Recovery breakwater screens the cache's working basin from the eastern watch.
 var breakwater=Rect2(2550,1510,140,300)
 m.rocks.append(breakwater)
 for band in [0,2]:m.depth_geometry[band].rocks.append(breakwater)
 #115 AI-DESIGNED: narrow MIDDLE exhaust strip separates the work lip from its watches.
 #Keep the original .4 transmission and90m close bypass; only placement changes.
 m.thermal_revision=1;m.thermal_band=1;m.thermal_fronts=[{"area":Rect2(250,730,2100,40),"transmission":.4,"close_range":90.}]
 #115 revision: the existing MIDDLE watch covers the recovery approach;
 #the DEEP watch still answers exposures across the western exhaust strip.
 _patrol(m,[Vector2(2720,1595),Vector2(2800,1595),Vector2(2800,1675),Vector2(2720,1675)])
 _patrol(m,[Vector2(340,880),Vector2(340,960),Vector2(260,960),Vector2(260,880)])
 m.sirens[1].band=2
static func _patrol(m:Dictionary,points:Array)->void:
 var guard=preload("res://src/campaign/encounters/roster.gd").guard("patroller",points[0],1,points,{"patrol":m.sirens.size()})
 # These layouts inherit their band at simulation launch, as before.
 guard.erase("band");m.sirens.append(guard)
