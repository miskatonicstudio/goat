class_name Goat
extends Node

signal game_mode_changed (new_game_mode)

enum GameMode {
	NONE,
	EXPLORING,
	INVENTORY,
	CONTEXT_INVENTORY,
	SETTINGS,
}

export (GameMode) var game_mode = GameMode.NONE setget set_game_mode


func set_game_mode(new_game_model):
	# Usually game mode change is a result of user input (e.g. pressing Tab),
	# and that input shouldn't cause further game mode changes
	get_tree().set_input_as_handled()
	game_mode = new_game_model
	emit_signal("game_mode_changed", game_mode)


##############################################################################
# SETTINGS
##############################################################################

# Exit scene: if null, 'Exit' button in settings ends the program.
# Otherwise, it will load the specified scene.
var EXIT_SCENE = null

# Game resources directory: defines a place where all game resources are stored.
# The directory needs to have a specific structure, e.g. it needs to contain
# 'inventory_items' and 'voice' directories.
var GAME_RESOURCES_DIRECTORY = null
