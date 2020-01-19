extends Control

onready var screen_blank = $BlankScreen
onready var screen_progress = $Background/ProgressBar
onready var screen_upload = $Background/Upload
onready var screen_why_not = $Background/WhyNot
onready var screen_done = $Background/Done
onready var timer = $Timer
onready var animation_player = $AnimationPlayer


func _ready():
	demo.connect("generator_activated", self, "_on_generator_activated")
	demo.connect("program_activated", self, "_on_program_activated")
	# For testing purpose
	if owner == null:
		animation_player.play("upload")


func _on_generator_activated():
	screen_blank.color = Color("005eff")


func _on_program_activated():
	screen_blank.hide()
	animation_player.play("upload")


func _on_AnimationPlayer_animation_finished(_anim_name):
	screen_progress.hide()
	screen_upload.show()


func _on_Yes_pressed():
	demo.emit_signal("program_uploaded")
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
