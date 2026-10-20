extends RefCounted
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Tutorial=preload("res://src/campaign/tutorial_missions.gd")
# Preserve the introductory briefing API; content lives in its authored factory.
const TITLES=Tutorial.TITLES
const BRIEFS=Tutorial.BRIEFS
const RECORDS=Tutorial.RECORDS
static func make(index:int,history:Dictionary={}) -> Dictionary:
 return Catalog.make(index,history)
