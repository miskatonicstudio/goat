extends Node

# Signals
# warning-ignore:unused_signal
signal interactive_item_selected (item_name, position)
# warning-ignore:unused_signal
signal interactive_item_deselected (item_name)
# warning-ignore:unused_signal
signal interactive_item_activated (item_name, position)

# warning-ignore:unused_signal
signal inventory_item_obtained (item_name)
# warning-ignore:unused_signal
signal inventory_item_selected (item_name)
# warning-ignore:unused_signal
signal inventory_item_removed (item_name)
# warning-ignore:unused_signal
signal inventory_item_replaced (item_name_replaced, item_name_replacing)
# warning-ignore:unused_signal
signal inventory_item_used (item_name)
# warning-ignore:unused_signal
signal inventory_item_used_on_inventory (item_name, inventory_item_name)
# warning-ignore:unused_signal
signal inventory_item_used_on_environment (item_name, environment_item_name)
# This is emitted when the global inventory item list was updated
signal inventory_items_changed (inventory_items)

# warning-ignore:unused_signal
signal game_mode_changed (new_game_mode)

# Enumerations
const GAME_MODE_EXPLORING = 0
const GAME_MODE_INVENTORY = 1
const GAME_MODE_CONTEXT_INVENTORY = 2
const GAME_MODE_SETTINGS = 3

enum GameMode {
	GAME_MODE_EXPLORING,
	GAME_MODE_INVENTORY,
	GAME_MODE_CONTEXT_INVENTORY,
	GAME_MODE_SETTINGS,
}

# Inventory
const INVENTORY_CAPACITY = 8
var inventory_items = []
var _previous_inventory_items = []

# Variables
export (GameMode) var game_mode = GAME_MODE_EXPLORING

var _unique_names = []
var _game_resources_directory = ProjectSettings.get("application/config/name").to_lower()
var _inventory_config = {}

var game_cursor = null

var settings = Settings.new()
var monologue = Monologue.new()

# Template settings/game settings
# Exit scene: if null, Exit button in settings ends the program.
# Otherwise, it will load the specified scene.
# warning-ignore:unused_class_variable
var EXIT_SCENE = null


func _ready():
	add_child(monologue)
	# warning-ignore:return_value_discarded
	connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	connect("inventory_item_obtained", self, "inventory_item_obtained")
	# warning-ignore:return_value_discarded
	connect("inventory_item_replaced", self, "inventory_item_replaced")
	# warning-ignore:return_value_discarded
	connect("inventory_item_removed", self, "inventory_item_removed")
	_load_game_resources()
	
	AudioServer.set_bus_layout(load("res://goat/default_bus_layout.tres"))
	settings.connect("value_changed_graphics_fullscreen", self, "update_fullscreen")
	update_fullscreen()
	settings.connect("value_changed_graphics_shadows", self, "update_shadows")
	update_shadows()
	settings.connect("value_changed_sound_music_volume", self, "update_music_volume")
	update_music_volume()
	settings.connect("value_changed_sound_effects_volume", self, "update_effects_volume")
	update_effects_volume()


func _process(_delta):
	# Send this signal after other signals were handled
	if _previous_inventory_items != inventory_items:
		emit_signal("inventory_items_changed", inventory_items)
		_previous_inventory_items = inventory_items.duplicate()


func _load_game_resources():
	game_cursor = load(
		"res://{}/images/cursor.png".format([_game_resources_directory], "{}")
	)


func game_mode_changed(new_game_mode):
	game_mode = new_game_mode


func inventory_item_obtained(item_name):
	if len(inventory_items) < INVENTORY_CAPACITY:
		inventory_items.append(item_name)


func inventory_item_replaced(item_name_replaced, item_name_replacing):
	var item_index = inventory_items.find(item_name_replaced)
	inventory_items[item_index] = item_name_replacing


func inventory_item_removed(item_name):
	inventory_items.erase(item_name)


func set_game_resources_directory(name):
	_game_resources_directory = name
	_load_game_resources()


func register_unique_name(unique_name):
	assert(not _unique_names.has(unique_name))
	
	var single_argument_signals = [
		"interactive_item_selected",
		"interactive_item_deselected",
		"interactive_item_activated",
		"inventory_item_obtained",
		"inventory_item_selected",
		"inventory_item_removed",
		"inventory_item_used",
	]
	
	var double_argument_signals = [
		"inventory_item_{}_replaced_by_{}",
		"inventory_item_{}_used_on_inventory_{}",
		"inventory_item_{}_used_on_environment_{}",
	]
	
	for s in single_argument_signals:
		add_user_signal(s + "_" + unique_name)
	for s in double_argument_signals:
		for other_name in _unique_names:
			add_user_signal(s.format([unique_name, other_name], "{}"))
			add_user_signal(s.format([other_name, unique_name], "{}"))
	_unique_names.append(unique_name)


