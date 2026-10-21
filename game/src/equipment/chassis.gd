extends RefCounted
# Drone chassis frames; each active drone flies one. "standard" is today's drone
# exactly. reach multiplies ordinary passive and chart reach; the other budgets
# match hulls.gd (power, noise, endurance, cargo, pulse).
const DEFAULT="standard"
const CHASSIS={
 "standard":{"id":"standard","name":"Standard drone","mounts":["SENSOR","UTILITY","CARGO","HARDWARE"],"power":2,"noise":1.0,"endurance":1.0,"cargo":2,"reach":1.0,"pulse":1.0,"summary":"Baseline drone. Four typed mounts on a two point power bus."},
 "scout":{"id":"scout","name":"Scout drone","mounts":["SENSOR","HARDWARE"],"power":2,"noise":0.7,"endurance":0.7,"cargo":0,"reach":1.25,"pulse":1.0,"summary":"Passive reach 25% longer and motion sound 30% lower. Battery 30% shorter and no winch cargo."},
 "heavy":{"id":"heavy","name":"Heavy drone","mounts":["CARGO","UTILITY","HARDWARE"],"power":3,"noise":1.35,"endurance":1.1,"cargo":4,"reach":0.8,"pulse":1.0,"summary":"Four cargo places and a three point power bus. Motion sound 35% higher, passive reach 20% shorter, no sensor mount."},
 "endurance":{"id":"endurance","name":"Long endurance drone","mounts":["SENSOR","HARDWARE"],"power":1,"noise":0.9,"endurance":1.6,"cargo":1,"reach":0.9,"pulse":1.0,"summary":"Battery 60% longer and slightly quieter. One point power bus, one cargo place, passive reach 10% shorter."}
}
