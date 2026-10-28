extends RefCounted
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
const W=preload("res://src/campaign/encounters/work_sites.gd")
const Patrols=preload("res://src/campaign/sweeper_patrols.gd")
const TITLES={14:"Glass Fence",15:"Needle Strait",16:"Furnace Drift",17:"Silt Archive",18:"Lantern Lock",19:"Last Boat Out",20:"Prism Grave",21:"Range Locker"}
const ACCOUNTS={
 14:"Dr. Tomas Vey / These floats are the Varne range's hydrophone fence. They listen to engines, not loyalties. Their lamps rise before a report. Deep water under the western teeth gives a slow quiet passage; the central opening is shorter and watched.",
 15:"Vey / The shallow strain vanes hold the listening fence taut. Release one locally and the western strait falls quiet. Deep water bypasses the vane wall but reaches the eastern repeater. A disabled listener cannot finish its charged report.",
 16:"Vey / This thermal atlas belongs to the range's cooling plant. The crossflow carries hot exhaust and sound around the central piers. Take the measured atlas home; its material spectrum may explain the prisms in the western wreck field.",
 17:"Vey / The archive spindle is the range's physical record. Its reception note is not the spindle itself. Winch it to a living craft and bring that carrier to recovery; losing the carrier leaves the same spindle in that water.",
 18:"Vey / The sealed habitat's lock needs its service bus. Restore the sheltered passage and the survivors can use the short water, but the listening relay stays supplied. Sever the reporting spur and the fence loses the channel; they take the longer outside passage. Quietus must carry the selected station account home.",
 19:"Vey / The last boat's local register is received. It names one boat out, not every vessel beyond the Reach. Cross the listening chain, hear the northern register, and choose either physical recovery mouth.",
 20:"Vey / A cracked directional prism remains in the grave. A photograph identifies it; only the recovered crystal supplies the material. The furnace atlas lets us cut one Quietus fitting: greater directional reach at higher pulse cost and a shared hardware slot.",
 21:"Vey / The range's service wafer is still in its sealed locker. Recover that material with the silt ledger and we can cut a local decoder. It opens a measured service gate quietly from nearby; it is no remote authority over the network."}
