extends Control

export var ROTATION_SENSITIVITY_X = 1.0
export var ROTATION_SENSITIVITY_Y = 1.0

const MAX_VERTICAL_ANGLE = 80
onready var viewport = $CenterContainer/ViewportContainer/Viewport
onready var ray_cast = $CenterContainer/ViewportContainer/Viewport/Inventory3D/Camera/RayCast3D
onready var camera = $CenterContainer/ViewportContainer/Viewport/Inventory3D/Camera
onready var rotator = $CenterContainer/ViewportContainer/Viewport/Inventory3D/Rotator
var current_angle_vertical = 0


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Godot Editor
	viewport.own_world = true
	goat.connect("game_mode_changed", self, "game_mode_changed")
	goat.connect("inventory_item_obtained", self, "item_obtained")
	goat.connect("oat_inventory_item_selected", self, "item_selected")
	goat.connect("oat_inventory_item_removed", self, "item_removed")
	goat.connect("oat_inventory_item_replaced", self, "item_replaced")


func _input(event):
	if goat.game_mode != goat.GAME_MODE_INVENTORY:
		return
	if Input.is_action_pressed("goat_rotate_inventory"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event is InputEventMouseMotion:
			var angles = event.relative
			var angle_horizontal = deg2rad(angles.x * ROTATION_SENSITIVITY_X)
			var angle_vertical = current_angle_vertical + (angles.y * ROTATION_SENSITIVITY_Y)
			angle_vertical = clamp(angle_vertical, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
			var delta_angle_vertical = deg2rad(angle_vertical - current_angle_vertical)
			current_angle_vertical = angle_vertical
		
			rotator.rotate_object_local(Vector3(0, 1, 0), angle_horizontal)
			rotator.rotate_x(delta_angle_vertical)
	elif Input.is_action_just_released("goat_rotate_inventory"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	elif Input.is_action_just_pressed("goat_toggle_inventory"):
		goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
		get_tree().set_input_as_handled()


func game_mode_changed(new_game_mode):
	var inventory_mode = new_game_mode == goat.GAME_MODE_INVENTORY
	ray_cast.enabled = inventory_mode
	if inventory_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		hide()


func item_obtained(item_name, insert_after=null):
	var obtained_item = goat.inventory_items_models[item_name].instance()
	obtained_item.add_to_group("goat_inventory_item")
	obtained_item.add_to_group("goat_inventory_item_" + item_name)
	obtained_item.translation.z = 999
	obtained_item.hide()
	if insert_after:
		rotator.add_child_below_node(insert_after, obtained_item)
	else:
		rotator.add_child(obtained_item)


func item_selected(item_name):
	for item in get_tree().get_nodes_in_group("goat_inventory_item"):
		item.translation.z = 999
		item.hide()
	var selected_item = get_tree().get_nodes_in_group("goat_inventory_item_" + item_name).pop_front()
	selected_item.translation.z = 0
	selected_item.show()


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group("goat_inventory_item_" + item_name).pop_front()
	removed_item.queue_free()


func item_replaced(item_name_replaced, item_name_replacing):
	var replaced_item = get_tree().get_nodes_in_group("goat_inventory_item_" + item_name_replaced).pop_front()
	item_obtained(item_name_replacing, replaced_item)
	replaced_item.queue_free()


func _on_ViewportContainer_gui_input(event):
	if goat.game_mode != goat.GAME_MODE_INVENTORY:
		return
	# We are currently rotating the item
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var ray_vector = camera.project_ray_normal(event.position)
		ray_cast.cast_to = ray_vector * 4
