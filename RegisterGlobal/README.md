# Easy Global References In Godot
This is the easiest way I've come up with to create a game global blackboard, where any object in the game can get a handle to an instance of any other registered object.

The idea is, we will place a custom node under each parent node that we wish to register with a globally accessible dictionary of references -- the game blackboard.  With this approach: 1) we don't need to manually add code to our existing nodes to create the reference, 2) you can see at a glance which parent nodes are flagged as globals, and 3) if you don't want to see the child node all the time in the scene editor then you can simply collapse the parent node's children.

At startup we'll parse the entire scene tree looking for these child nodes, register their parents with the dictionary, then self-destruct the child nodes because they've done their job and are no longer useful.

# How It Works

- Choose a node and click to add a new child node
- Pick the "RegisterGlobal" custom node
- Set the global name string reference (the dictionary key) that will identify the parent instance
- That's it!

**IMPORTANT**:  At game startup, we need to wait a frame before we query the global dictionary.  In other words, never query the global dictionary during Ready.  The dictionary gets populated only after the entire scene tree finishes initializing.  If we didn't wait, we would be querying an empty dictionary.

After the first frame, when all participating nodes have registered with the dictionary, any node can interrogate the Globals dictionary to look up a reference to any other registered node.

## Scene Tree

At game startup, the scene tree might look like this:

```
\root
    \Globals
    \World
        \Node1
            \RegisterGlobal
            \Node1-1
                \Node1-1-1
                    \RegisterGlobal
                \Node1-1-2
        \Node2
        \Node3
            \Node3-1
                \RegisterGlobal
            \Node3-2
```
- We intend to register these nodes in the dictionary: Node1, Node1-1-1, Node3-1.
- \Globals is the autoloaded Globals.gd script.

Let's examine the custom node "RegisterGlobal".

## RegisterGlobal.gd

```
class_name RegisterGlobal, "res://register_global.png" extends Node

export(String) var global_name: String = ""


func get_class(): return "RegisterGlobal"
```
- The first line sets the class name and points to an icon to display in the scene editor.
- Next, we export a string variable to use as the dictionary key.  The value paired with this key will be the RegisterGlobal node's parent node.
- Last, we override the base _get_class_ function so we can identify the RegisterGlobal nodes when parsing the scene tree.

Moving on to the autoload Globals script...

## Globals.gd
Autoload this script in your project settings and use the default name of "Globals".

```
# Global blackboard autoload
extends Node


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
  ```

Breaking this down...

```
var refs: Dictionary = {} # key=refname, value=object
var root_scene: Node
```

This is our globals dictionary and a reference to the scene tree's current (root) scene.

```
func _ready():
	root_scene = get_tree().current_scene
	root_scene.connect("ready", self, "scan_all_children", [root_scene])	
```
The first line of the Ready function stores the current scene node, under which all scene objects reside.  We need this as a starting point to iterate through all child nodes, looking for nodes with the RegisterGlobal class attached.

Using a signal, we wait for the entire scene tree (under this root node) to finish running all the node Ready functions.  We can now parse the full scene tree looking for RegisterGlobal child nodes.  To do this, the signal calls the _scan_all_children_ function.

```
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
```
Loops through the scene tree to:
- Find RegisterGlobal child nodes
- Check that the assigned key name is at least 5 characters long. This ensures no blanks and no short, cryptic names.
- Enters a new item in the dictionary using key = global_name, value = node reference.
- Queues the RegisterGlobal node for deletion next frame

And there we go!  A globally accessible dictionary ("blackboard") ready for use.

### func get_ref_or_null
This function solves the problem: What if a reference in the dictionary points to a now-deleted object?

To know when a reference has turned invalid, we need to check with _is_instance_valid_ -- a [notoriously wild and unpredictable beast](https://github.com/godotengine/godot/pull/51796) that Godot tamed only recently in the 3.4 release.  So we have an important function in Globals.gd to use when querying the dictionary.

**DANGEROUS**  
var x = Globals.refs["my_key"]  

**SAFE**  
var x = Globals.get_ref_or_null("my_key")

**IMPORTANT**:  Always test for null before using the fetched reference.  You'll get a null back if your requested global key isn't found (i.e. was never registered) or if the registered referenced object is now invalid (has been destroyed).
  
```
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
```
First, it checks if they supplied string key exists in the dictionary.  We can early-out if not.  Then is runs a validity check on the retrieved reference, returns it, if all good or, if not, purges the key from the dictionary and safely returns null.  You have the option of not bothering to run the validity check.  Resist the urge.  For the price of some insignificant runtime overhead you'll know that a return value of null means the reference is not in the dictionary or its object was deleted at some point (and is now no longer in the dictionary).

## Example
Let's say I have a Camera node inside a Player scene/prefab, and I have a SimplePCGTerrain node in a main scene that incorporates the Player scene.  At runtime, during Ready, I detach the camera from the Player scene and move it under the current scene root, so that I can manually control its position independent from the Player scene root.

The SimplePCGTerrain node uses a config resource to set the number of tiles to build around the player.  On startup, I want to set the player camera "Far" draw distance to the value contained in the SimplePCGTerrain node's config resource.  To do that, the camera needs a reference to the SimplePCGTerrain node.  Here's what I do:

* Add a RegisterGlobal child node under SimplePCGTerrain
* Enter a global name of "simple_pcg_terrain" in the RegisterGlobal node properties
* In the Camera script I add this code:

```
func _ready():
  # Do other stuff
  call_deferred("_wait_for_globals") # Wait a frame for all nodes (inc. SimplePCGTerrain) to register with Global.gd.


func _wait_for_globals():
	var _value = Globals.get_ref_or_null("simple_pcg_terrain").terrain_config.farDistFade
	if _value: far = _value
```
On the second frame after startup, the camera script fetches the reference to SimplePCGTerrain from the global dictionary and sets its own property "Far".  The draw distance is now set from the config resource attached to SimplePCGTerrain.  At this point, the RegisterGlobal child under SimplePCGTerrain is being queue_freed, having done its duty in the first frame.

# Improvements
* Further checks are probably a good idea, like checking for duplicate keys before adding to the dictionary on startup.
* If you like to be pure about your decoupling, here's how you don't assume Globals exists:
```
func _ready():
  # Do other stuff
  if get_node_or_null("/root/Globals"): call_deferred("_wait_for_globals")


func _wait_for_globals():
	var _value = Globals.get_ref_or_null("simple_pcg_terrain").terrain_config.farDistFade
	if _value: far = _value

```
