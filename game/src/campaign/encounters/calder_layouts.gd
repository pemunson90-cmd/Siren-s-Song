extends RefCounted
# Calder's drill cuts across an older Siren site. Deep galleries remain open
# beneath the drill deck; middle machinery always has a bare Quietus approach.
# ARC6 (076): layout() gives each op its own world, mouths and traversal shape
# (32 vertical shaft, 33 long gallery, 34 staged ring in calder_capstone.gd, 35 stepped
# keel, 36 twin chambers). Revert: set ENABLED=false to restore the legacy 2800x2800 rows.
static var ENABLED=true
# 065 AI-DESIGNED optional work positions and tuning, separate from core gates.
# Seal bypass stops drill wash before the mandatory disconnect; lift and breaker
# reuse their authored physical benefits. Revert: MODULE_SITES_ENABLED=false.
static var MODULE_SITES_ENABLED=true
const MODULE_SITES={
 34:{"key":"calder_34_wash_bypass","name":"OPTIONAL WASH BYPASS","offset":Vector2(0,100),"module":"quietus_wellhead_seal","duration":12.,"effect":{"calm":0.,"noise":{"radius":900.,"label":"WASH BYPASS PUMP","duration":8.}}},
 35:{"module":"quietus_wellhead_seal"},
 36:{"module":"drone_choir_tuner"}}
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
const Capstone=preload("res://src/campaign/encounters/calder_capstone.gd")
static func box(x:float,y:float,w:float,h:float,bands:Array=T.ALL)->Array:
 return [Rect2(x,y,w,h),bands]
