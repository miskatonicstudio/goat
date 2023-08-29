extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(_event):
	if Input.is_action_just_pressed("goat_dismiss"):
		$AnimationPlayer.advance(12)


func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().change_scene_to_file("res://demo/scenes/main/MainMenu.tscn")
