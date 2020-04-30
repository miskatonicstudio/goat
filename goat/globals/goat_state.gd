class_name GoatState
extends Node

signal changed (variable_name, from_value, to_value)

var _variables := {}
var _registered_variables := {}


func register_variable(variable_name: String, initial_value) -> void:
	_registered_variables[variable_name] = initial_value
	_variables[variable_name] = initial_value


func get_value(variable_name: String):
	assert(variable_name in _variables)
	return _variables[variable_name]


func set_value(variable_name: String, value) -> void:
	assert(variable_name in _variables)
	var previous_value = _variables[variable_name]
	_variables[variable_name] = value
	emit_signal("changed", variable_name, previous_value, value)


func reset() -> void:
	_variables = _registered_variables.duplicate(true)
