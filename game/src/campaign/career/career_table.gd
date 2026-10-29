extends RefCounted
# Provisional career tuning; career data stays in its own sidecars.
# Groups and regional work come from STORY_BIBLE_DRAFT; no new story outcomes.
const FACTIONS={"brannock":"BRANNOCK COMMAND","hollins":"HOLLINS FIELD CREWS","varne":"VARNE RANGE","mariners":"LOCAL MARINERS"}
const MIN_STANDING=-6
const MAX_STANDING=10
const SUCCESS=2
const LOSS=-2
# Recovery jobs always remain open. Higher trust opens deeper regional work.
const CONTRACTS={
	"brannock_watch":{"faction":"brannock","op":0,"reward":{"scrap":3,"cells":2},"brief":"Photograph the listening station and return the records."},
	"brannock_deep":{"faction":"brannock","op":3,"standing":2,"reward":{"scrap":6,"cells":3,"alloy":1},"brief":"Recover the deep photographic record."},
	"hollins_watch":{"faction":"hollins","op":1,"reward":{"scrap":3,"cells":2},"brief":"Bring back a reconnaissance record for the field crews."},
	"hollins_locks":{"faction":"hollins","op":22,"standing":2,"reward":{"scrap":7,"cells":3,"alloy":1},"brief":"Complete the pressure-lock operation and return."},
	"hollins_material":{"faction":"hollins","op":26,"standing":4,"reward":{"scrap":7,"cells":4,"alloy":2},"brief":"Recover regional material for fleet research."},
	"varne_watch":{"faction":"varne","op":2,"reward":{"scrap":3,"cells":2},"brief":"Return photographic reconnaissance for the range."},
	"varne_fence":{"faction":"varne","op":14,"standing":2,"reward":{"scrap":6,"cells":4,"alloy":1},"brief":"Complete reconnaissance along the listening fence."},
	"varne_atlas":{"faction":"varne","op":16,"standing":2,"reward":{"scrap":6,"cells":4,"alloy":1},"brief":"Return the thermal atlas needed to interpret range material."},
	"varne_material":{"faction":"varne","op":20,"standing":4,"reward":{"scrap":7,"cells":4,"alloy":2},"brief":"Recover range material for fleet research."},
	"mariners_watch":{"faction":"mariners","op":4,"reward":{"scrap":4,"cells":2},"brief":"Return a photographic record of the approach."},
	"mariners_trawler":{"faction":"mariners","op":37,"standing":2,"reward":{"scrap":7,"cells":3,"alloy":2},"brief":"Complete the trawler recovery operation."},
	"mariners_thread":{"faction":"mariners","op":38,"standing":4,"reward":{"scrap":8,"cells":4,"alloy":2},"brief":"Recover the deep-thread survey record."}}
