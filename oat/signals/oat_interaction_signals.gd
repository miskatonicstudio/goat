extends Node

signal oat_environment_item_selected (item_name)
# TODO: do not send "deselected" when obtained
signal oat_environment_item_deselected (item_name)
signal oat_environment_item_activated (item_name)
# TODO: signal for permanent deactivation?
# TODO: signal for reactivation (single use => deactivated => reactivated, or disabled => enabled)

# TODO: rename this to "inventory_item" added or obtained
signal oat_environment_item_obtained (item_name)
signal oat_inventory_item_selected (item_name)
signal oat_inventory_item_used (item_name)
signal oat_inventory_item_removed (item_name)
signal oat_inventory_item_replaced (item_name_replaced, item_name_replacing)
signal oat_inventory_item_used_on_inventory (item_name, inventory_item_name)
signal oat_inventory_item_used_on_environment (item_name, environment_item_name)

# TODO: send also old game mode, move all logic to global
signal oat_game_mode_changed (new_game_mode)

# TODO: fix enum (there are no hints in editor)
enum GameMode {
	EXPLORING,
	INVENTORY,
	CONTEXT_INVENTORY
}

# TODO: use setget for game_mode, raise exception when setting manually?
export (GameMode) var game_mode = GameMode.EXPLORING
export (Dictionary) var inventory_items_textures = {}
export (Dictionary) var inventory_items_models = {}
export (String) var selected_environment_item_name = null
# TODO: this will always be null, so just a setter will do
export (String) var context_inventory_item_name setget set_context_inventory_item_name

var monologue_player = null


func _ready():
	# TODO: send detailed signals and allow monologue player to easily connect to them
	monologue_player = AudioStreamPlayer.new()
	add_child(monologue_player)
	
	connect("oat_environment_item_selected", self, "environment_item_selected")
	connect("oat_environment_item_deselected", self, "environment_item_deselected")


# TODO: extract this to oat_event_handling.gd?
func _input(event):
	var old_game_mode = game_mode
	
	if Input.is_action_just_pressed("oat_toggle_inventory"):
		if game_mode == GameMode.EXPLORING:
			game_mode = GameMode.INVENTORY
		elif game_mode == GameMode.INVENTORY:
			game_mode = GameMode.EXPLORING
			# TODO: send this signal also when inventory is open and Esc is pressed
	if (
		Input.is_action_just_pressed("oat_toggle_context_inventory") and
		selected_environment_item_name and
		game_mode == GameMode.EXPLORING
	):
		game_mode = GameMode.CONTEXT_INVENTORY
	
	if old_game_mode != game_mode:
		emit_signal("oat_game_mode_changed", game_mode)


func set_context_inventory_item_name(new_item_name):
	if game_mode != GameMode.CONTEXT_INVENTORY:
		return
	if new_item_name:
		emit_signal("oat_inventory_item_used_on_environment", new_item_name, selected_environment_item_name)
	game_mode = GameMode.EXPLORING
	emit_signal("oat_game_mode_changed", game_mode)


func environment_item_selected(item_name):
	selected_environment_item_name = item_name


func environment_item_deselected(item_name):
	selected_environment_item_name = null


func connect_monologue(signal_name, sound):
	connect(signal_name, self, "play_monologue", [sound])


# TODO: send individual signals for every event, with no args, and remove arg1
func play_monologue(arg1, sound):
	if monologue_player.playing:
		monologue_player.stop()
	monologue_player.stream = sound
	monologue_player.stream.loop = false
	monologue_player.play()