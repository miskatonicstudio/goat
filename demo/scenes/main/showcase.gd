extends Node3D


func _ready():
	goat_interaction.connect("object_activated", self._on_oa)


func _on_oa(object_name, _point):
	if object_name == "open_2_minute_adventure":
		goat_voice.prevent_default()
		get_tree().change_scene_to_file("res://demo/scenes/main/Gameplay.tscn")
