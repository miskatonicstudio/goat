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

signal oat_interactive_screen_activated (screen_name, position)

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
# TODO: add a nice method to add inventory items here
export (Dictionary) var inventory_items_textures = {}
export (Dictionary) var inventory_items_models = {}

var monologue_player = null


func _ready():
	# TODO: send detailed signals and allow monologue player to easily connect to them
	monologue_player = AudioStreamPlayer.new()
	add_child(monologue_player)
	connect("oat_game_mode_changed", self, "game_mode_changed")


func connect_monologue(signal_name, sound):
	connect(signal_name, self, "play_monologue", [sound])


func game_mode_changed(new_game_mode):
	game_mode = new_game_mode


# TODO: send individual signals for every event, with no args, and remove arg1
func play_monologue(arg1, sound):
	if monologue_player.playing:
		monologue_player.stop()
	monologue_player.stream = sound
	monologue_player.stream.loop = false
	monologue_player.play()