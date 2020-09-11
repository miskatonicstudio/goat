class_name RayCast3D
extends RayCast

"""
Handles selecting and activating interactive objects, which includes e.g. light
switches or touch screens. There are currently 2 categories in use:
	* environment (for objects in the 3D environment, e.g. a switch on a wall)
	* inventory (for objects in 3D inventory, e.g. a screen of a smartphone)
"""

# Category associated with the raycast
export (String) var category
# If false, alternative interaction will be ignored
export (bool) var supports_alternative_interaction = true


func _input(_event):
	if not _is_interaction_enabled():
		return
	
	# Force detecting items, in case some of them were deactivated
	_detect_interactive_objects()
	
	if Input.is_action_just_pressed("goat_interact"):
		goat_interaction.activate_object(category)
	
	if Input.is_action_just_pressed("goat_interact_alternatively"):
		if supports_alternative_interaction:
			goat_interaction.alternatively_activate_object(category)


func _process(_delta):
	if _is_interaction_enabled():
		_detect_interactive_objects()


func _detect_interactive_objects():
	var collided = false
	
	if is_colliding():
		var collider = get_collider()
		if collider and collider.is_in_group("goat_interactive_objects"):
			var object_name = collider.unique_name
			var point = get_collision_point()
			goat_interaction.select_object(object_name, point, category)
			collided = true
	
	if not collided:
		goat_interaction.deselect_object(category)


func _is_interaction_enabled():
	return enabled and not goat_voice.is_playing()
