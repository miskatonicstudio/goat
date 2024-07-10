extends Control


func _ready():
	goat.connect("game_mode_changed", self._on_game_mode_changed)
	
	var settings_scene_path = "res://addons/goat/default/Settings.tscn"
	var game_resources_directory = goat.get_game_resources_directory()
	if game_resources_directory:
		settings_scene_path = game_resources_directory + "/goat/scenes/Settings.tscn"
	var settings_scene = load(settings_scene_path).instantiate()
	self.add_child(settings_scene)


func _on_game_mode_changed(new_game_mode):
	if new_game_mode == goat.GameMode.SETTINGS:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
	else:
		hide()


func _input(_event):
	if goat.game_mode != goat.GameMode.SETTINGS:
		return
	if Input.is_action_just_pressed("goat_dismiss"):
		goat.game_mode = goat.GameMode.EXPLORING
