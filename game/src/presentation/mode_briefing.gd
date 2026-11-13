extends RefCounted
# WP-40 (audit B8): Naval Career and Expedition briefings use the Campaign's short
# format. A GOAL block and a DANGER block come from the same lines the Campaign
# briefing shows for that operation; the rules of the mode follow as at most four
# one-line bullets. Nothing here is story text and no save field is touched.
const Rows=preload("res://src/campaign/onboarding2/briefing_rows.gd")
const Opening=preload("res://src/campaign/onboarding_text.gd")
const GOAL_SIZE=20
const RULES_SIZE=17
const MAX_RULES=4
const GOAL_PREFIX="GOAL: "
const DANGER_PREFIX="\nDANGER: "
const RULES_TITLE="RULES OF THIS MODE"
# The operation's own goal and danger. The Campaign rows win where both exist, as
# they do in the Campaign briefing; an operation with neither keeps the caller's fallback goal.
static func goal_danger(op:int,fallback_goal:String)->Dictionary:
	if Rows.applies(op):return {"goal":Rows.ROWS[op][0],"danger":Rows.ROWS[op][1]}
	var text:String=Opening.goal(op)
	if text.begins_with(GOAL_PREFIX):
		var parts=text.trim_prefix(GOAL_PREFIX).split(DANGER_PREFIX)
		return {"goal":parts[0],"danger":parts[1] if parts.size()>1 else ""}
	return {"goal":fallback_goal,"danger":""}
static func rule_lines(rules:Array)->String:
	var lines=[RULES_TITLE]
	for rule in rules.slice(0,MAX_RULES):lines.append("- "+rule)
	return "\n".join(lines)
static func show(host,op:int,fallback_goal:String,rules:Array)->void:
	var rows=goal_danger(op,fallback_goal)
	host._menu_text("GOAL: "+rows.goal,GOAL_SIZE)
	if not rows.danger.is_empty():host._menu_text("DANGER: "+rows.danger,GOAL_SIZE)
	if not rules.is_empty():host._menu_text(rule_lines(rules),RULES_SIZE)
