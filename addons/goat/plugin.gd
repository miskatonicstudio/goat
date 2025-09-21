@tool
extends EditorPlugin


var main_screen_instance
# Embedded plugins
var random_audio_stream_player
var dialogue_manager


func _enter_tree():
	prepare_goat_project_settings()
	
	add_goat_actions()
	add_goat_audio_buses()
	
	add_autoload_singleton("goat_audio_bus", "res://addons/goat/autoload/audio_bus.gd")
	add_autoload_singleton("goat_locale", "res://addons/goat/autoload/locale.gd")
	
	add_autoload_singleton("goat_utils", "res://addons/goat/globals/goat_utils.gd")
	add_autoload_singleton("goat", "res://addons/goat/globals/goat.gd")
	add_autoload_singleton("goat_state", "res://addons/goat/globals/goat_state.gd")
	add_autoload_singleton("goat_inventory", "res://addons/goat/globals/goat_inventory.gd")
	add_autoload_singleton("goat_interaction", "res://addons/goat/globals/goat_interaction.gd")
	add_autoload_singleton("goat_voice", "res://addons/goat/globals/goat_voice.gd")
	add_autoload_singleton("goat_settings", "res://addons/goat/globals/goat_settings.gd")
	
	main_screen_instance = load("res://addons/goat/main_screen/goat_main_screen.tscn").instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_screen_instance)
	_make_visible(false)
	load_plugins()


func _exit_tree():
	remove_autoload_singleton("goat_settings")
	remove_autoload_singleton("goat_voice")
	remove_autoload_singleton("goat_interaction")
	remove_autoload_singleton("goat_inventory")
	remove_autoload_singleton("goat_state")
	remove_autoload_singleton("goat")
	remove_autoload_singleton("goat_utils")
	
	remove_autoload_singleton("goat_locale")
	remove_autoload_singleton("goat_audio_bus")
	
	remove_goat_audio_buses()
	remove_goat_actions()
	
	clear_plugins()
	
	if main_screen_instance:
		main_screen_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_screen_instance:
		main_screen_instance.visible = visible


func _get_plugin_name():
	return "GOAT"


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
	random_audio_stream_player = load(
		"res://addons/goat/addons/randomAudioStreamPlayer/random_audio.gd"
	).new()
	random_audio_stream_player._enter_tree()
	dialogue_manager = load(
		"res://addons/goat/addons/dialogue_manager/plugin.gd"
	).new()
	dialogue_manager._enter_tree()
	print("Additional plugins loaded")


func clear_plugins():
	dialogue_manager._exit_tree()
	random_audio_stream_player._exit_tree()
	print("Additional plugins cleared")


func prepare_goat_project_settings():
	if not ProjectSettings.has_setting("goat/inventory/items"):
		ProjectSettings.set_setting("goat/inventory/items", [])
		ProjectSettings.set_initial_value("goat/inventory/items", [])
	ProjectSettings.add_property_info({
		"name": "goat/inventory/items",
		"type": TYPE_PACKED_STRING_ARRAY,
		"hint": PROPERTY_HINT_ARRAY_TYPE,
		"hint_string": "%d/%d:*.tscn" % [TYPE_STRING, PROPERTY_HINT_FILE],
	})
	if not ProjectSettings.has_setting("goat/state/variables"):
		ProjectSettings.set_setting("goat/state/variables", {})
		ProjectSettings.set_initial_value("goat/state/variables", {})
	ProjectSettings.add_property_info({
		"name": "goat/state/variables",
		"type": TYPE_DICTIONARY,
	})
	if not ProjectSettings.has_setting("goat/dialogues/dialogue_file"):
		ProjectSettings.set_setting("goat/dialogues/dialogue_file", "")
		ProjectSettings.set_initial_value("goat/dialogues/dialogue_file", "")
	ProjectSettings.add_property_info({
		"name": "goat/dialogues/dialogue_file",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.dialogue",
	})
	if not ProjectSettings.has_setting("goat/general/custom_settings_scene_path"):
		ProjectSettings.set_setting("goat/general/custom_settings_scene_path", "")
		ProjectSettings.set_initial_value("goat/general/custom_settings_scene_path", "")
	ProjectSettings.add_property_info({
		"name": "goat/general/custom_settings_scene_path",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.tscn",
	})
	if not ProjectSettings.has_setting("goat/dialogues/voices"):
		ProjectSettings.set_setting("goat/dialogues/voices", [])
		ProjectSettings.set_initial_value("goat/dialogues/voices", [])
	ProjectSettings.add_property_info({
		"name": "goat/dialogues/voices",
		"type": TYPE_PACKED_STRING_ARRAY,
		"hint": PROPERTY_HINT_ARRAY_TYPE,
		"hint_string": "%d/%d:*.ogg,*.wav,*.txt" % [TYPE_STRING, PROPERTY_HINT_FILE],
	})
	
	ProjectSettings.save()

##############################################################################
# Forward FileSystem events to Dialogue Manager
# (for now, GOAT only handles double-click on .dialogue files)
##############################################################################

func _edit(object: Object) -> void:
	dialogue_manager._edit(object)


func _handles(object) -> bool:
	return dialogue_manager._handles(object)