static func layout(id:int)->Dictionary:
 if not ENABLED:return legacy(id)
 var row={"world_size":Vector2(2800,2800),"start":Vector2(350,2450),"recovery":Vector2(350,2450),"terrain":[],"sirens":[],"structures":[],"core_band":2,"bonus_band":1,"mouth":"CALDER SOUTH RECOVERY"}
 match id:
  32:
   # Vertical shaft: a sealed casing column with the shut-in wheel at its foot. Opening the
   # mid-shaft gate lets the climb reach the deep seal core; the bonus nameplate is outside.
   row.merge({"world_size":Vector2(2000,3200),"start":Vector2(300,2900),"recovery":Vector2(1700,2900),"mouth":"CALDER EAST COLLAR","core":Vector2(1100,650),"core_label":"DRILL INTO THE OLD RIBS","core_art":"scoring","bonus":Vector2(1700,1500),"bonus_label":"GUARD SHIFT NAMEPLATE","bonus_art":"count","work":Vector2(1100,2000),"gate":Rect2(800,1500,600,100),"cargo":Vector2(1150,650),"cargo_band":2,"current":Vector2(1100,1900),"front":Rect2(850,1600,500,500)},true)
   row.terrain=[box(700,500,100,1900),box(1400,500,100,1900),box(700,400,800,100),box(300,1200,250,300,[0,1]),box(1550,2000,250,200),[T.ridge([Vector2(1900,300),Vector2(1700,600),Vector2(1750,900)],150,51),T.ALL]]
   row.sirens=[R.guard("buoy",Vector2(1650,1000),2),R.guard("relay",Vector2(350,1700),2),R.guard("warden",Vector2(1650,2500),1),R.guard("patroller",Vector2(1500,1700),1,[Vector2(1500,1700),Vector2(1800,2000),Vector2(1500,2300)])]
  33:
   # Long gallery: a west-to-east service corridor under a sealed survivor room. The
   # pressure wheel at the west end opens the room door; the mouth is at the far east.
   row.merge({"world_size":Vector2(3200,2000),"start":Vector2(300,1700),"recovery":Vector2(3000,1700),"mouth":"CALDER GALLERY END","core":Vector2(1850,650),"core_label":"DRILLERS AND GUARDS AT THE GLASS","core_art":"count","bonus":Vector2(650,600),"bonus_label":"SIREN REED SCORING","bonus_art":"scoring","work":Vector2(1000,1550),"gate":Rect2(1600,950,650,100),"cargo":Vector2(1850,730),"cargo_band":2,"current":Vector2(1200,1500),"front":Rect2(900,1350,600,500)},true)
   row.terrain=[box(1500,300,100,700),box(2250,300,100,700),box(1500,250,850,50),box(1600,400,650,550,[0,1]),box(300,1150,1200,100),box(2350,1150,850,100),[T.shard(Vector2(1300,1750),140,7,52),T.ALL],[T.shard(Vector2(2600,1650),150,7,56),T.ALL]]
   row.sirens=[R.guard("buoy",Vector2(2250,1500),2),R.guard("relay",Vector2(2850,1400),2),R.guard("hunter",Vector2(2600,1900),2,[Vector2(2600,1900),Vector2(3000,1900),Vector2(3000,1500)]),R.post(Vector2(1750,1450),1,150.)]
  34:return Capstone.layout() if Capstone.ENABLED else legacy(id)
  35:
   # Stepped keel: the keel lies under a deck at mid-map. A wall splits the east; the long way
   # round is the north gap, the optional deck lift opens a noisy shorter gate south.
   row.merge({"world_size":Vector2(3600,2000),"start":Vector2(300,300),"recovery":Vector2(3300,1700),"mouth":"CALDER SOUTHEAST RECOVERY","core":Vector2(1900,900),"core_label":"KEEL UNDER THE DRILL DECK","core_art":"scoring","bonus":Vector2(700,650),"bonus_label":"MISSING GUARD BERTHS","bonus_art":"count","work":Vector2(2300,1450),"gate":Rect2(2600,1250,100,350),"cargo":Vector2(1850,1000),"cargo_band":2},true)
   row.terrain=[box(1700,650,450,600,[0,1]),box(1350,550,200,800),box(1000,1650,700,150),box(2100,1600,350,400),box(600,1000,300,300),box(2600,700,100,550),box(2600,1600,100,400),[T.shard(Vector2(2350,500),160,8,53),T.ALL]]
   row.sirens=[R.guard("interceptor",Vector2(2250,1250),2),R.guard("buoy",Vector2(1650,1800),2),R.guard("relay",Vector2(3000,900),2),R.post(Vector2(1800,400),1,160.)]
  36:
   # Twin chambers: the guard station straddles the bore, entered from the east and left by
   # the west mouth. The optional breaker opens the central door; the bare route is the south gap.
   row.merge({"world_size":Vector2(2400,2400),"start":Vector2(2100,2100),"recovery":Vector2(300,2100),"mouth":"CALDER WEST RECOVERY","core":Vector2(1750,850),"core_label":"GUARD WINDOW ON THE FIRST STRIKE","core_art":"array","bonus":Vector2(850,550),"bonus_label":"DRILL PERMIT ON OLD STONE","bonus_art":"scoring","work":Vector2(1700,1350),"gate":Rect2(1200,1100,100,350)},true)
   row.terrain=[box(1500,600,500,500,[0,1]),box(1200,400,180,700),box(1200,1450,180,650),box(1900,1550,400,180),box(550,1650,350,200),[T.shard(Vector2(2150,300),140,7,54),T.ALL]]
   row.sirens=[R.guard("buoy",Vector2(1550,1700),2),R.guard("relay",Vector2(2150,1300),2),R.guard("hunter",Vector2(1800,2250),2,[Vector2(1800,2250),Vector2(2250,2250),Vector2(2250,1900)]),R.post(Vector2(750,850),1,150.)]
 return row
