extends KinematicBody

export (float) var MOUSE_SENSITIVITY = 0.3
export (float) var SPEED = 3.0

onready var camera = $Camera
onready var ray_cast = $Camera/RayCast3D
onready var inventory = $Inventory
onready var context_inventory = $ContextInventory

var movement_direction = Vector3()
var environment_item_name = null
var is_inventory_item = false


func _ready():
	inventory.hide()
	context_inventory.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	goat.connect("game_mode_changed", self, "game_mode_changed")
	goat.connect("interactive_item_selected", self, "interactive_item_selected")
	goat.connect("interactive_item_deselected", self, "interactive_item_deselected")


func _physics_process(delta):
	if goat.game_mode != goat.GAME_MODE_EXPLORING:
		return
	if movement_direction:
		move_and_slide(movement_direction * SPEED, Vector3(0, 1, 0))
	# Make sure that collisions didn't accidentally move the Player up or down 
	translation.y = 0


func _input(event):
	if goat.game_mode != goat.GAME_MODE_EXPLORING:
		return
	if Input.is_action_just_pressed("goat_toggle_inventory"):
		goat.emit_signal("game_mode_changed", goat.GAME_MODE_INVENTORY)
		get_tree().set_input_as_handled()
	if Input.is_action_just_pressed("goat_toggle_context_inventory") and environment_item_name:
		if is_inventory_item:
			goat.emit_signal("interactive_item_activated", environment_item_name, null)
			goat.emit_signal("interactive_item_activated_" + environment_item_name)
		else:
			goat.emit_signal("game_mode_changed", goat.GAME_MODE_CONTEXT_INVENTORY)
			get_tree().set_input_as_handled()
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	update_movement_direction()


func game_mode_changed(new_game_mode):
	var exploring = new_game_mode == goat.GAME_MODE_EXPLORING
	$Scope.visible = exploring
	ray_cast.enabled = exploring
	if exploring:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.environment.dof_blur_far_enabled = new_game_mode == goat.GAME_MODE_INVENTORY


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


func interactive_item_selected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		environment_item_name = item_name
		var actual_item = get_tree().get_nodes_in_group("goat_interactive_item_" + item_name).pop_back()
		is_inventory_item = actual_item.is_inventory_item()


func interactive_item_deselected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		if item_name == environment_item_name:
			environment_item_name = null
			is_inventory_item = false
