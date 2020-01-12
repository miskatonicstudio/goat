extends Control

const SIDE_SCREEN_MARGIN = 80

onready var viewport_container = $ViewportContainer
onready var viewport = $ViewportContainer/Viewport
onready var ray_cast = $ViewportContainer/Viewport/Inventory3D/Camera/RayCast3D
onready var camera = $ViewportContainer/Viewport/Inventory3D/Camera
onready var rotator = $ViewportContainer/Viewport/Inventory3D/Rotator

var current_item = null


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Godot Editor
	viewport.own_world = true
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "game_mode_changed")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_obtained", self, "item_obtained")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_selected", self, "item_selected")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_removed", self, "item_removed")
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_replaced", self, "item_replaced")
	_on_Inventory_resized()


func _input(event):
	if goat.game_mode != goat.GAME_MODE_INVENTORY:
		return
	if Input.is_action_pressed("goat_rotate_inventory"):
		var mouse_sensitivity = goat.settings.get_value("controls", "mouse_sensitivity")
		if event is InputEventMouseMotion and current_item:
			var angle_horizontal = deg2rad(event.relative.x * mouse_sensitivity)
			var angle_vertical = deg2rad(event.relative.y * mouse_sensitivity)
			current_item.rotate_y(angle_horizontal)
			current_item.rotate_x(angle_vertical)
	
	if Input.is_action_just_pressed("goat_rotate_inventory"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		ray_cast.enabled = false
		if ray_cast.currently_selected_item_name:
			goat.emit_signal("interactive_item_deselected", ray_cast.currently_selected_item_name)
			goat.emit_signal("interactive_item_deselected_" + ray_cast.currently_selected_item_name)
			ray_cast.currently_selected_item_name = null
	elif Input.is_action_just_released("goat_rotate_inventory"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(goat.game_cursor)
		ray_cast.enabled = true
	elif (
		Input.is_action_just_pressed("goat_toggle_inventory") or
		Input.is_action_just_pressed("goat_dismiss")
	):
		goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
		get_tree().set_input_as_handled()


func game_mode_changed(new_game_mode):
	var inventory_mode = new_game_mode == goat.GAME_MODE_INVENTORY
	ray_cast.enabled = inventory_mode
	if inventory_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(goat.game_cursor)
		show()
	else:
		hide()


func item_obtained(item_name):
	var obtained_item = goat.get_inventory_item_model(item_name).instance()
	obtained_item.add_to_group("goat_inventory_item")
	obtained_item.add_to_group("goat_inventory_item_" + item_name)
	obtained_item.translation.z = 999
	obtained_item.hide()
	rotator.add_child(obtained_item)


func item_selected(item_name):
	# Hide all other items
	for item in get_tree().get_nodes_in_group("goat_inventory_item"):
		item.translation.z = 999
		item.hide()
	# Select the item
	var selected_item = get_tree().get_nodes_in_group(
		"goat_inventory_item_" + item_name
	).front()
	selected_item.translation.z = 0
	selected_item.show()
	current_item = selected_item


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group(
		"goat_inventory_item_" + item_name
	).pop_front()
	removed_item.queue_free()
	if current_item == removed_item:
		current_item = null


func item_replaced(item_name_replaced, item_name_replacing):
	item_obtained(item_name_replacing)
	item_removed(item_name_replaced)


func _on_ViewportContainer_gui_input(event):
	if goat.game_mode != goat.GAME_MODE_INVENTORY:
		return
	# We are currently rotating the item
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var ray_vector = camera.project_ray_normal(event.position)
		ray_cast.cast_to = ray_vector * 4


func _on_Inventory_resized():
	# CenterContainer doesn't work correctly with ViewportContainer
	if viewport:
		var s = min(rect_size.x - 2 * SIDE_SCREEN_MARGIN, rect_size.y)
		var size = Vector2(s, s)
		viewport.size = size
		viewport_container.rect_size = size
		viewport_container.rect_position = (rect_size - size) / 2
