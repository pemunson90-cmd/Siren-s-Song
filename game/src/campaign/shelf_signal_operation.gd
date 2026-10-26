extends RefCounted
const Base=preload("res://src/campaign/tutorial_missions.gd")
const Patrols=preload("res://src/campaign/sweeper_patrols.gd")
# First authored depth encounter; remaining tutorial factories keep their geometry.
static func supports_config(config:Dictionary)->bool:
 return config=={"source_id":0,"history":false}
static func supports_identity(id:int,config:Dictionary)->bool:return id==config.source_id
static func build(config:Dictionary,_history:Dictionary={})->Dictionary:
 if not supports_config(config):return {}
 var m=Base.make(0)
 m["start"]=Vector2(140,800)
 m["depth_geometry"]={0:{"rocks":m.rocks+[Rect2(400,610,350,130)]},2:{"rocks":m.rocks.slice(1)}}
 var sweeper=m.sirens[0].duplicate(true)
 sweeper.pos=Vector2(850,300);sweeper.home=sweeper.pos;sweeper.goal=sweeper.pos;sweeper.route=[];sweeper.type="sweeper";sweeper.patrol_points=Patrols.circuit(0)
 m.sirens.append(sweeper)
 m["depth_hint"]="DEEP under the arch · MIDDLE camera/recovery · craft → DEPTH / SONAR."
 m.brief="Photograph the listening spire, then return Quietus. DEEP passes beneath the western arch; SHALLOW has an extra sill; MIDDLE retains the long water route. Craft → DEPTH / SONAR changes adjacent layers: four stationary seconds exposed in both. Deep pumps cost reserves. Work and recovery require MIDDLE. A sweeper guards the far side. A locally heard winding tone warns of its sweep and delayed strike at the old return. Move or disrupt before it lands. Passive bearings need movement or independent receivers to narrow a position. Choose a quiet crossing or coordinate a costly active sounding, then bring the evidence home."
 return m