static func supports_config(c:Dictionary)->bool:return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in TITLES
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func corridor(pos:Vector2,name:String,route:String="deep")->Dictionary:return {"pos":pos,"name":name,"route":route}
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id=c.source_id;var key="glass_record_"+str(id)
 var m={"id":id,"title":TITLES[id],"depth":4100,"darkness":false,"region_revision":1,"rocks":[],"structures":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[key],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":720.,"drone_seconds":480.},"record":ACCOUNTS[id]}
 m.glass_reach={"work_pos":Vector2.ZERO,"job":{},"choice":"","gate_open":false,"artifact":{},"retrieved":false}
 var prior=history.get("facts",{}).get("glass_choice","")
 match id:
  14:_fence(m,key)
  15:_strait(m,key)
  16:_drift(m,key)
  17:_archive(m,key)
  18:_anchorage(m,key)
  19:_carrier(m,key,prior)
  20:_grave(m,key)
  21:_cache(m,key)
 m.extraction=m.corridors[0].pos
 if m.glass_reach.work_pos==Vector2.ZERO:m.glass_reach.work_pos=m.objectives[0].pos
 if id==19:m.record+=" The recovered Lantern Lock account left the service water open." if prior=="service" else " Lantern Lock's reporting spur was severed; the outer return remains available." if prior=="sever" else " No recovered anchorage choice is assumed."
 m.brief=ACCOUNTS[id]+"\nKeep Quietus and its account together. Local records and machinery work in settled MIDDLE. The bare outside water avoids the central network; other bands open shorter inner crossings. Buoys hear real engines and emissions; relays forward stale uncertain reports after a charge. Quiet, masking, terrain, depth, relocation or physical disruption can break that chain. Return to a named recovery mouth."
 if id in [15,18,19]:m.brief+=" Tap a craft → REACH WORK for local machinery. Manual work takes8 audible seconds; a recovered fitted decoder can open the18/19 service gate quietly."
 if id in [17,20,21]:m.brief+=" Tap the marked material → RECOVER, or craft → REACH WORK. Winch4s within60m; carriers must recover in MIDDLE within65m of the chosen mouth, or transfer locally to Quietus. A lost carrier leaves its physical cargo at the lost position."
 if id==18:m.brief+=" REACH WORK offers RESTORE SERVICE or SEVER SPUR. First recovery commits the real consequence in Last Boat Out."
 var resolution=history.get("facts",{}).get("resolution","")
 if not resolution.is_empty():m.brief+=" Previous received outcome: "+{"concealed_recovery":"Kestrel's survivors were carried out by craft.","overt_warning":"Brannock's launch reached the northeast pickup."}.get(resolution,"the earlier local account remains in the archive.")
 # New range water uses Confluence's measured chart. Revert by removing this block.
 if id in [14,15,16,20]:
  m["earned_terrain"]=true
  m["launch_seed"]=Rect2(m.start-Vector2(160,200),Vector2(480,480)).intersection(Rect2(Vector2.ONE*40,m.world_size-Vector2.ONE*80))
  m.brief+="\nUNCHARTED: the chart fills in as your sensors find rock."
 return m

# 14 / A wide basin cut by one glass fence. MIDDLE: the western teeth are closed,
# the central opening is open but buoy-watched. DEEP: a gap under the teeth.
# SHALLOW: a crest gap at the east end, patrolled by a shallow hunter.
static func _fence(m,key):
 m.world_size=Vector2(3600,2000);m.start=Vector2(300,1750)
 T.apply(m,[
  [T.ridge([Vector2(-40,990),Vector2(400,1030),Vector2(800,970),Vector2(1200,1020),Vector2(1380,1000)],150,1),[0,1]],
  [T.shard(Vector2(560,1000),140,7,2),[0,1]],[T.shard(Vector2(1050,990),150,7,3),[0,1]],
  [T.ridge([Vector2(-40,1000),Vector2(350,980),Vector2(700,1010)],140,4),[2]],[T.shard(Vector2(1330,1000),120,7,5),[2]],
  [T.shard(Vector2(1420,1000),95,6,6),T.ALL],
  [T.ridge([Vector2(1900,1000),Vector2(2250,960),Vector2(2650,1010)],230,7),T.ALL],
  [T.ridge([Vector2(2650,1000),Vector2(2980,980)],170,8),T.ALL],
  [T.ridge([Vector2(2980,990),Vector2(3220,1000)],170,9),[1,2]],
  [T.ridge([Vector2(3220,1000),Vector2(3640,980)],170,10),T.ALL],
  [T.shard(Vector2(1000,670),60,7,11),T.ALL],[T.shard(Vector2(620,260),110,6,12),T.ALL],
  [T.shard(Vector2(2300,1560),140,8,13),T.ALL],[T.shard(Vector2(1000,1560),100,6,14),T.ALL],[T.shard(Vector2(2900,420),130,7,15),[1,2]]])
 m.objectives=[W.listen(key,TITLES[14].to_upper()+" / RECEIVED ACCOUNT",Vector2(950,420),ACCOUNTS[14])]
 m.corridors=[corridor(Vector2(3300,1760),"EAST REACH RECOVERY")]
 # Order matters to the network fixtures: investigator, buoy, relay first.
 R.add(m,[R.post(Vector2(1640,800),1,180.),R.guard("buoy",Vector2(1700,1000)),R.guard("relay",Vector2(2250,640)),
  R.guard("patroller",Vector2(1070,760),1,[Vector2(1070,760),Vector2(1500,760),Vector2(1500,600),Vector2(1070,600)]),
  R.guard("hunter",Vector2(3100,700),0,[Vector2(3100,700),Vector2(2750,560)])])

# 15 / A tall needle strait. Releasing the west vane silences every buoy for a
# limited time; DEEP bypasses the vane wall through an eastern channel with its
# own repeater and hunter. SHALLOW is barred by a sill at the needle.
static func _strait(m,key):
 m.world_size=Vector2(2000,3600);m.start=Vector2(1000,3350)
 var east_face=[Vector2(1440,900),Vector2(1300,1150),Vector2(1220,1450),Vector2(1170,1800),Vector2(1220,2150),Vector2(1300,2500),Vector2(1380,2750)]
 var deep_inner=east_face.duplicate();for n in range(east_face.size()-1,-1,-1):deep_inner.append(east_face[n]+Vector2(220,0))
 T.apply(m,[
  [T.wall([Vector2(0,900),Vector2(980,900),Vector2(700,1150),Vector2(780,1450),Vector2(830,1800),Vector2(780,2150),Vector2(700,2500),Vector2(620,2750),Vector2(0,2750)]),T.ALL],
  [T.wall([Vector2(2000,900)]+east_face+[Vector2(2000,2750)]),[0,1]],
  [T.wall(deep_inner),[2]],
  [T.wall([Vector2(2000,900),Vector2(1830,900),Vector2(1760,1250),Vector2(1720,1800),Vector2(1760,2350),Vector2(1820,2750),Vector2(2000,2750)]),[2]],
  [T.ridge([Vector2(780,1800),Vector2(1000,1790),Vector2(1220,1800)],110,1),[0]],[T.ridge([Vector2(740,2160),Vector2(1000,2170),Vector2(1260,2160)],120,6),[2]],
  [T.shard(Vector2(1500,3080),130,7,2),T.ALL],[T.shard(Vector2(620,3020),110,6,3),T.ALL],
  [T.shard(Vector2(1060,500),140,7,4),T.ALL],[T.shard(Vector2(1240,770),70,7,5),[0]]])
 m.objectives=[W.listen(key,TITLES[15].to_upper()+" / RECEIVED ACCOUNT",Vector2(1000,300),ACCOUNTS[15])]
 m.glass_reach.work_pos=Vector2(800,2380)
 m.corridors=[corridor(Vector2(300,3350),"SOUTH REACH RECOVERY")]
 R.add(m,R.listening_line([Vector2(1000,2250),Vector2(1000,1800),Vector2(1000,1350)],Vector2(1000,820)))
 R.add(m,[R.guard("relay",Vector2(1080,2860)),R.post(Vector2(1450,640),1,170.),
  R.guard("patroller",Vector2(1250,850),1,[Vector2(1250,850),Vector2(1250,600)]),
  R.guard("relay",Vector2(1650,1150),2),R.guard("hunter",Vector2(1610,2300),2,[Vector2(1610,2300),Vector2(1590,1500)])])

# 16 / A clockwise exhaust gyre around six piers and a walled cooling plant.
# MIDDLE enters the plant only through a sluice that the west intake valve
# opens (and weakens the gyre); DEEP slips under the plant's southern wall.
static func _drift(m,key):
 m.world_size=Vector2(2800,2800);m.start=Vector2(300,2500)
 var c=Vector2(1400,1400);var entries=[]
 for n in 6:entries.append([T.shard(Vector2(1480,2070) if n==1 else c+Vector2.from_angle(TAU*n/6)*640,60 if n==1 else 130,7,n),T.ALL])
 entries.append_array([[T.arc(c,250,330,.42,1.32,4),T.ALL],[T.arc(c,250,330,1.28,2.02,3),[0,1]],[T.arc(c,250,330,1.98,5.86,13),T.ALL]])
 entries.append([T.shard(c,60,6,9),T.ALL])
 entries.append_array([[T.shard(Vector2(2350,2350),160,7,10),T.ALL],[T.shard(Vector2(500,500),150,7,11),T.ALL],[T.shard(Vector2(2400,500),120,7,12),[1,2]]])
 T.apply(m,entries)
 var sluice=Rect2(1615,1255,125,290);m.structures=[sluice]
 m.objectives=[W.listen(key,TITLES[16].to_upper()+" / RECEIVED ACCOUNT",Vector2(1250,1400),ACCOUNTS[16]),
  W.machine("glass_16_valve","WEST INTAKE VALVE",Vector2(600,1400),{"open":[sluice],"calm":.25,"noise":{"radius":1100.,"label":"REACH MACHINERY","duration":6.}},true)] # TODO-S3
 m.corridors=[corridor(Vector2(300,300),"NORTH REACH RECOVERY")] # TODO-S3
 m.currents=[{"center":Vector2(1400,760),"radius":700.,"velocity":Vector2(24,0)},{"center":Vector2(2040,1400),"radius":700.,"velocity":Vector2(0,24)},{"center":Vector2(1400,2040),"radius":700.,"velocity":Vector2(-24,0)},{"center":Vector2(760,1400),"radius":700.,"velocity":Vector2(0,-24)}]
 m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(1760,1050,600,700),"transmission":.45,"close_range":90.}]
 R.add(m,[R.guard("patroller",Vector2(1250,1530),1,[Vector2(1250,1530),Vector2(1560,1450),Vector2(1500,1270),Vector2(1250,1270)]),
  R.post(Vector2(1900,1150),1,170.),R.guard("buoy",Vector2(520,1100)),R.guard("relay",Vector2(1000,700)),
  R.guard("sweeper",Vector2(1557,2100),2,[Vector2(1557,2100),Vector2(1557,2000)])])

