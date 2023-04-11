extends Node


# TODO: remove input actions
func _enter_tree():
	var input_map_with_keys = [
		["goat_toggle_inventory", [KEY_TAB]],
		["goat_crouch", [KEY_CONTROL]],
		["goat_screenshot", [KEY_P]],
		["goat_dismiss", [KEY_ESCAPE]],
		["goat_move_player_forward", [KEY_W, KEY_UP, KEY_Z]],
		["goat_move_player_backward", [KEY_S, KEY_DOWN]],
		["goat_move_player_left", [KEY_A, KEY_LEFT, KEY_Q]],
		["goat_move_player_right", [KEY_D, KEY_RIGHT]],
	]
	
	for entry in input_map_with_keys:
		var action_name = entry[0]
		var scancodes = entry[1]
		InputMap.add_action(action_name)
		for scancode in scancodes:
			var event = InputEventKey.new()
			event.scancode = scancode
			InputMap.action_add_event(action_name, event)
	
	var input_map_with_mouse = [
		["goat_interact", [BUTTON_LEFT]],
		["goat_interact_alternatively", [BUTTON_RIGHT]],
		["goat_rotate_inventory", [BUTTON_RIGHT]],
	]
	
	for entry in input_map_with_mouse:
		var action_name = entry[0]
		var buttons = entry[1]
		InputMap.add_action(action_name)
		for button in buttons:
			var event = InputEventMouseButton.new()
			event.button_index = button
			InputMap.action_add_event(action_name, event)
