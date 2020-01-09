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
		else:
			goat.monologue.play("useless_without_battery")


func item_used_on_item(item_name_1, item_name_2):
	if item_name_1 == "battery" and item_name_2 == "remote":
		goat.emit_signal("inventory_item_removed", "battery")
		powered_up = true
		$Button/Model/LED.material = load(
			"res://demo/materials/remote_led_on.material"
		)
		# Prevent playing the default monologue
		goat.monologue.play()
		$BatterySound.play()