# 17 / Switchback silt terraces. The spindle lies under a silt mound that only
# DEEP reaches; SHALLOW is choked by banks. Two recovery mouths, west and north.
static func _archive(m,key):
 m.world_size=Vector2(3200,2400);m.start=Vector2(3000,2250)
 T.apply(m,[
  [T.ridge([Vector2(-40,620),Vector2(800,580),Vector2(1600,640),Vector2(2280,600)],120,1),T.ALL],
  [T.ridge([Vector2(2660,600),Vector2(3240,630)],120,2),[0,1]],
  [T.ridge([Vector2(720,1100),Vector2(1500,1080)],120,3),T.ALL],[T.ridge([Vector2(1500,1080),Vector2(2100,1110)],120,4),[0,1]],
  [T.ridge([Vector2(2100,1110),Vector2(2800,1080),Vector2(3240,1100)],120,5),T.ALL],
  [T.ridge([Vector2(-40,1600),Vector2(900,1630),Vector2(1800,1580),Vector2(2480,1610)],120,6),T.ALL],
  [T.ridge([Vector2(940,2000),Vector2(2000,1980),Vector2(3240,2010)],120,7),[1,2]],
  [T.ridge([Vector2(-40,2000),Vector2(940,2000)],110,8),[0]],[T.shard(Vector2(2470,600),200,7,9,.1),[0]],[T.shard(Vector2(350,1100),200,7,10,.1),[0]],
  [T.shard(Vector2(2860,1350),120,8,11,.15),[0,1]],[T.shard(Vector2(1300,1350),110,7,12),T.ALL],[T.shard(Vector2(2000,300),110,6,13),T.ALL]])
 m.objectives=[W.listen(key,TITLES[17].to_upper()+" / RECEIVED ACCOUNT",Vector2(2100,380),ACCOUNTS[17])]
 m.glass_reach.artifact=W.cargo("silt_spindle",Vector2(2860,1350),2);m.glass_reach.work_pos=m.glass_reach.artifact.pos
 m.corridors=[corridor(Vector2(240,2180),"WEST REACH RECOVERY"),corridor(Vector2(1600,140),"NORTH REACH RECOVERY","shelf")] # TODO-S3
 R.add(m,[R.guard("buoy",Vector2(2560,1350),2),R.guard("relay",Vector2(2200,1830),2),R.guard("hunter",Vector2(1800,1350),2,[Vector2(1800,1350),Vector2(1800,800),Vector2(1200,850)]),
  R.guard("patroller",Vector2(2580,340),1,[Vector2(2580,340),Vector2(2640,340),Vector2(2640,280),Vector2(2580,280)]),R.guard("warden",Vector2(1250,330))])

