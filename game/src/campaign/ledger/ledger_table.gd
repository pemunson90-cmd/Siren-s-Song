extends RefCounted
# 078 campaign ledger data. Maps saved facts to short lines; rewrite text here only.
# AI-DESIGNED placeholder text, Pat to rewrite. No new plot: each line restates a saved fact.
# Revert: enabled=false restores the two-line END OF LINE and the previous ending screens.
static var enabled=true
const NOT_RECORDED="not recorded"
const UNKNOWN_VALUE="recorded as %s"
const MAX_VALUE_CHARS=24
const HEAD_SIZE=20
const LINE_SIZE=17
const FOOTER_SIZE=15
const FOOTER="AI-DESIGNED placeholder ledger, Pat to rewrite. Built only from recorded outcomes."
const PANELS=[["people","PEOPLE"],["knowledge","KNOWLEDGE"],["infrastructure","INFRASTRUCTURE"],["disclosure","DISCLOSURE"]]
# [panel, label, fact key, operation that makes the fact expected, thread ("" any), {value: line}]
# A row shows when its fact is recorded, or when its operation is done and the fact is missing.
const FACT_ROWS=[
 ["people","Kestrel sailors","witness_arrival",12,"",{"quietus":"landed alive by Quietus.","drone_a":"landed alive by Drone A.","drone_b":"landed alive by Drone B."}],
 ["people","Kestrel sailors","warning_arrival",13,"",{"exposed":"taken aboard a launch through the exposed channel.","sheltered":"taken aboard a launch through the sheltered passage."}],
 ["people","Port Ardent watch","concealed_consequence",12,"shelf",{"shelf_service":"six came out through the service approach.","shelf_baffle":"six came out through the baffled entrance."}],
 ["people","Tessaly divers","concealed_consequence",12,"deep",{"deep_trace_severed":"the bell began its lift after the trace was cut."}],
 ["people","Hollins last shift","choir_people",28,"",{"landed":"recovered workers were landed at the service berth."}],
 ["infrastructure","Port Ardent approach","concealed_consequence",12,"shelf",{"shelf_service":"service approach left open.","shelf_baffle":"north entrance baffled."}],
 ["infrastructure","Trench mouth","concealed_consequence",12,"deep",{"deep_trace_severed":"tracking float hauled off, surface trace broken."}],
 ["infrastructure","Varne fence","glass_choice",18,"",{"service":"service water opened, reporting spur kept.","sever":"reporting spur severed.","vane":"fence vanes released."}],
 ["infrastructure","Choir line","choir_choice",24,"",{"bypass":"line bypassed.","isolate":"line isolated."}],
 ["infrastructure","Choir plant","choir_plant",29,"",{"reconnect":"plant reconnected.","dismantle":"plant dismantled."}],
 ["disclosure","Confluence","confluence_route",11,"",{"concealed":"kept quiet, nothing broadcast.","overt":"called openly on a surface channel."}],
 ["disclosure","Witness","witness_arrival",12,"",{"quietus":"a rescue craft reached the lift point.","drone_a":"a rescue craft reached the lift point.","drone_b":"a rescue craft reached the lift point."}],
 ["disclosure","Recipient","warning_arrival",13,"",{"exposed":"a launch reached the pickup.","sheltered":"a launch reached the pickup."}]
]
# Counted knowledge rows: each prints only when its saved source exists and the count is positive.
const ARTIFACT_LINE="Artifacts recovered: %d of %d."
const PROJECT_LINE="Research completed: %d."
const INTEL_LINE="Photographed subjects with intel: %d."
const SIREN_LINE="Siren types photographed: %d."
