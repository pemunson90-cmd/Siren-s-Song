extends RefCounted
# A11Y1 presentation only. Revert: disable the two optional settings and remove
# the Soundscape observer / main caption seams. No campaign or simulation fields.
const ENABLED=true
const SECONDS=3.5
const MAX_ROWS=2
const HISTORY_ROWS=8
const PULSE_MS=45
const LAYOUT={"widths":[7.,5.,4.],"gap":8.,"edge":16.,"top":24.,"font_touch":.26,"font_min":17}
# Okabe/Ito Color Universal Design: blue / orange / yellow / sky blue.
# Source and perception limits are recorded in docs/A11Y_CUES.md.
const SAFE={"reach":Color("56b4e9"),"flash":Color("f0e442"),"warning":Color("e69f00"),"heard":Color("0072b2"),"ink":Color("ffffff")}
const PATTERNS={"flash":[1,4],"warning":[3,6],"heard":[1,8]}
const TEXT={"carrier_received":"HEARD: carrier signal","return_received":"HEARD: return signal","sweep_received":"HEARD: sweeper warning","camera":"Shutter released","ping":"Acoustic pulse","emp":"DISRUPT released","knock":"Torpedo launched","decoy":"Decoy released","recon":"Survey released","loss":"Craft lost","extraction":"Recovery confirmed","plant_control":"Machinery switched","berth_release":"Berth released","record":"Record secured","salvage":"Salvage secured","snare":"Snare impact","film_low":"FILM LOW","film_empty":"FILM EMPTY","develop":"Plate developed","engine_down":"ALL STOP: engines off","pressure_deep":"Pressure: descending","pressure_shallow":"Pressure: ascending","lock":"LOCK WARNING","factory":"HEARD: machinery pulse","hull_light":"Hull strain: light","hull_medium":"Hull strain: moderate","hull_heavy":"Hull strain: severe","survivor_aboard":"Survivor aboard","survivor_landed":"Survivor landed","cargo_handoff":"Cargo handed over","artifact_secured":"Artifact secured","research_complete":"Research complete","sonobuoy":"Sonobuoy set","silt_screen":"Silt screen released","hull_patch":"Hull patch applied","relay_buoy":"Relay buoy set"}
