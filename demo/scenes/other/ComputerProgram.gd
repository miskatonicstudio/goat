extends Control

onready var screen_blank = $BlankScreen
onready var screen_progress = $Background/ProgressBar
onready var screen_upload = $Background/Upload
onready var screen_why_not = $Background/WhyNot
onready var screen_done = $Background/Done
onready var timer = $Timer
onready var animation_player = $AnimationPlayer


func _ready():
	goat_state.connect("changed", self, "_on_game_state_changed")
	# For testing purpose
	if owner == null:
		animation_player.play("upload")


func _on_game_state_changed(variable_name, _from_value, to_value):
	if variable_name == "power_on" and to_value:
		screen_blank.color = Color("005eff")
	
	if variable_name == "floppy_inserted" and to_value:
		screen_blank.hide()
		animation_player.play("load_program")


func _on_AnimationPlayer_animation_finished(_anim_name):
	screen_progress.hide()
	screen_upload.show()


func _on_Yes_pressed():
	goat_state.set_value("coords_uploaded", true)
	goat_voice.play("coords_uploaded")
	screen_upload.hide()
	screen_done.show()


func _on_No_pressed():
	screen_upload.hide()
	screen_why_not.show()
	timer.start()


func _on_Timer_timeout():
	screen_why_not.hide()
	screen_upload.show()
