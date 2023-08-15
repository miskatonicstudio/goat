extends CenterContainer


func _on_Exit_pressed():
	goat_voice.stop()
	get_tree().change_scene_to_file("res://demo/scenes/main/MainMenu.tscn")
	goat.game_mode = goat.GameMode.NONE


func _on_Resume_pressed():
	goat.game_mode = goat.GameMode.EXPLORING
