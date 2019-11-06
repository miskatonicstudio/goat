extends KinematicBody

# TODO: add settings and signals to change mouse sensitivity (but not speed)
export (float) var MOUSE_SENSITIVITY = 0.3
export (float) var SPEED = 3.0

onready var camera = $Camera
onready var camera_ray = $Camera/Ray

var movement_direction = Vector3()
var selected_environment_item = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if movement_direction:
		move_and_slide(movement_direction * SPEED, Vector3(0, 1, 0))
	# Make sure that collisions didn't accidentally move the Player up or down 
	translation.y = 0
	select_environment_item()


func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	update_movement_direction()
	activate_environment_item()


func rotate_camera(relative_movement):
	# Rotate horizontally
	camera.rotate_y(deg2rad(relative_movement.x * MOUSE_SENSITIVITY * -1))
	# Rotate vertically
	var angle = -relative_movement.y * MOUSE_SENSITIVITY
	var camera_rot = camera.rotation_degrees
	camera_rot.x += angle
	camera_rot.x = clamp(camera_rot.x, -80, 80)
	camera.rotation_degrees = camera_rot
	
	select_environment_item()


func update_movement_direction():
	# Reset movement direction
	movement_direction = Vector3()
	
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("oat_movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("oat_movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("oat_movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("oat_movement_right"):
		input_movement_vector.x = 1
	
	input_movement_vector = input_movement_vector.normalized()
	
	var camera_basis = camera.get_global_transform().basis
	movement_direction += -camera_basis.z.normalized() * input_movement_vector.y
	movement_direction += camera_basis.x.normalized() * input_movement_vector.x
	movement_direction.y = 0
	movement_direction = movement_direction.normalized()


func select_environment_item():
	# TODO: consider replacing this logic with another signal
	# Clear single use collider
	if selected_environment_item and not selected_environment_item.is_in_group("oat_environment_item"):
		selected_environment_item = null
	if camera_ray.is_colliding():
		var collider = camera_ray.get_collider()
		if collider == selected_environment_item:
			return
		if collider.is_in_group("oat_environment_item"):
			if selected_environment_item == null:
				oat_interaction_signals.emit_signal(
					"oat_environment_item_selected", collider.unique_name
				)
			selected_environment_item = collider
		elif selected_environment_item:
			oat_interaction_signals.emit_signal(
				"oat_environment_item_deselected", selected_environment_item.unique_name
			)
			selected_environment_item = null
	elif selected_environment_item:
		oat_interaction_signals.emit_signal(
			"oat_environment_item_deselected", selected_environment_item.unique_name
		)
		selected_environment_item = null


func activate_environment_item():
	if Input.is_action_just_pressed("oat_environment_item_activation") and selected_environment_item:
		oat_interaction_signals.emit_signal(
			"oat_environment_item_activated", selected_environment_item.unique_name
		)
