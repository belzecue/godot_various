extends Spatial

signal collected_wood

onready var tree: SceneTree = get_tree()
var main_group: String = "main_group"


func _ready():
	# Connect to self signal and callback
	connect("collected_wood", self, "_collected_wood_notify_group")
	
	# Add selected nodes to main group
	var nodes: Array = [
		$Node,
		$Node/Node,
		$Node/Node2,
		$Node/Node2/Node
	]
	for i in nodes:
		i = i as Node
		i.add_to_group(main_group)
	
	# Test emitting our signal
	emit_signal("collected_wood")


func _collected_wood_notify_group():
	# Announce to all nodes in main group
	# Assumes they all have a "receive_wood" method
	tree.call_group(main_group, "receive_wood")
