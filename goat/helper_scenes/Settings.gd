extends CenterContainer


func _ready():
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "game_mode_changed")


func game_mode_changed(new_game_mode):
	if new_game_mode == goat.GAME_MODE_SETTINGS:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		hide()


func _input(_event):
	if goat.game_mode != goat.GAME_MODE_SETTINGS:
		return
	if Input.is_action_just_pressed("goat_dismiss"):
		goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
		get_tree().set_input_as_handled()


func _on_Exit_pressed():
	if goat.EXIT_SCENE:
		get_tree().change_scene(goat.EXIT_SCENE)
	else:
		get_tree().quit()


func _on_Back_pressed():
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
