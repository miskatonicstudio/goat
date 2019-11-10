extends Node

signal oat_environment_item_selected (item_name)
signal oat_environment_item_deselected (item_name)
signal oat_environment_item_activated (item_name)
# TODO: signal for permanent deactivation?
signal oat_environment_item_obtained (item_name)

signal oat_toggle_inventory (inventory_open)

enum GameMode {
	EXPLORING,
	INVENTORY
}

export (GameMode) var game_mode = GameMode.EXPLORING


# TODO: extract this to oat_event_handling.gd?
func _input(event):
	if Input.is_action_just_pressed("oat_toggle_inventory"):
		if game_mode == GameMode.EXPLORING:
			game_mode = GameMode.INVENTORY
		elif game_mode == GameMode.INVENTORY:
			game_mode = GameMode.EXPLORING
		# TODO: send this signal also when inventory is open and Esc is pressed
		emit_signal("oat_toggle_inventory", game_mode == GameMode.INVENTORY)