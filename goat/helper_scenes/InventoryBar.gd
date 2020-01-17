extends Control

const SLIDE_TIME = 0.4
const MOVEMENT_OFFSET = 70
const MOVEMENT_RANGE = 80

onready var animation_player = $AnimationPlayer
onready var items = $Items


func _ready():
	goat.connect("game_mode_changed", self, "game_mode_changed")
	goat_inventory.connect("item_added", self, "_on_item_added")
	goat_inventory.connect("items_changed", self, "_on_items_changed")


func game_mode_changed(_new_game_mode):
	animation_player.stop(true)
	animation_player.seek(0, true)


func _on_items_changed(new_items):
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node("Items/Item" + str(i))
		if i < len(new_items):
			var item_name = new_items[i]
			item_button.icon = goat_inventory.get_item_icon(item_name)
		else:
			item_button.icon = null


func _on_item_added(_item_name):
	if goat.game_mode == goat.GameMode.EXPLORING:
		if animation_player.is_playing():
			var progress = SLIDE_TIME * (
				MOVEMENT_OFFSET + items.rect_position.x
			) / MOVEMENT_RANGE
			animation_player.seek(progress, true)
		else:
			animation_player.play("show")
