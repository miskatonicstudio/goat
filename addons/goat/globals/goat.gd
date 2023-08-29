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

@export var game_mode : GameMode = GameMode.NONE: set = set_game_mode
# TODO: make this read-only
var game_directory_path = null


func set_game_mode(new_game_mode):
	# Usually game mode change is a result of user input (e.g. pressing Tab),
	# and that input shouldn't cause further game mode changes
	get_viewport().set_input_as_handled()
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
	DirAccess.make_dir_absolute(game_directory_path)


func take_screenshot() -> void:
	var screenshot_directory_path = game_directory_path + SCREENSHOT_DIRECTORY
	DirAccess.make_dir_absolute(screenshot_directory_path)
	var dt = Time.get_datetime_dict_from_system()
	var screenshot_filename = "Screenshot %04d-%02d-%02d %02d:%02d:%02d.png" % [
		dt["year"], dt["month"], dt["day"],
		dt["hour"], dt["minute"], dt["second"]
	]
	var screenshot_path = screenshot_directory_path + "/" + screenshot_filename
	var image = get_viewport().get_texture().get_image()
	image.save_png(screenshot_path)


func load_game(game_directory: String, parent_exit_scene = null):
	# TODO: clear previous game?
	assert(game_directory != null)
	goat_utils.add_translations(game_directory + "/goat/locale/")
	goat.GAME_RESOURCES_DIRECTORY = game_directory
	goat._PARENT_EXIT_SCENE = parent_exit_scene
	_setup_game_directory()
	goat_voice.load_all()
	goat_inventory.load_all()
	goat_state.load_all()
	goat_globals.load_all()


func clear_game():
	if goat.GAME_RESOURCES_DIRECTORY:
		goat_utils.remove_translations(goat.GAME_RESOURCES_DIRECTORY + "/goat/locale/")
	goat.GAME_RESOURCES_DIRECTORY = null
	game_directory_path = null
	goat_globals.clear()
	goat_inventory.clear()
	goat_state.clear()
	goat_voice.clear()
	if goat._PARENT_EXIT_SCENE:
		get_tree().change_scene_to_file(goat._PARENT_EXIT_SCENE)
		goat._PARENT_EXIT_SCENE = null
	else:
		get_tree().quit()


func reset_game():
	goat_inventory.reset()
	goat_state.reset()

##############################################################################
# SETTINGS
##############################################################################

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

# The scene where GOAT game will exit to when using goat.clear_game
var _PARENT_EXIT_SCENE = null
