extends Control

signal rotation_reset_requested

@onready var item_buttons_container = $MarginContainer/ItemButtons
@onready var use_button = $MarginContainer/Buttons/UseButton
@onready var reset_rotation_button = $MarginContainer/Buttons/ResetRotationButton
@onready var empty_inventory_text = $MarginContainer/CenterContainer/EmptyInventoryText
@onready var help_text = $MarginContainer/MarginContainer/HelpText


func _ready():
	goat.connect("game_mode_changed", self._on_game_mode_changed)
	goat_inventory.connect("item_selected", self._on_item_selected)
	goat_inventory.connect("items_changed", self._on_items_changed)
	
	_on_items_changed(goat_inventory.get_items())
	
	# Connect button signals
	for i in range(goat_inventory.CAPACITY):
		var item_button = _get_item_button(i)
		item_button.connect("pressed", self._on_item_button_pressed.bind(i))
		item_button.connect("gui_input", self._on_item_button_gui_input.bind(i))
		item_button.connect("button_down", self._on_item_button_down.bind(i))
		item_button.connect("button_up", self._on_item_button_up.bind(i))


func _on_game_mode_changed(new_game_mode) -> void:
	# Select the last item if this is the first time the inventory is opened
	if (
		new_game_mode == goat.GameMode.INVENTORY and
		goat_inventory.get_selected_item() == null and
		not goat_inventory.get_items().is_empty()
	):
		var item_name = goat_inventory.get_items().back()
		goat_inventory.select_item(item_name)


func _on_item_selected(item_name) -> void:
	if item_name == null:
		return
	
	var item_index = goat_inventory.get_items().find(item_name)
	var item_button = _get_item_button(item_index)
	# This should not send "pressed" signal
	if not item_button.button_pressed:
		item_button.button_pressed = true


func _on_items_changed(new_items: Array) -> void:
	# Update icons
	for i in range(goat_inventory.CAPACITY):
		var item_button = _get_item_button(i)
		if i < len(new_items):
			var item_name = new_items[i]
			var selected = item_name == goat_inventory.get_selected_item()
			item_button.icon = goat_inventory.get_item_icon(item_name)
			item_button.disabled = false
			item_button.button_pressed = selected
		else:
			item_button.icon = null
			item_button.disabled = true
	
	# Handle empty inventory
	var inventory_empty = new_items.is_empty()
	use_button.disabled = inventory_empty
	reset_rotation_button.disabled = inventory_empty
	empty_inventory_text.visible = inventory_empty
	help_text.visible = not inventory_empty


func _on_item_button_pressed(item_index: int) -> void:
	var item_name = goat_inventory.get_items()[item_index]
	goat_inventory.select_item(item_name)


func _on_item_button_gui_input(event: InputEvent, item_index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			var items = goat_inventory.get_items()
			if len(items) > 0:
				var item_name = items[item_index]
				goat_inventory.use_item(item_name)


func _on_item_button_down(item_index: int) -> void:
	var item_name = goat_inventory.get_items()[item_index]
	var texture = goat_inventory.get_item_icon(item_name)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_DRAG, Vector2(32, 32))
	var item_button = _get_item_button(item_index)
	item_button.mouse_default_cursor_shape = Input.CURSOR_DRAG


func _on_item_button_up(item_index: int) -> void:
	var item_name = goat_inventory.get_items()[item_index]
	
	var item_buttons_area = item_buttons_container.get_global_rect()
	var mouse_position = get_global_mouse_position()
	
	# Check if item was dropped, but not on other item buttons
	if (
		item_name != goat_inventory.get_selected_item() and
		not item_buttons_area.has_point(mouse_position)
	):
		var inventory_item = goat_inventory.get_selected_item()
		goat_inventory.use_item(item_name, inventory_item)
	
	# Restore original cursor shape
	var item_button = _get_item_button(item_index)
	item_button.mouse_default_cursor_shape = Input.CURSOR_ARROW
	Input.set_custom_mouse_cursor(null, Input.CURSOR_DRAG)
	# Send mouse motion event to update cursor's shape immediately
	get_viewport().push_input(InputEventMouseMotion.new())


func _on_UseButton_pressed() -> void:
	if goat_voice.is_playing():
		return
	var selected_item_name = goat_inventory.get_selected_item()
	if selected_item_name:
		goat_inventory.use_item(selected_item_name)


func _on_BackButton_pressed() -> void:
	goat.game_mode = goat.GameMode.EXPLORING


func _get_item_button(button_index: int) -> Button:
	return get_node("MarginContainer/ItemButtons/Button" + str(button_index)) as Button


func _on_ResetRotationButton_pressed():
	emit_signal("rotation_reset_requested")
