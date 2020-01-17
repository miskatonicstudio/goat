extends KinematicBody

export (float) var SPEED = 3.0

onready var camera = $Camera
onready var ray_cast = $Camera/RayCast3D
onready var inventory = $Inventory
onready var context_inventory = $ContextInventory
onready var settings = $Settings

var movement_direction = Vector3()
var environment_item_name = null
var is_pickable_item = false


func _ready():
	inventory.hide()
	context_inventory.hide()
	settings.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat.connect("interactive_item_selected", self, "interactive_item_selected")
	goat.connect("interactive_item_deselected", self, "interactive_item_deselected")


func _physics_process(_delta):
	if goat.game_mode != goat.GameMode.EXPLORING:
		return
	if movement_direction:
		move_and_slide(movement_direction * SPEED, Vector3(0, 1, 0))
	# Make sure that collisions didn't accidentally move the Player up or down 
	translation.y = 0


func _input(event):
	if goat.game_mode != goat.GameMode.EXPLORING:
		return
	if Input.is_action_just_pressed("goat_toggle_inventory"):
		goat.game_mode = goat.GameMode.INVENTORY
		get_tree().set_input_as_handled()
	# Instead of opening a context inventory, pick up an inventory item
	if Input.is_action_just_pressed("goat_dismiss"):
		goat.game_mode = goat.GameMode.SETTINGS
		get_tree().set_input_as_handled()
	if Input.is_action_just_pressed("goat_toggle_context_inventory") and environment_item_name:
		if is_pickable_item:
			goat.emit_signal("interactive_item_activated", environment_item_name, null)
		else:
			goat.game_mode = goat.GameMode.CONTEXT_INVENTORY
			get_tree().set_input_as_handled()
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	update_movement_direction()


func _on_game_mode_changed(new_game_mode):
	var exploring_mode = new_game_mode == goat.GameMode.EXPLORING
	var inventory_mode = new_game_mode == goat.GameMode.INVENTORY
	$Scope.visible = exploring_mode
	ray_cast.enabled = exploring_mode
	if exploring_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.environment.dof_blur_far_enabled = inventory_mode


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


func interactive_item_selected(item_name, _position):
	if goat.game_mode == goat.GameMode.EXPLORING:
		environment_item_name = item_name
		var actual_item = get_tree().get_nodes_in_group(
			"goat_interactive_item_" + item_name
		).pop_back()
		is_pickable_item = actual_item.is_pickable_item()


func interactive_item_deselected(item_name):
	if goat.game_mode == goat.GameMode.EXPLORING:
		if item_name == environment_item_name:
			environment_item_name = null
			is_pickable_item = false
