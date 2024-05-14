extends Control

@onready var screen_blank = $BlankScreen
@onready var screen_progress = $Background/ProgressBar
@onready var screen_upload = $Background/Upload
@onready var screen_why_not = $Background/WhyNot
@onready var screen_done = $Background/Done
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer


func _ready():
	goat_state.connect("changed", self._on_game_state_changed)
	_check_state()
	# For testing purpose
	if owner == null:
		animation_player.play("upload")


func _on_game_state_changed(variable_name, _from_value, to_value):
	_check_state()
	
	if variable_name == "floppy_inserted" and to_value:
		screen_progress.show()
		screen_upload.hide()
		animation_player.play("load_program")


func _on_AnimationPlayer_animation_finished(_anim_name):
	screen_progress.hide()
	screen_upload.show()


func _on_Yes_pressed():
	goat_state.set_value("portal_status", "ready")
	goat_voice.start_dialogue("coords_uploaded")
	screen_upload.hide()
	screen_done.show()


func _on_No_pressed():
	screen_upload.hide()
	screen_why_not.show()
	timer.start()


func _on_Timer_timeout():
	screen_why_not.hide()
	screen_upload.show()


func _check_state():
	if goat_state.get_value("portal_status") == "ready":
		screen_upload.hide()
		screen_done.show()
	if goat_state.get_value("floppy_inserted"):
		screen_blank.hide()
	elif goat_state.get_value("power_on"):
		screen_blank.color = Color("005eff")
