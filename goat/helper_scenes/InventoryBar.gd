extends Control

const SLIDE_TIME = 0.4
const MOVEMENT_OFFSET = 70
const MOVEMENT_RANGE = 80

onready var animation_player = $AnimationPlayer


func _ready():
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_obtained", self, "item_obtained")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_items_changed", self, "inventory_items_changed")


func game_mode_changed(_new_game_mode):
	animation_player.stop(true)
	animation_player.seek(0, true)


func inventory_items_changed(inventory_items):
	for i in range(goat.INVENTORY_CAPACITY):
		var item_button = get_node("Items/Item" + str(i))
		if i < len(inventory_items):
			var item_name = inventory_items[i]
			item_button.icon = goat.get_inventory_item_icon(item_name)
		else:
			item_button.icon = null


func item_obtained(_item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		if animation_player.is_playing():
			var progress = SLIDE_TIME * (MOVEMENT_OFFSET + $Items.rect_position.x) / MOVEMENT_RANGE
			animation_player.seek(progress, true)
		else:
			animation_player.play("show")
