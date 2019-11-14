extends Control

# TODO: read this from settings
export var ROTATION_SENSITIVITY_X = 1.0
export var ROTATION_SENSITIVITY_Y = 1.0

const MAX_VERTICAL_ANGLE = 80
onready var viewport = $CenterContainer/ViewportContainer/Viewport
onready var ray = $CenterContainer/ViewportContainer/Viewport/Inventory3D/RayCast
onready var camera = $CenterContainer/ViewportContainer/Viewport/Inventory3D/Camera
onready var rotator = $CenterContainer/ViewportContainer/Viewport/Inventory3D/Rotator
# TODO: keep rotation value separately for each item?
var current_angle_vertical = 0
var selected_inventory_item = null
var collision_position = null


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Godot Editor
	viewport.own_world = true
	oat_interaction_signals.connect("oat_game_mode_changed", self, "game_mode_changed")
	oat_interaction_signals.connect("oat_environment_item_obtained", self, "item_obtained")
	oat_interaction_signals.connect("oat_inventory_item_selected", self, "item_selected")
	oat_interaction_signals.connect("oat_inventory_item_removed", self, "item_removed")
	oat_interaction_signals.connect("oat_inventory_item_replaced", self, "item_replaced")


func _input(event):
	if oat_interaction_signals.game_mode != oat_interaction_signals.GameMode.INVENTORY:
		return
	if Input.is_action_pressed("oat_inventory_item_rotation"):
		# TODO: turn this into another global mode?
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
	if Input.is_action_just_released("oat_inventory_item_rotation"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func game_mode_changed(new_game_mode):
	# TODO: move this logic to oat global?
	if new_game_mode == oat_interaction_signals.GameMode.INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		hide()


func item_obtained(item_name, insert_after=null):
	var obtained_item = oat_interaction_signals.inventory_items_models[item_name].instance()
	obtained_item.add_to_group("oat_inventory_item")
	obtained_item.add_to_group("oat_inventory_item_" + item_name)
	# TODO: find a better way to disable picking on non-selected items (hiding doesn't work)
	obtained_item.translation.z = 999
	obtained_item.hide()
	# TODO: is this necessary for 3D?
	if insert_after:
		rotator.add_child_below_node(insert_after, obtained_item)
	else:
		rotator.add_child(obtained_item)


func item_selected(item_name):
	for item in get_tree().get_nodes_in_group("oat_inventory_item"):
		item.translation.z = 999
		item.hide()
	var selected_item = get_tree().get_nodes_in_group("oat_inventory_item_" + item_name).pop_front()
	selected_item.translation.z = 0
	selected_item.show()


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group("oat_inventory_item_" + item_name).pop_front()
	removed_item.queue_free()


func item_replaced(item_name_replaced, item_name_replacing):
	var replaced_item = get_tree().get_nodes_in_group("oat_inventory_item_" + item_name_replaced).pop_front()
	item_obtained(item_name_replacing, replaced_item)
	replaced_item.queue_free()


func _on_ViewportContainer_gui_input(event):
	if oat_interaction_signals.game_mode != oat_interaction_signals.GameMode.INVENTORY:
		return
	# We are currently rotating the item
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var ray_vector = camera.project_ray_normal(event.position)
		ray.cast_to = ray_vector * 4
		select_inventory_item()
	# TODO: join this logic with item detection in Player?
	if Input.is_action_just_pressed("oat_environment_item_activation") and selected_inventory_item:
		oat_interaction_signals.emit_signal(
			"oat_environment_item_activated", selected_inventory_item.unique_name
		)
	if Input.is_action_just_pressed("oat_environment_item_activation") and collision_position:
		oat_interaction_signals.emit_signal(
			"oat_interactive_screen_activated", selected_inventory_item.unique_name, collision_position
		)


func select_inventory_item():
	# TODO: join this logic with item detection in Player?
	# TODO: consider replacing this logic with another signal
	collision_position = null
	# Clear single use collider
	if selected_inventory_item and not selected_inventory_item.is_in_group("oat_interactive_item"):
		selected_inventory_item = null
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider == selected_inventory_item:
			return
		if collider.is_in_group("oat_interactive_item"):
			if selected_inventory_item == null:
				oat_interaction_signals.emit_signal(
					"oat_environment_item_selected", collider.unique_name
				)
			selected_inventory_item = collider
		elif selected_inventory_item:
			oat_interaction_signals.emit_signal(
				"oat_environment_item_deselected", selected_inventory_item.unique_name
			)
			selected_inventory_item = null
		if collider.is_in_group("oat_interactive_screen"):
			collision_position = ray.get_collision_point()
			selected_inventory_item = collider
		elif selected_inventory_item:
			selected_inventory_item = null
	elif selected_inventory_item:
		oat_interaction_signals.emit_signal(
			"oat_environment_item_deselected", selected_inventory_item.unique_name
		)
		selected_inventory_item = null
