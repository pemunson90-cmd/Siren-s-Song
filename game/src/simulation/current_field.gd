extends RefCounted
# V7's linear radial fade, expressed as water velocity in world units/second.
static func sample(fields:Array,point:Vector2)->Vector2:
 var velocity=Vector2.ZERO
 for field in fields:
  if not field is Dictionary or not field.get("center") is Vector2 or not field.get("velocity") is Vector2:continue
  var radius=float(field.get("radius",0))
  if radius>0:velocity+=field.velocity*maxf(0.0,1.0-point.distance_to(field.center)/radius)
 return velocity
