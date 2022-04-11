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
	
class_name SSSM_1 extends SSSM


enum States {ONE, TWO, THREE} # Never assign int values!
var keys: Array = States.keys()


# Optional exited/entered methods below.

func state_exited(from: int, to: int) -> void:
	print("SSSM_1 exited: %s" % keys[from])


func state_entered(from: int, to: int) -> void:
	print("SSSM_1 entered: %s" % keys[to])


"""

"""
# test.gd
extends Node


var sssm_1: SSSM_1 = SSSM_1.new()
var sssm_2: SSSM_2 = SSSM_2.new()


func _ready():
	sssm_1.connect("state_changed", self, "on_sssm1_changed")
	
	sssm_1.state = sssm_1.States.THREE
	sssm_2.state = sssm_2.States.CAT
	
	print(sssm_1.keys[sssm_1.state])
	print(sssm_2.keys[sssm_2.state])


func on_sssm1_changed(_old_state: int, _new_state: int):
	print("sssm1 changed from %s to %s" % [sssm_1.keys[_old_state], sssm_1.keys[_new_state]])

"""
