extends Node3D

@onready var portal_light_material = $CSGTorus3D/LED.material
@onready var portal = $CSGTorus3D/Portal
@onready var the_other_side_sound = $CSGTorus3D/Portal/TheOtherSideSound
@onready var animation_player = $AnimationPlayer


func _ready():
	goat_interaction.connect("object_activated", self._on_object_activated)
	goat_state.connect("changed", self._on_game_state_changed)
	_check_state()


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


func _on_game_state_changed(_variable_name, _from_value, _to_value):
	_check_state()


func _check_state():
	if goat_state.get_value("portal_status") == "open":
			portal_light_material.emission = Color("21dada")
			# Move the portal up, so it can be interacted with
			portal.position = Vector3(0, 0, 0)
			if not animation_player.is_playing():
				animation_player.play("portal_light")
				the_other_side_sound.play()
	elif goat_state.get_value("portal_status") == "ready":
		portal_light_material.emission = Color("93f740")
	elif goat_state.get_value("power_on"):
		portal_light_material.emission = Color("c87808")
