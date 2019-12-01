extends Node

# Signals
signal interactive_item_selected (item_name)
signal interactive_item_deselected (item_name)
signal interactive_item_activated (item_name, position)

signal inventory_item_obtained (item_name)
signal inventory_item_selected (item_name)
signal inventory_item_removed (item_name)
signal inventory_item_replaced (item_name_replaced, item_name_replacing)
signal inventory_item_used (item_name)
signal inventory_item_used_on_inventory (item_name, inventory_item_name)
signal inventory_item_used_on_environment (item_name, environment_item_name)

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

# Variables
export (GameMode) var game_mode = GAME_MODE_EXPLORING

var _unique_names = []
var _game_resources_directory = ProjectSettings.get("application/config/name").to_lower()
var _inventory_items = {}

var game_cursor = null
var monologue_player = null


func _ready():
	monologue_player = AudioStreamPlayer.new()
	add_child(monologue_player)
	connect("game_mode_changed", self, "game_mode_changed")
	_load_game_resources()


func _load_game_resources():
	game_cursor = load(
		"res://{}/images/cursor.png".format([_game_resources_directory], "{}")
	)


func connect_monologue(signal_name, sound):
	connect(signal_name, self, "play_monologue", [sound])


func game_mode_changed(new_game_mode):
	game_mode = new_game_mode


func play_monologue(arg1, sound):
	if monologue_player.playing:
		monologue_player.stop()
	monologue_player.stream = sound
	monologue_player.stream.loop = false
	monologue_player.play()


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


func set_game_resources_directory(name):
	_game_resources_directory = name
	_load_game_resources()


func register_inventory_item(item_name):
	assert(not _inventory_items.has(item_name))
	
	var icon_path = "res://{}/inventory_items/icons/{}.png".format(
		[_game_resources_directory, item_name], "{}"
	)
	# Comply with Godot scene naming standards
	var model_name = item_name.capitalize().replace(" ", "")
	var model_path = "res://{}/inventory_items/models/{}.tscn".format(
		[_game_resources_directory, model_name], "{}"
	)
	_inventory_items[item_name] = {
		"icon": load(icon_path),
		"model": load(model_path),
	}


func get_inventory_item_icon(item_name):
	return _inventory_items[item_name]["icon"]


func get_inventory_item_model(item_name):
	return _inventory_items[item_name]["model"]
