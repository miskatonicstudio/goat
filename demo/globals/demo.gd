extends Node

# Demo game signals
signal generator_activated
signal floppy_inserted
signal coords_uploaded
signal remote_activated
signal portal_entered
# Demo game variables (state)
enum PortalStatus {
	NOT_READY,
	READY,
	OPEN,
	ENTERED
}
var food_eaten = false
var power_on = false
var remote_has_battery = false
var portal_status = PortalStatus.NOT_READY


func _ready():
	goat.GAME_RESOURCES_DIRECTORY = "demo"
	goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
	
	goat_inventory.register_item("floppy_disk")
	goat_inventory.register_item("battery")
	goat_inventory.register_item("remote")
	goat_inventory.register_item("pizza")
	
	goat_voice.connect_default(goat_inventory, "item_used")
	goat_voice.connect_default(goat_interaction, "object_activated")


func reset():
	food_eaten = false
	power_on = false
	remote_has_battery = false
	portal_status = PortalStatus.NOT_READY
