class_name GoatState
extends Node

signal changed (variable_name, from_value, to_value)

var _variables := {}


func load_all():
	assert (goat.GAME_RESOURCES_DIRECTORY)
	# TODO: load saved game from file
	var state_directory = goat.GAME_RESOURCES_DIRECTORY + "/state/"
	var files = goat_utils.list_directory(state_directory)
	for file in files:
		if file.ends_with(".json"):
			var data = parse_json(goat_utils.load_text_file(state_directory + file))
			for key in data:
				_register_variable(key, data[key])


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
	_variables = {}
