extends Node

# TODO: get locale list from filesystem
const LOCALES = ["en", "pl", "de"]


func _enter_tree():
	for l in LOCALES:
		var translation = ResourceLoader.load("res://addons/goat/locale/goat." + l + ".translation")
		TranslationServer.add_translation(translation)
	print("GOAT translations added")


func _exit_tree():
	for l in LOCALES:
		var translation = ResourceLoader.load("res://addons/goat/locale/goat." + l + ".translation")
		TranslationServer.remove_translation(translation)
	print("GOAT translations removed")
