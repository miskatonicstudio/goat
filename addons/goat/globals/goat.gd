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


func set_game_mode(new_game_mode):
	# Usually game mode change is a result of user input (e.g. pressing Tab),
	# and that input shouldn't cause further game mode changes
	get_viewport().set_input_as_handled()
	game_mode = new_game_mode
	emit_signal("game_mode_changed", game_mode)


func _input(_event):
	if Input.is_action_just_pressed("goat_screenshot"):
		take_screenshot()


func take_screenshot() -> void:
	var screenshot_directory_path = "user://" + ProjectSettings.get_setting(
		"goat/general/screenshot_directory_name", "Screenshots"
	)
	DirAccess.make_dir_absolute(screenshot_directory_path)
	var dt = Time.get_datetime_dict_from_system()
	var screenshot_filename = "Screenshot %04d-%02d-%02d %02d:%02d:%02d.png" % [
		dt["year"], dt["month"], dt["day"],
		dt["hour"], dt["minute"], dt["second"]
	]
	var screenshot_path = screenshot_directory_path + "/" + screenshot_filename
	var image = get_viewport().get_texture().get_image()
	image.save_png(screenshot_path)


func reset_game():
	goat_inventory.reset()
	goat_state.reset()
