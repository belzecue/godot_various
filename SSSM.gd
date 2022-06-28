class_name SSSM extends Reference


signal state_changed
var state: int setget _set_state
var _keys: Array
var _has_exited_func: bool
var _has_entered_func: bool
const _func_name_exited: String = "_state_exited"
const _func_name_entered: String = "_state_entered"


func _init(_states: Dictionary):
	_keys = _states.keys()
	_has_exited_func = has_method(_func_name_exited)
	_has_entered_func = has_method(_func_name_entered)


func _set_state(new_state: int) -> void:
	var old_state: int = state
	if new_state == old_state: return
	if _has_exited_func: call(_func_name_exited, old_state, new_state) # PRE-CHANGE
	state = new_state
	if _has_entered_func: call(_func_name_entered, old_state, new_state)  # POST-CHANGE
	emit_signal("state_changed", old_state, new_state)


func get_state_name(_state: int) -> String:
	return _keys[_state]


"""
# Subclass as e.g.
	
# SSSM_1.gd
class_name SSSM_1 extends SSSM


# Must define States enum.
enum States {ONE, TWO, THREE} # Never assign int values!


# Must define constructor.
func _init(States).(States):
	pass # pass arguments through to base class.


# Optional exited/entered methods below.

func _state_exited(from: int, to: int) -> void:
	print("SSSM_1 exited: %s" % get_state_name(from))


func _state_entered(from: int, to: int) -> void:
	print("SSSM_1 entered: %s" % get_state_name(to))

"""

"""
# test.gd
extends Node


var sssm_1: SSSM_1 = SSSM_1.new(SSSM_1.States)


func _ready():
	sssm_1.connect("state_changed", self, "on_sssm1_changed")
	sssm_1.state = sssm_1.States.THREE
	print(sssm_1.get_state_name(sssm_1.state))


func on_sssm1_changed(_old_state: int, _new_state: int):
	print("sssm1 changed from %s to %s" % [sssm_1.get_state_name(_old_state), sssm_1.get_state_name(_new_state)])

"""
