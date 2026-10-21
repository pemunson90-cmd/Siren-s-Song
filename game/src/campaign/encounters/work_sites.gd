extends RefCounted
# Reusable Reach task pieces. Each returns a mission dictionary fragment; the
# simulation half lives in glass_reach_work.gd (apply_effect, cargo custody).
# Quietus-only passive account reception (CAMERA / LISTEN in settled MIDDLE).
static func listen(key:String,name:String,pos:Vector2,evidence:String,duration:float=4.)->Dictionary:
 return {"pos":pos,"name":name,"site_id":key,"captured":false,"kind":"receiver","required_unit":0,"duration":duration,"optical":key,"evidence":evidence}
# Local machinery any craft can operate with CAMERA inside240m clear view. It
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
