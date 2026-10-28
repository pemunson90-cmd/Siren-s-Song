extends RefCounted
# AI-DESIGNED expedition budgets. Revert enabled=false and remove the mode entry.
# Reuse the six standalone recon operations; never rewrite enemies or campaign data.
static var enabled=true
const POOL=[0,1,2,3,4,5]
const LOADOUTS=["endurance","survey","disruption"]
const SCARCITY=["supplied","limited","scarce"]
const TOOLS=["emp","decoy","recon","knock","sonobuoy","silt_screen","hull_patch","relay_buoy"]
const RESUPPLY=[2,1,0]
const MAX_SEED=2147483647
const FieldTools=preload("res://src/equipment/field_tools.gd")
static func stock(loadout:String,scarcity:int)->Dictionary:
	var counts={}
	for key in TOOLS:counts[key]=maxi(0,FieldTools.loadout_count(key,loadout)-scarcity)
	return counts
