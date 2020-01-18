class_name Goat
extends Node

signal inventory_item_used (item_name)
signal inventory_item_used_on_inventory (item_name, inventory_item_name)
signal inventory_item_used_on_environment (item_name, environment_item_name)
signal game_mode_changed (new_game_mode)

enum GameMode {
	EXPLORING,
	INVENTORY,
	CONTEXT_INVENTORY,
	SETTINGS,
}

export (GameMode) var game_mode = GameMode.EXPLORING setget set_game_mode

var _game_resources_directory = ProjectSettings.get(
	"application/config/name"
).to_lower()

var game_cursor = null

# Template settings/game settings
# Exit scene: if null, Exit button in settings ends the program.
# Otherwise, it will load the specified scene.
var EXIT_SCENE = null


func set_game_mode(new_game_model):
	# Usually game mode change is a result of user input (e.g. pressing Tab),
	# and that input shouldn't cause further game mode changes
	get_tree().set_input_as_handled()
	game_mode = new_game_model
	emit_signal("game_mode_changed", game_mode)


func set_game_resources_directory(name):
	_game_resources_directory = name
	_load_game_resources()


func _load_game_resources():
	game_cursor = load(
		"res://{}/images/cursor.png".format([_game_resources_directory], "{}")
	)
