extends Node

# Demo game signals
# warning-ignore:unused_signal
signal program_activated
# warning-ignore:unused_signal
signal program_uploaded
# warning-ignore:unused_signal
signal remote_pressed
# warning-ignore:unused_signal
signal portal_entered


func _ready():
	goat.set_game_resources_directory("demo")
	goat.EXIT_SCENE = "res://demo/MainMenu.tscn"
	
	goat.register_inventory_item("floppy_disk")
	goat.register_inventory_item("battery")
	goat.register_inventory_item("remote")
	goat.register_inventory_item("pizza")
	
	# Voice
	goat.monologue.register(
		"just_a_few_steps", "Just a few steps more and I will open the portal!"
	)
	goat.monologue.register(
		"power_it_up_first", "I should power it up first."
	)
	goat.monologue.register(
		"long_journey",
		"It's going to be a long journey, I should eat something first."
	)
	goat.monologue.register(
		"another_world_awaits",
		"Finally! This is actually happening! Another world awaits!"
	)
	goat.monologue.register(
		"useless_without_battery", "It's useless without a battery."
	)
	goat.monologue.register(
		"pizza_eaten", "Mmmm, delicious!"
	)
	goat.monologue.register(
		"upload_coords_first", "I should upload the coordinates first."
	)
	goat.monologue.register(
		"finally_active", "The portal is active! Almost there..."
	)
	goat.monologue.register(
		"coords_uploaded",
		"The coordinates are uploaded. Now, where is the remote..."
	)
	# Defaults
	goat.monologue.register("but_why", "But why?")
	goat.monologue.register("what_for", "What for?")
	goat.monologue.register(
		"this_doesnt_make_sense", "This doesn't make sense..."
	)
	
	goat.monologue.set_defaults(
		["but_why", "what_for", "this_doesnt_make_sense"]
	)
	
	goat.monologue.connect_default(goat, "inventory_item_used")
	goat.monologue.connect_default(goat, "inventory_item_used_on_inventory")
	goat.monologue.connect_default(goat, "inventory_item_used_on_environment")
