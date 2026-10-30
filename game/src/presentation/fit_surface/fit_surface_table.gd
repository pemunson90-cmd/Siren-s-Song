extends RefCounted
# Fit surface tunables. AI-DESIGNED (Pat tunes the order and wording).
# Mount sections in reading order. Items whose mount is empty or unknown fall under OTHER.
const MOUNT_ORDER=["SENSOR","HARDWARE","UTILITY","OPTICS","PROPULSION","CARGO"]
const OTHER="OTHER"
# Craft tab order (Catalog slot keys).
const TABS=["quietus","drone_a","drone_b"]
# Row sort: fitted first, then free to fit, then everything held back.
const STATE_ORDER={"fitted":0,"spare":1,"elsewhere":2,"refused":3,"left":4}
