extends Spatial

onready var animation_player = $AnimationPlayer


func _ready():
	# Configure Gameplay
	goat_state.connect("changed", self, "_on_game_state_changed")
	animation_player.connect("animation_finished", self, "animation_finished")
	
	animation_player.play("start_game")
	goat_voice.play("just_a_few_steps")
	goat.game_mode = goat.GameMode.EXPLORING


func _on_game_state_changed(variable_name, _from_value, to_value):
	if variable_name == "portal_status" and to_value == "entered":
		animation_player.play("end_game")


func animation_finished(animation_name):
	if animation_name == "end_game":
		goat.game_mode = goat.GameMode.NONE
		get_tree().change_scene("res://demo/scenes/main/Credits.tscn")
