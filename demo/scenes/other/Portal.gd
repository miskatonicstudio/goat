extends Node3D

@onready var portal_light_material = $CSGTorus3D/LED.material
@onready var portal = $CSGTorus3D/Portal
@onready var the_other_side_sound = $CSGTorus3D/Portal/TheOtherSideSound
@onready var animation_player = $AnimationPlayer


func _ready():
	goat_interaction.connect("object_activated", self._on_object_activated)
	goat_state.connect("changed", self._on_game_state_changed)


func _on_object_activated(object_name, _point):
	# Portal is only available after coords are uploaded and remote is pressed
	if object_name == "portal":
		if goat_state.get_value("portal_status") != "open":
			goat_voice.prevent_default()
			return
		
		if goat_state.get_value("food_eaten"):
			goat_state.set_value("portal_status", "entered")
			goat_voice.start_dialogue("another_world_awaits")
		else:
			goat_voice.start_dialogue("eat_something_first")


func _on_game_state_changed(variable_name, _from_value, to_value):
	# Generator can be activated only once
	if variable_name == "power_on" and to_value:
		portal_light_material.emission = Color("c87808")
	
	# Coords can be uploaded only once, and after generator is activated
	if variable_name == "coords_uploaded" and to_value:
		portal_light_material.emission = Color("93f740")
		goat_state.set_value("portal_status", "ready")
	
	if variable_name == "red_button_pressed" and to_value:
		if goat_state.get_value("portal_status") == "ready":
			portal_light_material.emission = Color("21dada")
			goat_state.set_value("portal_status", "open")
			# Move the portal up, so it can be interacted with
			portal.position = Vector3(0, 0, 0)
			animation_player.play("portal_light")
			the_other_side_sound.play()
			# Exit inventory mode to show that the portal is active
			goat.game_mode = goat.GameMode.EXPLORING
			goat_voice.start_dialogue("finally_active")
