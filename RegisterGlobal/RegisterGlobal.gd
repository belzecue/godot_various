tool # to generate default random global_name on adding to tree
class_name RegisterGlobal, "register_global.png" extends Node

export(String) var global_name: String = get_id()


func get_class(): return "RegisterGlobal"


func _init():
	randomize()


static func get_id() -> String:
	return "%016X" % (randi() << 31 | randi()) # random range 2^31 (unsigned) as hex

