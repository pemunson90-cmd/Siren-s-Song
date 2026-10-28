extends RefCounted
# 027 separate final layout. Revert with the final-pair PR, or disable its data switch.
# ARC6 (076): layout() is a forked shaft with an optional listen task. Revert: ARC6=false.
static var ARC6=true
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
static func legacy()->Dictionary:
 return {"world_size":Vector2(2600,2600),"start":Vector2(350,2250),"recovery":Vector2(2250,2250),
 "core":Vector2(650,550),"bonus":Vector2(1900,600),"core_label":"HUMAN SURVIVOR MARKS","bonus_label":"FEED TERMINALS",
 "core_band":1,"bonus_band":0,
 "structures":[Rect2(680,490,120,120),Rect2(1930,540,120,120)],
 "terrain":[[T.ridge([Vector2(1250,-20),Vector2(1250,650),Vector2(1300,950)],200,33),[0,1]],
 [T.ridge([Vector2(1250,1500),Vector2(1300,1950),Vector2(1250,2620)],200,34),[1,2]],
 [T.shard(Vector2(2000,1250),170,7,35),T.ALL]],
 "sirens":[R.post(Vector2(1200,1250),1,160.),R.guard("patroller",Vector2(1900,900),2,[Vector2(1900,900),Vector2(2200,1400),Vector2(1900,1700)])]}
static func layout()->Dictionary:
 if not ARC6:return legacy()
 # Forked shaft: the waist leads to two northern branches around a solid divider.
 # The western cross-ridge is open SHALLOW only, the eastern one DEEP only.
 return {"world_size":Vector2(2200,3000),"start":Vector2(350,2700),"recovery":Vector2(1700,300),"mouth":"SURVEY SHAFT HEAD",
 "core":Vector2(1000,1000),"bonus":Vector2(1500,700),"core_label":"HUMAN SURVIVOR MARKS","bonus_label":"FEED TERMINALS",
 "core_band":1,"bonus_band":0,
 "listen":{"key":"final_listen_31","name":"FEED LINE","pos":Vector2(500,2300),"evidence":"Received: a muffled count of voices on the feed line."},
 "structures":[Rect2(1030,940,120,120),Rect2(1530,640,120,120)],
 "terrain":[[T.ridge([Vector2(-20,1700),Vector2(400,1700),Vector2(700,1650)],160,33),[1,2]],
 [T.ridge([Vector2(1300,1650),Vector2(1700,1700),Vector2(2020,1700)],160,34),[0,1]],
 [T.wall([Vector2(1200,250),Vector2(1300,250),Vector2(1300,1200),Vector2(1200,1200)]),T.ALL]],
 "sirens":[R.post(Vector2(400,1100),1,160.),R.guard("patroller",Vector2(1500,2300),2,[Vector2(1500,2300),Vector2(1700,2700),Vector2(1300,2700)])]}
