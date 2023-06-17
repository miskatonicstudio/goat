extends Node


func _ready():
	Input.set_custom_mouse_cursor(load("res://demo/images/cursor.png"))
	
	goat.GRAVITY_ENABLED = false
	# Default voice recordings
	goat_voice.set_default_audio_names(
		["but_why", "what_for", "this_doesnt_make_sense"]
	)
	
	get_tree().change_scene("res://demo/scenes/main/MainMenu.tscn")


func _exit_tree():
	Input.set_custom_mouse_cursor(null)
