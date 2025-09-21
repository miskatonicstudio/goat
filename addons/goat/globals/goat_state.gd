extends Node

signal changed (variable_name, from_value, to_value)

var _variables := {}


func _init():
	reset()


func _register_variable(variable_name: String, initial_value) -> void:
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
	# TODO: load saved game from file
	_variables = ProjectSettings.get_setting("goat/state/variables", {}).duplicate()
