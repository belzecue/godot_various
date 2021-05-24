class_name BitflagSM


signal value_changed(old_value, new_value)

var value: int setget set_private
var enum_names: Dictionary = {} setget set_private


# Set third argument to null to not connect to value_changed signal.
func init(_name: String, _enums: Dictionary, _instance: Node) -> void:
	# Enums as flags MUST have power-of-2 values: 0, 1, 2, 4, 8, 16 etc. and must be ordered ascending.
	enum_names = {}
	for i in _enums.keys(): enum_names[_enums[i]] = i
	if _instance: connect("value_changed", _instance, "on_%s_changed" % _name)


# Only allow setting internally.
func set_private(_new_value): assert(false, "Attempt to change internal variable to '%s' from outside class '%s'" % [_new_value, self.name])


# Can override in subclass.
func set_value(new_value: int):
	var old_value: int = value
	if new_value != old_value:
		value = new_value
		emit_signal("value_changed", old_value, new_value)


# These are the only externally callable methods for setting the value of "value".
func fset(p_flags: int) -> void: set_value(value | p_flags)
func fclear(p_flags: int) -> void: set_value(value & ~p_flags)
func fcheck(p_flags: int) -> bool: return (value & p_flags) == p_flags
func ftoggle(p_flags : int) -> void: set_value(value ^ p_flags)


# Use to test if a bit changed in the Int.
# e.g.
# if (BitflagSM.get_state_bit(state1.value, State1.Enums.FIFTH)): do something!
static func get_state_bit(state: int, state_bit: int) -> bool: return bool(state & state_bit)


"""
EXAMPLE USAGE:

extends Node


# Extend BitflagSM class and define enums.
class State1 extends BitflagSM:
	# Run base class manual init method.
	func _init(_name: String, _enums: Dictionary, _instance: Node = null) -> void: .init(_name, _enums, _instance)
	enum Enums {
		UNKNOWN = 0
		FIRST = 1
		SECOND = 2
		THIRD = 4
		FOURTH = 8
		FIFTH = 16
	}


# Extend BitflagSM class and define enums.
class State2 extends BitflagSM:
	# Run base class manual init method.
	func _init(_name: String, _enums: Dictionary, _instance: Node = null) -> void: .init(_name, _enums, _instance)
	enum Enums {
		UNKNOWN = 0
		APPLE = 1
		ORANGE = 2
		PEAR = 4
		PEACH = 8
		GRAPE = 16
	}


# Instance.
var state1: State1 = State1.new("state1", State1.Enums, self)
var state2: State2 = State2.new("state2", State2.Enums, self)


func _ready() -> void:
	state1.ftoggle(State1.Enums.SECOND | State1.Enums.FIFTH)
	state1.ftoggle(State1.Enums.FIFTH)
	state1.ftoggle(State1.Enums.SECOND | State1.Enums.FIFTH)

	state2.ftoggle(State2.Enums.PEAR | State2.Enums.GRAPE)
	state2.ftoggle(State2.Enums.GRAPE)
	state2.ftoggle(State2.Enums.PEAR | State2.Enums.GRAPE)


func on_state1_changed(old_value: int, new_value: int):
	print_info(state1.enum_names, State1.Enums.SECOND, old_value, new_value)
	print_info(state1.enum_names, State1.Enums.FIFTH, old_value, new_value)


func on_state2_changed(old_value: int, new_value: int):
	print_info(state2.enum_names, State2.Enums.PEAR, old_value, new_value)
	print_info(state2.enum_names, State2.Enums.GRAPE, old_value, new_value)


func print_info(enum_dic: Dictionary, state_bit: int, old_value: int, new_value: int) -> void:
	print("flag %s %s: %s -> %s" % [
		enum_dic[state_bit],
		"changed" if old_value & state_bit != new_value & state_bit else "unchanged",
		bool(old_value & state_bit),
		bool(new_value & state_bit)
	])

"""
