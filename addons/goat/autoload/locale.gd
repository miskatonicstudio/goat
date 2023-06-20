extends Node


func _enter_tree():
	# To be available in a game, this has to be loaded as an autoload.
	# To avoid loading order issues, `goat_utils` is loaded directly here.
	load("res://addons/goat/globals/goat_utils.gd").new().add_translations("res://addons/goat/locale/")


func _exit_tree():
	load("res://addons/goat/globals/goat_utils.gd").new().remove_translations("res://addons/goat/locale/")
