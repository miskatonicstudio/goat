extends Node

signal changed (variable_name, from_value, to_value)

var _variables := {}


func _init():
	_load()


func _load():
	if not goat.get_game_resources_directory():
		print("No game state loaded from JSON")
		return
	# TODO: load saved game from file
	var state_directory = goat.get_game_resources_directory() + "/goat/state/"
	var files = goat_utils.list_directory(state_directory)
	for file in files:
		if file.ends_with(".json"):
			var test_json_conv = JSON.new()
			test_json_conv.parse(goat_utils.load_text_file(state_directory + file))
			var data = test_json_conv.get_data()
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
	# TODO: store initial values and use them for resetting
	_variables = {}
	_load()
