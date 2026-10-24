extends RefCounted
# 027 separate final layout. Revert with the final-pair PR, or disable its data switch.
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
static func layout()->Dictionary:
 return {"world_size":Vector2(2600,2600),"start":Vector2(350,2250),"recovery":Vector2(2250,2250),
 "core":Vector2(650,550),"bonus":Vector2(1900,600),"core_label":"HUMAN SURVIVOR MARKS","bonus_label":"FEED TERMINALS",
 "core_band":1,"bonus_band":0,
 "terrain":[[T.ridge([Vector2(1250,-20),Vector2(1250,650),Vector2(1300,950)],200,33),[0,1]],
 [T.ridge([Vector2(1250,1500),Vector2(1300,1950),Vector2(1250,2620)],200,34),[1,2]],
 [T.shard(Vector2(2000,1250),170,7,35),T.ALL]],
 "sirens":[R.post(Vector2(1200,1250),1,160.),R.guard("patroller",Vector2(1900,900),2,[Vector2(1900,900),Vector2(2200,1400),Vector2(1900,1700)])]}
