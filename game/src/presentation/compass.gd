extends RefCounted
# The one bearing convention: whole degrees clockwise from north, north is up the chart (0 to 359).
# Every readout that prints "BRG", a bearing or a direction word goes through here.
const POINTS=["NORTH","NORTH-EAST","EAST","SOUTH-EAST","SOUTH","SOUTH-WEST","WEST","NORTH-WEST"]
static func degrees(delta:Vector2)->float:
	return fposmod(rad_to_deg(atan2(delta.x,-delta.y)),360.0)
static func bearing(delta:Vector2)->int:
	return roundi(degrees(delta))%360
# The eight-point word for a bearing in degrees.
static func point(bearing_degrees:float)->String:
	return POINTS[roundi(fposmod(bearing_degrees,360.0)/45.0)%8]
static func word(delta:Vector2)->String:
	return point(degrees(delta))
# The chart direction (unit vector, screen axes) of a bearing in degrees.
static func direction(bearing_degrees:float)->Vector2:
	return Vector2(sin(deg_to_rad(bearing_degrees)),-cos(deg_to_rad(bearing_degrees)))
