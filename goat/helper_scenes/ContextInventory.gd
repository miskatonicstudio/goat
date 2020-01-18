extends Control

const ITEM_BUTTON_PATH = "CenterContainer/Center/Item{index}/Button"


func _ready():
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat_inventory.connect("items_changed", self, "_on_items_changed")
	
	# Connect button signals
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node(ITEM_BUTTON_PATH.format({"index": i}))
		item_button.connect("pressed", self, "_on_item_button_pressed", [i])
		item_button.disabled = true


func _input(_event):
	if goat.game_mode != goat.GameMode.CONTEXT_INVENTORY:
		return
	
	if Input.is_action_just_pressed("goat_dismiss"):
		_go_back_to_exploring()


func _on_game_mode_changed(new_game_mode):
	if new_game_mode == goat.GameMode.CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(goat.game_cursor)
		show()
	else:
		hide()


func _on_items_changed(new_items):
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node(ITEM_BUTTON_PATH.format({"index": i}))
		if i < len(new_items):
			var item_name = new_items[i]
			item_button.icon = goat_inventory.get_item_icon(item_name)
			item_button.disabled = false
		else:
			item_button.icon = null
			item_button.disabled = true


func _on_item_button_pressed(item_index):
	var item_name = goat_inventory.get_items()[item_index]
	var environment_object = goat_interaction.get_selected_object("environment")
	goat_inventory.use_item(item_name, environment_object)
	_go_back_to_exploring()


func _on_ExitButton_pressed():
	_go_back_to_exploring()


func _go_back_to_exploring():
	goat.game_mode = goat.GameMode.EXPLORING
