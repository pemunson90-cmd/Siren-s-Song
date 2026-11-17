extends RefCounted
# WP-103: two lines the status strip carries while they are true, so a dive never silently eats time (critics 14 Nov):
#   - a craft with a route that holds in place says why and which control lets it go on (no_progress.gd names the
#     hold; hud_words.gd holds the words);
#   - Quietus in a recovery area that cannot be recovered there yet says what is missing (extraction_hint.gd).
# Both read the dive only. An urgent display (a threat, a lock card) hides them without consuming them, as it does the
# route-finished line.
const Words=preload("res://src/presentation/hud_words.gd")
const NoProgress=preload("res://src/presentation/no_progress.gd")
const ExtractionHint=preload("res://src/presentation/extraction_hint.gd")
static func lines(sim,urgent:bool)->Array:
	if urgent or not sim.outcome.is_empty():return []
	var result:Array=[]
	# The selected craft first; the strip holds two lines, so the first note found for each craft is enough.
	var order:Array=[sim.selected]
	for i in sim.units.size():
		if i!=sim.selected:order.append(i)
	for id in order:
		var hold:String=NoProgress.holding(sim,id)
		if not hold.is_empty():
			result.append(Words.TEXT["hold_"+hold]%str(sim.units[id].name).to_upper());break
	var extraction:String=ExtractionHint.line(sim)
	if not extraction.is_empty():result.append(extraction)
	return result
