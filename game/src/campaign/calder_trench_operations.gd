extends RefCounted
# Arc 6, Calder Trench: a deep test well that is still flowing and must be shut in
# by hand. Core 30-33 and optional 34-39. Layouts reuse the shared encounter helpers
# and the Reach work simulation (receiver records and local machinery objectives).
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
const W=preload("res://src/campaign/encounters/work_sites.gd")
const TITLES={30:"Shut-In Stack",31:"Casing Descent",32:"Silent Drift",33:"Closure Split",34:"Sorley's Trawler",35:"Flare Line",36:"Drillers' Camp",37:"Silt Slump",38:"Casing Graveyard",39:"Pressure Door"}
const ACCOUNTS={
 30:"Calder crew / Shut the well in by hand. Three manifold valves open in order: yard, gallery, wellhead. Each valve is loud when it finishes. Then take the wellhead record home.",
 31:"Calder crew / The casing runs down through three bulkheads. Cross each in the band it leaves open: deep, then shallow, then deep again. Take the record at the top.",
 32:"Calder crew / A long channel carries the flow north. Listening buoys line it. Drift quietly, take the record mid channel and leave by either end.",
 33:"Calder crew / Two sites, one flow: the main well in the west and the relief well in the east. Shut in both valves and take the relief record. Cross the ridge by the watched gap or under it.",
 34:"Sorley / One trawler, one survivor, and no threat in these waters. Find the wreck, take its record and go home.",
 35:"Calder crew / The flare line burns and shouts. Close its valve to quiet the line, then take the record at the far stack.",
 36:"Calder crew / The guard detail's camp sits inside a ring of casing. Find the entrance and take the camp record.",
 37:"Calder crew / A silt slump has buried the old road. Only the shallow crest is open past the pit. Take the record beyond it.",
 38:"Calder crew / Dead casing stands in rows. A warden walks them. Take the record at the center.",
 39:"Calder crew / A pressure door seals the survey chamber. Open it from outside, take the record, then leave."}
const CORE=[30,31,32,33]
static func supports_config(c:Dictionary)->bool:return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in TITLES
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func corridor(pos:Vector2,name:String,route:String="deep")->Dictionary:return {"pos":pos,"name":name,"route":route}
# A horizontal wall across x0..x1 at y, for the listed bands.
static func hwall(y:float,x0:float,x1:float,bands:Array,seed:int,width:float=150.)->Array:
 return [T.ridge([Vector2(x0,y),Vector2((x0+x1)*.5,y+12),Vector2(x1,y-8)],width,seed),bands]
