extends Control

const SLIDE_TIME = 0.4
const MOVEMENT_OFFSET = 70
const MOVEMENT_RANGE = 80

@onready var animation_player = $AnimationPlayer
@onready var items = $Items


func _ready():
	goat.connect("game_mode_changed", self._on_game_mode_changed)
	goat_inventory.connect("item_added", self._on_item_added)
	goat_inventory.connect("item_replaced", self._on_item_replaced)
	goat_inventory.connect("items_changed", self._on_items_changed)


func _on_game_mode_changed(new_game_mode):
	if new_game_mode != goat.GameMode.EXPLORING:
		animation_player.stop(true)
		hide()


func _on_items_changed(new_items):
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node("Items/Item" + str(i))
		if i < len(new_items):
			var item_name = new_items[i]
			item_button.icon = goat_inventory.get_item_icon(item_name)
		else:
			item_button.icon = null


func _on_item_replaced(_replaced_item_name, _replacing_item_name):
	_on_item_added(_replacing_item_name)


func _on_item_added(_item_name):
	if goat.game_mode == goat.GameMode.EXPLORING or goat.game_mode == goat.GameMode.CONTEXT_INVENTORY:
		show()
		if animation_player.is_playing():
			var progress = SLIDE_TIME * (
				MOVEMENT_OFFSET + items.position.x
			) / MOVEMENT_RANGE
			animation_player.seek(progress, true)
		else:
			animation_player.play("show")


func _on_AnimationPlayer_animation_finished(_anim_name):
	hide()
