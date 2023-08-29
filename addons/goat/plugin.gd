@tool
extends EditorPlugin


func _enter_tree():
	load_plugins()
	
	add_goat_actions()
	add_goat_audio_buses()
	
	add_autoload_singleton("goat_audio_bus", "res://addons/goat/autoload/audio_bus.gd")
	add_autoload_singleton("goat_locale", "res://addons/goat/autoload/locale.gd")
	
	add_autoload_singleton("goat_utils", "res://addons/goat/globals/goat_utils.gd")
	add_autoload_singleton("goat", "res://addons/goat/globals/goat.gd")
	add_autoload_singleton("goat_globals", "res://addons/goat/globals/goat_globals.gd")
	add_autoload_singleton("goat_state", "res://addons/goat/globals/goat_state.gd")
	add_autoload_singleton("goat_inventory", "res://addons/goat/globals/goat_inventory.gd")
	add_autoload_singleton("goat_interaction", "res://addons/goat/globals/goat_interaction.gd")
	add_autoload_singleton("goat_voice", "res://addons/goat/globals/goat_voice.gd")
	add_autoload_singleton("goat_settings", "res://addons/goat/globals/goat_settings.gd")


func _exit_tree():
	remove_autoload_singleton("goat_settings")
	remove_autoload_singleton("goat_voice")
	remove_autoload_singleton("goat_interaction")
	remove_autoload_singleton("goat_inventory")
	remove_autoload_singleton("goat_state")
	remove_autoload_singleton("goat_globals")
	remove_autoload_singleton("goat")
	remove_autoload_singleton("goat_utils")
	
	remove_autoload_singleton("goat_locale")
	remove_autoload_singleton("goat_audio_bus")
	
	remove_goat_audio_buses()
	remove_goat_actions()
	
	clear_plugins()


func add_goat_audio_buses():
	# To be available in audio nodes in GOAT, audio buses have to be added here
	# TODO: check if in Godot 4 this might be called only once
	load("res://addons/goat/autoload/audio_bus.gd").new()._enter_tree()


func remove_goat_audio_buses():
	load("res://addons/goat/autoload/audio_bus.gd").new()._exit_tree()


func add_goat_actions():
	load("res://addons/goat/autoload/input_map.gd").new().add_goat_actions()


func remove_goat_actions():
	load("res://addons/goat/autoload/input_map.gd").new().remove_goat_actions()


func load_plugins():
	load("res://addons/goat/addons/randomAudioStreamPlayer/random_audio.gd").new()._enter_tree()
	print("Additional plugins loaded")


func clear_plugins():
	load("res://addons/goat/addons/randomAudioStreamPlayer/random_audio.gd").new()._exit_tree()
	print("Additional plugins cleared")
