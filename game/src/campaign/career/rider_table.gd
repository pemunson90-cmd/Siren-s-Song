extends RefCounted
# Optional bonuses only. Revert: enabled=false; saved assignments still validate.
# Provisional rewards reuse existing resources and the contract client's standing.
static var enabled=true
const SEED=71071
# Runs have finite carried supplies rather than the career's money/standing.
# One extra charge, capped by the existing run stock limit. Provisional tuning.
const EXPEDITION_PAY={"no_sonar":{"recon":1},"no_tools":{"emp":1},"hull_intact":{"hull_patch":1},"no_losses":{"decoy":1},"middle_only":{"silt_screen":1},"one_tool":{"knock":1},"quiet_propulsion":{"relay_buoy":1},"time_limit":{"emp":1}}
const ROWS={
	"no_sonar":{"pay":{"cells":2},"standing":0},
	"no_tools":{"pay":{"scrap":3},"standing":0},
	"hull_intact":{"pay":{"alloy":1},"standing":0},
	"no_losses":{"pay":{},"standing":1},
	"middle_only":{"pay":{"cells":2},"standing":0},
	"one_tool":{"pay":{"scrap":2},"standing":0},
	"quiet_propulsion":{"pay":{},"standing":1},
	"time_limit":{"pay":{"alloy":1},"standing":0}
}
