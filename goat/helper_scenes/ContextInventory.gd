extends Control

const ITEM_BUTTON_PATH = "CenterContainer/Center/Item{index}/Button"

var environment_item_name = null


func _ready():
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat.connect(
		"interactive_item_selected", self, "_on_interactive_item_selected"
	)
	goat.connect(
		"interactive_item_deselected", self, "_on_interactive_item_deselected"
	)
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
		go_back_to_exploring()


func _on_game_mode_changed(new_game_mode):
	if new_game_mode == goat.GameMode.CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(goat.game_cursor)
		show()
	else:
		hide()


func _on_interactive_item_selected(item_name, _position):
	if goat.game_mode == goat.GameMode.EXPLORING:
		environment_item_name = item_name


func _on_interactive_item_deselected(item_name):
	if goat.game_mode == goat.GameMode.EXPLORING:
		if item_name == environment_item_name:
			environment_item_name = null


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
	goat.emit_signal(
		"inventory_item_used_on_environment", item_name, environment_item_name
		)
	go_back_to_exploring()


func _on_ExitButton_pressed():
	go_back_to_exploring()


func go_back_to_exploring():
	goat.game_mode = goat.GameMode.EXPLORING
	get_tree().set_input_as_handled()
