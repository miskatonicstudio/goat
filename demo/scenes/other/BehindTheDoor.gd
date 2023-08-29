extends Node3D


func _process(delta):
	$Text.rotation_degrees.y += delta * 20