# 18 / An anchorage behind a long reef. The service gate is the short sheltered
# return; the east end is the long outside passage under a warden; DEEP has a
# narrow western gap under the reef watched by a sweeper.
static func _anchorage(m,key):
 m.world_size=Vector2(2800,2600);m.start=Vector2(2400,2350)
 T.apply(m,[
  [T.ridge([Vector2(-40,1500),Vector2(500,1480)],150,1),T.ALL],[T.ridge([Vector2(500,1480),Vector2(720,1490)],150,2),[0,1]],
  [T.ridge([Vector2(720,1490),Vector2(1310,1500)],150,3),T.ALL],[T.ridge([Vector2(1490,1500),Vector2(2000,1470),Vector2(2480,1510)],150,4),T.ALL],
  [T.shard(Vector2(880,720),60,5,5),T.ALL],[T.shard(Vector2(1850,650),70,5,6),T.ALL],[T.shard(Vector2(2150,1120),60,5,7),T.ALL],[T.shard(Vector2(680,1150),65,5,8),T.ALL],[T.shard(Vector2(1820,1180),55,5,9),T.ALL],
  [T.shard(Vector2(1000,2050),130,7,10),T.ALL],[T.shard(Vector2(1900,2000),110,7,11),[1,2]]])
 m.glass_reach.gate=Rect2(1300,1430,200,140);m.structures=[m.glass_reach.gate]
 m.glass_reach.work_pos=Vector2(1400,900)
 m.objectives=[W.listen(key,TITLES[18].to_upper()+" / RECEIVED ACCOUNT",Vector2(1400,900),ACCOUNTS[18])]
 m.corridors=[corridor(Vector2(400,2300),"SOUTH REACH RECOVERY")]
 R.add(m,[R.guard("buoy",Vector2(1120,720)),R.guard("buoy",Vector2(1700,820)),R.guard("relay",Vector2(1400,430)),R.post(Vector2(620,900),1,160.),
  R.guard("warden",Vector2(2620,1700)),R.guard("sweeper",Vector2(1560,900),1,[Vector2(1560,900),Vector2(1760,900),Vector2(1760,450),Vector2(1560,450)])])

