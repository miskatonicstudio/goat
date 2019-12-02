extends Control

const item_button_path = "CenterContainer/Center/Item{index}/Button"

var environment_item_name = null


func _ready():
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_selected", self, "interactive_item_selected")
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_deselected", self, "interactive_item_deselected")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_items_changed", self, "inventory_items_changed")
	
	# Connect button signals
	for i in range(goat.INVENTORY_CAPACITY):
		var item_button = get_node(item_button_path.format({"index": i}))
		item_button.connect("pressed", self, "item_button_pressed", [i])


func _input(_event):
	if goat.game_mode != goat.GAME_MODE_CONTEXT_INVENTORY:
		return
	if Input.is_action_just_pressed("goat_dismiss"):
		go_back_to_exploring()


func game_mode_changed(new_game_mode):
	if new_game_mode == goat.GAME_MODE_CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		Input.set_custom_mouse_cursor(goat.game_cursor)
		show()
	else:
		hide()


func interactive_item_selected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		environment_item_name = item_name


func interactive_item_deselected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		if item_name == environment_item_name:
			environment_item_name = null


func inventory_items_changed(inventory_items):
	for i in range(goat.INVENTORY_CAPACITY):
		var item_button = get_node(item_button_path.format({"index": i}))
		if i < len(inventory_items):
			item_button.icon = goat.get_inventory_item_icon(inventory_items[i])
			item_button.disabled = false
		else:
			item_button.icon = null
			item_button.disabled = true


func item_button_pressed(item_index):
	var item_name = goat.inventory_items[item_index]
	goat.emit_signal("inventory_item_used_on_environment", item_name, environment_item_name)
	goat.emit_signal(
		"inventory_item_{}_used_on_environment_{}".format([item_name, environment_item_name], "{}")
	)
	go_back_to_exploring()


func _on_ExitButton_pressed():
	go_back_to_exploring()


func go_back_to_exploring():
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
