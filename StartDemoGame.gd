extends Node


func _ready():
	goat.call_deferred("load_game", "res://demo")
