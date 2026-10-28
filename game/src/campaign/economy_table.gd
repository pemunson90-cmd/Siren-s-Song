extends RefCounted
# Campaign economy data and master switch (AI-DESIGNED numbers, Pat to tune).
# Seam: economy.gd reads every price, income and preset here; glass_research.gd reads only
# `enabled`. Revert: set enabled=false. Launches become free, research is automatic again,
# hulls and chassis are all offered, and the panel hides. Saved economy fields are ignored.
static var enabled=true
const RES=["scrap","cells","alloy"]
const NAMES={"scrap":"SCRAP","cells":"CELLS","alloy":"ALLOY"}
const ORDER=["standard","accessible","survival"]
# cost: price multiplier; income: salvage multiplier; floor: lowest condition a dive can leave
# a craft at; replenish: supplies refill and craft mend between operations.
const PRESETS={
 "standard":{"name":"STANDARD","cost":1.0,"income":1.0,"floor":60,"replenish":false,"note":"Costs persist. Wear and wrecks are recoverable."},
 "accessible":{"name":"ACCESSIBLE","cost":0.5,"income":1.0,"floor":100,"replenish":true,"note":"Supplies refill and craft mend between operations."},
 "survival":{"name":"SURVIVAL","cost":1.5,"income":0.6,"floor":30,"replenish":false,"note":"Heavy attrition. Lean income, dear repairs."}
}
const START={"scrap":8,"cells":10,"alloy":0}
const REFILL={"scrap":8,"cells":8,"alloy":2}
const CAP=99
# Salvage after a dive. Recovered modules add scrap each; a new alien artifact adds alloy.
const INCOME={"first":{"scrap":3,"cells":2,"alloy":0},"replay":{"scrap":1,"cells":1,"alloy":0},"lost":{"scrap":0,"cells":1,"alloy":0},
 "module_scrap":2,"artifact_alloy":3}
# Manufacturing: scrap = BASE + power of the fitting; alien-derived fittings also take alloy.
const ITEM_BASE_SCRAP=2
const ALIEN=["quietus_pressure_sleeve","drone_traction_yoke","quietus_prism","quietus_decoder","quietus_wellhead_seal","drone_choir_tuner"]
# Per-item price overrides keyed by item id, e.g. {"photo_flash":{"scrap":3}}.
const ITEM_PRICE={}
const RESEARCH_COST={"alloy":2}
const REFINE={"scrap":6,"alloy":1}
# Hull and chassis entitlements: bought with alloy, or granted by research of a recipe target.
const UNLOCK_PRICE={"hull:quiet":{"alloy":4},"hull:fast":{"alloy":4},"chassis:scout":{"alloy":2},"chassis:heavy":{"alloy":2},
 "chassis:endurance":{"alloy":2}}
const REPAIR_HULL_PER_STEP=25
const TARGETS=["quietus","drone_a","drone_b"]
const LABELS={"quietus":"QUIETUS HULL","drone_a":"DRONE A","drone_b":"DRONE B"}
