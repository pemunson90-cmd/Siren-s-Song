extends RefCounted
# ARC6 capstone layout for operation 34, "Beneath the Well". Three existing W.machine work
# sites around a ring corridor; each completed machine opens the next gate. The well casing
# is solid in every band, so the order cannot be skipped under it. Stage rosters escalate
# (stage 1 listeners, stage 2 relay and patrol, stage 3 hunter). Two returns exist: the
# loud disconnect opens the west corridor shortcut under the Middle warden, within
# the disconnect investigation radius; the quiet longer retrace leaves that sound field and goes back
# around the east and south corridors. No new simulation rules: machines, cargo-free gates
# and the roster builders are the existing pieces.
# Seam: calder_layouts.layout(34) returns layout(); calder_trench_operations.build reads
# row.works. Revert: ENABLED=false restores the legacy single-machine operation 34 row.
static var ENABLED=true
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
# Data table: one row per stage in play order. effect is the shared machine effect shape.
const STAGES=[
 {"key":"calder_34_stage_1","name":"FEED SLUICE","pos":Vector2(1500,2150),"gate":Rect2(1900,1600,500,100),"noise":900.,"noise_time":8.},
 {"key":"calder_34_stage_2","name":"CASING COUPLING","pos":Vector2(2150,1200),"gate":Rect2(1700,800,100,500),"noise":1100.,"noise_time":9.},
 {"key":"calder_34_disconnect","name":"DRILL FEED DISCONNECT","pos":Vector2(1000,1100),"gate":Rect2(800,1600,500,100),"noise":1350.,"noise_time":10.}]
static func keys()->Array:return STAGES.map(func(s):return s.key)
static func work_rows()->Array:
 var rows=[]
 for stage in STAGES:
  var effect={"open":[stage.gate],"noise":{"radius":stage.noise,"label":stage.name,"duration":stage.noise_time}}
  if stage.key=="calder_34_disconnect":
   effect.merge({"quiet":1100.,"quiet_time":120.,"calm":0.},true)
  rows.append({"key":stage.key,"name":stage.name,"pos":stage.pos,"gate":stage.gate,"effect":effect})
 return rows
static func box(x:float,y:float,w:float,h:float,bands:Array=T.ALL)->Array:
 return [Rect2(x,y,w,h),bands]
static func layout()->Dictionary:
 var row={"world_size":Vector2(3200,3200),"start":Vector2(300,2900),"recovery":Vector2(300,2500),"mouth":"CALDER WEST COLLAR","terrain":[],"sirens":[],"structures":[],"core_band":2,"bonus_band":1,
 "core":Vector2(1450,1050),"core_label":"HUMAN BORE THROUGH SIREN FOUNDATION","core_art":"array","bonus":Vector2(2100,2150),"bonus_label":"FIRST STRIKE IMPACT FACE","bonus_art":"scoring","current":Vector2(1100,2150),"front":Rect2(900,1900,700,450)}
 var works=work_rows()
 row.works=works;row.work=works[2].pos;row.gate=works[0].gate
 # Outer ring walls with a single south-west entrance gap; solid casing core.
 row.terrain=[box(700,700,1800,100),box(700,700,100,1800),box(2400,700,100,1800),box(700,2400,200,100),box(1200,2400,1300,100),box(1300,1300,600,600),
 [T.shard(Vector2(2850,1700),170,7,57),T.ALL]]
 row.sirens=[R.guard("buoy",Vector2(2000,2150),1),R.guard("warden",Vector2(1100,2150),1),
 R.guard("relay",Vector2(2150,950),1),R.guard("patroller",Vector2(2150,1500),2,[Vector2(2150,1500),Vector2(2150,1000)]),
 R.guard("hunter",Vector2(1100,1000),0,[Vector2(1100,1000),Vector2(1550,1050),Vector2(1100,1450)])]
 return row