# 19 / The listening chain: a broken wall with buoy-watched gaps west and east,
# the anchorage service channel in the centre, and a DEEP-only gap watched by a
# sweeper. The register lies north; two recovery mouths lie south.
static func _carrier(m,key,prior):
 m.world_size=Vector2(3200,2800);m.start=Vector2(1600,2550)
 T.apply(m,[
  [T.ridge([Vector2(-40,1400),Vector2(600,1380)],160,1),T.ALL],
  [T.ridge([Vector2(850,1400),Vector2(1100,1410)],160,2),T.ALL],[T.ridge([Vector2(1100,1410),Vector2(1300,1400)],160,3),[0,1]],
  [T.ridge([Vector2(1300,1400),Vector2(1490,1400)],160,4),T.ALL],[T.ridge([Vector2(1710,1400),Vector2(2100,1380),Vector2(2500,1410)],160,5),T.ALL],
  [T.ridge([Vector2(2750,1400),Vector2(3240,1390)],160,6),T.ALL],
  [T.shard(Vector2(1000,700),140,7,7),T.ALL],[T.shard(Vector2(2300,800),150,7,8),T.ALL],[T.shard(Vector2(700,2100),130,7,9),T.ALL],[T.shard(Vector2(2500,2050),140,7,10),T.ALL]])
 m.glass_reach.gate=Rect2(1480,1340,240,120);m.glass_reach.work_pos=Vector2(1600,1250)
 if prior=="service":m.glass_reach.gate_open=true
 else:m.structures=[m.glass_reach.gate]
 m.objectives=[W.listen(key,TITLES[19].to_upper()+" / RECEIVED ACCOUNT",Vector2(1600,500),ACCOUNTS[19],6.)]
 m.corridors=[corridor(Vector2(700,2600),"SOUTH REACH RECOVERY"),corridor(Vector2(3000,2600),"EAST REACH RECOVERY","shelf")]
 R.add(m,[R.guard("buoy",Vector2(725,1400)),R.guard("buoy",Vector2(2625,1400)),R.post(Vector2(2150,450),1,170.),
  R.guard("interceptor",Vector2(800,1000)),R.guard("sweeper",Vector2(1200,1700),2),
  R.guard("patroller",Vector2(1600,1900),1,[Vector2(1600,1900),Vector2(2600,1800),Vector2(1600,1900),Vector2(700,1800)])])
 # The supplied reporting relay is last: a severed spur removes it.
 if prior!="sever":R.add(m,[R.guard("relay",Vector2(1600,950))])

