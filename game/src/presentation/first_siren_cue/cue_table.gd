extends RefCounted
# D1 presentation settings. Revert by setting enabled=false or reverting this PR.
static var enabled=true
const OPERATIONS=[0,1,2,3]
# One-time type note: shown the first time a Siren kind appears in a notice, on any operation.
# Keys are the sim's existing `type` strings; an absent type shows nothing.
const TYPE_NAMES={"patroller":"PATROLLER","sweeper":"SWEEPER","hunter":"HUNTER","sentinel":"SENTINEL","warden":"WARDEN","interceptor":"INTERCEPTOR","buoy":"BUOY","relay":"RELAY"}
const NOTE_PREFIX="NEW SIREN TYPE: "
const NOTE_DURATION=2.5
const NOTE_LIMIT=16
# Existing emissions at an own craft. Remote decoys, projectiles and machinery
# are not a notice of the craft itself; they must not consume its warning.
const CRAFT_EMISSIONS=["ACTIVE SONAR","CAMERA","DISRUPTION","KNOCKDOWN","RECON UPLINK"]
const DURATION=2.5
const AUDIO={"id":"alert","gain_db":-18.,"pitch":.65,"seconds":.18}
const LAYOUT={"width_touch":4.4,"height_touch":.9,"top_touch":3.,"gap":16.,"font_touch":.25,"font_min":18}
