extends Node3D

@onready var led = $Button/Model/LED
@onready var animation_player = $AnimationPlayer
@onready var battery_insert_sound = $BatterySound


func _ready():
	goat_interaction.connect("object_activated", self._on_object_activated)
	goat_inventory.connect("item_used", self._on_item_used)
	led.material = led.material.duplicate()
	if goat_state.get_value("battery_inserted"):
		turn_on_led()


func _on_object_activated(object_name, _point):
	if object_name == "remote_button":
		animation_player.play("press_button")
		if goat_state.get_value("battery_inserted"):
			if goat_state.get_value("portal_status") == "ready":
				goat_state.set_value("portal_status", "open")
				# Exit inventory mode to show that the portal is active
				goat.game_mode = goat.GameMode.EXPLORING
				goat_voice.start_dialogue("finally_active")
			if goat_state.get_value("portal_status") == "not_ready":
				goat_voice.start_dialogue("upload_coords_first")
			else:
				goat_voice.prevent_default()
		else:
			goat_voice.start_dialogue("useless_without_battery")


func _on_item_used(item_name, used_on_name):
	if item_name == "battery" and used_on_name == "remote":
		goat_state.set_value("battery_inserted", true)
		goat_inventory.remove_item("battery")
		goat_voice.prevent_default()
		battery_insert_sound.play()
		turn_on_led()


func turn_on_led():
		led.material.emission_energy = 1
