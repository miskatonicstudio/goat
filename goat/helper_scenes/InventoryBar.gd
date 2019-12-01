extends Control

onready var animation_player = $AnimationPlayer


func _ready():
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_obtained", self, "item_obtained")


func game_mode_changed(_new_game_mode):
	animation_player.stop(true)
	animation_player.seek(0, true)


func item_obtained(_item_name):
	for i in range(goat.INVENTORY_CAPACITY):
		var item_button = get_node("Items/Item" + str(i))
		if i < len(goat.inventory_items):
			var item_name = goat.inventory_items[i]
			item_button.icon = goat.get_inventory_item_icon(item_name)
		else:
			item_button.icon = null
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		animation_player.play("show")
