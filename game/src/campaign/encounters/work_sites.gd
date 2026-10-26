extends RefCounted
# Reusable Reach task pieces. Each returns a mission dictionary fragment; the
# simulation half lives in glass_reach_work.gd (apply_effect, cargo custody).
# Three different crew tasks share the craft's camera control; keep them apart:
#   listen   passive hydrophone reception of an account (no image is made)
#   photo    an optical exposure of a real subject (viewpoint, light, framing)
#   machine  physical work on local machinery (REACH WORK)
# Quietus-only passive account reception (LISTEN in settled MIDDLE).
static func listen(key:String,name:String,pos:Vector2,evidence:String,duration:float=4.)->Dictionary:
 return {"pos":pos,"name":name,"site_id":key,"captured":false,"kind":"receiver","required_unit":0,"duration":duration,"optical":key,"evidence":evidence}
# Optical task: the exposure frames `subject` (see photo_capture.gd for fields).
static func photo(key:String,name:String,pos:Vector2,evidence:String,subject:Dictionary,duration:float=4.,optional:bool=false)->Dictionary:
 var o={"pos":pos,"name":name,"site_id":key,"captured":false,"kind":"","duration":duration,"optical":key,"evidence":evidence,"subject":subject}
 if optional:o.optional=true
 return o
# Local machinery any craft can operate inside240m clear view. It
# is audible while worked and its completion physically changes the water:
#  open: Rect2 structures removed; quiet: network listeners within this radius
#  go deaf for quiet_time; calm: authored currents stop; noise: completion sound.
static func machine(key:String,name:String,pos:Vector2,effect:Dictionary,optional:bool=false,duration:float=8.)->Dictionary:
 var o={"pos":pos,"name":name,"site_id":key,"captured":false,"duration":duration,"glass_effect":effect}
 if optional:o.optional=true
 return o
static func sluice(shape:Rect2,label:String="REACH MACHINERY",radius:float=900.)->Dictionary:
 return {"open":[shape],"noise":{"radius":radius,"label":label,"duration":6.}}
# Physical cargo that must ride a living craft to a settled MIDDLE recovery mouth.
static func cargo(id:String,pos:Vector2,band:int=1)->Dictionary:
 return {"id":id,"pos":pos,"band":band,"state":"site","carrier":-1}
