extends RefCounted
# [AI-DESIGNED] A6 (code audit, Pat approved 2026-11-12): the one home for names
# that many files share. A name written as text in fifty files breaks silently
# when one copy is misspelled or renamed; a constant from this file fails to
# compile instead.
#
# Rules for this file:
# - It preloads nothing, so every other file may preload it.
# - It holds identifiers and their fixed orders only. Numbers, tuning and
#   behavior stay with their owners (enemy_types.gd, field_tools.gd, ...).
# - The text of every value is what saves, tests and tables already use.
#   Changing a value here changes a save format: do not, without a migration.
# - What the player reads comes from the display tables (LABELS below or the
#   owner's own table), never from an identifier in capitals.
#
# How to add a name: add the constant, add it to its list, then use the
# constant everywhere. game/tests/names_registry_tests.gd fails when a listed
# name is written as text outside this file and the allowed data files.

# Siren roles (unit "type"). Order is the save checker's order.
const ROLE_PATROLLER="patroller"
const ROLE_SENTINEL="sentinel"
const ROLE_HUNTER="hunter"
const ROLE_SWEEPER="sweeper"
const ROLE_BUOY="buoy"
const ROLE_RELAY="relay"
const ROLE_INTERCEPTOR="interceptor"
const ROLE_WARDEN="warden"
const ROLES=[ROLE_PATROLLER,ROLE_SENTINEL,ROLE_HUNTER,ROLE_SWEEPER,ROLE_BUOY,ROLE_RELAY,ROLE_INTERCEPTOR,ROLE_WARDEN]

# Player craft. Index in every list is the unit index in Simulation.units.
const CRAFT_QUIETUS="quietus"
const CRAFT_DRONE_A="drone_a"
const CRAFT_DRONE_B="drone_b"
const CRAFT_IDS=[CRAFT_QUIETUS,CRAFT_DRONE_A,CRAFT_DRONE_B]
const UNIT_QUIETUS="QUIETUS"
const UNIT_DRONE_A="DRONE A"
const UNIT_DRONE_B="DRONE B"
const UNIT_NAMES=[UNIT_QUIETUS,UNIT_DRONE_A,UNIT_DRONE_B]
const UNIT_LETTERS=["Q","A","B"]

# Campaign loadouts. LOADOUTS is the order of equipment/field_tools.gd;
# campaign/runs/run_table.gd keeps its own order because seeded Expedition
# selection indexes into it.
const LOADOUT_ENDURANCE="endurance"
const LOADOUT_EMP="disruption" # id kept for saves; the player reads EMP
const LOADOUT_SURVEY="survey"
const LOADOUTS=[LOADOUT_ENDURANCE,LOADOUT_EMP,LOADOUT_SURVEY]

# Noise labels a craft or a tool emits (the "label" of an entry in
# Simulation.noises). Hunt pressure, hearing and the death-cause text key on them.
const NOISE_ACTIVE_SONAR="ACTIVE SONAR"
const NOISE_CAMERA="CAMERA"
const NOISE_EMP="DISRUPTION" # label kept for saves; the player reads EMP
const NOISE_KNOCKDOWN="KNOCKDOWN"
const NOISE_TORPEDO_RUN="TORPEDO RUN"
const NOISE_DECOY="DECOY"
const NOISE_RECON_UPLINK="RECON UPLINK"
const NOISE_RECOVERY_WINCH="RECOVERY WINCH"
const CRAFT_NOISES=[NOISE_ACTIVE_SONAR,NOISE_CAMERA,NOISE_EMP,NOISE_KNOCKDOWN,NOISE_RECON_UPLINK]
# Noise labels Siren works emit.
const NOISE_BUOY_REPORT_WINDUP="BUOY REPORT WINDUP"
const NOISE_RELAY_FORWARD="RELAY FORWARD"
const NOISE_INTERCEPTOR_WINDUP="INTERCEPTOR WINDUP"
const NOISE_WARDEN_CHARGE="WARDEN CHARGE"
const NOISE_WARDEN_PRESSURE="WARDEN PRESSURE"
const SIREN_NOISES=[NOISE_BUOY_REPORT_WINDUP,NOISE_RELAY_FORWARD,NOISE_INTERCEPTOR_WINDUP,NOISE_WARDEN_CHARGE,NOISE_WARDEN_PRESSURE]

# Depth bands, by band index.
const BAND_SHALLOW="SHALLOW"
const BAND_MIDDLE="MIDDLE"
const BAND_DEEP="DEEP"
const BANDS=[BAND_SHALLOW,BAND_MIDDLE,BAND_DEEP]

# Hunt stages, by stage index.
const HUNT_STAGES=["DORMANT","STIRRING","SEARCHING","HUNTING","LOCKDOWN"]

static func is_role(value)->bool:return value is String and value in ROLES
static func unit_name(index:int)->String:return UNIT_NAMES[index] if index>=0 and index<UNIT_NAMES.size() else ""
static func craft_id(index:int)->String:return CRAFT_IDS[index] if index>=0 and index<CRAFT_IDS.size() else ""
