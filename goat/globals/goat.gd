extends Node

# Signals
signal interactive_item_selected (item_name, position)
signal interactive_item_deselected (item_name)
signal interactive_item_activated (item_name, position)

signal inventory_item_used (item_name)
signal inventory_item_used_on_inventory (item_name, inventory_item_name)
signal inventory_item_used_on_environment (item_name, environment_item_name)

signal game_mode_changed (new_game_mode)

# Enums
enum GameMode {
	EXPLORING,
	INVENTORY,
	CONTEXT_INVENTORY,
	SETTINGS,
}

# Variables
export (GameMode) var game_mode = GameMode.EXPLORING setget set_game_mode

var _unique_names = []
var _game_resources_directory = ProjectSettings.get(
	"application/config/name"
).to_lower()

var game_cursor = null

# Template settings/game settings
# Exit scene: if null, Exit button in settings ends the program.
# Otherwise, it will load the specified scene.
var EXIT_SCENE = null


func set_game_mode(new_game_model):
	game_mode = new_game_model
	emit_signal("game_mode_changed", game_mode)


func _load_game_resources():
	game_cursor = load(
		"res://{}/images/cursor.png".format([_game_resources_directory], "{}")
	)


func set_game_resources_directory(name):
	_game_resources_directory = name
	_load_game_resources()


func register_unique_name(_unique_name):
	pass
#	assert(not _unique_names.has(unique_name))
	
#	var single_argument_signals = [
#		"interactive_item_selected",
#		"interactive_item_deselected",
#		"interactive_item_activated",
##		"inventory_item_obtained",
##		"inventory_item_selected",
##		"inventory_item_removed",
#		"inventory_item_used",
#	]
	
#	var double_argument_signals = [
#		"inventory_item_{}_replaced_by_{}",
#		"inventory_item_{}_used_on_inventory_{}",
#		"inventory_item_{}_used_on_environment_{}",
#	]
	
	# TODO: bring back specific signals after GOAT redesign
#	for s in single_argument_signals:
#		add_user_signal(s + "_" + unique_name)
#	for s in double_argument_signals:
#		for other_name in _unique_names:
#			add_user_signal(s.format([unique_name, other_name], "{}"))
#			add_user_signal(s.format([other_name, unique_name], "{}"))
#	_unique_names.append(unique_name)
