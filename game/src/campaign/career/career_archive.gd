extends "res://src/persistence/save_store.gd"
# Independent checked atomic sidecar, pinned to the physical profile store.
# Valid interrupted dives resume paused; legacy snapshots retain loss recovery.
# Revert: remove the frontend seam; campaign saves never contain this ledger.
const Active=preload("res://src/campaign/mode_active.gd")
const Shared=preload("res://src/campaign/mode_archive.gd")
const State=preload("res://src/campaign/career/career_state.gd")
func valid(data:Dictionary)->bool:
	return data.get("version") is int and data.version==1 and data.has("career") and State.valid(data.career) and not data.career.is_empty()
const CFG={"mode":"career","key":"career","suffix":"career","script":"res://src/campaign/career/career_archive.gd","state":State,
	"unavailable":"Profile storage is unavailable. Career archive retained.",
	"locked":"Career archive is unreadable. Original files retained; select another profile to start a career.",
	"notice_snapshot":"Could not restore, run kept at last checkpoint. The interrupted dive is recorded as a loss; choose another contract.",
	"notice_legacy":"Legacy interrupted dive has no snapshot. A loss was recorded; choose another contract."}
static func restore(host)->Dictionary:return Shared.restore(CFG,host)
static func persist(host,state:Dictionary,envelope:Dictionary={})->bool:return Shared.persist(CFG,host,state,envelope)