static func vwall(x:float,y0:float,y1:float,bands:Array,seed:int,width:float=150.)->Array:
 return [T.ridge([Vector2(x,y0),Vector2(x+10,(y0+y1)*.5),Vector2(x-8,y1)],width,seed),bands]
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id=c.source_id;var key="calder_record_"+str(id)
 var m={"id":id,"title":TITLES[id],"depth":4800,"darkness":false,"region_revision":1,"rocks":[],"structures":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[key],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":760.,"drone_seconds":480.},"record":ACCOUNTS[id]}
 m.glass_reach={"work_pos":Vector2.ZERO,"job":{},"choice":"","gate_open":false,"artifact":{},"retrieved":false}
 match id:
  30:_stack(m,key)
  31:_descent(m,key)
  32:_drift(m,key)
  33:_split(m,key)
  34:_trawler(m,key)
  35:_flare(m,key)
  36:_camp(m,key)
  37:_slump(m,key)
  38:_graveyard(m,key)
  39:_door(m,key)
 m.extraction=m.corridors[0].pos
 m.glass_reach.work_pos=m.objectives[0].pos
 m.brief=ACCOUNTS[id]+"\nTap an objective, then CAMERA within 240m in settled MIDDLE. Valves are loud while worked and again when they finish. Quiet, cover, depth and timing break a watcher's chain. Return to a named recovery mouth."
 return m

static func _valve(key:String,name:String,pos:Vector2,effect:Dictionary)->Dictionary:return W.machine(key,name,pos,effect,false)

# 30 / Yard, gallery and wellhead in strict order. Valve A opens the gallery door,
# valve B opens the wellhead ring, valve C closes the well. Every finish is loud.
static func _stack(m,key):
 m.world_size=Vector2(3000,2600);m.start=Vector2(300,2350)
 var c=Vector2(900,800)
 T.apply(m,[
  [T.ridge([Vector2(-40,1750),Vector2(700,1760),Vector2(1500,1740),Vector2(2300,1750)],140,1),T.ALL],
  [T.ridge([Vector2(2700,1750),Vector2(3040,1760)],140,2),T.ALL],
  [T.arc(c,330,470,.6,TAU-.6,10),T.ALL],
  [T.shard(Vector2(2000,1300),130,7,3),T.ALL],[T.shard(Vector2(1550,1500),110,6,4),T.ALL],[T.shard(Vector2(2550,650),140,7,5),T.ALL],
  [T.shard(Vector2(1800,450),120,7,6),[1,2]],[T.shard(Vector2(1000,2200),120,7,7),T.ALL],[T.shard(Vector2(2500,2250),150,7,8),T.ALL],[T.shard(Vector2(500,1300),100,6,9),T.ALL]])
 var door_a=Rect2(2290,1670,420,160);var door_b=Rect2(1170,530,230,540)
 m.structures=[door_a,door_b]
 m.objectives=[W.listen(key,"WELLHEAD / RECEIVED ACCOUNT",Vector2(900,560),ACCOUNTS[30],5.),
  _valve("calder_30_a","YARD VALVE A",Vector2(1900,2150),{"open":[door_a],"noise":{"radius":1100.,"label":"MANIFOLD VALVE","duration":6.}}),
  _valve("calder_30_b","GALLERY VALVE B",Vector2(2450,1050),{"open":[door_b],"calm":.5,"noise":{"radius":1300.,"label":"MANIFOLD VALVE","duration":6.}}),
  _valve("calder_30_c","WELLHEAD VALVE C",Vector2(820,860),{"calm":.2,"noise":{"radius":1600.,"label":"WELLHEAD SHUT-IN","duration":8.}})]
 m.currents=[{"center":Vector2(1500,1100),"radius":750.,"velocity":Vector2(0,-20)},{"center":Vector2(1900,700),"radius":600.,"velocity":Vector2(-16,0)}]
 m.corridors=[corridor(Vector2(300,2350),"SOUTH YARD RECOVERY")]
 R.add(m,[R.post(Vector2(1300,1950),1,160.),R.post(Vector2(1900,550),1,170.),R.post(Vector2(2900,1500),1,170.),
  R.guard("buoy",Vector2(1650,1200)),R.guard("warden",Vector2(400,1100))])

# 31 / Three bulkheads, each open in only one band: B1 DEEP, B2 SHALLOW, B3 DEEP
# (or a watched MIDDLE gap). Cold water in the second chamber hides sound.
static func _descent(m,key):
 m.world_size=Vector2(2400,3400);m.start=Vector2(1200,3150)
 T.apply(m,[
  hwall(2500,-40,2440,[0,1],1),hwall(1800,-40,2440,[1,2],2),
  hwall(1100,-40,1900,[0,1],3),hwall(1100,2250,2440,[0,1],4),
  [T.shard(Vector2(500,2950),130,7,5),T.ALL],[T.shard(Vector2(1900,2900),120,7,6),T.ALL],
  [T.shard(Vector2(700,2150),120,7,7),[1,2]],[T.shard(Vector2(1800,2100),130,7,8),T.ALL],
  [T.shard(Vector2(900,1450),130,7,9),T.ALL],[T.shard(Vector2(1900,1400),110,6,10),[0,1]],
  [T.shard(Vector2(500,600),140,7,11),T.ALL],[T.shard(Vector2(1800,500),130,7,12),T.ALL],[T.shard(Vector2(1200,300),90,6,13),[1,2]]])
 m.objectives=[W.listen(key,"CASING HEAD / RECEIVED ACCOUNT",Vector2(1200,650),ACCOUNTS[31],5.)]
 m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(500,1900,1300,500),"transmission":.5,"close_range":90.}]
 m.corridors=[corridor(Vector2(1200,3150),"SOUTH CASING RECOVERY"),corridor(Vector2(300,200),"NORTH CASING RECOVERY","shelf")]
 R.add(m,[R.guard("hunter",Vector2(700,2250),1,[Vector2(700,2250),Vector2(1700,2250),Vector2(1700,2400)]),
  R.guard("sweeper",Vector2(2100,1500),2),R.guard("warden",Vector2(2075,1200)),R.guard("buoy",Vector2(1900,700)),R.guard("relay",Vector2(1900,350))])

