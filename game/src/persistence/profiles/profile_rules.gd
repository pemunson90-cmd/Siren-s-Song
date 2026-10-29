extends RefCounted
# SAVE1 off switch. Revert: disable ENABLED, remove frontend registration and
# SaveStore resolver. Retain user://profiles and exports. Legacy originals stay
# at user://quietus.save; copy the desired slot sidecars there to keep progress.
# SAVE2 sidecars stay pinned to their original slots; retain them and transaction
# recovery. Copying slot sidecars does not migrate/merge manual or fork states.
const ENABLED = true
# Ironman guard: false restores copy/import/export of Ironman campaigns (a rewind path).
const IRONMAN_GUARD = true
const COUNT = 3
const NAME_LIMIT = 24
const FILE_LIMIT = 4000000
const PACKAGE_LIMIT = 32002000
const UNDO_SECONDS = 30
const INDEX_LIMIT = 4096
const VARIANT_DEPTH_LIMIT = 64
const VARIANT_ITEM_LIMIT = 1000000
const SUFFIXES = ["", ".bak", ".challenges", ".challenges.bak", ".runs", ".runs.bak", ".career", ".career.bak"]
const MAGIC = "QUIETUS_PROFILES"
const VERSION = 1
