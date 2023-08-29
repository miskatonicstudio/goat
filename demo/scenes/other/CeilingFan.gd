extends Node3D


func _physics_process(delta):
	$Blades.rotate_y(2.4 * delta)
