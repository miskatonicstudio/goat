extends KinematicBody

# TODO: add settings and signals to change mouse sensitivity (but not speed)
export (float) var MOUSE_SENSITIVITY = 0.3
export (float) var SPEED = 3.0

onready var camera = $Camera
onready var camera_ray = $Camera/Ray
onready var inventory = $Inventory
onready var context_inventory = $ContextInventory

var movement_direction = Vector3()
# TODO: extract selecting items (raycast)
# TODO: for 3D items with a touch screen, keep also the point of collision
var previous_collider = null


func _ready():
	inventory.hide()
	context_inventory.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	oat_interaction_signals.connect("oat_game_mode_changed", self, "game_mode_changed")


func _physics_process(delta):
	if oat_interaction_signals.game_mode != oat_interaction_signals.GameMode.EXPLORING:
		return
	if movement_direction:
		move_and_slide(movement_direction * SPEED, Vector3(0, 1, 0))
	# Make sure that collisions didn't accidentally move the Player up or down 
	translation.y = 0
	select_environment_item()


func _input(event):
	if oat_interaction_signals.game_mode != oat_interaction_signals.GameMode.EXPLORING:
		return
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	update_movement_direction()
	interact_with_environment()


func game_mode_changed(new_game_mode):
	if new_game_mode == oat_interaction_signals.GameMode.EXPLORING:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Scope.visible = new_game_mode == oat_interaction_signals.GameMode.EXPLORING
	$Camera.environment.dof_blur_far_enabled = new_game_mode == oat_interaction_signals.GameMode.INVENTORY


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
	# TODO: consider moving this logic to globals, maybe using methods
	if camera_ray.is_colliding():
		var collider = camera_ray.get_collider()
		if collider == previous_collider:
			return
		previous_collider = collider
		
		if collider.is_in_group("oat_interactive_item"):
			# Collision with a new item
			if oat_interaction_signals.selected_environment_item_name != null:
				oat_interaction_signals.emit_signal(
					"oat_environment_item_deselected", oat_interaction_signals.selected_environment_item_name
				)
			oat_interaction_signals.emit_signal(
				"oat_environment_item_selected", collider.unique_name
			)
		elif oat_interaction_signals.selected_environment_item_name:
			if oat_interaction_signals.selected_environment_item_name != null:
				oat_interaction_signals.emit_signal(
					"oat_environment_item_deselected", oat_interaction_signals.selected_environment_item_name
				)
	else:
		if oat_interaction_signals.selected_environment_item_name:
			oat_interaction_signals.emit_signal(
				"oat_environment_item_deselected", oat_interaction_signals.selected_environment_item_name
			)
		previous_collider = null


func interact_with_environment():
	# TODO: consider moving this to global
	if oat_interaction_signals.selected_environment_item_name:
		if Input.is_action_just_pressed("oat_environment_item_activation"):
			oat_interaction_signals.emit_signal(
				"oat_environment_item_activated", oat_interaction_signals.selected_environment_item_name
			)
