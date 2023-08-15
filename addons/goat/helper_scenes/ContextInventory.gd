extends Control

const ITEM_BUTTON_PATH = "CenterContainer/Center/Item{index}/Button"

@onready var exit_button = $CenterContainer/ExitButton


func _ready():
	goat.connect("game_mode_changed", self._on_game_mode_changed)
	goat_inventory.connect("items_changed", self._on_items_changed)
	
	# Connect button signals
	for i in range(goat_inventory.CAPACITY):
		var item_button = get_node(ITEM_BUTTON_PATH.format({"index": i}))
		item_button.connect("pressed", self._on_item_button_pressed.bind(i))
		item_button.disabled = true


func _input(event):
	if goat.game_mode != goat.GameMode.CONTEXT_INVENTORY:
		return
	
	if Input.is_action_just_pressed("goat_dismiss"):
		_go_back_to_exploring()
	
	if event is InputEventMouseMotion:
		exit_button.release_focus()


func _on_game_mode_changed(new_game_mode):
	if new_game_mode == goat.GameMode.CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# This is a workaround for "hovering" the button before the mouse moves
		exit_button.grab_focus()
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
	_go_back_to_exploring()
	goat_inventory.use_item(item_name, environment_object)


func _on_ExitButton_pressed():
	_go_back_to_exploring()


func _go_back_to_exploring():
	goat.game_mode = goat.GameMode.EXPLORING
