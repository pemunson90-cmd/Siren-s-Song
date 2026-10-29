extends RefCounted
# BRANNOCK CREW presenter: adds crew text to the existing briefing and SUPPLIES columns (host._menu_text).
# Seams: CampaignFlow.briefing and EconomyPanel.show, one line each. Revert: crew_table.enabled=false.
const Crew=preload("res://src/campaign/crew/crew.gd")
const Table=preload("res://src/campaign/crew/crew_table.gd")
static func _facts(host)->Dictionary:
	var facts=host.expedition.get("facts",{}) if host.expedition is Dictionary else {}
	return facts if facts is Dictionary else {}
# Crew list plus any crew line aimed at this operation. Draws nothing when nobody was rescued.
static func briefing(host,op:int)->void:
	var facts=_facts(host)
	var roster=Crew.roster(facts)
	if roster.is_empty():return
	host._menu_text("%s / %s"%[Table.HEAD,", ".join(Crew.present(facts).map(func(r):return r.name))],14)
	for line in Crew.briefing_lines(facts,op):host._menu_text(line,16)
# Full roster with each group's effect, under the supplies report.
static func supplies(host)->void:
	var roster=Crew.roster(_facts(host))
	if roster.is_empty():return
	host._menu_text("%s\n%s\n%s"%[Table.HEAD,"\n".join(roster),Table.FOOTER],14)
