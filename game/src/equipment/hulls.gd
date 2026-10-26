extends RefCounted
# Quietus hull frames. "standard" is the baseline craft every operation was
# authored and solved with: its multipliers are exactly 1 and its cargo matches
# the existing winch carriage, so a bare standard launch plays as before.
# power: hardware draw capacity; noise: motion sound multiplier; endurance:
# life-support multiplier; cargo: winched module capacity; speed: drive speed
# multiplier; pulse: SONAR reserve cost multiplier.
const MOUNT_TYPES=["SENSOR","PROPULSION","UTILITY","CARGO","HARDWARE","OPTICS"]
const DEFAULT="standard"
const HULLS={
 "standard":{"id":"standard","name":"Standard hull","mounts":["SENSOR","PROPULSION","UTILITY","HARDWARE","OPTICS"],"power":3,"noise":1.0,"endurance":1.0,"cargo":2,"speed":1.0,"pulse":1.0,"summary":"Baseline Quietus. Five typed mounts including a camera mount, on a modest power bus."},
 "quiet":{"id":"quiet","name":"Low noise hull","mounts":["SENSOR","UTILITY","HARDWARE","OPTICS"],"power":2,"noise":0.7,"endurance":1.2,"cargo":1,"speed":0.85,"pulse":1.25,"summary":"Motion sound 30% lower and life support 20% longer. 15% slower, no propulsion mount, small power bus, one cargo place, SONAR pulses cost 25% more."},
 "fast":{"id":"fast","name":"Fast transit hull","mounts":["SENSOR","SENSOR","PROPULSION","UTILITY","HARDWARE","OPTICS"],"power":5,"noise":1.3,"endurance":0.85,"cargo":3,"speed":1.15,"pulse":0.75,"summary":"15% faster with five mounts, a large power bus, three cargo places and SONAR pulses 25% cheaper. Motion sound 30% higher and life support 15% shorter."}
}
