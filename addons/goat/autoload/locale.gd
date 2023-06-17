extends Node


func _enter_tree():
	goat_utils.add_translations("res://addons/goat/locale/")


func _exit_tree():
	goat_utils.remove_translations("res://addons/goat/locale/")
