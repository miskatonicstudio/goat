extends CenterContainer


func _ready():
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")


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


func _on_Exit_pressed():
	goat_voice.stop()
	if goat.EXIT_SCENE:
		get_tree().change_scene(goat.EXIT_SCENE)
		goat.game_mode = goat.GameMode.NONE
	else:
		get_tree().quit()


func _on_Resume_pressed():
	goat.game_mode = goat.GameMode.EXPLORING
