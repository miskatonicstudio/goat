extends Node3D

@onready var animation_player = $AnimationPlayer


func _ready():
	goat_interaction.connect("object_enabled", self._on_oe)
	goat_interaction.connect("object_disabled", self._on_od)


func _on_oe(object_name):
	if object_name == "peek":
		animation_player.play_backwards("peek")


func _on_od(object_name):
	if object_name == "peek":
		animation_player.play("peek")