# 20 / A field of prism shards cut into lanes. Stationary interceptors sit at
# lane ends; their committed bursts reach about400m. The prism lies at the grave.
static func _grave(m,key):
 m.world_size=Vector2(2400,3200);m.start=Vector2(1200,240)
 var entries=[];var n=0
 for row in 7:
  for col in 7:
   var p=Vector2(260+col*310+(150 if row%2 else 0),760+row*330)
   if p.distance_to(Vector2(1200,1650))<330 or p.x>2250:continue
   n+=1;entries.append([T.shard(p,62+(n*37)%40,3+n%3,n,.25),[1,2] if n%5==0 else [0,1] if n%7==0 else T.ALL])
 T.apply(m,entries)
 m.glass_reach.artifact=W.cargo("prism_core",Vector2(1200,1650),1);m.glass_reach.work_pos=m.glass_reach.artifact.pos
 m.objectives=[W.listen(key,TITLES[20].to_upper()+" / RECEIVED ACCOUNT",Vector2(1200,1480),ACCOUNTS[20])]
 m.corridors=[corridor(Vector2(1200,3020),"SOUTH REACH RECOVERY"),corridor(Vector2(200,2950),"WEST REACH RECOVERY","shelf")] # TODO-S3
 R.add(m,[R.guard("interceptor",Vector2(1200,1040)),R.guard("interceptor",Vector2(1920,2300)),R.guard("interceptor",Vector2(330,2300)),
  R.guard("warden",Vector2(1200,2250)),R.guard("buoy",Vector2(950,1900)),R.guard("relay",Vector2(1650,2080))])

# 21 / A crater cache. MIDDLE enters by a watched north-east breach or by the
# sealed west door (local machinery, loud); DEEP enters by a south-west tunnel
# under the rim. The wafer rests on the crater floor in DEEP.
static func _cache(m,key):
 m.world_size=Vector2(2800,2800);m.start=Vector2(300,2500)
 var c=Vector2(1600,1200)
 T.apply(m,[
  [T.arc(c,380,520,-.55,2.15,7),T.ALL],[T.arc(c,380,520,2.15,2.95,3),[0,1]],[T.arc(c,380,520,3.3,4.95,6),T.ALL],
  [T.shard(Vector2(700,700),150,7,1),T.ALL],[T.shard(Vector2(2400,2200),160,7,2),T.ALL],[T.shard(Vector2(900,1900),120,7,3),[1,2]],[T.shard(Vector2(2300,500),110,6,4),T.ALL]])
 var door=Rect2(1040,1090,200,230);m.structures=[door]
 m.glass_reach.artifact=W.cargo("keeper_wafer",Vector2(1600,1300),2);m.glass_reach.work_pos=m.glass_reach.artifact.pos
 m.objectives=[W.listen(key,TITLES[21].to_upper()+" / RECEIVED ACCOUNT",Vector2(1600,1060),ACCOUNTS[21]),
  W.machine("glass_21_door","WEST CACHE DOOR",Vector2(980,1120),W.sluice(door),true)] # TODO-S3
 m.corridors=[corridor(Vector2(2500,2560),"SOUTH REACH RECOVERY"),corridor(Vector2(260,260),"NORTH REACH RECOVERY","shelf")] # TODO-S3
 R.add(m,[R.guard("buoy",Vector2(2080,700)),R.post(Vector2(2350,850),1,170.),R.guard("warden",Vector2(700,1150)),
  R.guard("relay",Vector2(1100,1750),2),R.guard("hunter",Vector2(1250,1700),2,[Vector2(1250,1700),Vector2(1500,2100),Vector2(900,2300)])])
