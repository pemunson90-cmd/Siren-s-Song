extends RefCounted
# AI-designed run-only starting supplies. Revert: enabled=false stops new offers;
# retain replay validation for already saved offers. No physical rules change.
static var enabled=true
const VERSION=1
const CAP=9
const BOONS=["sonobuoy","silt_screen","relay_buoy"]
const REFIT={"hull_patch":2,"decoy":1}
const ROUTE_REWARD={"emp":2}
const ROUTE_COST="decoy"
const BOON_COUNT=2
