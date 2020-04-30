extends Spatial

onready var animation_player = $AnimationPlayer


func _ready():
	goat_inventory.reset()
	demo.reset()
	
	# Configure Gameplay
	demo.connect("portal_entered", animation_player, "play", ["end_game"])
	animation_player.connect("animation_finished", self, "animation_finished")
	
	animation_player.play("start_game")
	goat_voice.play("just_a_few_steps")
	goat.game_mode = goat.GameMode.EXPLORING


func animation_finished(animation_name):
	if animation_name == "end_game":
		goat.game_mode = goat.GameMode.NONE
		get_tree().change_scene("res://demo/scenes/main/Credits.tscn")
