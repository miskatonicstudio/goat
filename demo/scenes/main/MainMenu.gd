extends Control


func _ready():
	Input.set_custom_mouse_cursor(load("res://demo/images/cursor.png"))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Default voice recordings
	goat_voice.set_default_audio_names(
		["but_why", "what_for", "this_doesnt_make_sense"]
	)
	goat.reset_game()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Play_pressed():
	get_tree().change_scene_to_file("res://demo/scenes/main/Gameplay.tscn")


func _on_Credits_pressed():
	get_tree().change_scene_to_file("res://demo/scenes/main/Credits.tscn")


func _on_Settings_pressed():
	$Settings.show()
