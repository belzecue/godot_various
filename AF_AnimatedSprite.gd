"""
Subclass of AnimatedSprite
Permits setting individual frame flip_h values per animation.
In Inspector dictionary, enter a String key and PoolByteArray value for frame flip_h assignments.
To set flip_h for all frames of an animation, give the animation key just one array value
e.g. {"default":[1]}
"""

tool
class_name AF_AnimatedSprite extends AnimatedSprite


# Frames to flip horizontally
export(Dictionary) var hflipFrames: Dictionary
export(float, 0, 10) var zscale: float = 1


func _ready():
	connect("frame_changed", self, "flip_horizontal")


func flip_horizontal() -> void:
	var anim_name = animation
	if hflipFrames.has(anim_name): # Current animation is a key in hflip dictionary
		var frame_idx: int = frame
		if frame_idx < hflipFrames[anim_name].size(): # Current frame is in the value array
			flip_h = bool(hflipFrames[anim_name][frame_idx]) 
