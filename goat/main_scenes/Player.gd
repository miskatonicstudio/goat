class_name Player
extends KinematicBody

export (float) var SPEED = 3.0

var movement_direction = Vector3()

onready var camera = $Camera
onready var ray_cast = $Camera/RayCast3D
onready var inventory = $Inventory
onready var context_inventory = $ContextInventory
onready var settings = $Settings
onready var scope = $Scope


func _ready():
	inventory.hide()
	context_inventory.hide()
	settings.hide()
	update_scope_visibility()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat_settings.connect(
		"value_changed_gui_scope", self, "_on_scope_settings_changed"
	)
	# Make sure that the Player is standing on the ground
	move_and_collide(Vector3(0, -100, 0))


func _input(event):
	if goat.game_mode != goat.GameMode.EXPLORING:
		return
	
	if Input.is_action_just_pressed("goat_toggle_inventory"):
		goat.game_mode = goat.GameMode.INVENTORY
	
	if Input.is_action_just_pressed("goat_dismiss"):
		goat.game_mode = goat.GameMode.SETTINGS
	
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	
	update_movement_direction()


func _physics_process(_delta):
	if goat.game_mode != goat.GameMode.EXPLORING:
		return
	
	if movement_direction:
		move_and_slide_with_snap(
			movement_direction * SPEED, Vector3(0, -100, 0), Vector3(0, 1, 0)
		)


func rotate_camera(relative_movement):
	var mouse_sensitivity = goat_settings.get_value(
		"controls", "mouse_sensitivity"
	)
	# Rotate horizontally
	camera.rotate_y(deg2rad(relative_movement.x * mouse_sensitivity * -1))
	# Rotate vertically
	var angle = -relative_movement.y * mouse_sensitivity
	var camera_rot = camera.rotation_degrees
	camera_rot.x += angle
	camera_rot.x = clamp(camera_rot.x, -80, 80)
	camera.rotation_degrees = camera_rot


func update_movement_direction():
	# Reset movement direction
	movement_direction = Vector3()
	
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("goat_move_player_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("goat_move_player_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("goat_move_player_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("goat_move_player_right"):
		input_movement_vector.x = 1
	
	input_movement_vector = input_movement_vector.normalized()
	
	var camera_basis = camera.get_global_transform().basis
	movement_direction += -camera_basis.z.normalized() * input_movement_vector.y
	movement_direction += camera_basis.x.normalized() * input_movement_vector.x
	movement_direction.y = 0
	movement_direction = movement_direction.normalized()


func update_scope_visibility():
	scope.visible = (
		goat.game_mode == goat.GameMode.EXPLORING and
		goat_settings.get_value("gui", "scope")
	)


func _on_game_mode_changed(new_game_mode):
	var exploring_mode = new_game_mode == goat.GameMode.EXPLORING
	var inventory_mode = new_game_mode == goat.GameMode.INVENTORY
	
	update_scope_visibility()
	ray_cast.enabled = exploring_mode
	camera.environment.dof_blur_far_enabled = inventory_mode
	
	if exploring_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_scope_settings_changed():
	update_scope_visibility()
