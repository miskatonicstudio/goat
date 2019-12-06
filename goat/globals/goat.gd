extends Node

# Signals
# warning-ignore:unused_signal
signal interactive_item_selected (item_name)
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

enum GameMode {
	GAME_MODE_EXPLORING,
	GAME_MODE_INVENTORY,
	GAME_MODE_CONTEXT_INVENTORY
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
var _monologues = {}

var game_cursor = null
var _monologue_player = null

var settings = Settings.new()


func _ready():
	_monologue_player = AudioStreamPlayer.new()
	add_child(_monologue_player)
	# warning-ignore:return_value_discarded
	connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	connect("inventory_item_obtained", self, "inventory_item_obtained")
	# warning-ignore:return_value_discarded
	connect("inventory_item_replaced", self, "inventory_item_replaced")
	# warning-ignore:return_value_discarded
	connect("inventory_item_removed", self, "inventory_item_removed")
	_load_game_resources()
	
	settings.connect("value_changed_graphics_fullscreen", self, "update_fullscreen")
	update_fullscreen()


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


func register_monologue(sound_name):
	assert(not _monologues.has(sound_name))
	var sound_path = "res://{}/sounds/{}.ogg".format(
		[_game_resources_directory, sound_name], "{}"
	)
	var sound = load(sound_path)
	if sound is AudioStreamSample:
		sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	elif sound is AudioStreamOGGVorbis:
		sound.loop = false
	_monologues[sound_name] = sound


func connect_monologue(signal_name, sound_name):
	# warning-ignore:return_value_discarded
	connect(signal_name, self, "play_monologue", [sound_name])


# Can be used manually
func play_monologue(sound_name):
	if _monologue_player.playing:
		_monologue_player.stop()
	_monologue_player.stream = _monologues[sound_name]
	_monologue_player.play()


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


# Settings
func update_fullscreen():
	OS.window_fullscreen = settings.get_value("graphics", "fullscreen")


class Settings:
	const SETTINGS_FILE_NAME = "user://settings.cfg"
	const DEFAULT_VALUES = [
		["graphics", "fullscreen", true],
		["graphics", "glow", true],
		["graphics", "reflections", true],
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
