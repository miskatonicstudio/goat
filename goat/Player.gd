extends KinematicBody

# TODO: add settings and signals to change mouse sensitivity (but not speed)
export (float) var MOUSE_SENSITIVITY = 0.3
export (float) var SPEED = 3.0

onready var camera = $Camera
onready var ray_cast = $Camera/RayCast3D
onready var inventory = $Inventory
onready var context_inventory = $ContextInventory

var movement_direction = Vector3()


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


func _input(event):
	if oat_interaction_signals.game_mode != oat_interaction_signals.GameMode.EXPLORING:
		return
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	update_movement_direction()


func game_mode_changed(new_game_mode):
	var exploring = new_game_mode == oat_interaction_signals.GameMode.EXPLORING
	$Scope.visible = exploring
	ray_cast.enabled = exploring
	if exploring:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.environment.dof_blur_far_enabled = new_game_mode == oat_interaction_signals.GameMode.INVENTORY


func rotate_camera(relative_movement):
	# Rotate horizontally
	camera.rotate_y(deg2rad(relative_movement.x * MOUSE_SENSITIVITY * -1))
	# Rotate vertically
	var angle = -relative_movement.y * MOUSE_SENSITIVITY
	var camera_rot = camera.rotation_degrees
	camera_rot.x += angle
	camera_rot.x = clamp(camera_rot.x, -80, 80)
	camera.rotation_degrees = camera_rot


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
