extends PanelContainer
# Touch-first scrolling developer panel. All interactive rows use the host's 48dp metric.
const HELP="jump 0..41 | preset deep/shelf concealed/overt none/concealed/overt found/absent\nfact KEY VALUE | clear KEY | complete OP | grant ID [COUNT] | unlock\noverlay sight/hearing/patrol/hunt/locks/noise/endurance/cargo/chart\ntime 0.25..4 | step | invulnerable | oxygen | end | export | help\nProfile/run changes permanently mark DEV. Setup commands apply between dives."
var console
var output:Label
var entry:LineEdit
var body:VBoxContainer
var thread="deep"
var channel="concealed"
var votes="none"
var sorley="absent"
var op=0
func _ready()->void:mouse_filter=Control.MOUSE_FILTER_STOP
func _process(_dt)->void:
 var extent=console.host.size
 position=Vector2(12,12);size=extent-Vector2(24,24)
func button(text:String,callback:Callable,id:String="")->Button:
 var b=Button.new();b.text=text;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 b.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);b.set_meta("ui_action","dev_"+id);body.add_child(b);b.pressed.connect(callback,CONNECT_DEFERRED);return b
func run(command:String)->void:
 output.text=console.execute(command)
func rebuild()->void:
 for child in get_children():remove_child(child);child.queue_free()
 var scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
 body=VBoxContainer.new();body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(body)
 button("CLOSE DEVELOPER CONSOLE",func():hide(),"close")
 output=Label.new();output.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;output.text=HELP;body.add_child(output)
 entry=LineEdit.new();entry.placeholder_text="Command (desktop history: Up / Down)";entry.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(entry)
 entry.text_submitted.connect(func(line):run(line);entry.clear())
 entry.gui_input.connect(func(event):
  if event is InputEventKey and event.pressed and event.keycode in [KEY_UP,KEY_DOWN] and not console.history.is_empty():
   console.history_index=clampi(console.history_index+(-1 if event.keycode==KEY_UP else 1),0,console.history.size())
   entry.text=console.history[console.history_index] if console.history_index<console.history.size() else "";entry.caret_column=entry.text.length();accept_event())
 button("RUN COMMAND",func():run(entry.text);entry.clear(),"command")
 var picker=OptionButton.new();picker.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(picker)
 for id in console.Catalog.registered_ids():picker.add_item("%02d  %s"%[id,console.Catalog.make(id).get("title",str(id))],id)
 picker.select(op);picker.item_selected.connect(func(index):op=picker.get_item_id(index))
 button("THREAD: "+thread.to_upper(),func():thread="shelf" if thread=="deep" else "deep";rebuild(),"thread")
 button("CONFLUENCE: "+channel.to_upper(),func():channel="overt" if channel=="concealed" else "concealed";rebuild(),"channel")
 button("LATE VOTES: "+votes.to_upper(),func():votes={"none":"concealed","concealed":"overt","overt":"none"}[votes];rebuild(),"votes")
 button("SORLEY: "+sorley.to_upper(),func():sorley="found" if sorley=="absent" else "absent";rebuild(),"sorley")
 button("END DEV DIVE / RETURN TO SETUP",func():run("end"),"end")
 button("APPLY HISTORY PRESET",func():run("preset %s %s %s %s"%[thread,channel,votes,sorley]),"preset")
 button("LAUNCH SELECTED OPERATION",func():run("jump "+str(op)),"jump")
 button("MARK SELECTED OP COMPLETE",func():run("complete "+str(op)),"complete")
 # Touch selectors retain a keyboard-free path to every fact and grant command.
 var facts=OptionButton.new();facts.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(facts)
 for key in console.Catalog.fact_keys():facts.add_item(key)
 var value=LineEdit.new();value.placeholder_text="Fact value";value.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(value)
 button("SET SELECTED FACT",func():run("fact "+facts.get_item_text(facts.selected)+" "+value.text),"fact")
 button("CLEAR SELECTED FACT",func():run("clear "+facts.get_item_text(facts.selected)),"clear")
 var grants=OptionButton.new();grants.custom_minimum_size.y=maxf(48,console.host.ui_touch_height);body.add_child(grants)
 var ids=console.State.Equipment.ITEMS.keys()+console.host.economy.stock.keys()+preload("res://src/campaign/economy_table.gd").UNLOCK_PRICE.keys()+console.Tools.ids()
 for id in ids:grants.add_item(id)
 button("GRANT SELECTED (ONE)",func():run("grant "+grants.get_item_text(grants.selected)),"grant")
 button("UNLOCK ALL HARDWARE",func():run("unlock"),"unlock")
 for layer in console.Overlay.LAYERS:
  var key=layer
  button("OVERLAY "+key.to_upper(),func():run("overlay "+key),"overlay_"+key)
 for scale in [.25,.5,1.,2.,4.]:
  var rate=scale;button("TIME %.2fx"%rate,func():run("time "+str(rate)),"time_"+str(rate))
 for item in [["ONE PAUSED TICK","step"],["TOGGLE INVULNERABLE","invulnerable"],["REFILL OXYGEN","oxygen"],["EXPORT RUN LOG","export"]]:
  var command=item[1];button(item[0],func():run(command),command)
