extends RefCounted
# C2 field tools: the single table of the eight finite tools. AI-DESIGNED (Pat tunes the numbers).
# emp, decoy, recon and knock keep their owner (sim.tools, weapon_orders, sensor_orders); their rows only
# describe them. sonobuoy, silt_screen, hull_patch and relay_buoy are new and live in
# simulation/field_tool_effects.gd with orders in simulation/orders/tool_orders.gd.
# Tools protect the player and never disable a Siren: silt only hides sight for a short time.
# Seams: simulation.gd start() seeds counts, passive_range() scales relay reach, depth_bands.gd sight() asks silt.
# Revert: set enabled=false (no counts, no effect, orders refuse) or remove the seam lines and table rows.
const enabled=true
# Touch target for every tool order button, in dp (a presentation host builds it).
const TOUCH_DP=48
const LOADOUTS=["endurance","disruption","survey"]
# counts: starting stock per campaign loadout. deploy: placement range from the craft in metres.
const TOOLS={
 "emp":{"id":"emp","name":"Disrupt","order":"emp","owner":"tools","enabled":true,
  "counts":{"endurance":2,"disruption":3,"survey":2},"summary":"Pulse that stuns Sirens for 12 s."},
 "decoy":{"id":"decoy","name":"Decoy","order":"decoy","owner":"tools","enabled":true,
  "counts":{"endurance":3,"disruption":3,"survey":3},"summary":"Open-water transmission that draws Sirens."},
 "recon":{"id":"recon","name":"Survey","order":"recon","owner":"tools","enabled":true,
  "counts":{"endurance":2,"disruption":2,"survey":3},"summary":"Loud local survey uplink."},
 "knock":{"id":"knock","name":"Torpedo","order":"knock","owner":"tools","enabled":true,
  "counts":{"endurance":2,"disruption":2,"survey":2},"summary":"Pins one Siren on impact."},
 "sonobuoy":{"id":"sonobuoy","name":"Sonobuoy","order":"sonobuoy","owner":"field","enabled":true,"ai_designed":true,
  "counts":{"endurance":2,"disruption":1,"survey":3},"deploy":160.0,"life":90.0,"max_active":2,"range":520.0,
  "bearing_step":0.0873,"noise":0.0,"noise_time":0.0,"noise_label":"",
  "summary":"Drop a passive listener: bearings to nearby Sirens for 90 s, never range."},
 "silt_screen":{"id":"silt_screen","name":"Silt screen","order":"silt_screen","owner":"field","enabled":true,"ai_designed":true,
  "counts":{"endurance":1,"disruption":2,"survey":1},"deploy":160.0,"life":25.0,"max_active":1,"radius":110.0,
  "noise":320.0,"noise_time":1.5,"noise_label":"SILT RELEASE",
  "summary":"Cloud blocks sight through it for 25 s, for you and for Sirens."},
 "hull_patch":{"id":"hull_patch","name":"Hull patch","order":"hull_patch","owner":"field","enabled":true,"ai_designed":true,
  "counts":{"endurance":1,"disruption":1,"survey":1},"repair":30.0,"noise":260.0,"noise_time":2.0,"noise_label":"PATCH WORK",
  "summary":"Repairs up to 30% collision hull damage once. Live Quietus only."},
 "relay_buoy":{"id":"relay_buoy","name":"Relay buoy","order":"relay_buoy","owner":"field","enabled":true,"ai_designed":true,
  "counts":{"endurance":1,"disruption":0,"survey":2},"deploy":160.0,"life":180.0,"max_active":1,"radius":420.0,"scale":1.35,
  "noise":420.0,"noise_time":2.0,"noise_label":"RELAY BUOY",
  "summary":"Drones within 420 m reach 35% farther for 3 min. Chirp is audible."}
}
static func ids()->Array:return TOOLS.keys()
static func field_ids()->Array:
 return TOOLS.keys().filter(func(id):return TOOLS[id].owner=="field")
static func is_enabled(id:String)->bool:
 return enabled and TOOLS.has(id) and TOOLS[id].enabled
static func spec(id:String)->Dictionary:return TOOLS.get(id,{})
static func loadout_count(id:String,loadout:String)->int:
 if not TOOLS.has(id):return 0
 return int(TOOLS[id].counts.get(loadout,TOOLS[id].counts.endurance))
# Starting stock of the enabled new tools for a campaign loadout (existing tools are seeded by Simulation).
static func initial_counts(loadout:String)->Dictionary:
 var result={}
 for id in field_ids():
  if is_enabled(id):result[id]=loadout_count(id,loadout)
 return result
