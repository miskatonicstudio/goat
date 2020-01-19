extends Spatial

onready var generator_model = $InteractiveItem/Model
onready var working_sound = $WorkingSound


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")


func _on_object_activated(object_name, _point):
	if object_name == "generator":
		goat_voice.prevent_default()
		# Set generator screen's material (surface: 2)
		generator_model.set_surface_material(
			2, load("res://demo/materials/generator_screen_on.material")
		)
		working_sound.play()
		demo.emit_signal("generator_activated")
