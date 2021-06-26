extends Spatial

onready var interactive_item = $InteractiveItem
onready var camera = $Camera
onready var ray_cast = $Camera/RayCast3D
onready var tween = $Tween
# Backplate is used to stop the ray_cast from reaching environment items
onready var backplate = $Backplate
onready var original_camera_transform = camera.global_transform

var player_camera = null


func _ready():
	var unique_name = "detailed_interaction_" + str(get_instance_id())
	interactive_item.unique_name = unique_name
	goat_interaction.connect("object_activated", self, "_on_object_activated")


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
	
	player_camera = get_viewport().get_camera()
	var transform_from = player_camera.global_transform
	var transform_to = camera.global_transform
	tween.interpolate_property(
		camera, "global_transform",
		transform_from, transform_to,
		0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.start()
	camera.current = true


func _input(event):
	if goat.game_mode != goat.GameMode.DETAILED_INTERACTION:
		return
	
	if event is InputEventMouseMotion:
		var ray_vector = camera.project_local_ray_normal(
			event.position
		)
		ray_cast.cast_to = ray_vector * 10
	
	if Input.is_action_just_pressed("goat_dismiss"):
		goat.game_mode = goat.GameMode.EXPLORING
		goat_interaction.enable_object(interactive_item.unique_name)
		backplate.collision_layer = 0
		backplate.collision_mask = 0
		ray_cast.enabled = false
		ray_cast._detect_interactive_objects()
		
		var transform_from = camera.global_transform
		var transform_to = player_camera.global_transform
		tween.interpolate_property(
			camera, "global_transform",
			transform_from, transform_to,
			0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
		tween.start()
		player_camera = null


func _on_Tween_tween_all_completed():
	if player_camera == null:
		camera.current = false
		camera.global_transform = original_camera_transform
