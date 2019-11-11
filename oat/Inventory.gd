extends Control

# TODO: read this from settings
export var ROTATION_SENSITIVITY_X = 1.0
export var ROTATION_SENSITIVITY_Y = 1.0

const MAX_VERTICAL_ANGLE = 80
onready var viewport = $CenterContainer/ViewportContainer/Viewport
onready var rotator = $CenterContainer/ViewportContainer/Viewport/Inventory3D/Rotator
# TODO: keep rotation value separately for each item?
var current_angle_vertical = 0


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Godot Editor
	viewport.own_world = true
	oat_interaction_signals.connect("oat_toggle_inventory", self, "toggle")
	oat_interaction_signals.connect("oat_environment_item_obtained", self, "item_obtained")
	oat_interaction_signals.connect("oat_inventory_item_selected", self, "item_selected")


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


func toggle(inventory_open):
	# TODO: move this logic to oat global?
	if inventory_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()


func item_obtained(item_name):
	var obtained_item = oat_interaction_signals.inventory_items_models[item_name].instance()
	obtained_item.add_to_group("oat_inventory_item")
	obtained_item.add_to_group("oat_inventory_item_" + item_name)
	obtained_item.hide()
	rotator.add_child(obtained_item)


func item_selected(item_name):
	for item in get_tree().get_nodes_in_group("oat_inventory_item"):
		item.hide()
	get_tree().get_nodes_in_group("oat_inventory_item_" + item_name).pop_front().show()
