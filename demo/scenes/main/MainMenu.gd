extends Control


func _ready():
	# TODO: EXIT_SCENE should be defined outside of the game directory ("demo")
	goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
	goat.GRAVITY_ENABLED = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(load("res://demo/images/cursor.png"))
	
	goat.clear_game()


func _on_Exit_pressed():
	get_tree().quit()


func _on_Play_pressed():
	goat.load_game("res://demo")


func _on_Credits_pressed():
	get_tree().change_scene("res://demo/scenes/main/Credits.tscn")


func _on_Settings_pressed():
	$Settings.show()
