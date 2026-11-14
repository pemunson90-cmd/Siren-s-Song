extends RefCounted
# A fitting drawn as a card (UI review C7): name, one plain line about what it changes, extra lines, a CHOSEN
# mark on the selected one and a lock line on one that cannot be taken yet. The card is a Button made by
# Main._button, so taps, action ids, touch height and scrolling behave exactly as the old rows did.
const UiStyle=preload("res://src/presentation/ui_style.gd")
const CHOSEN="CHOSEN"
const LOCKED="LOCKED"
# spec: name, line, chosen (bool), lock (text, empty when not locked), extra (Array of lines).
static func text_of(spec:Dictionary)->String:
	var lines=[("%s · %s"%[CHOSEN,spec.name]) if spec.get("chosen",false) else str(spec.name)]
	if not str(spec.get("line","")).is_empty():lines.append(spec.line)
	for extra in spec.get("extra",[]):
		if not str(extra).is_empty():lines.append(extra)
	if not str(spec.get("lock","")).is_empty():lines.append("%s · %s"%[LOCKED,spec.lock])
	return "\n".join(lines)
static func add(main,spec:Dictionary,action:Callable,action_id:String)->Button:
	var button:Button=main._button(main.panel_box,text_of(spec),action,action_id)
	UiStyle.apply_card(button,spec.get("chosen",false),not str(spec.get("lock","")).is_empty())
	return button
