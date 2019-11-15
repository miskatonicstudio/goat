extends RayCast

# TODO: handle deselecting item from another scene (setting it to null changes the value in emitted signal)
var currently_selected_item_name = null
var collision_point = null


func _input(event):
	if not enabled:
		return
	# TODO: rename to item activation
	# TODO: consider using multiple actions for different raycast types?
	if Input.is_action_just_pressed("oat_environment_item_activation") and currently_selected_item_name:
		if collision_point:
			# The item is a screen
			oat_interaction_signals.emit_signal(
				"oat_interactive_screen_activated", currently_selected_item_name, collision_point
			)
		else:
			oat_interaction_signals.emit_signal(
				"oat_environment_item_activated", currently_selected_item_name
			)


func _process(delta):
	if not enabled:
		return
	var new_item_name = null
	
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("goat_interactive_screen"):
			new_item_name = collider.unique_name
			collision_point = get_collision_point()
		elif collider.is_in_group("goat_interactive_item"):
			new_item_name = collider.unique_name
		
	if (new_item_name or currently_selected_item_name) and new_item_name != currently_selected_item_name:
		if currently_selected_item_name:
			oat_interaction_signals.emit_signal("oat_environment_item_deselected", currently_selected_item_name)
		currently_selected_item_name = new_item_name
		if currently_selected_item_name:
			oat_interaction_signals.emit_signal("oat_environment_item_selected", currently_selected_item_name)
