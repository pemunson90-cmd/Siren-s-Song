extends RefCounted
# Authored encounters use the same geometry/actor vocabulary. Runtime systems do
# not branch on operation identity; more content adds a profile and catalog entry.
const Base=preload("res://src/campaign/tutorial_missions.gd")
const Patrols=preload("res://src/campaign/sweeper_patrols.gd")
const PROFILES={
 "split_crossing":{
  "source":1,
  "bands":{
   0:{"remove":[3,5],"add":[Rect2(980,1550,300,160)]},
   2:{"remove":[1],"add":[Rect2(1320,650,180,300)]}
  },
  "threats":{1:{"band":2}},
  "hint":"Southern shelf: DEEP crossing · northern saddle: SHALLOW · LINK in MIDDLE.",
  "brief":"Split two receivers across the branching trench. Photograph WEST and EAST, then Quietus must LINK six seconds at the UPLINK and return. DEEP opens the southern shelf crossing; SHALLOW opens the northern saddle but closes the uplink mouth. The eastern patrol works DEEP. Separate drones can earn independent bearings while Quietus stages. Use craft → DEPTH / SONAR for soundings and layers; local work needs MIDDLE."
 },
 "blackwater_custody":{
  "source":2,
  "bands":{0:{"remove":[1],"add":[Rect2(650,650,360,120)]},2:{"remove":[0],"add":[]}},
  "threats":{0:{"pos":Vector2(700,350),"home":Vector2(700,350),"goal":Vector2(700,350),"type":"sentinel","tether":190.0,"patrol_points":[Vector2(760,350),Vector2(760,180),Vector2(1120,180),Vector2(1120,520),Vector2(760,720)]},1:{"band":0}},
  "sweepers":[{"pos":Vector2(1120,570),"band":2}],
  "hint":"Buffers stay on craft · SAMPLE in MIDDLE · TRANSFER at same depth within 60m.",
  "brief":"SAMPLE REQUEST and REPLY, then bring both raw buffers aboard Quietus and return. DEEP opens the western underpass; SHALLOW opens the northern reply approach but blocks the southern glider lane. A shallow patrol and deep sweeper guard different waters. SAMPLE in MIDDLE; meet in the same settled band within 60m to TRANSFER drone buffers. Quietus can sample directly. Craft → DEPTH / SONAR shows received bearings, not promised positions."
 },
 "foundry_layers":{
  "source":3,
  "bands":{0:{"remove":[3],"add":[Rect2(1020,720,100,120)]},2:{"remove":[2,4],"add":[]}},
  "threats":{1:{"band":2}},
  "hint":"Cold front weakens sound · plant solid at all depths · deep motor gives no cover.",
  "brief":"Photograph FURNACE, then LAUNCH CRADLE; recover Quietus past the southern wall. DEEP passes beneath the central spine, but the plant stays solid. The furnace sentinel holds MIDDLE; the recovery sentinel and the plant's deep motor work DEEP. The cold front weakens sound in addition to layer loss. Wait quietly for a crossing, or coordinate a drone sounding while Quietus moves. Use craft → DEPTH / SONAR; image and recover in MIDDLE."
 },
 "well_interpretation":{
  "source":4,
  "bands":{0:{"remove":[0],"add":[Rect2(660,640,380,90),Rect2(760,440,90,90)]},1:{"remove":[],"add":[Rect2(760,440,90,90)]},2:{"remove":[1],"add":[]}},
  "threats":{0:{"band":0,"pos":Vector2(420,180),"home":Vector2(420,180),"goal":Vector2(420,180),"patrol_points":[Vector2(420,180),Vector2(460,200),Vector2(420,260),Vector2(360,200)]},1:{"pos":Vector2(1480,860),"home":Vector2(1480,860),"goal":Vector2(1480,860)}},
  "sweepers":[{"pos":Vector2(1380,820),"band":2}],
  "hint":"Optional comparison: moving Quietus at MIDDLE aperture, then local MIDDLE receiver.",
  "brief":"Recover three perimeter records and return. SHALLOW clears western basalt but closes the southern record; DEEP clears the eastern wall under a sweeper. The fast hunter holds MIDDLE. An unverified archive is valid. Optional comparison: cruise Quietus past PROFILE APERTURE in MIDDLE after PATTERN, then receive near RETURN ARCHIVE in MIDDLE. A deep pass is no engine reference. Craft → DEPTH / SONAR compares received bearing history."
 },
 "song_convergence":{
  "source":5,
  "bands":{0:{"remove":[2],"add":[Rect2(1030,120,90,80),Rect2(1260,600,140,100)]},1:{"remove":[],"add":[Rect2(1030,120,90,80)]},2:{"remove":[1],"add":[Rect2(760,700,240,190)]}},
  "threats":{0:{"pos":Vector2(970,300),"home":Vector2(970,300),"goal":Vector2(970,300),"patrol_points":[Vector2(970,300),Vector2(1080,400),Vector2(920,560),Vector2(900,300)]},1:{"band":0},2:{"band":2}},
  "sweepers":[{"pos":Vector2(1100,700),"band":2}],
  "hint":"Two images → Quietus LISTEN 6s in MIDDLE lee → physical return with the packet.",
  "brief":"Photograph TRANSMITTER CROWN and OUTBOUND WAKES; Quietus must LISTEN six seconds at LEE RECEIVER, then return with the packet. DEEP opens the central crossing but closes the southern lee; SHALLOW opens the eastern approach. Different patrols and a deep sweeper cover different layers. MIDDLE retains the covered lee route. Break sight to interrupt local reports; reports carry an old area and observed depth. Coordinate drones or take observations alone. Work and recover in MIDDLE."
 }
}
static func supports_config(config:Dictionary)->bool:
 return config.size()==3 and config.get("history")==false and config.get("encounter") in PROFILES and config.get("source_id")==PROFILES[config.encounter].source
static func supports_identity(id:int,config:Dictionary)->bool:
 return Base.supports_identity(id,config)
static func build(config:Dictionary,_history:Dictionary={})->Dictionary:
 if not supports_config(config):return {}
 var m=Base.make(config.source_id);var profile=PROFILES[config.encounter]
 var geometry={}
 for band in profile.bands:
  var recipe=profile.bands[band];var rocks=[]
  for index in m.rocks.size():
   if index not in recipe.get("remove",[]):rocks.append(m.rocks[index])
  rocks.append_array(recipe.get("add",[]));geometry[band]={"rocks":rocks}
 m["depth_geometry"]=geometry
 for index in profile.get("threats",{}):m.sirens[index].merge(profile.threats[index],true)
 var sweeper_index=0
 for descriptor in profile.get("sweepers",[]):
  var enemy=m.sirens[0].duplicate(true)
  enemy.merge({"pos":descriptor.pos,"home":descriptor.pos,"goal":descriptor.pos,"route":[],"type":"sweeper","patrol_points":Patrols.circuit(config.source_id,sweeper_index),"band":descriptor.band},true)
  m.sirens.append(enemy);sweeper_index+=1
 m.brief=profile.brief;m["depth_hint"]=profile.hint
 if config.source_id==2:m.brief+=" A quiet drone can sample the northern REQUEST from farther off the watched lip; meet Quietus in the southern water to transfer. A recovered local transfer earns a service premium on the first return."
 return m