# 32 / A long channel. The flow carries Quietus north; buoys sit in side alcoves and
# report engines. Drifting and holding still is quieter than steering.
static func _drift(m,key):
 m.world_size=Vector2(1800,5200);m.start=Vector2(900,4950)
 var left=[Vector2(-40,300),Vector2(520,300),Vector2(440,1200),Vector2(520,2200),Vector2(430,3200),Vector2(520,4200),Vector2(480,4800),Vector2(-40,4800)]
 var right=[Vector2(1840,300),Vector2(1280,300),Vector2(1360,1200),Vector2(1280,2200),Vector2(1370,3200),Vector2(1280,4200),Vector2(1320,4800),Vector2(1840,4800)]
 T.apply(m,[[T.wall(left),T.ALL],[T.wall(right),T.ALL],
  [T.ridge([Vector2(520,3900),Vector2(700,3890)],110,1),[1]],[T.ridge([Vector2(1280,2900),Vector2(1100,2890)],110,2),[1]],
  [T.ridge([Vector2(520,1900),Vector2(700,1880)],110,3),[1]],[T.shard(Vector2(900,4300),90,6,4),T.ALL],[T.shard(Vector2(950,3400),100,6,5),[0,1]],
  [T.shard(Vector2(850,2400),90,6,6),[1,2]],[T.shard(Vector2(950,1000),100,6,7),T.ALL],[T.shard(Vector2(900,600),80,6,8),[0,1]]])
 m.objectives=[W.listen(key,"MID CHANNEL / RECEIVED ACCOUNT",Vector2(900,1550),ACCOUNTS[32],5.)]
 m.currents=[]
 for y in [4400,3700,3000,2300,1600,900,300]:m.currents.append({"center":Vector2(900,y),"radius":800.,"velocity":Vector2(0,-26)})
 m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(500,2600,800,900),"transmission":.5,"close_range":90.}]
 m.corridors=[corridor(Vector2(900,4950),"SOUTH CHANNEL RECOVERY"),corridor(Vector2(900,420),"NORTH CHANNEL RECOVERY","shelf")]
 R.add(m,[R.guard("buoy",Vector2(560,3600)),R.guard("buoy",Vector2(1240,2700)),R.guard("buoy",Vector2(560,1700)),R.guard("relay",Vector2(1240,1100)),
  R.guard("patroller",Vector2(900,700),1,[Vector2(900,700),Vector2(900,1100)])])

# 33 / Two sites joined by one ridge. Main-well valve in the west, relief-well valve
# and record in the east. Cross by the watched MIDDLE gap or under the ridge.
static func _split(m,key):
 m.world_size=Vector2(4200,2400);m.start=Vector2(300,2150)
 T.apply(m,[
  vwall(2100,-40,800,T.ALL,1),vwall(2100,1450,2440,[0,1],2),vwall(2100,1450,1650,[2],3),vwall(2100,2150,2440,[2],4),
  [T.shard(Vector2(900,1700),140,7,5),T.ALL],[T.shard(Vector2(1400,700),130,7,6),T.ALL],[T.shard(Vector2(500,600),120,7,7),T.ALL],
  [T.shard(Vector2(3000,1500),140,7,8),T.ALL],[T.shard(Vector2(2800,500),130,7,9),T.ALL],[T.shard(Vector2(3600,1800),130,7,10),T.ALL],[T.shard(Vector2(3300,800),100,6,11),[1,2]]])
 m.objectives=[W.listen(key,"RELIEF WELL / RECEIVED ACCOUNT",Vector2(3600,600),ACCOUNTS[33],5.),
  _valve("calder_33_w","MAIN WELL VALVE",Vector2(700,1200),{"calm":.3,"noise":{"radius":1400.,"label":"MAIN WELL SHUT-IN","duration":8.}}),
  _valve("calder_33_e","RELIEF WELL VALVE",Vector2(3500,1250),{"calm":.3,"noise":{"radius":1400.,"label":"RELIEF WELL SHUT-IN","duration":8.}})]
 m.currents=[{"center":Vector2(700,1200),"radius":600.,"velocity":Vector2(0,-20)},{"center":Vector2(3500,1250),"radius":600.,"velocity":Vector2(0,20)}]
 m.corridors=[corridor(Vector2(300,2150),"WEST WELL RECOVERY"),corridor(Vector2(3900,2150),"EAST WELL RECOVERY","shelf")]
 R.add(m,[R.post(Vector2(1000,500),1,160.),R.guard("warden",Vector2(2100,1050)),R.guard("sweeper",Vector2(2000,1900),2),R.guard("relay",Vector2(2500,900)),
  R.guard("patroller",Vector2(2600,300),1,[Vector2(2600,300),Vector2(3000,300),Vector2(3000,520)]),R.guard("buoy",Vector2(3100,1750))])