static func legacy(id:int)->Dictionary:
 var row={"world_size":Vector2(2800,2800),"start":Vector2(350,2450),"recovery":Vector2(350,2450),"terrain":[],"sirens":[],"structures":[],"core_band":2,"bonus_band":1,"mouth":"CALDER SOUTH RECOVERY","current":Vector2(1400,1250),"front":Rect2(1450,900,650,650)}
 match id:
  32:
   # Two drill-deck roofs force a descent into the west bore. The middle
   # shut-in alcove sits outside the well, with a clear southern approach.
   row.merge({"core":Vector2(1100,650),"core_label":"DRILL INTO THE OLD RIBS","core_art":"scoring","bonus":Vector2(2200,1450),"bonus_label":"GUARD SHIFT NAMEPLATE","bonus_art":"count","work":Vector2(700,1150),"gate":Rect2(900,850,400,100),"cargo":Vector2(1150,650),"cargo_band":2},true)
   row.terrain=[box(900,400,500,450,[0,1]),box(1650,400,500,800,[0,1]),box(1350,950,230,850),box(650,1550,450,220),box(1850,1750,500,250),[T.ridge([Vector2(200,400),Vector2(400,550),Vector2(450,850)],170,51),T.ALL]]
   row.sirens=[R.guard("buoy",Vector2(1550,550),2),R.guard("relay",Vector2(2050,900),2),R.guard("warden",Vector2(2250,2050),1),R.guard("patroller",Vector2(2000,1400),1,[Vector2(2000,1400),Vector2(2400,1200),Vector2(2400,1650)])]
  33:
   # A roofed survivor gallery in the east, a divided drill spine in the
   # centre, and a middle-depth pressure wheel at the western gallery door.
   row.merge({"core":Vector2(1850,650),"core_label":"DRILLERS AND GUARDS AT THE GLASS","core_art":"count","bonus":Vector2(650,600),"bonus_label":"SIREN REED SCORING","bonus_art":"scoring","work":Vector2(1150,1250),"gate":Rect2(1300,1100,100,400),"cargo":Vector2(1850,730),"cargo_band":2},true)
   row.terrain=[box(1600,400,550,450,[0,1]),box(1300,400,180,700),box(1300,1500,180,650),box(650,1600,350,300),box(1950,1450,450,230),box(2200,400,170,650),[T.shard(Vector2(800,900),120,7,52),T.ALL]]
   row.sirens=[R.guard("buoy",Vector2(2300,1250),2),R.guard("relay",Vector2(2300,1750),2),R.guard("hunter",Vector2(1900,2050),2,[Vector2(1900,2050),Vector2(2400,2100),Vector2(2400,1800)]),R.post(Vector2(1750,1200),1,150.)]
  34:
   # Broken concentric well casing. Its open southern deep mouth has no
   # tool gate; the deck above remains solid. Manual disconnect is outside.
   row.merge({"core":Vector2(1400,650),"core_label":"HUMAN BORE THROUGH SIREN FOUNDATION","core_art":"array","bonus":Vector2(2200,1850),"bonus_label":"FIRST STRIKE IMPACT FACE","bonus_art":"scoring","work":Vector2(700,1200),"gate":Rect2(950,1300,250,100)},true)
   row.terrain=[[T.arc(Vector2(1400,650),350,490,-PI,0.,10),T.ALL],[T.arc(Vector2(1400,650),350,490,0.,.65,3),T.ALL],[T.arc(Vector2(1400,650),350,490,2.45,PI,3),T.ALL],box(1080,350,640,600,[0,1]),box(1500,1500,350,500),box(650,1700,400,200),box(2050,850,350,450)]
   row.sirens=[R.guard("buoy",Vector2(1850,1400),2),R.guard("relay",Vector2(2350,1450),2),R.guard("warden",Vector2(2250,2200),1),R.guard("patroller",Vector2(2000,700),2,[Vector2(2000,700),Vector2(2450,650),Vector2(2450,1050)])]
  35:
   # A heavy keel pinned under the east drill deck. Deep salvage has two
   # approaches around the broken support, with a noisy optional deck lift.
   row.merge({"core":Vector2(1900,900),"core_label":"KEEL UNDER THE DRILL DECK","core_art":"scoring","bonus":Vector2(700,650),"bonus_label":"MISSING GUARD BERTHS","bonus_art":"count","work":Vector2(1200,1550),"gate":Rect2(1350,1350,300,110),"cargo":Vector2(1850,1000),"cargo_band":2},true)
   row.terrain=[box(1700,650,450,600,[0,1]),box(1350,550,200,800),box(1000,1650,700,150),box(2100,1600,350,400),box(600,1000,300,300),[T.shard(Vector2(2350,500),160,8,53),T.ALL]]
   row.sirens=[R.guard("interceptor",Vector2(2250,1350),2),R.guard("buoy",Vector2(1650,2000),2),R.guard("relay",Vector2(2300,2250),2),R.post(Vector2(1800,400),1,160.)]
  36:
   # A flooded guard station straddles the bore. Photograph the deep-facing
   # strike window; the optional middle breaker cuts its listening network.
   row.merge({"core":Vector2(1750,850),"core_label":"GUARD WINDOW ON THE FIRST STRIKE","core_art":"array","bonus":Vector2(850,550),"bonus_label":"DRILL PERMIT ON OLD STONE","bonus_art":"scoring","work":Vector2(850,1300),"gate":Rect2(1200,1100,100,350)},true)
   row.terrain=[box(1500,600,500,500,[0,1]),box(1200,400,180,700),box(1200,1450,180,650),box(1900,1550,500,180),box(550,1650,350,200),[T.shard(Vector2(2300,700),140,7,54),T.ALL]]
   row.sirens=[R.guard("buoy",Vector2(1550,1250),2),R.guard("relay",Vector2(2200,1300),2),R.guard("hunter",Vector2(2250,2050),2,[Vector2(2250,2050),Vector2(2400,1800)]),R.post(Vector2(750,850),1,150.)]
 return row
