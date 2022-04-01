# Global blackboard autoload.
extends Node

# refs: Global reference tracking
# Reading values directly from the dictionary is unsafe due
# to potentially invalid references to deleted objects.
# The safe way to get a value is through get_ref_or_null, which will
# return null if key not found or reference was deleted.
# You can optionally omit the check by setting second param to false,
# if you know the node will never be deleted.

var refs: Dictionary = {} # key=refname, value=object
var root_scene: Node


func _ready():
	root_scene = get_tree().current_scene
	root_scene.connect("ready", self, "scan_all_children", [root_scene])	


func scan_all_children(node: Node):
	for N in node.get_children():
		# Action only nodes of class RegisterGlobal
		if N.get_class() == "RegisterGlobal":
			var _parent = N.get_parent()
			assert(N.global_name.length() >= 5, _parent.name + ": global name must be 5 characters minimum!")
			refs[N.global_name] = _parent
			N.call_deferred("queue_free")
		# Process children
		if N.get_child_count() > 0:
			scan_all_children(N)


# Always use this method to retrieve a value by key name.
# Returns null if key not found or reference was deleted (in which
# case the entry will be removed from the dictionary).
func get_ref_or_null(key: String, check_valid: bool = true):
	if not refs.has(key):
		return null
	elif check_valid:
		if is_instance_valid(refs[key]):
			return refs[key] # Reference still valid
		else:
			refs.erase(key) # Reference invalid! Remove from dictionary
			return null
	else: return refs[key]
