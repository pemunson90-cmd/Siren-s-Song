extends RefCounted
# Archived missions omit region fields and keep the original geometry/survey.
const LEGACY_SIZE=Vector2(1600,960)
const TILE=40.0
const SURVEY_RANGE=560.0
static func size_of(mission:Dictionary)->Vector2:
 return mission.get("world_size",LEGACY_SIZE)
static func grid_size(mission:Dictionary)->Vector2i:
 return Vector2i(size_of(mission)/TILE)
static func contains(point:Vector2,size:Vector2)->bool:
 return point.is_finite() and point.x>=0 and point.y>=0 and point.x<size.x and point.y<size.y
static func valid_dimensions(dimensions)->bool:
 if not dimensions is Vector2 or not dimensions.is_finite():return false
 if dimensions.x<400 or dimensions.y<400 or dimensions.x>6000 or dimensions.y>6000:return false
 return fmod(dimensions.x,TILE)==0 and fmod(dimensions.y,TILE)==0
static func valid(data:Dictionary)->bool:
 var mission:Dictionary=data.mission
 if not mission.has("world_size"):return not mission.has("region_revision")
 var dimensions=mission.world_size
 if not valid_dimensions(dimensions) or not mission.get("region_revision") is int or mission.region_revision!=1:return false
 if mission.has("survey_origin") and (not mission.survey_origin is Vector2 or not contains(mission.survey_origin,dimensions)):return false
 if not mission.get("start") is Vector2 or not contains(mission.start,dimensions) or not contains(mission.extraction,dimensions):return false
 for objective in mission.objectives:
  if not contains(objective.pos,dimensions):return false
 var cells=Vector2i(dimensions/TILE)
 for cell in data.known:
  if not cell is Vector2i or cell.x<0 or cell.y<0 or cell.x>=cells.x or cell.y>=cells.y:return false
 for actor in data.units+data.sirens:
  if not actor is Dictionary or not actor.get("pos") is Vector2 or not contains(actor.pos,dimensions):return false
  for waypoint in actor.get("route",[]):
   if not waypoint is Dictionary or not waypoint.get("pos") is Vector2 or not contains(waypoint.pos,dimensions):return false
 if not data.get("contacts",{}) is Dictionary:return false
 for contact in data.get("contacts",{}).values():
  if not contact is Dictionary or not contact.get("pos") is Vector2 or not contains(contact.pos,dimensions):return false
 return true
# Bound observation work to actual receiver disks; never scan the larger world
# each sensor pulse. Canonical visible() still decides occlusion and exact reach.
static func observation_cells(sim)->Dictionary:
 var result={};var cells=grid_size(sim.mission)
 for i in sim.units.size():
  var unit=sim.units[i]
  if not unit.alive:continue
  var radius=sim.passive_range(i)
  _disk(result,unit.pos,radius,cells)
 if sim.recon_time>0:_disk(result,sim.mission.get("survey_origin",sim.units[0].pos),SURVEY_RANGE,cells)
 if sim.ping_time>0:_disk(result,sim.ping_origin,650.0,cells)
 return result
static func _disk(result:Dictionary,origin:Vector2,radius:float,cells:Vector2i)->void:
 var low=Vector2i((origin-Vector2.ONE*radius)/TILE)
 var high=Vector2i((origin+Vector2.ONE*radius)/TILE)
 for y in range(maxi(0,low.y),mini(cells.y,high.y+1)):
  for x in range(maxi(0,low.x),mini(cells.x,high.x+1)):
   var cell=Vector2i(x,y)
   if (Vector2(cell)*TILE+Vector2.ONE*TILE/2).distance_squared_to(origin)<radius*radius:result[cell]=true
static func survey_visible(sim,point:Vector2)->bool:
 if sim.recon_time<=0:return false
 if not sim.mission.has("world_size"):return true
 return sim.mission.get("survey_origin",sim.units[0].pos).distance_to(point)<SURVEY_RANGE
