extends RayCast3D

"""
Handles selecting and activating interactive objects, which includes e.g. light
switches or touch screens. There are currently 2 categories in use:
	* environment (for objects in the 3D environment, e.g. a switch on a wall)
	* inventory (for objects in 3D inventory, e.g. a screen of a smartphone)
"""

const COLLISION_MASK_NORMAL = 2
const COLLISION_MASK_HOLDING = 4

# Category associated with the raycast
@export var category = ""
# If false, alternative interaction will be ignored
@export var supports_alternative_interaction = true
@export var is_holding = false : set = _set_is_holding


func _set_is_holding(value):
	is_holding = value
	collision_mask = COLLISION_MASK_HOLDING if is_holding else COLLISION_MASK_NORMAL


func _input(_event):
	if not _is_interaction_enabled():
		return
	
	# Force detecting items, in case some of them were deactivated
	_detect_interactive_objects()
	
	if Input.is_action_just_pressed("goat_interact"):
		if is_holding:
			_put_down_hand_item()
		else:
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


func _put_down_hand_item():
	var collider = get_collider()
	if collider:
		var point = get_collision_point()
		var hand = get_tree().get_nodes_in_group("goat_player_hand")[0]
		hand.get_child(0)._put_down(collider, point)
