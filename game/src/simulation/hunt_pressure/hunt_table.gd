extends RefCounted
const Names=preload("res://src/names.gd")
# 050 sight-only global pressure. Revert enabled=false; retain validators and tests.
# Hearing, movement, lock, damage, goals and reports never consume this table.
static var enabled=true
const REVISION=1
const THRESHOLDS=[20.,45.,70.,90.]
const STAGES=Names.HUNT_STAGES
const SCALES=[1.,1.15,1.3,1.5,1.7]
const CAPS=[1.,1.,1.,1.15,1.15,1.15,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.7,1.7,1.7,1.7,1.7,1.7,1.7,1.7,1.,1.,1.7,1.7,1.7,1.7,1.7,1.5,1.3,1.3,1.3,1.3]
# Sorley41 shares the 1.30 cap of the neighbouring optional range operations38..40.
# Final pair30/31 deliberately retain1.00 pending their distinct balance evidence.
# CAPS is indexed by operation ID; operation_meta.gd hunt_cap(id) is the bounds-safe lookup (1.0 past the end).
const ROLES=["",Names.ROLE_PATROLLER,Names.ROLE_SENTINEL,Names.ROLE_HUNTER,Names.ROLE_SWEEPER]
const ACTIONS={Names.NOISE_ACTIVE_SONAR:5.,Names.NOISE_EMP:4.,Names.NOISE_KNOCKDOWN:4.,Names.NOISE_DECOY:0.,Names.NOISE_RECON_UPLINK:0.}
const SIGHT_EDGE=6.
const CUE_INTERVAL=3.
const AMBIENCE_DB=[0.,1.6,2.9,4.1,5.1]
const EARLY_AMBIENCE_CAP=3.
const CUE_SOURCE="develop"
const CAUSES={"FACTORY":"factory sensors","LAUNCH":"operation start",Names.NOISE_ACTIVE_SONAR:"active sonar",Names.NOISE_EMP:"EMP",Names.NOISE_KNOCKDOWN:"knockdown","EXPOSURE":"photographic exposure","UNUSABLE EXPOSURE":"unusable exposure","SECURED RECORD":"secured record","NEW SIGHT":"new visual detection","ACTIVITY":"own activity","TIME":"elapsed time","COOLING":"quiet cooling"}
