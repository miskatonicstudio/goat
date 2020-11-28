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


func _input(_event):
	if Input.is_action_just_pressed("goat_screenshot"):
		take_screenshot()


func take_screenshot() -> void:
	var screenshot_directory_path = "user://" + SCREENSHOT_DIRECTORY
	Directory.new().make_dir(screenshot_directory_path)
	var dt = OS.get_datetime()
	var screenshot_filename = "Screenshot %04d-%02d-%02d %02d:%02d:%02d.png" % [
		dt["year"], dt["month"], dt["day"],
		dt["hour"], dt["minute"], dt["second"]
	]
	var screenshot_path = screenshot_directory_path + "/" + screenshot_filename
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png(screenshot_path)


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

# Screenshot directory: the name of a subdirectory in user's local folder, where
# the screenshots taken during the game will be stored.
var SCREENSHOT_DIRECTORY = "Screenshots"

var PLAYER_SPEED = 3.0

var GRAVITY_ENABLED = true

var ALLOW_CAMERA_MOVEMENT_WHEN_VOICE_IS_PLAYING = false

var BOTTOM_CAMERA_ANGLE = -80.0
var TOP_CAMERA_ANGLE = 80.0
var LEFT_CAMERA_ANGLE = null
var RIGHT_CAMERA_ANGLE = null

var ENABLE_INVENTORY_ICON_ROTATION = true
var INVENTORY_ICON_ROTATION_PER_SECOND = 2
