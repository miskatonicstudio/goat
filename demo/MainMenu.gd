extends Control


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(load("res://demo/images/cursor.png"))


func _on_Exit_pressed():
	get_tree().quit()


func _on_Play_pressed():
	get_tree().change_scene("res://demo/Gameplay.tscn")


func _on_Credits_pressed():
	get_tree().change_scene("res://demo/Credits.tscn")


func _on_Settings_pressed():
	$Settings.show()
