tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("goat_input_map", "res://addons/goat/input_map.gd")
	add_autoload_singleton("goat_locale", "res://addons/goat/locale.gd")
	add_autoload_singleton("goat_audio_bus", "res://addons/goat/audio_bus.gd")
	
	add_autoload_singleton("goat", "res://addons/goat/globals/goat.gd")
	add_autoload_singleton("goat_globals", "res://addons/goat/globals/goat_globals.gd")
	add_autoload_singleton("goat_state", "res://addons/goat/globals/goat_state.gd")
	add_autoload_singleton("goat_inventory", "res://addons/goat/globals/goat_inventory.gd")
	add_autoload_singleton("goat_interaction", "res://addons/goat/globals/goat_interaction.gd")
	add_autoload_singleton("goat_voice", "res://addons/goat/globals/goat_voice.gd")
	add_autoload_singleton("goat_settings", "res://addons/goat/globals/goat_settings.gd")
	add_autoload_singleton("goat_utils", "res://addons/goat/globals/goat_utils.gd")


func _exit_tree():
	remove_autoload_singleton("goat_input_map")
	remove_autoload_singleton("goat_locale")
	remove_autoload_singleton("goat_audio_bus")
	
	remove_autoload_singleton("goat")
	remove_autoload_singleton("goat_globals")
	remove_autoload_singleton("goat_state")
	remove_autoload_singleton("goat_inventory")
	remove_autoload_singleton("goat_interaction")
	remove_autoload_singleton("goat_voice")
	remove_autoload_singleton("goat_settings")
	remove_autoload_singleton("goat_utils")
