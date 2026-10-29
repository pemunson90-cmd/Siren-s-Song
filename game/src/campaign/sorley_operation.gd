extends RefCounted
const W=preload("res://src/campaign/encounters/work_sites.gd")
static func supports_config(c:Dictionary)->bool:return c.size()==2 and c.get("history")==true and c.get("source_id")==41
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var m={"id":41,"title":"OPTIONAL / Last Boat Out","depth":4100,"darkness":false,"region_revision":1,"acoustic_revision":1,"expedition_revision":2,"rocks":[],"structures":[],"sirens":[],"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":["sorley_boy"],"launch_context":history.duplicate(true)}
 m.glass_reach={"artifact":{},"work_pos":Vector2.ZERO}
 preload("res://src/campaign/optional_operations.gd")._trawler(m,"unused")
 m.erase("glass_reach")
 m.objectives=[{"pos":Vector2(1450,980),"name":"BOY'S SEALED POD","site_id":"sorley_boy","captured":false,"kind":"pod","evidence":"The boy entered the sealed rescue pod at the trawler's air pocket."}]
 m.sorley_quiet=true
 m.witness_evacuation=preload("res://src/simulation/witness_evacuation.gd").initial()
 m.witness_evacuation.pos=Vector2(1450,980)
 m.extraction=m.start
 m.corridors=[{"pos":m.start,"name":"SOUTH BOAT LIFT","route":"deep"}]
 m.signal_sources=[{"id":"sorley_boy","label":"AIR-POCKET WINDOW","pos":Vector2(1450,980),"evidence":"A boy waits inside the trawler's air pocket. Winch the sealed pod locally, then LAND at the south boat.","located":false,"cadence":[1.,2.,1.]}]
 preload("res://src/campaign/divergence_missions.gd")._patrol(m,Vector2(1660,1180),[Vector2(1660,1180)])
 m.sirens[0].type="sentinel";m.sirens[0].band=0
 preload("res://src/campaign/divergence_missions.gd")._patrol(m,Vector2(900,1180),[Vector2(900,1180),Vector2(1150,1550),Vector2(1650,1540),Vector2(1600,1160)])
 m.sirens[1].type="hunter";m.sirens[1].band=1
 m.endurance={"oxygen_seconds":600.,"drone_seconds":480.}
 m.brief="Sorley's boy is at the SHALLOW air-pocket window (1450,980). Approach below the eastern patrol, ascend outside the wreck, then WINCH the sealed pod within60m after settling. LAND at SOUTH BOAT LIFT (300,1500) in MIDDLE; recover Quietus there too.\nThe 4s winch is audible. Bare Quietus can wait for the patrol and use depth and the long southern return. An intact drone landing without a lock warning or hull damage earns extra supplies: scout first, reserve power, and use finite Disrupt or silt to protect the transfer."
 m.record="Sorley's boy was landed at the south boat. Supplies from his father are aboard Brannock."
 return m
