extends RefCounted
# 027 authored survey layout. Revert with the final-pair PR, or disable its data switch.
const T=preload("res://src/campaign/encounters/terrain.gd")
const R=preload("res://src/campaign/encounters/roster.gd")
static func layout()->Dictionary:
 return {"world_size":Vector2(2800,2200),"start":Vector2(350,1850),"recovery":Vector2(2450,1850),
 "core":Vector2(1200,450),"bonus":Vector2(2200,550),"core_label":"SCOUR EDGE","bonus_label":"SPINDLE WEAR",
 "core_band":1,"bonus_band":2,
 "terrain":[[T.ridge([Vector2(-20,1100),Vector2(600,1100),Vector2(800,1050)],180,30),[0,1]],
 [T.ridge([Vector2(1450,1100),Vector2(2000,1100),Vector2(2820,1150)],180,31),[1,2]],
 [T.shard(Vector2(1900,450),150,7,32),T.ALL]],
 "sirens":[R.guard("buoy",Vector2(1050,1050),1),R.guard("patroller",Vector2(1900,800),0,[Vector2(1900,800),Vector2(2400,600),Vector2(2400,1300)])]}
