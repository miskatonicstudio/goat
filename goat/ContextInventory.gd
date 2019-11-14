extends Control

onready var item_container = $ScrollContainer/CenterContainer/HBoxContainer


func _ready():
	oat_interaction_signals.connect("oat_game_mode_changed", self, "game_mode_changed")
	oat_interaction_signals.connect("oat_environment_item_obtained", self, "item_obtained")
	oat_interaction_signals.connect("oat_inventory_item_removed", self, "item_removed")
	oat_interaction_signals.connect("oat_inventory_item_replaced", self, "item_replaced")


func game_mode_changed(new_game_mode):
	if new_game_mode == oat_interaction_signals.GameMode.CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		hide()


func item_obtained(item_name, insert_after=null):
	var item_button = TextureButton.new()
	item_button.texture_normal = oat_interaction_signals.inventory_items_textures[item_name]
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
	var replaced_item = get_tree().get_nodes_in_group("oat_context_inventory_item_icon_" + item_name_replaced).pop_front()
	item_obtained(item_name_replacing, replaced_item)
	replaced_item.queue_free()
	oat_interaction_signals.emit_signal("oat_context_inventory_item_selected", item_name_replacing)


func item_button_pressed(item_name):
	oat_interaction_signals.set_context_inventory_item_name(item_name)


func _on_ExitButton_pressed():
	# TODO: react also on Esc
	oat_interaction_signals.set_context_inventory_item_name(null)
