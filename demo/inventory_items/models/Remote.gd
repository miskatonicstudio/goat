extends Spatial

var powered_up = false

onready var animation_player = $AnimationPlayer
onready var led = $Button/Model/LED
onready var battery_insert_sound = $BatterySound


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat.connect("inventory_item_used_on_inventory", self, "item_used_on_item")


func _on_object_activated(object_name, _point):
	if object_name == "remote_button":
		animation_player.play("press_button")
		if powered_up:
			demo.emit_signal("remote_pressed")
		else:
			goat_voice.play("useless_without_battery")


func item_used_on_item(item_name_1, item_name_2):
	if item_name_1 == "battery" and item_name_2 == "remote":
		goat_inventory.remove_item("battery")
		powered_up = true
		led.material = load("res://demo/materials/remote_led_on.material")
		goat_voice.prevent_default()
		battery_insert_sound.play()
