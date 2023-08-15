extends Node

const GOAT_ACTIONS = [
	["goat_toggle_inventory", {"keys": [KEY_TAB]}],
	["goat_crouch", {"keys": [KEY_CTRL]}],
	["goat_screenshot", {"keys": [KEY_P]}],
	["goat_dismiss", {"keys": [KEY_ESCAPE]}],
	["goat_move_player_forward", {"keys": [KEY_W, KEY_UP, KEY_Z]}],
	["goat_move_player_backward", {"keys": [KEY_S, KEY_DOWN]}],
	["goat_move_player_left", {"keys": [KEY_A, KEY_LEFT, KEY_Q]}],
	["goat_move_player_right", {"keys": [KEY_D, KEY_RIGHT]}],
	
	["goat_interact", {"mouse_buttons": [MOUSE_BUTTON_LEFT]}],
	["goat_interact_alternatively", {"mouse_buttons": [MOUSE_BUTTON_RIGHT]}],
	["goat_rotate_inventory", {"mouse_buttons": [MOUSE_BUTTON_RIGHT]}],
]

func add_goat_actions():
	for action in GOAT_ACTIONS:
		var action_name = action[0]
		var action_events = action[1]
		var events = []
		for keycode in action_events.get("keys", []):
			var event = InputEventKey.new()
			event.keycode = keycode
			events.append(event)
		for button_index in action_events.get("mouse_buttons", []):
			var event = InputEventMouseButton.new()
			event.button_index = button_index
			events.append(event)
		ProjectSettings.set_setting("input/" + action_name, {
			"deadzone": 0.5,
			"events": events
		})
		print("Added GOAT action: ", action_name)


func remove_goat_actions():
	for action in GOAT_ACTIONS:
		var action_name = action[0]
		if ProjectSettings.has_setting("input/" + action_name):
			ProjectSettings.set_setting("input/" + action_name, null)
			print("Removed GOAT action: ", action_name)
