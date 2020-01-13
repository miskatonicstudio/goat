extends Node

# Demo game signals
signal program_activated
signal program_uploaded
signal remote_pressed
signal portal_entered


func _ready():
	goat.set_game_resources_directory("demo")
	goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
