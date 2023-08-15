extends Node

"""
Helps with handling Godot Engine settings relevant to GOAT.
"""

signal value_changed (section, key)

const SETTINGS_FILE_NAME := "user://settings.cfg"
# Each entry contains: section name, key name, default value
var DEFAULT_VALUES := [
	["graphics", "fullscreen_enabled", true],
	["graphics", "glow_enabled", true],
	["graphics", "reflections_enabled", disable_for_html()],
	["graphics", "shadows_enabled", true],
	["graphics", "ao_enabled", disable_for_html()],
	["sound", "music_volume", 1.0],
	["sound", "effects_volume", 1.0],
	["controls", "mouse_sensitivity", 0.3],
	["gui", "subtitles", true],
	["gui", "scope", true],
	["gui", "language", find_matching_loaded_locale()],
]

# If enabled, settings will be saved to file when changed
var autosave := true

var _settings_file := ConfigFile.new()


func _ready():
	_settings_file.load(SETTINGS_FILE_NAME)
	
	for entry in DEFAULT_VALUES:
		var section =  entry[0]
		var key = entry[1]
		var value = entry[2]
		# Add detailed signals for each section and key
		add_user_signal("value_changed_{}_{}".format([section, key], "{}"))
		# If settings file doesn't have the section/key yet,
		# add it with the default value
		if not _settings_file.has_section_key(section, key):
			_settings_file.set_value(section, key, value)
	
	_settings_file.save(SETTINGS_FILE_NAME)
	
	# Connect settings to global handlers
	var settings_signals_handlers = {
		"value_changed_graphics_shadows_enabled": "_on_shadows_settings_changed",
		"value_changed_graphics_reflections_enabled": "_on_camera_settings_changed",
		"value_changed_graphics_glow_enabled": "_on_camera_settings_changed",
		"value_changed_graphics_ao_enabled": "_on_camera_settings_changed",
		"value_changed_graphics_fullscreen_enabled": "_on_fullscreen_settings_changed",
		"value_changed_sound_music_volume": "_on_music_settings_changed",
		"value_changed_sound_effects_volume": "_on_effects_settings_changed",
		"value_changed_gui_language": "_on_gui_language_changed",
	}
	
	for key in settings_signals_handlers:
		connect(key, Callable(self, settings_signals_handlers[key]))
	
	# Make sure that settings are applied to new nodes
	get_tree().connect("node_added", self._on_node_added)
	
	# Make sure that initial values are loaded correctly
	_on_fullscreen_settings_changed()
	_on_music_settings_changed()
	_on_effects_settings_changed()
	_on_gui_language_changed()


func get_value(section: String, key: String):
	var value = _settings_file.get_value(section, key)
	assert(value != null)
	return value


func set_value(section: String, key: String, value) -> void:
	var previous_value = _settings_file.get_value(section, key)
	if previous_value != value:
		_settings_file.set_value(section, key, value)
		if autosave:
			_settings_file.save(SETTINGS_FILE_NAME)
		emit_signal("value_changed", section, key)
		emit_signal("value_changed_{}_{}".format([section, key], "{}"))


func find_matching_loaded_locale() -> String:
	"""
	Returns a loaded locale that best matches currently set locale. If there are
	no translations provided, returns the fallback locale. Otherwise, attempts
	to match the exact locale name, if that fails, checks a partial match
	(e.g. "en_US" will match "en"). If the matching process fails for the
	current locale, fallback locale (from Project Settings) is checked.
	If that fails too, the first provided locale is returned.
	"""
	var current_locale = TranslationServer.get_locale()
	var loaded_locales = TranslationServer.get_loaded_locales()
	var fallback_locale = ProjectSettings.get("internationalization/locale/fallback")
	
	# If no translations are provided, return fallback locale
	if loaded_locales.is_empty():
		return fallback_locale
	
	# If the exact locale is loaded, return it
	if current_locale in loaded_locales:
		return current_locale
	
	# Look for partial matches, e.g. current is "en_US", loaded is "en"
	# Try the current locale first, then the fallback locale
	for locale in [current_locale, fallback_locale]:
		for loaded_locale in loaded_locales:
			if locale.substr(0, 2) == loaded_locale.substr(0, 2):
				return loaded_locale
	
	# If nothing matches, return first provided translation
	return loaded_locales[0]


func disable_for_html():
	return OS.get_name() != "HTML5"


func _on_fullscreen_settings_changed() -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (get_value("graphics", "fullscreen_enabled")) else Window.MODE_WINDOWED


func _on_music_settings_changed() -> void:
	var volume = get_value("sound", "music_volume")
	_set_volume_db("GoatMusic", volume)


func _on_effects_settings_changed() -> void:
	var volume = get_value("sound", "effects_volume")
	_set_volume_db("GoatEffects", volume)


func _on_shadows_settings_changed() -> void:
	for lamp in get_tree().get_nodes_in_group("goat_lamps"):
		_update_single_lamp_settings(lamp)


func _on_camera_settings_changed() -> void:
	for environment in get_tree().get_nodes_in_group("goat_environments"):
		_update_single_environment_settings(environment)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("goat_lamps"):
		_update_single_lamp_settings(node)
	if node.is_in_group("goat_environments"):
		_update_single_environment_settings(node)


func _update_single_lamp_settings(lamp: Light3D) -> void:
	var shadows_enabled = get_value("graphics", "shadows_enabled")
	lamp.shadow_enabled = shadows_enabled
	# Specular light creates reflections, without shadows they look wrong
	lamp.light_specular = 0.5 if shadows_enabled else 0.0


func _update_single_environment_settings(world_environment: WorldEnvironment) -> void:
	var reflections_enabled = get_value("graphics", "reflections_enabled")
	var glow_enabled = get_value("graphics", "glow_enabled")
	var ao_enabled = get_value("graphics", "ao_enabled")
	world_environment.environment.ssr_enabled = reflections_enabled
	world_environment.environment.glow_enabled = glow_enabled
	world_environment.environment.ssao_enabled = ao_enabled


func _on_gui_language_changed() -> void:
	var locale = get_value("gui", "language")
	TranslationServer.set_locale(locale)


func _set_volume_db(bus_name: String, volume: float) -> void:
	"""
	Volume is a value between 0 (complete silence) and 1 (default bus volume).
	It is recalculated to a non-linear value between -80 and 0 dB.
	Using a linear value causes the sound to almost vanish long before the
	volume slider reaches minimum.
	"""
	# Min volume dB
	var M = -80.0
	# Recalculate to <M, 0>, non-linear
	var volume_db = abs(M) * sqrt(2 * volume - pow(volume, 2)) + M
	var bus_id = AudioServer.get_bus_index(bus_name)
	if bus_id >= 0:
		AudioServer.set_bus_volume_db(bus_id, volume_db)
	else:
		print("Audio bus not found: ", bus_name)
		print_stack()
