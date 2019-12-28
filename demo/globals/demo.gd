extends Node


# warning-ignore:unused_signal
signal program_activated
# warning-ignore:unused_signal
signal program_uploaded
# warning-ignore:unused_signal
signal remote_pressed


func _ready():
	goat.set_game_resources_directory("demo")
	
	goat.register_inventory_item("floppy_disk")
	goat.register_inventory_item("battery")
	goat.register_inventory_item("remote")
	goat.register_inventory_item("pizza")