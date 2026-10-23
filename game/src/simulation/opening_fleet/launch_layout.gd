extends RefCounted
# Opening launch data only. Existing saves keep their own positions.
# Revert: remove the LaunchLayout seam in Simulation.start and restore LEGACY.
const LEGACY=[Vector2.ZERO,Vector2(0,-100),Vector2(140,0)]
const CLEAR_LANE=[Vector2.ZERO,Vector2(0,-100),Vector2(0,100)]
const PROFILES={0:CLEAR_LANE,1:CLEAR_LANE,2:CLEAR_LANE,3:CLEAR_LANE,4:CLEAR_LANE,5:CLEAR_LANE}
static func offset(operation:int,craft:int)->Vector2:
 return PROFILES.get(operation,LEGACY)[craft]
