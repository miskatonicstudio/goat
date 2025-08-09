extends Node3D

@onready var animation_player = $AnimationPlayer


func _ready():
	goat_interaction.connect("object_activated", self._on_object_activated)


func _on_object_activated(object_name, _point):
	if object_name == "floppy_shutter":
		goat_voice.prevent_default()
		if not animation_player.is_playing():
			animation_player.play("move_shutter")
