extends Node3D

"""
Used to 'zoom in' to a part of the environment, possibly containing a puzzle.
It should not be used with inventory items.

NOTE: Currently there can only be one DetailedInteraction per scene.
"""

@onready var interactive_item = $InteractiveItem
@onready var camera = $Camera3D
@onready var ray_cast = $Camera3D/RayCast3D
# Backplate is used to stop the ray_cast from reaching environment items
@onready var backplate = $Backplate
@onready var original_camera_transform = camera.global_transform
# This is the camera that is active when the detailed interaction starts
var player_camera = null


func _ready():
	if interactive_item.unique_name.is_empty():
		var unique_name = "detailed_interaction_" + str(get_instance_id())
		interactive_item.unique_name = unique_name
	goat_interaction.connect("object_activated", self._on_object_activated)


func _on_object_activated(object_name, _point):
	if object_name != interactive_item.unique_name:
		return
	
	goat_voice.prevent_default()
	goat.game_mode = goat.GameMode.DETAILED_INTERACTION
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	goat_interaction.disable_object(object_name)
	backplate.collision_layer = interactive_item.COLLISION_MASK_LAYER
	backplate.collision_mask = interactive_item.COLLISION_MASK_LAYER
	ray_cast.enabled = true
	
	player_camera = get_viewport().get_camera_3d()
	var transform_from = player_camera.global_transform
	var transform_to = camera.global_transform
	var tween = _create_tween()
	tween.tween_property(camera, "global_transform", transform_from, 0)
	tween.tween_property(camera, "global_transform", transform_to, 0.5)
	tween.tween_callback(self._on_Tween_tween_all_completed)
	camera.current = true


func _input(event):
	if goat.game_mode != goat.GameMode.DETAILED_INTERACTION:
		return
	
	if not camera.current:
		return
	
	if event is InputEventMouseMotion:
		var ray_vector = camera.project_local_ray_normal(
			event.position
		)
		ray_cast.target_position = ray_vector * 10
	
	if (
		Input.is_action_just_pressed("goat_dismiss") or
		Input.is_action_just_pressed("goat_toggle_inventory") or
		Input.is_action_just_pressed("goat_interact_alternatively")
	):
		goat.game_mode = goat.GameMode.EXPLORING
		goat_interaction.enable_object(interactive_item.unique_name)
		backplate.collision_layer = 0
		backplate.collision_mask = 0
		ray_cast.enabled = false
		ray_cast._detect_interactive_objects()
		
		var transform_from = camera.global_transform
		var transform_to = player_camera.global_transform
		var tween = _create_tween()
		tween.tween_property(camera, "global_transform", transform_from, 0)
		tween.tween_property(camera, "global_transform", transform_to, 0.5)
		tween.tween_callback(self._on_Tween_tween_all_completed)
		player_camera = null


# TODO: rename this
func _on_Tween_tween_all_completed():
	if player_camera == null:
		for c in get_tree().get_nodes_in_group("goat_cameras_player"):
			c.current = true
		camera.global_transform = original_camera_transform


func _create_tween():
	return create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
