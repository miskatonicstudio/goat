extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	goat.reset_game()


func _on_Exit_pressed():
	goat.clear_game()


func _on_Play_pressed():
	get_tree().change_scene("res://demo/scenes/main/Gameplay.tscn")


func _on_Credits_pressed():
	get_tree().change_scene("res://demo/scenes/main/Credits.tscn")


func _on_Settings_pressed():
	$Settings.show()
