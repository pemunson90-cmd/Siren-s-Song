extends RefCounted
# Numeric seeds fit Android's number keyboard and native paste menu. No clipboard
# access or physical keyboard required. Revert: remove this start-screen seam.
const State=preload("res://src/campaign/runs/run_state.gd")
const Records=preload("res://src/campaign/runs/run_records.gd")
const MAX_LENGTH=10
static func sanitize(text:String)->String:
	var out=""
	for character in text.left(MAX_LENGTH):
		if character>="0" and character<="9":out+=character
	return out
static func parse(text:String)->int:
	if text.is_empty() or text.length()>MAX_LENGTH or sanitize(text)!=text:return -1
	var number=text.to_int()
	return number if number<=State.Table.MAX_SEED else -1
static func show(front,seed_value:int,back:Callable,start:Callable)->void:
	front._reset("run_seed")
	front._button("BACK",back,"frontend_back")
	front._text("EXPEDITION SEED",30)
	front._text("Type or paste a number from 0 to 2147483647. The same seed keeps the same starting operations and modifiers.",17)
	var edit=LineEdit.new();edit.name="ExpeditionSeed";edit.max_length=MAX_LENGTH
	edit.virtual_keyboard_type=LineEdit.KEYBOARD_TYPE_NUMBER
	edit.custom_minimum_size=Vector2(0,front.touch_height());edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	edit.add_theme_font_size_override("font_size",roundi(20*front.FrontendSettings.text_scale()))
	edit.text=str(seed_value);front.column.add_child(edit)
	var preview=front._text("",17)
	var begin=front._button("START THIS SEED",func():
		var chosen=parse(edit.text)
		if chosen>=0:start.call(chosen)
	,"run_seed_start")
	var refresh=func(text:String):
		var cleaned=sanitize(text)
		if edit.text!=cleaned:
			var caret=edit.caret_column;edit.text=cleaned;edit.caret_column=mini(caret,cleaned.length())
		var chosen=parse(cleaned);begin.disabled=chosen<0
		preview.text="Enter a seed in range." if chosen<0 else Records.modifiers(State.new_run(chosen))
	edit.text_changed.connect(refresh)
	front._button("RANDOM SEED",func():
		edit.text=str(randi_range(0,State.Table.MAX_SEED));refresh.call(edit.text)
	,"run_seed_random")
	refresh.call(edit.text)
