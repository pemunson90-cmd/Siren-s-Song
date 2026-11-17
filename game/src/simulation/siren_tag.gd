extends RefCounted
# The ONE name a Siren carries on screen: "S" and its place in the mission's Siren list plus one ("S1" is the
# first). The lock card and its marker, the camera caption and the photo study names take it from here, so they
# say the same number for the same Siren.
static func tag(index:int)->String:
	return "S%d"%(index+1)
