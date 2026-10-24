extends RefCounted
# Death cause line settings. Revert: set enabled=false, or remove the two debrief calls and this folder.
# AI-DESIGNED wording, Pat to adjust. Story text stays 1 to 2 line placeholders.
static var enabled=true
const WINDOW=20.0          # seconds of own-craft emissions kept (ring buffer span)
const CAP=48               # hard entry cap for the ring buffer
const MOTION_RADIUS=250.0  # existing motion_radius() at or above this counts as moving at speed (cruise is 430)
const MOTION_MERGE=1.0     # motion samples closer than this collapse into one entry
const LOCKISH=["LOCKING","BEAM"]
# Emission label -> phrase used after "It was drawn by: ". Labels come from NoticeSources.CRAFT_EMISSIONS.
const EMISSION_PHRASE={"ACTIVE SONAR":"ACTIVE SONAR","CAMERA":"the CAMERA shutter","DISRUPTION":"a DISRUPTION pulse","KNOCKDOWN":"a KNOCKDOWN pulse","RECON UPLINK":"the RECON UPLINK"}
const DRAWN="It was drawn by: %s %d s before the lock."
const MOVING="It heard %s moving at speed."
const SIGHT="%s was in the Siren's sight line."
