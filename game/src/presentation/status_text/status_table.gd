extends RefCounted
# Presentation copy only. Set enabled=false to restore the prior HUD wording.
static var enabled=true
const FALLBACK="No exact source located · listen from another position or spend local RECON"
const LINES={
 6:"SOURCE SEARCH · listen elsewhere or spend local RECON",
 9:"RETURN RECEIVER · listen elsewhere or spend local RECON",
 11:"CONFLUENCE SIGNALS · listen elsewhere or spend local RECON",
 22:"FREIGHT SLED · use CHOIR WORK at the berth and lane gates",
 24:"BALLAST · CHOIR WORK offers BYPASS or ISOLATE",
 27:"COUNTERWEIGHT · CHOIR WORK tracks its tow, lock and cradle",
 28:"OCCUPIED BELL · CHOIR WORK handles tow, locks and landing",
 29:"SECURITY FEED · CHOIR WORK offers LOCK C / RECONNECT or DISMANTLE"
}
const CHOIR_IDS=[22,24,27,28,29]
const RECOVERY_READY="RECOVERY READY · bring Quietus to an available corridor"
const CHOIR_NO_ACTION="CHOIR WORK · inspect known local job or recovery route"
const ARRIVALS_LABEL="ARRIVALS\n%d signals"
const ARRIVALS_LABEL_OLD="ARRIVALS\n%d"
const ARRIVALS_EMPTY="ARRIVALS: no signals received yet"
const ARRIVALS_RECEIVED="%d signals received; tap ARRIVALS to read"