func register_inventory_item(item_name):
	assert(not _inventory_config.has(item_name))
	register_unique_name(item_name)
	
	var icon_path = "res://{}/inventory_items/icons/{}.png".format(
		[_game_resources_directory, item_name], "{}"
	)
	# Comply with Godot scene naming standards
	var model_name = item_name.capitalize().replace(" ", "")
	var model_path = "res://{}/inventory_items/models/{}.tscn".format(
		[_game_resources_directory, model_name], "{}"
	)
	_inventory_config[item_name] = {
		"icon": load(icon_path),
		"model": load(model_path),
	}


func get_inventory_item_icon(item_name):
	return _inventory_config[item_name]["icon"]


func get_inventory_item_model(item_name):
	return _inventory_config[item_name]["model"]


# Monologue
class Monologue extends Node:
	var _audio_player = null
	var _currently_playing = null
	var _monologues = {}
	var _defaults = []
	var _default_scheduled = false
	signal started (monologue_name)
	signal finished (monologue_name, interrupted)
	
	func _init():
		_audio_player = AudioStreamPlayer.new()
		_audio_player.bus = "Music"
		add_child(_audio_player)
		_audio_player.connect("finished", self, "_on_audio_player_finished")
	
	func register(monologue_name, transcript=""):
		assert(not _monologues.has(monologue_name))
		var sound_path = "res://{}/voice/{}.ogg".format(
			[goat._game_resources_directory, monologue_name], "{}"
		)
		var sound = load(sound_path)
		if sound is AudioStreamSample:
			sound.loop_mode = AudioStreamSample.LOOP_DISABLED
		elif sound is AudioStreamOGGVorbis:
			sound.loop = false
		_monologues[monologue_name] = {"sound": sound, "transcript": transcript}
	
	func trigger(signal_object, signal_name, monologue_names):
		signal_object.connect(signal_name, self, "play", [monologue_names])
	
	func play(monologue_names=null):
		_default_scheduled = false
		if monologue_names == null:
			return
		if _audio_player.playing:
			emit_signal("finished", _currently_playing, true)
			_audio_player.stop()
		var monologue_name = null;
		if monologue_names is Array:
			randomize()
			monologue_name = monologue_names[randi() % monologue_names.size()]
		else:
			monologue_name = monologue_names
		_currently_playing = monologue_name
		_audio_player.stream = _monologues[monologue_name]["sound"]
		_audio_player.play()
		emit_signal("started", monologue_name)
	
	func _process(_delta):
		if _default_scheduled:
			play_default()
	
	func set_defaults(defaults):
		_defaults = defaults
	
	func get_transcript(monologue_name):
		return _monologues[monologue_name]["transcript"]
	
	func _on_audio_player_finished():
		emit_signal("finished", _currently_playing, false)
		_currently_playing = null
	
	func connect_default(signal_object, signal_name):
		signal_object.connect(signal_name, self, "schedule_default")
	
	func schedule_default(_arg1=null, _arg2=null, _arg3=null, _arg4=null):
		_default_scheduled = true
	
	func play_default():
		if _defaults:
			randomize()
			var monologue_name = _defaults[randi() % _defaults.size()]
			play(monologue_name)
		_default_scheduled = false


# Settings
func update_fullscreen():
	OS.window_fullscreen = settings.get_value("graphics", "fullscreen")


func update_shadows():
	var shadows_enabled = settings.get_value("graphics", "shadows")
	var lamps = get_tree().get_nodes_in_group("lamp")
	for lamp in lamps:
		lamp.shadow_enabled = shadows_enabled
		# Specular light creates reflections, without shadows they look wrong
		lamp.light_specular = 0.5 if shadows_enabled else 0.0


func update_music_volume():
	var volume = settings.get_value("sound", "music_volume")
	var bus_id = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_id, volume)


func update_effects_volume():
	var volume = settings.get_value("sound", "effects_volume")
	var bus_id = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(bus_id, volume)


class Settings:
	const SETTINGS_FILE_NAME = "user://settings.cfg"
	const DEFAULT_VALUES = [
		["graphics", "fullscreen", true],
		["graphics", "glow", true],
		["graphics", "reflections", true],
		["graphics", "shadows", true],
		["sound", "music_volume", 0.0],
		["sound", "effects_volume", 0.0],
		["controls", "mouse_sensitivity", 0.3],
	]
	var _settings_file = ConfigFile.new()
	var autosave = true
	
	signal value_changed (section, key)
	
	func _init():
		_settings_file.load(SETTINGS_FILE_NAME)
		for entry in DEFAULT_VALUES:
			var section =  entry[0]
			var key = entry[1]
			add_user_signal("value_changed_{}_{}".format([section, key], "{}"))
			if _settings_file.get_value(section, key) == null:
				var value = entry[2]
				_settings_file.set_value(section, key, value)
		_settings_file.save(SETTINGS_FILE_NAME)
	
	func get_value(section, key):
		var value = _settings_file.get_value(section, key)
		assert(value != null)
		return value
	
	func set_value(section, key, value):
		var previous_value = _settings_file.get_value(section, key)
		if previous_value != value:
			_settings_file.set_value(section, key, value)
			if autosave:
				_settings_file.save(SETTINGS_FILE_NAME)
			emit_signal("value_changed", section, key)
			emit_signal("value_changed_{}_{}".format([section, key], "{}"))
