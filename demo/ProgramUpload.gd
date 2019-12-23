extends Control


func _ready():
	demo.connect("program_activated", $AnimationPlayer, "play", ["upload"])


func _on_Upload_pressed():
	demo.emit_signal("program_uploaded")
	$ColorRect/Upload.hide()
	$ColorRect/Done.show()


func _on_AnimationPlayer_animation_finished(_anim_name):
	$ColorRect/ProgressBar.hide()
	$ColorRect/Upload.show()
