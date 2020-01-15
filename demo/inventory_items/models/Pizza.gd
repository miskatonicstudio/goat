extends Spatial


func _ready():
	goat.connect("inventory_item_used", self, "item_used")


func item_used(item_name):
	if item_name == "pizza":
		goat_inventory.remove_item("pizza")
		goat_voice.play("pizza_eaten")
