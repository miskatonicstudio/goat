extends Node

# Demo game signals
# warning-ignore:unused_signal
signal program_activated
# warning-ignore:unused_signal
signal program_uploaded
# warning-ignore:unused_signal
signal remote_pressed
# warning-ignore:unused_signal
signal portal_entered


func _ready():
	goat.set_game_resources_directory("demo")
	goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