# 34 / Optional. One survivor's trawler in a quiet pocket. No Siren is present.
static func _trawler(m,key):
 m.world_size=Vector2(2200,2000);m.start=Vector2(300,1750)
 T.apply(m,[hwall(1300,-40,1500,T.ALL,1),vwall(1500,700,1300,T.ALL,2),hwall(700,1500,2240,[0,1],3),
  [T.shard(Vector2(800,900),130,7,4),T.ALL],[T.shard(Vector2(1800,1500),120,7,5),T.ALL],[T.shard(Vector2(500,400),110,6,6),T.ALL]])
 m.objectives=[W.listen(key,"TRAWLER / RECEIVED ACCOUNT",Vector2(1800,400),ACCOUNTS[34],6.)]
 m.corridors=[corridor(Vector2(300,1750),"SOUTH POCKET RECOVERY")]

# 35 / Optional. A burning flare line draws attention; its valve quiets the line.
static func _flare(m,key):
 m.world_size=Vector2(3000,2000);m.start=Vector2(300,1750)
 var v=Rect2(1450,820,120,360)
 T.apply(m,[vwall(1500,-40,820,T.ALL,1),vwall(1500,1180,2040,T.ALL,2),
  [T.shard(Vector2(800,1000),130,7,3),T.ALL],[T.shard(Vector2(2300,1500),130,7,4),T.ALL],[T.shard(Vector2(2300,500),120,7,5),T.ALL]])
 m.structures=[v]
 m.objectives=[W.listen(key,"FAR STACK / RECEIVED ACCOUNT",Vector2(2550,1000),ACCOUNTS[35],5.),
  _valve("calder_35_v","FLARE LINE VALVE",Vector2(900,1400),{"open":[v],"quiet":1400.,"quiet_time":120.,"noise":{"radius":900.,"label":"FLARE VALVE","duration":6.}})]
 m.corridors=[corridor(Vector2(300,1750),"WEST FLARE RECOVERY")]
 R.add(m,[R.guard("buoy",Vector2(1000,800)),R.guard("relay",Vector2(700,500)),R.post(Vector2(2000,800),1,170.),R.guard("buoy",Vector2(2200,1300))])

# 36 / Optional. The guard detail's camp: a casing ring whose only MIDDLE entrance is
# watched, with a DEEP slip under the ring.
static func _camp(m,key):
 m.world_size=Vector2(2600,2400);m.start=Vector2(300,2150);var c=Vector2(1500,1000)
 T.apply(m,[[T.arc(c,300,430,2.9,5.0,8),T.ALL],[T.arc(c,300,430,5.0,5.6,3),[0,1]],[T.arc(c,300,430,5.6,TAU+2.0,8),T.ALL],
  [T.shard(Vector2(700,1500),130,7,1),T.ALL],[T.shard(Vector2(2100,1800),140,7,2),T.ALL],[T.shard(Vector2(600,500),120,7,3),T.ALL],[T.shard(Vector2(2200,500),120,7,4),T.ALL]])
 m.objectives=[W.listen(key,"CAMP / RECEIVED ACCOUNT",Vector2(1500,1000),ACCOUNTS[36],5.)]
 m.corridors=[corridor(Vector2(300,2150),"SOUTH CAMP RECOVERY")]
 R.add(m,[R.guard("interceptor",Vector2(2100,1000)),R.guard("interceptor",Vector2(1900,1500)),R.post(Vector2(700,600),1,170.),R.guard("warden",Vector2(1500,1750))])

