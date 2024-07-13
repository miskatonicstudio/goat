extends CenterContainer


func _on_Exit_pressed():
	get_tree().quit()


func _on_Resume_pressed():
	goat.game_mode = goat.GameMode.EXPLORING
