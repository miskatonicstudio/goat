extends Spatial

onready var led_material = $Button/Model/LED.material
onready var animation_player = $AnimationPlayer
onready var battery_insert_sound = $BatterySound


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat_inventory.connect("item_used", self, "_on_item_used")


func _on_object_activated(object_name, _point):
	if object_name == "remote_button":
		animation_player.play("press_button")
		if demo.remote_has_battery:
			demo.emit_signal("remote_activated")
			if demo.portal_status == demo.PortalStatus.NOT_READY:
				goat_voice.play("upload_coords_first")
			else:
				goat_voice.prevent_default()
		else:
			goat_voice.play("useless_without_battery")


func _on_item_used(item_name, used_on_name):
	if item_name == "battery" and used_on_name == "remote":
		demo.remote_has_battery = true
		goat_inventory.remove_item("battery")
		led_material.emission_energy = 1
		goat_voice.prevent_default()
		battery_insert_sound.play()
