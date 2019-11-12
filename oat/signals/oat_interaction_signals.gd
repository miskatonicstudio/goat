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

enum GameMode {
	EXPLORING,
	INVENTORY,
	CONTEXT_INVENTORY
}

export (GameMode) var game_mode = GameMode.EXPLORING
export (Dictionary) var inventory_items_textures = {}
export (Dictionary) var inventory_items_models = {}


# TODO: extract this to oat_event_handling.gd?
func _input(event):
	if Input.is_action_just_pressed("oat_toggle_inventory"):
		if game_mode == GameMode.EXPLORING:
			game_mode = GameMode.INVENTORY
			emit_signal("oat_game_mode_changed", game_mode)
		elif game_mode == GameMode.INVENTORY:
			game_mode = GameMode.EXPLORING
			# TODO: send this signal also when inventory is open and Esc is pressed
			emit_signal("oat_game_mode_changed", game_mode)