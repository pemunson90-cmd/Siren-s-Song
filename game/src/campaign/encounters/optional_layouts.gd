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
 # Local landmark metadata is reserved for root's shared landmark reconciliation.
 m.landmarks=[{"id":"thread_split_tooth","pos":Vector2(1050,2390),"kind":"ribs"},{"id":"thread_low_roof","pos":Vector2(1250,1450),"kind":"ridge"},{"id":"thread_mooring_ribs","pos":Vector2(660,650),"kind":"berth"}]
static func shelf(m:Dictionary)->void:
 m.world_size=Vector2(3000,1920);m.start=Vector2(350,1520)
 T.apply(m,[[T.ridge([Vector2(850,950),Vector2(1050,1150),Vector2(1150,1500),Vector2(1150,1900)],170,75),T.ALL],[T.wall([Vector2(1050,450),Vector2(2200,450),Vector2(2200,800),Vector2(1950,800),Vector2(1950,650),Vector2(1050,650)]),T.ALL],[T.shard(Vector2(1650,150),130,7,76,.2,Vector2(1.8,.6)),T.ALL],[Rect2(170,440,230,120),T.ALL],[Rect2(170,640,230,120),T.ALL]])
 m.structures=[];m.currents=[];m.sirens=[]
 m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(850,660,1500,280),"transmission":.4,"close_range":90.}]
 _patrol(m,[Vector2(1250,1040),Vector2(1800,1040),Vector2(2400,1100),Vector2(2000,1350)])
 _patrol(m,[Vector2(2350,300),Vector2(2750,300),Vector2(2750,750),Vector2(2400,750)])
 m.landmarks=[{"id":"shelf_exhaust_comb","pos":Vector2(285,600),"kind":"works"},{"id":"shelf_hooked_terrace","pos":Vector2(2000,550),"kind":"ridge"},{"id":"shelf_numbered_spur","pos":Vector2(1650,150),"kind":"scour"}]
static func _patrol(m:Dictionary,points:Array)->void:
 var pos:Vector2=points[0]
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.,"mode":"PATROL","suspicion":0.,"stun":0.,"lock":0.,"target":-1,"patrol":m.sirens.size(),"path_time":0.,"type":"patroller","patrol_points":points,"patrol_index":0})
