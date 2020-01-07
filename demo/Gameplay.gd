extends Spatial

onready var animation_player = $AnimationPlayer


func _ready():
	goat.monologue.play("just_a_few_steps")
	
	animation_player.play("start_game")
	# warning-ignore:return_value_discarded
	demo.connect("portal_entered", animation_player, "play", ["end_game"])
	# warning-ignore:return_value_discarded
	animation_player.connect("animation_finished", self, "animation_finished")


func animation_finished(animation_name):
	if animation_name == "end_game":
		get_tree().change_scene("res://demo/Credits.tscn")
