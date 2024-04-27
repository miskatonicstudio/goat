extends Node


# This scene is used only to provide a "Node" instance to Dialogue Manager
# All the logic is located in goat_voice singleton
func start(dialogue_resource, title, extra_game_states = []) -> void:
	# This scene is no longer necessary
	queue_free()
	# Forward the call to goat_voice
	goat_voice.start(dialogue_resource, title, extra_game_states)
