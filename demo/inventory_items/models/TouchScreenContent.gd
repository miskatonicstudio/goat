extends Control

onready var dot = $Dot


func _on_ButtonDown_pressed():
	dot.rect_position.y += 10


func _on_ButtonUp_pressed():
	dot.rect_position.y -= 10


func _on_ButtonRight_pressed():
	dot.rect_position.x += 10


func _on_ButtonLeft_pressed():
	dot.rect_position.x -= 10
