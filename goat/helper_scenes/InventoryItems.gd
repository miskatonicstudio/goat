extends Control

const ITEM_BUTTON_PATH = "Items/Button{index}"

var currently_dragged_item_name = null

onready var items_container = $Items
onready var use_button = $Buttons/UseButton
onready var empty_inventory_text = $CenterContainer/EmptyInventoryText


func _ready():
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat_inventory.connect("item_selected", self, "_on_item_selected")
	goat_inventory.connect("items_changed", self, "_on_items_changed")
	
	# Connect button signals
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node(ITEM_BUTTON_PATH.format({"index": i}))
		item_button.connect("pressed", self, "_on_item_button_pressed", [i])
		item_button.connect("button_down", self, "_on_item_button_down", [i])


func _input(event):
	if (
		currently_dragged_item_name and
		Input.is_action_just_released("goat_drag_inventory")
	):
		Input.set_custom_mouse_cursor(goat.game_cursor)
		var item_container_area = items_container.get_global_rect()
		if (
			event is InputEventMouse and
			not item_container_area.has_point(event.global_position) and
			currently_dragged_item_name != goat_inventory.get_selected_item()
		):
			# Making a copy of names to avoid changing them
			# when the first signal is handled
			var item_name_1 = currently_dragged_item_name
			var item_name_2 = goat_inventory.get_selected_item()
			goat.emit_signal(
				"inventory_item_used_on_inventory", item_name_1, item_name_2
			)
		currently_dragged_item_name = null


func _on_game_mode_changed(new_game_mode):
	# Select the last item if this is the first time the inventory is opened
	if (
		new_game_mode == goat.GameMode.INVENTORY and
		goat_inventory.get_selected_item() == null and
		not goat_inventory.get_items().empty()
	):
		var item_name = goat_inventory.get_items().back()
		goat_inventory.select_item(item_name)


func _on_item_selected(item_name):
	if item_name == null:
		return
	var item_index = goat_inventory.get_items().find(item_name)
	var item_button = get_node(ITEM_BUTTON_PATH.format({"index": item_index}))
	# This should not send "pressed" signal
	if not item_button.pressed:
		item_button.pressed = true


func _on_items_changed(new_items):
	# Update icons
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node(ITEM_BUTTON_PATH.format({"index": i}))
		if i < len(new_items):
			var item_name = new_items[i]
			var selected = item_name == goat_inventory.get_selected_item()
			item_button.icon = goat_inventory.get_item_icon(item_name)
			item_button.disabled = false
			item_button.pressed = selected
		else:
			item_button.icon = null
			item_button.disabled = true
	
	var inventory_empty = new_items.empty()
	# Handle empty inventory
	empty_inventory_text.visible = inventory_empty
	use_button.disabled = inventory_empty


func _on_item_button_pressed(item_index):
	var item_name = goat_inventory.get_items()[item_index]
	goat_inventory.select_item(item_name)


func _on_item_button_down(item_index):
	var item_name = goat_inventory.get_items()[item_index]
	var texture = goat_inventory.get_item_icon(item_name)
	currently_dragged_item_name = item_name
	Input.set_custom_mouse_cursor(texture, 0, Vector2(32, 32))


func _on_UseButton_pressed():
	var selected_item_name = goat_inventory.get_selected_item()
	if selected_item_name:
		# Making a copy of names to avoid changing them when the first signal is handled
		goat.emit_signal("inventory_item_used", selected_item_name)


func _on_BackButton_pressed():
	goat.game_mode = goat.GameMode.EXPLORING
