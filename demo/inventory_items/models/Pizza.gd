extends Spatial


func _ready():
	goat.connect("inventory_item_used", self, "item_used")


func item_used(item_name):
	if item_name == "pizza":
		goat.emit_signal("inventory_item_removed", "pizza")
		goat_voice.play("pizza_eaten")
