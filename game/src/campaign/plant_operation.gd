extends RefCounted
# Supported authored variant of the existing physical warning plant. This is a
# content factory, not a shipped operation; only catalog entries make it playable.
const Base=preload("res://src/campaign/onward_missions.gd")
const KEYS=["source_id","history","title","brief","world_size","start","extraction","rocks","plant"]
const STATIONS=["inlet","panel","mast","recovery"]
static func supports_config(c:Dictionary)->bool:
 if c.size()!=KEYS.size() or not c.has_all(KEYS) or c.source_id!=10 or c.history!=true:return false
 if not c.title is String or c.title.is_empty() or not c.brief is String or c.brief.is_empty():return false
 if not preload("res://src/simulation/world_region.gd").valid_dimensions(c.world_size) or c.world_size.x<800 or c.world_size.y<800:return false
 var bounds=Rect2(Vector2.ONE*40,c.world_size-Vector2.ONE*80)
 if not c.start is Vector2 or not c.extraction is Vector2 or not c.start.is_finite() or not c.extraction.is_finite() or not bounds.has_point(c.start) or not bounds.has_point(c.extraction):return false
 if not c.rocks is Array or not c.plant is Dictionary or c.plant.size()!=5 or not c.plant.has_all(STATIONS+["shutter"]):return false
 var gate=c.plant.shutter
 if not gate is Rect2 or not gate.is_finite() or gate.size.x<=0 or gate.size.y<=0 or not bounds.encloses(gate):return false
 for point in [c.start,c.start+Vector2(0,-100),c.start+Vector2(140,0),c.extraction]:
  if not bounds.has_point(point) or gate.grow(24).has_point(point):return false
 for key in STATIONS:
  var point=c.plant[key]
  if not point is Vector2 or not point.is_finite() or not bounds.has_point(point) or gate.grow(24).has_point(point):return false
 for shape in c.rocks:
  if not shape is Rect2 or not shape.is_finite() or shape.size.x<=0 or shape.size.y<=0:return false
  for point in [c.start,c.start+Vector2(0,-100),c.start+Vector2(140,0),c.extraction,c.plant.inlet,c.plant.panel,c.plant.mast,c.plant.recovery]:
   if shape.grow(24).has_point(point):return false
 return true
static func build(config:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(config):return {}
 var m=Base.make(10,history)
 for key in ["title","brief","world_size","start","extraction","rocks"]:m[key]=config[key].duplicate(true) if config[key] is Array else config[key]
 m.sirens=[]
 m.structures=[config.plant.shutter]
 m.objectives[0].pos=config.plant.inlet
 for id in [1,2]:m.objectives[id].pos=config.plant.panel
 m.corridors=[{"pos":config.extraction,"name":"NORTH WATER RECOVERY","route":"shelf"},{"pos":config.plant.recovery,"name":"WEST SERVICE RECOVERY","route":"shelf"}]
 return m
