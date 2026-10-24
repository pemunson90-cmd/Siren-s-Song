extends RefCounted
# SAVE1 off switch. Revert: disable ENABLED, remove frontend registration and
# SaveStore resolver. Retain user://profiles and exports. Legacy originals stay
# at user://quietus.save; copy the desired four slot files there to keep progress.
const ENABLED = true
const COUNT = 3
const NAME_LIMIT = 24
const FILE_LIMIT = 4000000
const PACKAGE_LIMIT = 16002000
const UNDO_SECONDS = 30
const SUFFIXES = ["", ".bak", ".challenges", ".challenges.bak"]
const MAGIC = "QUIETUS_PROFILES"
const VERSION = 1
