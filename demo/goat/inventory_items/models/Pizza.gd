extends Node3D


func _ready():
	goat_inventory.connect("item_used", self._on_item_used)


func _on_item_used(item_name, used_on_name):
	if item_name == "pizza" and used_on_name == "pizza":
		goat_inventory.remove_item("pizza")
		goat_voice.start_dialogue("pizza_eaten")
		goat_state.set_value("food_eaten", true)
