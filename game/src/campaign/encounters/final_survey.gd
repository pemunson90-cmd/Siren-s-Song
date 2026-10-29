extends RefCounted
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
static func layout()->Dictionary:
 # Long gallery: wall A is open DEEP, wall B is open SHALLOW; the gap between them is watched.
 return {"world_size":Vector2(3200,1800),"start":Vector2(300,1500),"recovery":Vector2(2900,500),"mouth":"SURVEY GALLERY END",
 "core":Vector2(1300,420),"bonus":Vector2(2500,500),"core_label":"SCOUR EDGE","bonus_label":"SPINDLE WEAR",
 "core_band":1,"bonus_band":2,
 "listen":{"key":"final_listen_30","name":"SPINDLE CHATTER","pos":Vector2(1500,1350),"evidence":"Received: a four-beat count repeats from the spindle housing."},
 "structures":[Rect2(1330,360,120,120),Rect2(2530,440,120,120)],
 "terrain":[[T.ridge([Vector2(-20,900),Vector2(700,900),Vector2(1000,880)],160,30),[0,1]],
 [T.ridge([Vector2(1700,900),Vector2(2300,900),Vector2(3220,940)],160,31),[1,2]],
 [T.shard(Vector2(2000,1350),150,7,32),T.ALL]],
 "sirens":[R.guard("buoy",Vector2(1350,950),1),R.guard("patroller",Vector2(1050,620),1,[Vector2(1050,620),Vector2(1050,620)])]}
