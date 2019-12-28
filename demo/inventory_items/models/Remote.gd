extends Spatial


var powered_up = false


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")
	goat.connect("inventory_item_used_on_inventory", self, "item_used_on_item")


func item_activated(item_name, _position):
	if item_name == "remote_button":
		$AnimationPlayer.play("press_button")
		if powered_up:
			demo.emit_signal("remote_pressed")


func item_used_on_item(item_name_1, item_name_2):
	if item_name_1 == "battery" and item_name_2 == "remote":
		goat.emit_signal("inventory_item_removed", "battery")
		powered_up = true
		$LED.set_surface_material(
			0, load("res://demo/workshop/materials/remote_led_on.material")
		)
