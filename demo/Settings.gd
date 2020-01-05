extends CenterContainer


func _input(_event):
	if not visible:
		return
	if Input.is_action_just_pressed("goat_dismiss"):
		hide()


func _on_Back_pressed():
	hide()
