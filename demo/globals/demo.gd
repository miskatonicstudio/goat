extends Node


func _ready():
	goat.GAME_RESOURCES_DIRECTORY = "demo"
	goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
	goat.GRAVITY_ENABLED = false
	
	# Configure game state
	goat_state.register_variable("food_eaten", false)
	goat_state.register_variable("power_on", false)
	goat_state.register_variable("battery_inserted", false)
	goat_state.register_variable("red_button_pressed", false)
	goat_state.register_variable("floppy_inserted", false)
	goat_state.register_variable("coords_uploaded", false)
	goat_state.register_variable("portal_status", "not_ready")
	
	# Configure inventory items
	goat_inventory.register_item("floppy_disk")
	goat_inventory.register_item("battery")
	goat_inventory.register_item("remote")
	goat_inventory.register_item("pizza")
	
	# Configure voice recordings
	var audio_to_transcript := {
		"just_a_few_steps": "Just a few steps more and I will open the portal!",
		"power_it_up_first": "I should power it up first.",
		"pizza_eaten": "Mmmm, delicious!",
		"useless_without_battery": "It's useless without a battery.",
		"upload_coords_first": "I should upload the coordinates first.",
		"finally_active": "The portal is active! Almost there...",
		"coords_uploaded": "The coordinates are uploaded. Now, where is the remote...",
		"eat_something_first": "It's going to be a long journey, I should eat something first.",
		"another_world_awaits": "Finally! This is actually happening! Another world awaits!",
		# Defaults
		"but_why": "But why?",
		"what_for": "What for?",
		"this_doesnt_make_sense": "This doesn't make sense...",
	}
	
	for audio_name in audio_to_transcript:
		goat_voice.register(
			audio_name + ".ogg", audio_to_transcript[audio_name]
		)
	
	# Voice without audio, with forced duration for subtitles
	goat_voice.register(
		"better_way", "There should be a better way of using it...", 4
	)
	goat_voice.register(
		"look_around", "I have to look around.", 2
	)
	goat_voice.register(
		"find_something", "Maybe I'll find something.", 3
	)
	
	# Default voice recordings
	goat_voice.set_default_audio_names(
		["but_why", "what_for", "this_doesnt_make_sense"]
	)
	
	goat_voice.connect_default(goat_inventory, "item_used")
	goat_voice.connect_default(goat_interaction, "object_activated")
