extends RefCounted
# QUALITY: presentation only. Revert by keeping STANDARD / removing consumers.
# Optional SettingsStore key and Display page select the tier explicitly.
const STANDARD="STANDARD"
const LOW_EFFECTS="LOW_EFFECTS"
const FRAME_BUDGET_SECONDS=1.0/30.0
const ROLLING_SECONDS=2.0
const SUGGEST_AFTER_SECONDS=10.0
const IDLE_HEARTBEAT_SECONDS=0.1
# Explicit allowlist: required terrain, contacts, evidence and captions have no switch.
# Only existing decorative layers with consumers belong here.
const DECORATIVES={
	"regional_dust_drift":{STANDARD:true,LOW_EFFECTS:false},
	"regional_water_light_bands":{STANDARD:true,LOW_EFFECTS:false},
}
static func normalize(value:Variant)->String:
	return LOW_EFFECTS if value is String and value==LOW_EFFECTS else STANDARD
static func decorative_enabled(layer:String,tier:Variant=STANDARD)->bool:
	# Unknown names fail open so a typo cannot remove essential information.
	return bool(DECORATIVES[layer][normalize(tier)]) if DECORATIVES.has(layer) else true
