extends RefCounted
# SAVE2 is optional. Revert enabled=false to hide capture/UI, retaining files.
# Recovery of an already-written transaction remains enabled for save safety.
static var enabled=true
# Ironman integrity: false restores the earlier behavior (restore and manual save available to Ironman).
# Module: save2_controller.gd locked(); revert by setting this to false.
static var ironman_lock=true
const MANUAL_COUNT=3
const FORK_COUNT=4
const FILE_LIMIT=4000000
const JOURNAL_LIMIT=13000000
const NAME_LIMIT=48
const COUNT_LIMIT=1000000
const STATE="save2_state"
const RECORD="save2_record"
const SUFFIXES=["",".bak",".tmp"]
const KINDS=["manual","fork","pending"]
const EVENTS={"route":"Before the first route","thread":"Before the recovered thread","confluence":"Before Confluence choice","first_ending":"Before the first ending","glass":"Before Glass Reach choice","choir_choice":"Before Iron Choir choice","choir_people":"Before the people recovery","choir_plant":"Before the plant choice"}
const TARGETS={6:["route"],9:["thread"],10:["thread"],11:["confluence"],12:["first_ending"],13:["first_ending"],18:["glass"],24:["choir_choice"],28:["choir_people"],29:["choir_plant"]}
const EXACT_WARNING="Loading replaces this campaign's later film, fittings and recovered operations. Later progress is not merged. Hard saves and fork states remain."
const IRONMAN_LINE="Ironman keeps one timeline. Hard saves, fork replay and profile copies cannot rewind it."
const PROFILE_NOTICE="These saves stay with this profile slot. Profile copy, import, export and clear affect the live campaign, not these saved states."
static func count(kind:String)->int:
 return {"manual":MANUAL_COUNT,"fork":FORK_COUNT,"pending":1}.get(kind,0)
static func identity()->String:
 return Crypto.new().generate_random_bytes(16).hex_encode()
