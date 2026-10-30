extends RefCounted
# 050 sight-only global pressure. Revert enabled=false; retain validators and tests.
# Hearing, movement, lock, damage, goals and reports never consume this table.
static var enabled=true
const REVISION=1
const THRESHOLDS=[20.,45.,70.,90.]
const STAGES=["DORMANT","STIRRING","SEARCHING","HUNTING","LOCKDOWN"]
const SCALES=[1.,1.15,1.3,1.5,1.7]
const CAPS=[1.,1.,1.,1.15,1.15,1.15,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.7,1.7,1.7,1.7,1.7,1.7,1.7,1.7,1.,1.,1.7,1.7,1.7,1.7,1.7,1.5,1.3,1.3,1.3,1.3]
# Sorley41 shares the 1.30 cap of the neighbouring optional range operations38..40.
# Final pair30/31 deliberately retain1.00 pending their distinct balance evidence.
const ROLES=["","patroller","sentinel","hunter","sweeper"]
const ACTIONS={"ACTIVE SONAR":5.,"DISRUPTION":4.,"KNOCKDOWN":4.,"DECOY":0.,"RECON UPLINK":0.}
const SIGHT_EDGE=6.
const CUE_INTERVAL=3.
const AMBIENCE_DB=[0.,1.6,2.9,4.1,5.1]
const EARLY_AMBIENCE_CAP=3.
const CUE_SOURCE="develop"
const CAUSES={"LAUNCH":"operation start","ACTIVE SONAR":"active sonar","DISRUPTION":"Disrupt","KNOCKDOWN":"knockdown","EXPOSURE":"photographic exposure","UNUSABLE EXPOSURE":"unusable exposure","SECURED RECORD":"secured record","NEW SIGHT":"new visual detection","ACTIVITY":"own activity","TIME":"elapsed time","COOLING":"quiet cooling"}
