extends RefCounted
# WP-40 (audit B13): Career and Expedition results say what changed, in words.
# Every number shown is read from the saved career report or run record; a row
# whose value is zero or unchanged is left out, and a result with no change says so.
const NOTHING="Nothing lost, nothing gained."
const NONE_WORD="NONE"
const Records=preload("res://src/campaign/runs/run_records.gd")
static var _career_head=RegEx.create_from_string("^(.+) · (RECOVERED|LOST)$")
static var _career_standing=RegEx.create_from_string("^STANDING \\+?(-?\\d+) → (-?\\d+) · CONTRACT PAY (.+)$")
static var _career_salvage=RegEx.create_from_string("^SALVAGE RECOVERED · (.+)$")
static var _career_rider=RegEx.create_from_string("^RIDER (PASSED|FAILED) · BONUS (.+)$")
static func plus_list(text:String)->String:
	return ", ".join(Array(text.to_lower().split(" + ")))
# The saved Career report as short lines. A report written before any dive
# (or any line this does not know) passes through untouched.
static func career_lines(report:String)->Array:
	var rows=report.split("\n")
	var head=_career_head.search(rows[0])
	if head==null:return Array(rows)
	var won=head.get_string(2)=="RECOVERED"
	var out=["%s: contract %s."%[head.get_string(1).capitalize(),"recovered" if won else "lost"]]
	var changes:Array=[]
	for row in rows.slice(1):
		var standing=_career_standing.search(row)
		var salvage=_career_salvage.search(row)
		var rider=_career_rider.search(row)
		if standing!=null:
			var before=int(standing.get_string(1));var after=int(standing.get_string(2))
			if after!=before:changes.append("Standing %s %d, now %d."%["up" if after>before else "down",absi(after-before),after])
			if standing.get_string(3)!=NONE_WORD:changes.append("Contract pay: %s."%plus_list(standing.get_string(3)))
		elif salvage!=null:
			if salvage.get_string(1)!=NONE_WORD:changes.append("Salvage: %s."%plus_list(salvage.get_string(1)))
		elif rider!=null:
			if rider.get_string(1)=="PASSED":changes.append("Rider passed. Bonus: %s."%plus_list(rider.get_string(2)))
			else:changes.append("Rider failed. No bonus.")
		elif not row.begins_with("LAST DIVE"):changes.append(row)
	out.append_array(changes if not changes.is_empty() else [NOTHING])
	return out
# What a Career dive earned, as one phrase, from the same report lines career_lines reads: contract pay, salvage and a rider bonus.
static func career_earned(report:String)->String:
	var parts:Array=[]
	for row in report.split("\n"):
		var standing=_career_standing.search(row)
		var salvage=_career_salvage.search(row)
		var rider=_career_rider.search(row)
		if standing!=null and standing.get_string(3)!=NONE_WORD:parts.append("contract pay %s"%plus_list(standing.get_string(3)))
		elif salvage!=null and salvage.get_string(1)!=NONE_WORD:parts.append("salvage %s"%plus_list(salvage.get_string(1)))
		elif rider!=null and rider.get_string(1)=="PASSED":parts.append("rider bonus %s"%plus_list(rider.get_string(2)))
	return ", ".join(parts) if not parts.is_empty() else "nothing"
# Tools used and gained over a run, one line per tool that moved.
static func tool_change(name:String,spent:int,gained:int)->String:
	var parts:Array=[]
	if spent!=0:parts.append("used %d"%spent)
	if gained!=0:parts.append("gained %d"%gained)
	return "%s: %s"%[name,", ".join(parts)] if not parts.is_empty() else ""
# The grade and percentage come from the run records rule, so the letter is decided in one place.
static func photo_word(quality:float)->String:
	if quality<0.:return "no photo"
	var parts=Records.photo_text(quality).split(" / ")
	return "photo %s (%s)"%[parts[0],parts[1]]
