extends CenterContainer

# TODO: read this from settings
export var ROTATION_SENSITIVITY_X = 1.0
export var ROTATION_SENSITIVITY_Y = 1.0

const MAX_VERTICAL_ANGLE = 80
onready var rotator = $ViewportContainer/Viewport/Inventory3D/Rotator
var current_angle_vertical = 0


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Godot Editor
	$ViewportContainer/Viewport.own_world = true
	oat_interaction_signals.connect("oat_toggle_inventory", self, "toggle")


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
