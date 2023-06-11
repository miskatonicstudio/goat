extends Node

signal game_mode_changed (new_game_mode)

enum GameMode {
	NONE,
	EXPLORING,
	DETAILED_INTERACTION,
	INVENTORY,
	CONTEXT_INVENTORY,
	SETTINGS,
}

export (GameMode) var game_mode = GameMode.NONE setget set_game_mode
# TODO: make this read-only
var game_directory_path = null


func set_game_mode(new_game_mode):
	# Usually game mode change is a result of user input (e.g. pressing Tab),
	# and that input shouldn't cause further game mode changes
	get_tree().set_input_as_handled()
	game_mode = new_game_mode
	emit_signal("game_mode_changed", game_mode)


func _input(_event):
	if Input.is_action_just_pressed("goat_screenshot"):
		take_screenshot()


func _setup_game_directory():
	var path_prefix = RegEx.new()
	path_prefix.compile("^(user|res)://")
	var game_directory_name = path_prefix.sub(GAME_RESOURCES_DIRECTORY, "")
	game_directory_path = "user://" + game_directory_name + "/"
	Directory.new().make_dir(game_directory_path)


func take_screenshot() -> void:
	var screenshot_directory_path = game_directory_path + SCREENSHOT_DIRECTORY
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


func load_game(game_directory: String):
	assert(game_directory != null)
	goat.GAME_RESOURCES_DIRECTORY = game_directory
	_setup_game_directory()
	goat_voice.load_all()
	goat_inventory.load_all()
	goat_state.load_all()
	goat_globals.load_all()
	goat_utils.add_translations(game_directory + "/locale/")


func clear_game():
	if goat.GAME_RESOURCES_DIRECTORY:
		goat_utils.remove_translations(goat.GAME_RESOURCES_DIRECTORY + "/locale/")
	goat.GAME_RESOURCES_DIRECTORY = null
	game_directory_path = null
	goat_globals.reset()
	goat_inventory.reset()
	goat_state.reset()
	goat_voice.reset()


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
