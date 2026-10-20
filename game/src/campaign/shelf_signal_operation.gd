extends RefCounted
const Base=preload("res://src/campaign/tutorial_missions.gd")
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
 sweeper.pos=Vector2(850,300);sweeper.home=sweeper.pos;sweeper.goal=sweeper.pos;sweeper.route=[];sweeper.type="sweeper";sweeper.patrol_points=[]
 m.sirens.append(sweeper)
 m.brief="The spire stands beyond a shelf arch. MIDDLE keeps the long water route. DEEP passes beneath the western arch, with weaker cross-layer sound but pressure-pump cost. SHALLOW has an extra sill. Shift one band at a time: a4s stationary transition exposes both bands. Work and extraction require MIDDLE.\n\nA sweeper guards the far side. Its motor and winding tone give local bearings; a received active pulse is a bearing, not a map icon. It charges2.5s, receives delayed echoes and strikes the old return after1.5s. Quiet depth cover can avoid its return. Or coordinate separate drone bearings, choose forward/all-round SONAR and low/high power, then move or disrupt during its sweep. Active pulses cost energy and expose the emitter. Photograph the spire and bring Quietus home."
 return m
