extends Node3D

@onready var screen_surface = $InteractiveItem/Model.get_surface_override_material(2)
@onready var working_sound = $WorkingSound


func _ready():
	goat_interaction.connect("object_activated", self._on_object_activated)
	goat_state.connect("changed", self._on_game_state_changed)
	if goat_state.get_value("power_on"):
		activate()


func _on_object_activated(object_name, _point):
	if object_name == "generator":
		goat_voice.prevent_default()
		goat_state.set_value("power_on", true)


func _on_game_state_changed(variable_name, _from_value, to_value):
	if variable_name == "power_on" and to_value:
		activate()


func activate():
	screen_surface.emission = Color("ff4848")
	working_sound.play()
	goat_interaction.disable_object("generator")
