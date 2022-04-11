class_name SSSM extends Reference


signal state_changed
var state: int setget _set_state


func _set_state(new_state: int) -> void:
	var old_state: int = state
	if new_state == old_state: return
	if has_method("state_exited"): call("state_exited", old_state, new_state) # PRE-CHANGE
	state = new_state
	if has_method("state_entered"): call("state_entered", old_state, new_state)  # POST-CHANGE
	emit_signal("state_changed", old_state, new_state)

"""
# Subclass as e.g.
	
# SSSM_1.gd
class_name SSSM_1 extends SSSM


enum States {ONE, TWO, THREE} # Never assign int values!
var keys: Array = States.keys()


func get_state_name(_state: int) -> String:
	return keys[_state]


# Optional exited/entered methods below.

func state_exited(from: int, to: int) -> void:
	print("SSSM_1 exited: %s" % get_state_name(from))


func state_entered(from: int, to: int) -> void:
	print("SSSM_1 entered: %s" % get_state_name(to))



"""

"""
# test.gd
extends Node


var sssm_1: SSSM_1 = SSSM_1.new()


func _ready():
	sssm_1.connect("state_changed", self, "on_sssm1_changed")
	sssm_1.state = sssm_1.States.THREE
	print(sssm_1.get_state_name(sssm_1.state))


func on_sssm1_changed(_old_state: int, _new_state: int):
	print("sssm1 changed from %s to %s" % [sssm_1.get_state_name(_old_state), sssm_1.get_state_name(_new_state)])

"""
