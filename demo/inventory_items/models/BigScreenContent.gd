extends Control

var green = true


func _on_Button_pressed():
	green = not green
	$ColorRect.color = Color("8bff00") if green else Color("f700ff")