# 37 / Optional. A silt pit across the road: MIDDLE and DEEP are choked, SHALLOW is open.
static func _slump(m,key):
 m.world_size=Vector2(2600,2600);m.start=Vector2(300,2350)
 T.apply(m,[hwall(1400,-40,2640,[1,2],1,170.),
  [T.shard(Vector2(800,1900),130,7,2),T.ALL],[T.shard(Vector2(1800,2000),140,7,3),T.ALL],[T.shard(Vector2(700,800),130,7,4),T.ALL],[T.shard(Vector2(1900,700),130,7,5),[0,1]]])
 m.objectives=[W.listen(key,"BURIED ROAD / RECEIVED ACCOUNT",Vector2(1300,550),ACCOUNTS[37],5.)]
 m.corridors=[corridor(Vector2(300,2350),"SOUTH ROAD RECOVERY")]
 R.add(m,[R.guard("hunter",Vector2(1300,1950),1,[Vector2(1300,1950),Vector2(2100,2300),Vector2(600,2200)]),R.guard("buoy",Vector2(1300,1250),0),R.guard("sentinel",Vector2(2000,800))])

# 38 / Optional. Rows of dead casing with a walking warden.
static func _graveyard(m,key):
 m.world_size=Vector2(2600,2600);m.start=Vector2(1300,2400);var entries=[];var n=0
 for row in 5:
  for col in 6:
   var p=Vector2(350+col*390+(190 if row%2 else 0),600+row*380)
   if p.distance_to(Vector2(1300,1250))<300 or p.x>2400:continue
   n+=1;entries.append([T.shard(p,70+(n*29)%30,4+n%3,n,.2),T.ALL if n%3 else [1,2]])
 T.apply(m,entries)
 m.objectives=[W.listen(key,"CASING ROWS / RECEIVED ACCOUNT",Vector2(1300,1250),ACCOUNTS[38],5.)]
 m.corridors=[corridor(Vector2(1300,2400),"SOUTH CASING ROW RECOVERY")]
 R.add(m,[R.guard("warden",Vector2(400,700)),R.guard("patroller",Vector2(450,1200),1,[Vector2(450,1200),Vector2(450,1900),Vector2(700,1900)]),R.guard("buoy",Vector2(1900,900))])

# 39 / Optional. A sealed survey chamber: open the door from outside.
static func _door(m,key):
 m.world_size=Vector2(2800,2400);m.start=Vector2(300,2150);var c=Vector2(2000,900)
 var door=Rect2(1530,640,160,520)
 T.apply(m,[[T.arc(c,380,520,-PI+.5,PI-.5,10),T.ALL],[T.shard(Vector2(900,1500),140,7,1),T.ALL],[T.shard(Vector2(1400,2000),120,7,2),T.ALL],[T.shard(Vector2(900,500),120,7,3),T.ALL],[T.shard(Vector2(2500,2000),130,7,4),T.ALL]])
 m.structures=[door]
 m.objectives=[W.listen(key,"SURVEY CHAMBER / RECEIVED ACCOUNT",Vector2(2000,900),ACCOUNTS[39],5.),
  _valve("calder_39_d","PRESSURE DOOR",Vector2(1400,1100),{"open":[door],"noise":{"radius":1200.,"label":"PRESSURE DOOR","duration":6.}})]
 m.corridors=[corridor(Vector2(300,2150),"WEST SURVEY RECOVERY")]
 R.add(m,[R.guard("relay",Vector2(1000,700)),R.guard("sweeper",Vector2(1900,1500),2),R.post(Vector2(600,1300),1,170.),R.guard("buoy",Vector2(2300,2000))])
