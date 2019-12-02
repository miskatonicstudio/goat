extends Control

const item_button_path = "TopBar/Button{index}"

var currently_selected_item_name = null
var currently_selected_item_index = null
var currently_dragged_item_name = null

onready var top_bar = $TopBar
onready var use_button = $BottomBar/UseButton
onready var empty_inventory_text = $CenterContainer/EmptyInventoryText


func _ready():
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_selected", self, "item_selected")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_items_changed", self, "inventory_items_changed")
	
	# Connect button signals
	for i in range(goat.INVENTORY_CAPACITY):
		var item_button = get_node(item_button_path.format({"index": i}))
		item_button.connect("pressed", self, "item_button_pressed", [i])
		item_button.connect("button_down", self, "item_button_down", [i])


func _input(event):
	if currently_dragged_item_name and Input.is_action_just_released("goat_drag_inventory"):
		Input.set_custom_mouse_cursor(goat.game_cursor)
		if (
			event is InputEventMouse and
			not top_bar.get_global_rect().has_point(event.global_position) and
			currently_dragged_item_name != currently_selected_item_name
		):
			# Making a copy of names to avoid changing them when the first signal is handled
			var item_name_1 = currently_dragged_item_name
			var item_name_2 = currently_selected_item_name
			goat.emit_signal("inventory_item_used_on_inventory", item_name_1, item_name_2)
			goat.emit_signal(
				"inventory_item_{}_used_on_inventory_{}".format([item_name_1, item_name_2], "{}")
			)
		currently_dragged_item_name = null


func game_mode_changed(new_game_mode):
	if (
		new_game_mode == goat.GAME_MODE_INVENTORY and
		currently_selected_item_name == null and
		not goat.inventory_items.empty()
	):
		var item_name = goat.inventory_items.back()
		goat.emit_signal("inventory_item_selected", item_name)
		goat.emit_signal("inventory_item_selected_" + item_name)


func item_selected(item_name):
	var item_index = goat.inventory_items.find(item_name)
	var item_button = get_node(item_button_path.format({"index": item_index}))
	# This should not send "pressed" signal
	if not item_button.pressed:
		item_button.pressed = true
	currently_selected_item_name = item_name
	currently_selected_item_index = item_index


func inventory_items_changed(inventory_items):
	# Update icons
	for i in range(goat.INVENTORY_CAPACITY):
		var item_button = get_node(item_button_path.format({"index": i}))
		if i < len(inventory_items):
			var item_name = inventory_items[i]
			item_button.icon = goat.get_inventory_item_icon(item_name)
			item_button.disabled = false
			item_button.pressed = item_name == currently_selected_item_name
		else:
			item_button.icon = null
			item_button.disabled = true
	
	var inventory_empty = inventory_items.empty()
	# Select a new item if current was removed
	if currently_selected_item_name and not inventory_items.has(currently_selected_item_name):
		var item_index = currently_selected_item_index
		currently_selected_item_name = null
		currently_selected_item_index = null
		if not inventory_empty:
			if item_index >= len(inventory_items):
				item_index -= 1
			var new_item_name = inventory_items[item_index]
			goat.emit_signal("inventory_item_selected", new_item_name)
			goat.emit_signal("inventory_item_selected_" + new_item_name)
	# Handle empty inventory
	empty_inventory_text.visible = inventory_empty
	use_button.disabled = inventory_empty


func item_button_pressed(item_index):
	var item_name = goat.inventory_items[item_index]
	if item_name != currently_selected_item_name:
		goat.emit_signal("inventory_item_selected", item_name)
		goat.emit_signal("inventory_item_selected_" + item_name)


func item_button_down(item_index):
	var item_name = goat.inventory_items[item_index]
	var texture = goat.get_inventory_item_icon(item_name)
	currently_dragged_item_name = item_name
	Input.set_custom_mouse_cursor(texture, 0, Vector2(32, 32))


func _on_UseButton_pressed():
	if currently_selected_item_name:
		# Making a copy of names to avoid changing them when the first signal is handled
		var item_name = currently_selected_item_name
		goat.emit_signal("inventory_item_used", item_name)
		goat.emit_signal("inventory_item_used_" + item_name)


func _on_BackButton_pressed():
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
