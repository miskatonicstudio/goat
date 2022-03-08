extends Node


func _ready():
	# Default voice recordings
	goat_voice.set_default_audio_names(
		["but_why", "what_for", "this_doesnt_make_sense"]
	)
	
	get_tree().change_scene("res://demo/scenes/main/Gameplay.tscn")
