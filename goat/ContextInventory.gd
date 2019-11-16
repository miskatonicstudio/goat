extends Control

onready var item_container = $ScrollContainer/CenterContainer/HBoxContainer

var environment_item_name = null


func _ready():
	goat.connect("game_mode_changed", self, "game_mode_changed")
	goat.connect("oat_environment_item_selected", self, "environment_item_selected")
	goat.connect("oat_environment_item_deselected", self, "environment_item_deselected")
	goat.connect("oat_environment_item_obtained", self, "item_obtained")
	goat.connect("oat_inventory_item_removed", self, "item_removed")
	goat.connect("oat_inventory_item_replaced", self, "item_replaced")


func game_mode_changed(new_game_mode):
	if new_game_mode == goat.GAME_MODE_CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		hide()


func environment_item_selected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		environment_item_name = item_name


func environment_item_deselected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		if item_name == environment_item_name:
			environment_item_name = null


func item_obtained(item_name, insert_after=null):
	var item_button = TextureButton.new()
	item_button.texture_normal = goat.inventory_items_textures[item_name]
	item_button.connect("pressed", self, "item_button_pressed", [item_name, ])
	item_button.add_to_group("oat_context_inventory_item_icon_" + item_name)
	
	if insert_after:
		item_container.add_child_below_node(insert_after, item_button)
	else:
		item_container.add_child(item_button)


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group("oat_context_inventory_item_icon_" + item_name).pop_front()
	removed_item.queue_free()


func item_replaced(item_name_replaced, item_name_replacing):
	var replaced_item = get_tree().get_nodes_in_group(
		"oat_context_inventory_item_icon_" + item_name_replaced
	).pop_front()
	item_obtained(item_name_replacing, replaced_item)
	replaced_item.queue_free()
	goat.emit_signal("oat_context_inventory_item_selected", item_name_replacing)


func item_button_pressed(item_name):
	goat.emit_signal("oat_inventory_item_used_on_environment", item_name, environment_item_name)
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)


func _on_ExitButton_pressed():
	# TODO: react also on Esc
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
