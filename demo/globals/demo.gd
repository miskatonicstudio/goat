extends Node

# Demo game signals
signal generator_activated
signal program_activated
signal program_uploaded
signal remote_pressed
signal portal_entered


func _ready():
	goat.GAME_RESOURCES_DIRECTORY = "demo"
	goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
	
	goat_inventory.register_item("floppy_disk")
	goat_inventory.register_item("battery")
	goat_inventory.register_item("remote")
	goat_inventory.register_item("pizza")
	
	goat_voice.connect_default(goat_inventory, "item_used")
	goat_voice.connect_default(goat_interaction, "object_activated")
